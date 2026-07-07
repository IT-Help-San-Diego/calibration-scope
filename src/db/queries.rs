use sqlx::PgPool;

use crate::error::AppResult;
use crate::models::benchmark::BenchmarkRow;
use crate::models::model_entry::ModelEntry;

/// Legacy 61-row capability matrix (historical baseline, read-only).
pub async fn fetch_all_benchmarks(db: &PgPool) -> AppResult<Vec<BenchmarkRow>> {
    let rows = sqlx::query_as::<_, BenchmarkRow>(
        r#"SELECT model, provider, test, verdict, detail, date FROM legacy_matrix ORDER BY date DESC"#,
    )
    .fetch_all(db)
    .await?;
    Ok(rows)
}

/// Model registry with per-axis verdict roll-up.
///
/// Verdict semantics (computed from the LATEST completed run per (model, axis)):
///   SAFE  = all trials passed
///   UNSAFE = zero trials passed
///   FLAKY = partial pass
/// A model/axis with no completed runs is absent from the JSON object (= untested).
/// `verdicts` is serialized as a JSON object string, e.g. {"vision":"SAFE","tools":"FLAKY"},
/// matching the dashboard's JSON.parse(m.verdicts || '{}') contract.
pub async fn fetch_unique_models(db: &PgPool) -> AppResult<Vec<ModelEntry>> {
    let rows = sqlx::query_as::<_, ModelEntry>(
        r#"
        SELECT
            m.id, m.key, m.display_name, m.provider, m.location,
            m.context_length, m.size_gb, m.notes, m.tags, m.active,
            m.created_at, m.updated_at,
            COALESCE(v.verdicts::text, '{}') AS verdicts
        FROM models m
        LEFT JOIN (
            SELECT model_id, jsonb_object_agg(axis, verdict) AS verdicts
            FROM (
                SELECT DISTINCT ON (model_id, axis)
                    model_id,
                    axis,
                    CASE
                        WHEN pass_count = total_count THEN 'SAFE'
                        WHEN pass_count = 0 THEN 'UNSAFE'
                        ELSE 'FLAKY'
                    END AS verdict
                FROM test_runs
                WHERE status = 'done' AND total_count > 0
                ORDER BY model_id, axis, created_at DESC
            ) latest
            GROUP BY model_id
        ) v ON v.model_id = m.id
        WHERE m.active = true
        ORDER BY m.display_name
        "#,
    )
    .fetch_all(db)
    .await?;
    Ok(rows)
}
