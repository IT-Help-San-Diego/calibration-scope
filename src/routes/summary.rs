use axum::response::Json;
use axum::extract::State;
use crate::state::AppState;
use crate::error::AppError;
use crate::db::queries;

pub async fn summary_handler(State(state): State<AppState>) -> Result<Json<Vec<crate::models::benchmark::BenchmarkRow>>, AppError> {
    let rows = queries::fetch_all_benchmarks(&state.db).await?;
    Ok(Json(rows))
}
