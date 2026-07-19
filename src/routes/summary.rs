use crate::db::queries;
use crate::error::AppError;
use crate::state::AppState;
use axum::extract::State;
use axum::response::Json;

pub async fn summary_handler(
    State(state): State<AppState>,
) -> Result<Json<Vec<crate::models::benchmark::BenchmarkRow>>, AppError> {
    let rows = queries::fetch_all_benchmarks(&state.db).await?;
    Ok(Json(rows))
}
