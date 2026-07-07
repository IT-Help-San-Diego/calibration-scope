use axum::response::Json;
use axum::extract::State;
use crate::state::AppState;
use crate::error::AppError;
use crate::db::queries;
use crate::models::model_entry::ModelEntry;

pub async fn models_handler(State(state): State<AppState>) -> Result<Json<Vec<ModelEntry>>, AppError> {
    let rows = queries::fetch_unique_models(&state.db).await?;
    Ok(Json(rows))
}
