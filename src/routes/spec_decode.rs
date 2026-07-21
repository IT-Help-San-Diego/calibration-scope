//! Speculative Decode panel — pair discovery + live timing test.
//!
//! Two endpoints:
//!   GET  /api/spec-decode/pairs   — configured pairs + live LM Studio state
//!   POST /api/spec-decode/test    — run a timing comparison for one pair
//!
//! Why this lives here instead of in the benchmark executor:
//! The executor enforces single-model isolation (memory guard, clean-room
//! semantics). Speculative decoding requires BOTH models resident. This
//! module bypasses the executor and talks directly to LM Studio's own
//! /v1/chat/completions endpoint, then restores config afterward.
use axum::{extract::State, response::Json};
use serde::{Deserialize, Serialize};
use std::path::PathBuf;
use std::time::Duration;

use walkdir::WalkDir;

use crate::error::{AppError, AppResult};
use crate::state::AppState;

// data shapes

#[derive(Debug, Serialize)]
pub struct SpecPair {
    pub main_model: String,
    pub draft_model: String,
    pub draft_source: DraftSource,
    pub main_loaded: bool,
    pub draft_loaded: bool,
    pub spec_active: bool,
    pub reason: Option<String>,
}

#[derive(Debug, Serialize, Clone, Copy)]
#[serde(rename_all = "lowercase")]
pub enum DraftSource {
    Simple,
    Mtp,
    Unknown,
}

#[derive(Debug, Serialize)]
pub struct PairsResponse {
    pub pairs: Vec<SpecPair>,
    pub lmstudio_connected: bool,
    pub lmstudio_base_url: String,
}

#[derive(Debug, Deserialize)]
pub struct TestRequest {
    pub main_model: String,
    pub prompt: Option<String>,
    pub max_tokens: Option<u32>,
}

/// Result of a real speculative-decode probe. The old implementation timed a
/// config against itself over `/v1/chat/completions` — blind to draft counters
/// and unable to toggle the draft. This instead reports the ground-truth
/// draft-token counters LM Studio returns from `/api/v0/chat/completions` — the
/// SAME signal `extract_speculative_stats` reads during real benchmark runs.
/// `acceptance_rate` = accepted / total draft tokens (None when no draft ran).
#[derive(Debug, Serialize)]
pub struct TestResult {
    pub main_model: String,
    pub draft_model: String,
    pub draft_active: bool,
    pub total_draft_tokens: Option<i64>,
    pub accepted_draft_tokens: Option<i64>,
    pub rejected_draft_tokens: Option<i64>,
    pub acceptance_rate: Option<f64>,
    pub completion_tokens: Option<i64>,
    pub elapsed_secs: f64,
    pub tokens_per_sec: f64,
    pub verdict: String,
}

// config scanning

const LMSTUDIO_CONFIG_DIR: &str = ".lmstudio/.internal/user-concrete-model-default-config";

fn scan_draft_pairs() -> Vec<SpecPair> {
    let home = PathBuf::from(std::env::var("HOME").unwrap_or_default());
    let config_root = home.join(LMSTUDIO_CONFIG_DIR);
    let mut pairs = Vec::new();

    for entry in WalkDir::new(&config_root)
        .follow_links(false)
        .into_iter()
        .filter_map(|e| e.ok())
    {
        let path = entry.path();
        if !path.is_file() {
            continue;
        }
        if path.extension().and_then(|s| s.to_str()) != Some("json") {
            continue;
        }
        if path
            .file_name()
            .and_then(|s| s.to_str())
            .map(|n| n.ends_with(".json.bak"))
            == Some(true)
        {
            continue;
        }

        if let Ok(raw) = std::fs::read_to_string(path) {
            if let Ok(cfg) = serde_json::from_str::<serde_json::Value>(&raw) {
                let fields = cfg
                    .get("load")
                    .and_then(|l| l.get("fields"))
                    .and_then(|f| f.as_array());

                let mut draft_model = None;
                let mut draft_source = DraftSource::Unknown;

                if let Some(fields) = fields {
                    for f in fields {
                        let key = f.get("key").and_then(|k| k.as_str()).unwrap_or("");
                        let value = f.get("value");
                        if key == "llm.load.llama.speculativeDecoding.draftModel" {
                            draft_model = value.and_then(|v| v.as_str()).map(|s| s.to_string());
                            let mtp = fields.iter().any(|f2| {
                                f2.get("key").and_then(|k| k.as_str())
                                    == Some("llm.load.llama.speculativeDecoding.draftMtp")
                                    && f2.get("value") == Some(&serde_json::json!(true))
                            });
                            draft_source = if mtp {
                                DraftSource::Mtp
                            } else {
                                DraftSource::Simple
                            };
                        }
                    }
                }

                if let Some(draft) = draft_model {
                    // Reconstruct the NAMESPACED key: configs live under a
                    // publisher dir (google/gemma-4-31b.json → key
                    // "google/gemma-4-31b"). Bare file_stem() dropped the
                    // publisher, putting main_model in a different identifier
                    // space than draft_model / the roster / LM Studio instance
                    // keys — the root of the bare-vs-namespaced mismatch class
                    // (and it defeated ensure_pair_loaded's exact residency
                    // check, risking duplicate loads from the pairs panel).
                    let stem = path.file_stem().and_then(|s| s.to_str()).unwrap_or("");
                    let main_model = match path
                        .parent()
                        .and_then(|p| p.strip_prefix(&config_root).ok())
                        .and_then(|rel| rel.to_str())
                        .filter(|rel| !rel.is_empty())
                    {
                        Some(publisher) => format!("{}/{}", publisher, stem),
                        None => stem.to_string(),
                    };
                    pairs.push(SpecPair {
                        main_model,
                        draft_model: draft,
                        draft_source,
                        main_loaded: false,
                        draft_loaded: false,
                        spec_active: false,
                        reason: None,
                    });
                }
            }
        }
    }

    pairs
}

// LM Studio API helpers

fn normalize_for_match(s: &str) -> String {
    let lower = s.to_lowercase();
    let no_pub = lower.split('/').next_back().unwrap_or(&lower);
    let no_ext = no_pub.strip_suffix(".gguf").unwrap_or(no_pub);
    let no_ext = no_ext.strip_suffix(".gguf.bak").unwrap_or(no_ext);
    no_ext.replace("@", "-").replace(".", "-")
}

async fn fetch_ls_models(base_url: &str) -> AppResult<Vec<serde_json::Value>> {
    let url = format!("{}/api/v0/models", base_url);
    let resp = reqwest::Client::new()
        .get(&url)
        .timeout(Duration::from_secs(10))
        .send()
        .await?;

    let status = resp.status();
    if !status.is_success() {
        let body = resp.text().await.unwrap_or_default();
        return Err(AppError::Executor(format!(
            "LM Studio HTTP {} from {} — {}",
            status, url, body
        )));
    }

    let json: serde_json::Value = resp.json().await?;
    Ok(json
        .get("data")
        .and_then(|d| d.as_array())
        .cloned()
        .unwrap_or_default())
}

// endpoints

pub async fn spec_decode_pairs(State(state): State<AppState>) -> AppResult<Json<PairsResponse>> {
    let base_url = state.config.lmstudio_base_url.clone();
    let mut pairs = scan_draft_pairs();

    // Reflects the fetch outcome below — previously hardcoded true, which made
    // the dashboard's "unreachable" branch dead and reported "LM Studio
    // connected" while every pair's reason said unreachable.
    let lmstudio_connected;

    match fetch_ls_models(&base_url).await {
        Ok(models) => {
            lmstudio_connected = true;
            let loaded_ids: Vec<String> = models
                .iter()
                .filter(|m| m.get("state").and_then(|s| s.as_str()) == Some("loaded"))
                .filter_map(|m| m.get("id").and_then(|s| s.as_str()))
                .map(|s| s.to_string())
                .collect();

            for pair in &mut pairs {
                let main_norm = normalize_for_match(&pair.main_model);
                let draft_norm = normalize_for_match(&pair.draft_model);
                let main_loaded = loaded_ids
                    .iter()
                    .any(|id| normalize_for_match(id) == main_norm);
                let draft_loaded = loaded_ids
                    .iter()
                    .any(|id| normalize_for_match(id) == draft_norm);

                pair.main_loaded = main_loaded;
                pair.draft_loaded = draft_loaded;
                pair.spec_active = main_loaded && draft_loaded;
                pair.reason = if main_loaded && draft_loaded {
                    None
                } else if !main_loaded {
                    Some(format!(
                        "Main model not loaded (LM Studio has: {})",
                        loaded_ids.join(", ")
                    ))
                } else {
                    Some("Draft model not loaded".to_string())
                };
            }
        }
        Err(_) => {
            lmstudio_connected = false;
            for pair in &mut pairs {
                pair.reason = Some(format!("LM Studio unreachable at {}", base_url));
            }
        }
    }

    Ok(Json(PairsResponse {
        lmstudio_connected,
        lmstudio_base_url: base_url,
        pairs,
    }))
}

pub async fn spec_decode_test(
    State(state): State<AppState>,
    Json(req): Json<TestRequest>,
) -> AppResult<Json<TestResult>> {
    let base_url = state.config.lmstudio_base_url.clone();

    let pairs = scan_draft_pairs();
    let pair = pairs
        .iter()
        .find(|p| {
            let exact = req.main_model == format!("{}-qat", p.main_model)
                || req.main_model == p.main_model
                || p.main_model.contains(&req.main_model)
                || req.main_model.contains(&p.main_model);
            exact
        })
        .ok_or_else(|| AppError::Executor(format!(
            "No speculative-decode pair configured for model '{}'. Check LM Studio persistent config (user-concrete-model-default-config/).",
            req.main_model
        )))?;

    // Drive the model by the caller's key (a full roster key like
    // "google/gemma-4-31b") so LM Studio resolves the exact instance; the draft
    // comes from the configured pair.
    let primary_key = req.main_model.clone();
    let draft_key = pair.draft_model.clone();
    let prompt = req.prompt.clone().unwrap_or_else(|| {
        "List the first 25 prime numbers, comma separated, then state in one sentence what makes a number prime.".to_string()
    });
    let max_tokens = req.max_tokens.unwrap_or(120);

    let client = reqwest::Client::new();

    // Bind the pair the SAME way real runs do — this is the executor's own
    // loader, not a reimplementation. No-op when the pair is already resident
    // with its draft; otherwise loads the primary with the speculative binding.
    crate::executor::lmstudio::ensure_pair_loaded(
        &client,
        &base_url,
        &primary_key,
        &draft_key,
        180,
    )
    .await?;

    // Probe via /api/v0/chat/completions — the endpoint that reports draft
    // counters — parsed with the executor's OWN helpers so there is no drift
    // from what real benchmark runs record. Unlike the trial loop we deliberately
    // tolerate empty content: a reasoning model can spend its whole token budget
    // in reasoning_content (finish_reason=length), and for a spec-decode probe
    // only the draft counters matter, not the answer text.
    let body = serde_json::json!({
        "model": primary_key,
        "messages": [{ "role": "user", "content": prompt }],
        "max_tokens": max_tokens,
        "temperature": 0.2,
    });
    let start = std::time::Instant::now();
    let resp = client
        .post(format!("{}/api/v0/chat/completions", base_url))
        .json(&body)
        .timeout(Duration::from_secs(120))
        .send()
        .await?;
    let elapsed_secs = start.elapsed().as_secs_f64();
    let status = resp.status();
    if !status.is_success() {
        let b = resp.text().await.unwrap_or_default();
        return Err(AppError::Executor(format!(
            "LM Studio spec-decode probe failed: HTTP {} — {}",
            status, b
        )));
    }
    let json: serde_json::Value = resp.json().await?;
    let (_prompt_tokens, completion_tokens) = crate::executor::usage_tokens(&json);
    let tokens_per_sec = match completion_tokens {
        Some(c) if elapsed_secs > 0.0 => c as f64 / elapsed_secs,
        _ => 0.0,
    };
    let sd = crate::executor::lmstudio::extract_speculative_stats(&json);
    let total_draft_tokens = sd.as_ref().and_then(|s| s.total_draft_tokens_count);
    let accepted_draft_tokens = sd.as_ref().and_then(|s| s.accepted_draft_tokens_count);
    let rejected_draft_tokens = sd.as_ref().and_then(|s| s.rejected_draft_tokens_count);
    let acceptance_rate = match (accepted_draft_tokens, total_draft_tokens) {
        (Some(a), Some(t)) if t > 0 => Some(a as f64 / t as f64),
        _ => None,
    };
    let draft_active = total_draft_tokens.map(|t| t > 0).unwrap_or(false);
    let draft_model = sd
        .as_ref()
        .and_then(|s| s.draft_model.clone())
        .unwrap_or_else(|| pair.draft_model.clone());

    let verdict = match (
        draft_active,
        acceptance_rate,
        accepted_draft_tokens,
        total_draft_tokens,
    ) {
        (true, Some(rate), Some(a), Some(t)) => format!(
            "[OK] Draft active — {}% acceptance ({}/{} draft tokens)",
            (rate * 100.0).round() as i32,
            a,
            t
        ),
        _ if sd.is_some() => {
            "[--] Draft bound but 0 draft tokens this run — spec-decode idle".to_string()
        }
        _ => "[X] No draft activity — spec-decode not active (draft not bound on this instance)"
            .to_string(),
    };

    Ok(Json(TestResult {
        main_model: pair.main_model.clone(),
        draft_model,
        draft_active,
        total_draft_tokens,
        accepted_draft_tokens,
        rejected_draft_tokens,
        acceptance_rate,
        completion_tokens,
        elapsed_secs,
        tokens_per_sec,
        verdict,
    }))
}
