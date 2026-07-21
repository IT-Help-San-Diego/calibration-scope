//! Signal/Carrier read API — surfaces the `owl_signal_carrier` view
//! (migration 043) so the dashboard can SHOW the split instead of it
//! living only in the database.
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
//! Subjects are models today and human participants when the carbon arm
//! ships a UI — both land in the same shape (that is the whole point).

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
    let rows: Vec<SignalCarrierRow> = sqlx::query_as(
        r#"SELECT
              CASE WHEN sc.participant_id IS NOT NULL THEN 'human' ELSE 'model' END AS subject_kind,
              COALESCE(p.display_name, m.key, '?') AS subject_name,
              sc.family_root_id,
              sc.family_name,
              sc.axis,
              sc.surface_forms_attempted::bigint AS surface_forms_attempted,
              sc.total_trials::bigint AS total_trials,
              sc.total_passes::bigint AS total_passes,
              sc.signal_score::float8 AS signal_score,
              sc.carrier_variance::float8 AS carrier_variance
           FROM owl_signal_carrier sc
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

    let measurable = rows
        .iter()
        .filter(|r| r.carrier_variance.is_some())
        .count();
    Ok(Json(serde_json::json!({
        "rows": rows,
        "row_count": rows.len(),
        "carrier_measurable_rows": measurable,
        "note": "carrier_variance is NULL below 2 surface forms — not enough data to measure a wording swing; a 0 there would be a false claim."
    })))
}
