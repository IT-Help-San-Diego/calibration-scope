//! GET /api/loot — the trophy case + squad-building leaderboard.
//!
//! Answers the two questions the demographic actually asks:
//!   1. "What's my best bot for X?" — per-axis champion: among models that
//!      ever fully PASSED/SAFE'd this axis, the fastest one, with the run
//!      that proves it (timestamp + SHA3 seal).
//!   2. "Which bots should I load into which slots?" — a recommended squad:
//!      one model per axis, chosen the same way, framed explicitly as a
//!      loadout (mirrors Hermes' main-model / auxiliary-task split).
//! Aggregates across ALL completed runs per (model, axis), not just the
//! latest — a model's loot is its best-ever proof, same as any leaderboard.
use axum::extract::State;
use axum::response::Json;
use serde::Serialize;
use std::collections::HashMap;

use crate::error::AppResult;
use crate::state::AppState;

#[derive(sqlx::FromRow)]
struct AxisAggRow {
    model_id: i32,
    model_key: String,
    display_name: String,
    location: String,
    axis: String,
    ever_fully_passed: bool,
    best_ms: Option<i64>,
    total_runs: i64,
    total_trials: i64,
    total_passed_trials: i64,
    best_run_id: Option<i32>,
    best_run_sha3: Option<String>,
    best_run_at: Option<chrono::NaiveDateTime>,
}

#[derive(Serialize)]
struct AxisStat {
    axis: String,
    verdict: String, // "PASS"/"SAFE" if ever_fully_passed, else "FAIL"/"UNSAFE"/"FLAKY"/"untested"
    best_ms: Option<i64>,
    total_runs: i64,
    pass_rate: f64, // 0.0-1.0 across all trials ever run on this axis
    evidence_run_id: Option<i32>,
    evidence_sha3: Option<String>,
    evidence_at: Option<String>,
}

#[derive(Serialize)]
struct ModelLoot {
    model_key: String,
    display_name: String,
    location: String,
    axes: HashMap<String, AxisStat>,
    total_wins: i64,   // count of axes ever fully passed
    overall_score: f64, // wins weighted by speed — see compute below
}

#[derive(Serialize)]
struct SquadPick {
    axis: String,
    model_key: String,
    display_name: String,
    best_ms: i64,
    evidence_run_id: i32,
    evidence_sha3: String,
    evidence_at: String,
}

pub async fn loot_handler(State(state): State<AppState>) -> AppResult<Json<serde_json::Value>> {
    let rows = sqlx::query_as::<_, AxisAggRow>(
        r#"
        SELECT
            m.id AS model_id,
            m.key AS model_key,
            m.display_name,
            m.location,
            r.axis,
            BOOL_OR(r.pass_count = r.total_count) AS ever_fully_passed,
            MIN(CASE WHEN r.pass_count = r.total_count THEN r.avg_ms END) AS best_ms,
            COUNT(*) AS total_runs,
            SUM(r.total_count) AS total_trials,
            SUM(r.pass_count) AS total_passed_trials,
            (ARRAY_AGG(r.id ORDER BY
                (r.pass_count = r.total_count) DESC,
                COALESCE(r.avg_ms, 999999999) ASC
            ))[1] AS best_run_id,
            (ARRAY_AGG(r.sha3_provenance ORDER BY
                (r.pass_count = r.total_count) DESC,
                COALESCE(r.avg_ms, 999999999) ASC
            ))[1] AS best_run_sha3,
            (ARRAY_AGG(r.created_at ORDER BY
                (r.pass_count = r.total_count) DESC,
                COALESCE(r.avg_ms, 999999999) ASC
            ))[1] AS best_run_at
        FROM (
            SELECT tr.*,
                   (SELECT ROUND(AVG(t.latency_ms))::bigint
                    FROM trial_results t
                    WHERE t.run_id = tr.id AND t.latency_ms >= 0) AS avg_ms
            FROM test_runs tr
            WHERE tr.status = 'done' AND tr.total_count > 0
        ) r
        JOIN models m ON m.id = r.model_id
        WHERE m.active = true
        GROUP BY m.id, m.key, m.display_name, m.location, r.axis
        "#,
    )
    .fetch_all(&state.db)
    .await?;

    // Assemble per-model loot.
    let mut by_model: HashMap<i32, ModelLoot> = HashMap::new();
    // Track the best (fastest, fully-passing) candidate per axis across ALL models for the squad.
    struct SquadCandidate {
        model_key: String,
        display_name: String,
        run_id: i32,
        sha3: String,
        at: String,
    }
    let mut squad_candidates: HashMap<String, (i64, SquadCandidate)> = HashMap::new();

    for row in rows {
        let axis_key = row.axis.clone();
        let is_security = axis_key == "security";
        let verdict = if row.ever_fully_passed {
            if is_security { "SAFE" } else { "PASS" }
        } else if row.total_passed_trials == 0 {
            if is_security { "UNSAFE" } else { "FAIL" }
        } else {
            "FLAKY"
        };
        let pass_rate = if row.total_trials > 0 {
            row.total_passed_trials as f64 / row.total_trials as f64
        } else {
            0.0
        };

        let stat = AxisStat {
            axis: axis_key.clone(),
            verdict: verdict.to_string(),
            best_ms: row.best_ms,
            total_runs: row.total_runs,
            pass_rate,
            evidence_run_id: row.best_run_id,
            evidence_sha3: row.best_run_sha3.clone(),
            evidence_at: row.best_run_at.map(|t| t.to_string()),
        };

        if row.ever_fully_passed {
            if let Some(ms) = row.best_ms {
                let candidate = SquadCandidate {
                    model_key: row.model_key.clone(),
                    display_name: row.display_name.clone(),
                    run_id: row.best_run_id.unwrap_or(0),
                    sha3: row.best_run_sha3.clone().unwrap_or_default(),
                    at: row.best_run_at.map(|t| t.to_string()).unwrap_or_default(),
                };
                let better = match squad_candidates.get(&axis_key) {
                    Some((existing_ms, _)) => ms < *existing_ms,
                    None => true,
                };
                if better {
                    squad_candidates.insert(axis_key.clone(), (ms, candidate));
                }
            }
        }

        let entry = by_model.entry(row.model_id).or_insert_with(|| ModelLoot {
            model_key: row.model_key.clone(),
            display_name: row.display_name.clone(),
            location: row.location.clone(),
            axes: HashMap::new(),
            total_wins: 0,
            overall_score: 0.0,
        });
        if row.ever_fully_passed {
            entry.total_wins += 1;
        }
        entry.axes.insert(axis_key, stat);
    }

    // Overall score: wins are primary, speed is the tiebreaker — sum of
    // (1 / avg_ms_in_seconds) across won axes, so faster wins score higher
    // without letting speed alone beat correctness.
    for m in by_model.values_mut() {
        let speed_bonus: f64 = m
            .axes
            .values()
            .filter_map(|a| if matches!(a.verdict.as_str(), "PASS" | "SAFE") { a.best_ms } else { None })
            .map(|ms| 1000.0 / (ms as f64).max(1.0))
            .sum();
        m.overall_score = (m.total_wins as f64) * 100.0 + speed_bonus;
    }

    let mut leaderboard: Vec<ModelLoot> = by_model.into_values().collect();
    leaderboard.sort_by(|a, b| b.overall_score.partial_cmp(&a.overall_score).unwrap());

    let axis_order = ["vision", "tools", "reasoning", "security"];
    let squad: Vec<SquadPick> = axis_order
        .iter()
        .filter_map(|axis| {
            squad_candidates.get(*axis).map(|(ms, c)| SquadPick {
                axis: axis.to_string(),
                model_key: c.model_key.clone(),
                display_name: c.display_name.clone(),
                best_ms: *ms,
                evidence_run_id: c.run_id,
                evidence_sha3: c.sha3.clone(),
                evidence_at: c.at.clone(),
            })
        })
        .collect();

    Ok(Json(serde_json::json!({
        "leaderboard": leaderboard,
        "recommended_squad": squad,
        "missing_axes": axis_order.iter().filter(|a| !squad_candidates.contains_key(**a)).collect::<Vec<_>>(),
    })))
}
