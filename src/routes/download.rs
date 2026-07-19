//! POST /api/lmstudio/download — start an LM Studio model download and track it.
//!
//! Foundation feature (endorsed 2026-07-19): let the dashboard pull known-good
//! demo bots from LM Studio's own download pipeline. We NEVER touch disk — LM
//! Studio writes the bytes into its content-addressed blob store; we only read
//! JSON progress over localhost:1234. See docs/lm-studio-api-notes.md for the
//! full verified contract.
//!
//! Lightweight guarantee: the poller loop sleeps 3s and, when the active-map is
//! EMPTY, does zero network work. It only polls `download/status/:job_id` for
//! jobs WE started (we hold the job_id). Idle dashboard = zero extra calls.

use axum::extract::State;
use axum::response::Json;
use reqwest::Client;
use serde::{Deserialize, Serialize};
use serde_json::json;
use std::collections::HashMap;
use std::sync::Arc;
use tokio::sync::Mutex;

use crate::error::AppResult;
use crate::state::AppState;

/// Live download we are tracking. Keyed by LM Studio `job_id` in `ActiveDownloads`.
#[derive(Clone)]
pub struct ActiveDownload {
    pub job_id: String,
    /// The model registry key we'll write size_gb against on completion.
    /// Derived from the LM Studio `model` identifier (publisher/name).
    pub model_key: String,
    pub model_identifier: String,
    pub total_size_bytes: Option<i64>,
    pub started_at: String,
}

/// Shared, mutable registry of in-flight downloads. Arc<Mutex<>> is sufficient:
/// the poller holds the lock only briefly per 3s tick; route handlers touch it
/// once per request. No contention concern at this scale.
pub type ActiveDownloads = Arc<Mutex<HashMap<String, ActiveDownload>>>;

#[derive(Debug, Deserialize)]
pub struct DownloadRequest {
    /// LM Studio model identifier: Hugging Face link or catalog id
    /// (e.g. "openai/gpt-oss-20b" or "https://huggingface.co/.../Q4_K_M").
    pub model: String,
    /// Optional explicit registry key (publisher/model) to record size_gb against.
    /// If omitted we derive it from `model` (last path segment after the org).
    pub key: Option<String>,
    /// Optional quantization (HF links only).
    pub quantization: Option<String>,
}

#[derive(Debug, Serialize)]
pub struct DownloadStarted {
    pub job_id: Option<String>,
    pub status: String,
    pub total_size_bytes: Option<i64>,
    pub already_downloaded: bool,
    pub model_key: String,
}

/// POST /api/lmstudio/download
/// Forwards to LM Studio's `/api/v1/models/download`. On `downloading`, records
/// the job and returns immediately. On `already_downloaded`, triggers a sync so
/// the model shows up in the roster.
pub async fn lmstudio_download(
    State(state): State<AppState>,
    Json(req): Json<DownloadRequest>,
) -> AppResult<Json<DownloadStarted>> {
    let client = Client::new();
    let base = &state.config.lmstudio_base_url;
    let model_key = req
        .key
        .clone()
        .unwrap_or_else(|| derive_key(&req.model));

    let mut body = json!({ "model": req.model });
    if let Some(q) = &req.quantization {
        body["quantization"] = json!(q);
    }

    let resp = client
        .post(format!("{}/api/v1/models/download", base))
        .json(&body)
        .send()
        .await
        .map_err(|e| crate::error::AppError::Executor(format!("LM Studio download forward failed: {}", e)))?;

    if !resp.status().is_success() {
        let code = resp.status().as_u16();
        let txt = resp.text().await.unwrap_or_default();
        return Err(crate::error::AppError::Executor(format!(
            "LM Studio rejected download (HTTP {}): {}",
            code, txt
        )));
    }

    let job: serde_json::Value = resp.json().await.map_err(|e| {
        crate::error::AppError::Executor(format!("Malformed LM Studio download response: {}", e))
    })?;

    let status = job.get("status").and_then(|s| s.as_str()).unwrap_or("unknown").to_string();
    let job_id = job.get("job_id").and_then(|j| j.as_str()).map(|s| s.to_string());
    let total_size_bytes = job.get("total_size_bytes").and_then(|t| t.as_i64());

    if status == "already_downloaded" {
        // Nothing to track — just sync so it appears in the roster.
        let _ = crate::routes::lmstudio::lmstudio_sync(State(state.clone())).await;
        return Ok(Json(DownloadStarted {
            job_id: None,
            status,
            total_size_bytes,
            already_downloaded: true,
            model_key,
        }));
    }

    if let Some(jid) = &job_id {
        let started = job
            .get("started_at")
            .and_then(|s| s.as_str())
            .unwrap_or("")
            .to_string();
        state
            .active_downloads
            .lock()
            .await
            .insert(jid.clone(), ActiveDownload {
                job_id: jid.clone(),
                model_key: model_key.clone(),
                model_identifier: req.model.clone(),
                total_size_bytes,
                started_at: started,
            });
        // Nudge the poller to pick this up immediately (best-effort; the 3s loop
        // would catch it regardless).
        state.events_tx.send(json!({
            "type": "model_download_started",
            "job_id": jid,
            "model_key": model_key,
            "total_size_bytes": total_size_bytes,
        }).to_string()).ok();
    }

    Ok(Json(DownloadStarted {
        job_id,
        status,
        total_size_bytes,
        already_downloaded: false,
        model_key,
    }))
}

/// GET /api/lmstudio/downloads — current in-flight downloads for the UI.
pub async fn list_downloads(State(state): State<AppState>) -> AppResult<Json<Vec<serde_json::Value>>> {
    let map = state.active_downloads.lock().await;
    let mut out = Vec::new();
    for d in map.values() {
        out.push(json!({
            "job_id": d.job_id,
            "model_key": d.model_key,
            "model_identifier": d.model_identifier,
            "total_size_bytes": d.total_size_bytes,
        }));
    }
    Ok(Json(out))
}

/// Derive a registry key (publisher/model) from an LM Studio model identifier.
/// Catalog id "openai/gpt-oss-20b" → "openai/gpt-oss-20b".
/// HF link "https://huggingface.co/lmstudio-community/gpt-oss-20b-GGUF" →
/// "lmstudio-community/gpt-oss-20b-GGUF".
fn derive_key(model: &str) -> String {
    if let Some(idx) = model.rfind("huggingface.co/") {
        return model[idx + "huggingface.co/".len()..].to_string();
    }
    model.to_string()
}

/// Normalize a model key for fuzzy matching across LM Studio's key format and
/// the HF identifier we send. LM Studio lowercases and strips the org prefix
/// and "-GGUF" suffix (e.g. "Qwen/Qwen2.5-0.5B-Instruct-GGUF" →
/// "qwen2.5-0.5b-instruct"). We normalize by: lowercase, drop the org prefix
/// (text before first '/'), strip a trailing "-gguf", and collapse internal
/// separators to a single canonical form so both sides compare equal.
fn normalize_key(key: &str) -> String {
    let k = key.to_lowercase();
    // Drop org prefix: "qwen/foo" → "foo".
    let k = k.split('/').last().unwrap_or(&k);
    // Strip "-gguf" suffix and any quantization token (Q4_K_M, q4_k_m, etc.).
    let k = k.trim_end_matches("-gguf");
    let k = regex_free_strip_quant(k);
    k.to_string()
}

/// Strip a trailing quantization token like "q4_k_m" or "Q8_0" so
/// "qwen2.5-0.5b-instruct-q4_k_m" → "qwen2.5-0.5b-instruct".
fn regex_free_strip_quant(k: &str) -> &str {
    // Quant tokens are alphanumeric + underscore, preceded by '-'.
    if let Some(pos) = k.rfind('-') {
        let suffix = &k[pos + 1..];
        if !suffix.is_empty() && suffix.chars().all(|c| c.is_ascii_alphanumeric() || c == '_') {
            // Heuristic: a quant suffix contains a digit (e.g. 4, 8, 0).
            if suffix.chars().any(|c| c.is_ascii_digit()) {
                return &k[..pos];
            }
        }
    }
    k
}

/// Single background poller. Spawned ONCE at startup. Every 3s: if the active
/// map is empty, do nothing (zero network cost). Otherwise poll each job's
/// `download/status`, update progress via SSE, and on terminal state write
/// `size_gb` + trigger a registry refresh.
pub fn spawn_download_poller(state: AppState) {
    tokio::spawn(async move {
        let client = Client::new();
        loop {
            tokio::time::sleep(std::time::Duration::from_secs(3)).await;

            // Snapshot current jobs (brief lock).
            let jobs: Vec<ActiveDownload> = {
                let map = state.active_downloads.lock().await;
                if map.is_empty() {
                    continue; // idle: zero cost, no network
                }
                map.values().cloned().collect()
            };

            let base = state.config.lmstudio_base_url.clone();

            for job in jobs {
                let url = format!(
                    "{}/api/v1/models/download/status/{}",
                    base, job.job_id
                );
                let status = client.get(&url).send().await;
                let parsed = match status {
                    Ok(r) if r.status().is_success() => r.json::<serde_json::Value>().await.ok(),
                    _ => None,
                };
                let parsed = match parsed {
                    Some(p) => p,
                    None => continue, // transient; retry next tick
                };

                let st = parsed.get("status").and_then(|s| s.as_str()).unwrap_or("unknown");
                let downloaded = parsed.get("downloaded_bytes").and_then(|d| d.as_i64());
                let total = parsed
                    .get("total_size_bytes")
                    .and_then(|t| t.as_i64())
                    .or(job.total_size_bytes);

                // Progress broadcast (drives the live "⏳ 73% · 4.2/5.7 GB" UI).
                let pct = match (downloaded, total) {
                    (Some(d), Some(t)) if t > 0 => (d as f64 / t as f64 * 100.0).round() as i64,
                    _ => 0,
                };
                state.events_tx.send(json!({
                    "type": "model_download_progress",
                    "job_id": job.job_id,
                    "model_key": job.model_key,
                    "downloaded_bytes": downloaded,
                    "total_size_bytes": total,
                    "pct": pct,
                    "status": st,
                }).to_string()).ok();

                if st == "completed" {
                    // The model only enters LM Studio's registry ON completion,
                    // so our `models` row does not exist yet. Sync first to create
                    // it (with the correct key LM Studio reports), THEN write the
                    // honest size_gb from total_size_bytes.
                    let _ = crate::routes::lmstudio::lmstudio_sync(State(state.clone())).await;
                    if let Some(t) = total {
                        let gb = (t as f64 / 1_073_741_824.0 * 10.0).round() / 10.0;
                        // LM Studio stores the model under its OWN key format
                        // (lowercased, no org prefix, no "-GGUF"), which differs
                        // from the HF identifier we sent. Normalize both sides
                        // in Rust and match the lmstudio row we just synced.
                        let want = normalize_key(&job.model_key);
                        let keys: Vec<(String,)> = sqlx::query_as(
                            "SELECT key FROM models WHERE provider = 'lmstudio'",
                        )
                        .fetch_all(&state.db)
                        .await
                        .unwrap_or_default();
                        let matched = keys
                            .into_iter()
                            .map(|(k,)| k)
                            .find(|k| normalize_key(k) == want);
                        if let Some(k) = matched {
                            let rows = sqlx::query(
                                "UPDATE models SET size_gb = $1 WHERE key = $2 AND provider = 'lmstudio'",
                            )
                            .bind(gb)
                            .bind(&k)
                            .execute(&state.db)
                            .await;
                            if let Err(e) = rows {
                                tracing::warn!("size_gb write failed for {}: {}", k, e);
                            } else {
                                tracing::info!("size_gb written: {} = {} GB", k, gb);
                            }
                        } else {
                            tracing::warn!(
                                "size_gb: no lmstudio row matched normalized key '{}' for {}",
                                want, job.model_key
                            );
                        }
                    }
                    state.active_downloads.lock().await.remove(&job.job_id);
                    // Registry changed — push fresh snapshot.
                    if let Some(env) =
                        crate::routes::events::registry_envelope(&state, "refresh").await
                    {
                        state.events_tx.send(env).ok();
                    }
                    state.events_tx.send(json!({
                        "type": "model_download_complete",
                        "job_id": job.job_id,
                        "model_key": job.model_key,
                    }).to_string()).ok();
                } else if st == "failed" {
                    state.active_downloads.lock().await.remove(&job.job_id);
                    state.events_tx.send(json!({
                        "type": "model_download_failed",
                        "job_id": job.job_id,
                        "model_key": job.model_key,
                    }).to_string()).ok();
                }
                // "downloading" | "paused" → keep tracking.
            }
        }
    });
}
