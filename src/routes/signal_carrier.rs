//! Signal/Carrier read API — the `owl_signal_carrier` aggregation
//! (migration 043) so the dashboard can SHOW the split instead of it
//! living only in the database. The aggregation is inlined here rather
//! than read from the view because the view lacks the
//! is_infra_error = false filter (see the note in signal_carrier below).
//!
//! Two numbers per (subject, family):
//!   signal_score     — pooled pass rate across every surface form of a
//!                      family (I + N siblings). Format-invariant: the
//!                      real construct.
//!   carrier_variance — variance of per-surface-form pass rate. High
//!                      signal + high carrier variance = the reasoning is
//!                      there and the WORDING is doing work that has
//!                      nothing to do with reasoning. NULL (never 0) when
//!                      fewer than 2 forms were attempted.
//!
//! Subjects are models AND human participants — the carbon arm's UI is the
//! dashboard's Human Cal page, and rows carry subject_kind + subject_id so
//! both land in the same shape (that is the whole point).

use axum::extract::{Query, State};
use axum::response::Json;
use serde::{Deserialize, Serialize};

use crate::error::AppResult;
use crate::state::AppState;

#[derive(Debug, Deserialize)]
pub struct SignalCarrierQuery {
    /// Optional: restrict to one model key (matches models.key).
    pub model_key: Option<String>,
    /// Optional: restrict to one axis (reasoning, literary, ...).
    pub axis: Option<String>,
    /// Minimum surface forms attempted (default 1; pass 2 to see only
    /// rows where carrier_variance is actually measurable).
    pub min_forms: Option<i64>,
}

#[derive(Debug, Serialize, sqlx::FromRow)]
pub struct SignalCarrierRow {
    pub subject_kind: String,
    /// participants.id for humans, models.id for models — display names are
    /// not unique (two participants can both be "CB"), so UI filtering must
    /// key on this, never on subject_name.
    pub subject_id: Option<i32>,
    pub subject_name: String,
    pub family_root_id: Option<i32>,
    pub family_name: Option<String>,
    pub axis: Option<String>,
    pub surface_forms_attempted: Option<i64>,
    pub total_trials: Option<i64>,
    pub total_passes: Option<i64>,
    pub signal_score: Option<f64>,
    pub carrier_variance: Option<f64>,
}

pub async fn signal_carrier(
    State(state): State<AppState>,
    Query(q): Query<SignalCarrierQuery>,
) -> AppResult<Json<serde_json::Value>> {
    let min_forms = q.min_forms.unwrap_or(1);
    // This inlines the owl_signal_carrier view's aggregation WITH two
    // corrections the view itself lacks (review catches, 2026-07-27):
    // (1) is_infra_error = false — unfiltered, a backend outage mid-run
    // reads as the subject's reasoning getting worse, and an outage that
    // hits one surface form manufactures fake carrier variance. Infra
    // failures are missing data, never wrong answers — the rule every
    // other results query already follows. (2) VAR_POP, not VARIANCE():
    // Postgres VARIANCE() is sample variance (÷ n−1), which reaches 0.5
    // for two forms at 0% and 100% — but the forms attempted are the
    // complete set under measurement, not a sample, and the UI's stated
    // 0.25 theoretical max is a population-variance bound. The view is not
    // changed here because it is schema other consumers may read directly
    // (relay to the backend lane to fix at the source once its consumers
    // agree — including the var_samp/var_pop choice).
    let rows: Vec<SignalCarrierRow> = sqlx::query_as(
        r#"WITH family_member AS (
              SELECT id AS test_id,
                     CASE WHEN owl_type = 'I' THEN id ELSE owl_root_id END AS family_root_id,
                     axis
              FROM tests
              WHERE owl_type IN ('I', 'N')
           ),
           subject_test_rate AS (
              SELECT tr.model_id, tr.participant_id, fm.family_root_id,
                     fm.test_id, fm.axis,
                     COUNT(*) AS total,
                     COUNT(*) FILTER (WHERE trr.passed) AS passes,
                     COUNT(*) FILTER (WHERE trr.passed)::FLOAT / NULLIF(COUNT(*), 0) AS pass_rate
              FROM trial_results trr
              JOIN test_runs tr ON tr.id = trr.run_id
              JOIN family_member fm ON fm.test_id = trr.test_id
              WHERE trr.is_infra_error = false
              GROUP BY tr.model_id, tr.participant_id, fm.family_root_id, fm.test_id, fm.axis
           ),
           sc AS (
              SELECT model_id, participant_id, family_root_id,
                     (SELECT name FROM tests WHERE id = family_root_id) AS family_name,
                     axis,
                     COUNT(DISTINCT test_id) AS surface_forms_attempted,
                     SUM(total) AS total_trials,
                     SUM(passes) AS total_passes,
                     SUM(passes)::FLOAT / NULLIF(SUM(total), 0) AS signal_score,
                     -- VAR_POP of one value is 0, not NULL — var_samp's n−1
                     -- division used to make the below-2-forms NULL free.
                     -- The contract says NULL, never 0, when the swing is
                     -- unmeasurable, so the guard is now explicit.
                     CASE WHEN COUNT(DISTINCT test_id) >= 2
                          THEN VAR_POP(pass_rate) END AS carrier_variance
              FROM subject_test_rate
              GROUP BY model_id, participant_id, family_root_id, axis
           )
           SELECT
              CASE WHEN sc.participant_id IS NOT NULL THEN 'human' ELSE 'model' END AS subject_kind,
              COALESCE(sc.participant_id, sc.model_id)::int AS subject_id,
              COALESCE(p.display_name, m.key, '?') AS subject_name,
              sc.family_root_id,
              sc.family_name,
              sc.axis,
              sc.surface_forms_attempted::bigint AS surface_forms_attempted,
              sc.total_trials::bigint AS total_trials,
              sc.total_passes::bigint AS total_passes,
              sc.signal_score::float8 AS signal_score,
              sc.carrier_variance::float8 AS carrier_variance
           FROM sc
           LEFT JOIN models m ON m.id = sc.model_id
           LEFT JOIN participants p ON p.id = sc.participant_id
           WHERE ($1::text IS NULL OR m.key = $1)
             AND ($2::text IS NULL OR sc.axis = $2)
             AND sc.surface_forms_attempted >= $3
           ORDER BY subject_name, sc.axis, sc.family_name"#,
    )
    .bind(&q.model_key)
    .bind(&q.axis)
    .bind(min_forms)
    .fetch_all(&state.db)
    .await?;

    let measurable = rows.iter().filter(|r| r.carrier_variance.is_some()).count();
    Ok(Json(serde_json::json!({
        "rows": rows,
        "row_count": rows.len(),
        "carrier_measurable_rows": measurable,
        "note": "carrier_variance is NULL below 2 surface forms — not enough data to measure a wording swing; a 0 there would be a false claim. Infra-error trials are excluded throughout: missing data, never wrong answers."
    })))
}
