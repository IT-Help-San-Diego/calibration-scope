use crate::db::queries;
use crate::routes::events::annotate_runnable;
use axum::{extract::State, response::Json};

pub async fn models_handler(
    State(state): State<crate::state::AppState>,
) -> Json<Vec<serde_json::Value>> {
    match queries::fetch_unique_models(&state.db).await {
        Ok(models) => {
            let annotated = annotate_runnable(models);
            Json(annotated)
        }
        Err(e) => {
            tracing::error!("Failed to fetch registry models: {:?}", e);
            Json(Vec::new())
        }
    }
}
