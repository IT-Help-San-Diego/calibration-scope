use axum::response::Html;
use crate::state::AppState;
use crate::error::AppError;
use axum::extract::State;

pub async fn index_handler(State(state): State<AppState>) -> Result<Html<String>, AppError> {
    let content = tokio::fs::read_to_string(&state.config.dashboard_path)
        .await
        .map_err(|e| AppError::FileNotFound(format!("{}: {}", state.config.dashboard_path.display(), e)))?;
    Ok(Html(content))
}
