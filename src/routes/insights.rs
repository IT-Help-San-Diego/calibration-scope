//! GET /api/model-insights/{key} — the teaching layer.
//!
//! Returns the data that makes this a scientific instrument, not just a
//! leaderboard:
//!   1. LATENCY PROFILE — avg/min/max latency across all trials, per axis
//!   2. FALLACY MAP — which specific tests this model failed (the universal
//!      pattern: affirming the consequent, denying the antecedent, principle
//!      of explosion — visible as a named pattern, not just a score)
//!   3. REASONING TRACES — the model's actual reasoning_content for failed
//!      trials, so users can see HOW the model was wrong, not just that it
//!      was wrong
//!   4. HARDWARE FIT — model size + estimated RAM need (including spec-decode
//!      overhead) vs. common hardware tiers
//!
//! This endpoint is what the dossier is missing: the dossier shows WHAT
//! happened (runs, pass rates, seals). This shows WHY it happened and WHAT
//! IT MEANS for the user.
use axum::extract::{Path, State};
use axum::response::Json;
use serde::Serialize;

use crate::error::{AppError, AppResult};
use crate::state::AppState;

#[derive(sqlx::FromRow, Serialize)]
struct LatencyRow {
    axis: String,
    avg_ms: Option<i64>,
    min_ms: Option<i64>,
    max_ms: Option<i64>,
    trial_count: i64,
}

#[derive(sqlx::FromRow, Serialize)]
struct FallacyRow {
    test_id: Option<i32>,
    test_name: String,
    axis: String,
    trials: i64,
    passed: i64,
    avg_ms: Option<i64>,
}

#[derive(sqlx::FromRow, Serialize)]
struct ReasoningTraceRow {
    run_id: i32,
    test_id: Option<i32>,
    test_name: String,
    trial_num: i32,
    passed: bool,
    latency_ms: i64,
    raw_response: String,
    reasoning_content: Option<String>,
    detail: String,
}

#[derive(sqlx::FromRow)]
struct ModelRow {
    id: i32,
    key: String,
    display_name: String,
    location: String,
    provider: String,
    size_gb: f64,
    context_length: i32,
    supports_vision: bool,
}

// Known fallacy tests — the universal failure pattern we documented across
// 21 models. These are the tests that nearly every local LLM fails.
const FALLACY_TESTS: &[(&str, &str, &str)] = &[
    // (test_name_substring, formal_name, what_it_tests)
    ("Affirming the Consequent", "Affirming the Consequent", "Model says VALID for an INVALID argument (if P→Q and Q, therefore P)"),
    ("Denying the Antecedent", "Denying the Antecedent", "Model says VALID for an INVALID argument (if P→Q and ¬P, therefore ¬Q)"),
    ("Contradiction Detection", "Principle of Explosion", "Model says INVALID for a VALID argument (from contradiction, anything follows)"),
    ("Existential Fallacy", "Existential Import", "Model mishandles syllogism with existential assumptions"),
];

pub async fn model_insights(
    State(state): State<AppState>,
    Path(key): Path<String>,
) -> AppResult<Json<serde_json::Value>> {
    // Get model info
    let model: ModelRow = sqlx::query_as(
        r#"SELECT id, key, display_name, location, provider, size_gb,
                  context_length, supports_vision
           FROM models WHERE key = $1 AND active = true"#,
    )
    .bind(&key)
    .fetch_optional(&state.db)
    .await?
    .ok_or_else(|| AppError::Executor(format!("Unknown model: {key}")))?;

    // ── 1. LATENCY PROFILE ──────────────────────────────────────────────
    let latency: Vec<LatencyRow> = sqlx::query_as(
        r#"SELECT r.axis,
                  ROUND(AVG(tr.latency_ms))::bigint AS avg_ms,
                  MIN(tr.latency_ms) AS min_ms,
                  MAX(tr.latency_ms) AS max_ms,
                  COUNT(*) AS trial_count
           FROM trial_results tr
           JOIN test_runs r ON r.id = tr.run_id
           WHERE r.model_id = $1 AND r.status = 'done'
             AND tr.latency_ms >= 0
           GROUP BY r.axis ORDER BY r.axis"#,
    )
    .bind(model.id)
    .fetch_all(&state.db)
    .await?;

    // ── 2. FALLACY MAP ──────────────────────────────────────────────────
    // Per-test pass/fail across all completed runs
    let per_test: Vec<FallacyRow> = sqlx::query_as(
        r#"SELECT tr.test_id,
                  COALESCE(t.name, '(pre-linkage)') AS test_name,
                  r.axis,
                  COUNT(*) AS trials,
                  COUNT(*) FILTER (WHERE tr.passed) AS passed,
                  ROUND(AVG(tr.latency_ms) FILTER (WHERE tr.latency_ms >= 0))::bigint AS avg_ms
           FROM trial_results tr
           JOIN test_runs r ON r.id = tr.run_id
           LEFT JOIN tests t ON t.id = tr.test_id
           WHERE r.model_id = $1 AND r.status = 'done'
           GROUP BY tr.test_id, t.name, r.axis
           ORDER BY r.axis, t.name NULLS LAST"#,
    )
    .bind(model.id)
    .fetch_all(&state.db)
    .await?;

    // Identify which are known fallacy tests and whether this model failed them
    let fallacy_map: Vec<serde_json::Value> = FALLACY_TESTS
        .iter()
        .map(|(substr, formal, description)| {
            // Find matching test rows
            let matching: Vec<&FallacyRow> = per_test
                .iter()
                .filter(|t| t.test_name.contains(substr))
                .collect();
            let total_trials: i64 = matching.iter().map(|t| t.trials).sum();
            let total_passed: i64 = matching.iter().map(|t| t.passed).sum();
            let failed = total_trials > 0 && total_passed < total_trials;
            serde_json::json!({
                "test_name": substr,
                "formal_name": formal,
                "description": description,
                "is_known_fallacy": true,
                "trials": total_trials,
                "passed": total_passed,
                "failed": failed,
                "failure_pattern": if failed {
                    if total_passed == 0 { "deterministic_fail" } else { "intermittent_fail" }
                } else if total_trials > 0 {
                    "passed"
                } else {
                    "untested"
                },
            })
        })
        .collect();

    // All tests with pass/fail, not just fallacy ones
    let all_tests: Vec<serde_json::Value> = per_test
        .iter()
        .map(|t| {
            let is_fallacy = FALLACY_TESTS.iter().any(|(s, _, _)| t.test_name.contains(s));
            serde_json::json!({
                "test_id": t.test_id,
                "test_name": t.test_name,
                "axis": t.axis,
                "trials": t.trials,
                "passed": t.passed,
                "failed": t.passed < t.trials,
                "pass_rate": if t.trials > 0 { t.passed as f64 / t.trials as f64 } else { 0.0 },
                "avg_ms": t.avg_ms,
                "is_known_fallacy": is_fallacy,
            })
        })
        .collect();

    // ── 3. REASONING TRACES (failed trials only — the teaching gold) ────
    let traces: Vec<ReasoningTraceRow> = sqlx::query_as(
        r#"SELECT tr.run_id, tr.test_id,
                  COALESCE(t.name, '(pre-linkage)') AS test_name,
                  tr.trial_num, tr.passed, tr.latency_ms,
                  tr.raw_response, tr.reasoning_content, tr.detail
           FROM trial_results tr
           JOIN test_runs r ON r.id = tr.run_id
           LEFT JOIN tests t ON t.id = tr.test_id
           WHERE r.model_id = $1 AND r.status = 'done'
             AND tr.passed = false
             AND tr.is_infra_error = false
           ORDER BY r.created_at DESC, tr.id DESC
           LIMIT 20"#,
    )
    .bind(model.id)
    .fetch_all(&state.db)
    .await?;

    let traces_json: Vec<serde_json::Value> = traces
        .iter()
        .map(|t| {
            serde_json::json!({
                "run_id": t.run_id,
                "test_name": t.test_name,
                "trial_num": t.trial_num,
                "latency_ms": t.latency_ms,
                "raw_response": t.raw_response,
                "reasoning_content": t.reasoning_content,
                "detail": t.detail,
            })
        })
        .collect();

    // ── 4. HARDWARE FIT ─────────────────────────────────────────────────
    // Estimate RAM need including spec-decode overhead
    let base_gb = model.size_gb;
    let spec_decode_overhead = base_gb * 0.25; // conservative estimate
    let safety_margin = 8.0; // OS + apps + inference
    let estimated_ram_gb = base_gb + spec_decode_overhead + safety_margin;

    let hardware_tiers = serde_json::json!([
        { "label": "8 GB (e.g., M1 MacBook Air)", "fits": estimated_ram_gb <= 8.0 },
        { "label": "16 GB (e.g., M2 Pro)", "fits": estimated_ram_gb <= 16.0 },
        { "label": "32 GB (e.g., M3 Max)", "fits": estimated_ram_gb <= 32.0 },
        { "label": "64 GB (e.g., M4 Max)", "fits": estimated_ram_gb <= 64.0 },
        { "label": "128 GB (e.g., M4 Max unified)", "fits": estimated_ram_gb <= 128.0 },
    ]);

    // ── 5. TRADEOFF SUMMARY (plain-language assessment) ─────────────────
    // Compute a plain-language summary of this model's strengths/weaknesses
    let mut strengths: Vec<String> = Vec::new();
    let mut weaknesses: Vec<String> = Vec::new();
    let mut tradeoffs: Vec<String> = Vec::new();

    // Latency assessment
    let avg_latency: f64 = latency
        .iter()
        .filter_map(|l| l.avg_ms.map(|v| v as f64))
        .collect::<Vec<_>>()
        .iter()
        .sum::<f64>()
        / latency.iter().filter(|l| l.avg_ms.is_some()).count().max(1) as f64;

    if avg_latency < 2000.0 {
        strengths.push(format!("Fast: {:.1}s average response time", avg_latency / 1000.0));
    } else if avg_latency > 30000.0 {
        weaknesses.push(format!("Slow: {:.1}s average response time (may feel unresponsive)", avg_latency / 1000.0));
    } else {
        tradeoffs.push(format!("Moderate speed: {:.1}s average response time", avg_latency / 1000.0));
    }

    // Size assessment
    if base_gb > 0.0 && base_gb <= 5.0 {
        strengths.push(format!("Compact: {:.1} GB — fits on most hardware", base_gb));
    } else if base_gb > 25.0 {
        weaknesses.push(format!("Large: {:.1} GB — needs substantial RAM", base_gb));
    }

    // Fallacy assessment
    let fallacy_fails: Vec<_> = fallacy_map.iter().filter(|f| f["failed"].as_bool() == Some(true)).collect();
    if !fallacy_fails.is_empty() {
        let names: Vec<String> = fallacy_fails.iter()
            .filter_map(|f| f["formal_name"].as_str().map(String::from))
            .collect();
        weaknesses.push(format!("Fallacy-blind: fails {} known logical fallacy test(s): {}", names.len(), names.join(", ")));
    }

    // Vision assessment
    if model.supports_vision {
        if !fallacy_fails.is_empty() {
            tradeoffs.push("Has vision but fails logical reasoning — may confidently give wrong answers about images".into());
        } else {
            strengths.push("Has vision support".into());
        }
    }

    Ok(Json(serde_json::json!({
        "model": {
            "key": model.key,
            "display_name": model.display_name,
            "location": model.location,
            "provider": model.provider,
            "size_gb": model.size_gb,
            "context_length": model.context_length,
            "supports_vision": model.supports_vision,
        },
        "latency": latency,
        "fallacy_map": fallacy_map,
        "all_tests": all_tests,
        "reasoning_traces": traces_json,
        "hardware_fit": {
            "model_size_gb": base_gb,
            "estimated_ram_gb": estimated_ram_gb,
            "breakdown": {
                "model": base_gb,
                "spec_decode_overhead_25pct": spec_decode_overhead,
                "safety_margin": safety_margin,
            },
            "tiers": hardware_tiers,
        },
        "assessment": {
            "strengths": strengths,
            "weaknesses": weaknesses,
            "tradeoffs": tradeoffs,
        },
    })))
}
