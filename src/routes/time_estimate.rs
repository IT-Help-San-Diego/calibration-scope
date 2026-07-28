//! GET /api/models/{key}/time-estimate?tests=N — estimated wall-clock time for N tests on this model.
//! Derived from real historical trial latencies, not guesses.

use axum::{
    extract::{Path, Query, State},
    response::Json,
};
use serde::Deserialize;

#[derive(Deserialize)]
pub struct TimeEstimateParams {
    tests: Option<i64>,
}

pub async fn time_estimate(
    State(state): State<crate::state::AppState>,
    Path(model_key): Path<String>,
    Query(params): Query<TimeEstimateParams>,
) -> Json<serde_json::Value> {
    let n_tests = params.tests.unwrap_or(64);
    let trials_per_test: i64 = 3; // N=3 discipline
    let total_trials = n_tests * trials_per_test;

    let row: Option<(String, i64, f64, f64, f64, f64, f64)> = sqlx::query_as(
        r#"
        SELECT
            m.key,
            COUNT(*)::bigint as trials,
            AVG(tr.latency_ms)::float8 as avg_ms,
            PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY tr.latency_ms)::float8 as p50_ms,
            PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY tr.latency_ms)::float8 as p95_ms,
            MIN(tr.latency_ms)::float8 as min_ms,
            MAX(tr.latency_ms)::float8 as max_ms
        FROM trial_results tr
        JOIN test_runs r ON r.id = tr.run_id
        JOIN models m ON m.id = r.model_id
        WHERE m.key = $1
          AND tr.latency_ms IS NOT NULL
          AND tr.latency_ms > 0
          AND tr.is_infra_error = false
        GROUP BY m.key
        "#,
    )
    .bind(&model_key)
    .fetch_optional(&state.db)
    .await
    .unwrap_or(None);

    match row {
        Some((key, trials, avg_ms, p50_ms, p95_ms, _min_ms, _max_ms)) => {
            let avg_secs = avg_ms / 1000.0;
            let est_total_secs = total_trials as f64 * avg_secs;
            let est_total_mins = est_total_secs / 60.0;
            let p50_secs = p50_ms / 1000.0;
            let est_p50_mins = (total_trials as f64 * p50_secs) / 60.0;
            let p95_secs = p95_ms / 1000.0;
            let est_p95_mins = (total_trials as f64 * p95_secs) / 60.0;

            Json(serde_json::json!({
                "model_key": key,
                "tests_requested": n_tests,
                "trials_per_test": trials_per_test,
                "total_trials": total_trials,
                "historical_trials": trials,
                "avg_trial_ms": avg_ms.round() as i64,
                "avg_trial_secs": (avg_secs * 10.0).round() / 10.0,
                "p50_trial_secs": (p50_secs * 10.0).round() / 10.0,
                "p95_trial_secs": (p95_secs * 10.0).round() / 10.0,
                "est_total_mins": (est_total_mins * 10.0).round() / 10.0,
                "est_p50_mins": (est_p50_mins * 10.0).round() / 10.0,
                "est_p95_mins": (est_p95_mins * 10.0).round() / 10.0,
                "confidence": if trials >= 100 { "high" } else if trials >= 30 { "medium" } else { "low" },
                "basis": format!("{} historical trials", trials),
            }))
        }
        None => Json(serde_json::json!({
            "model_key": model_key,
            "error": "no historical trial data for this model",
            "tests_requested": n_tests,
            "confidence": "none",
        })),
    }
}
