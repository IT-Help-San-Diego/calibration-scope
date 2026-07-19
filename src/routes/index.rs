use crate::error::AppError;
use crate::state::AppState;
use axum::extract::State;
use axum::http::header::{CACHE_CONTROL, EXPIRES, PRAGMA};
use axum::response::{Html, IntoResponse};

pub async fn index_handler(State(state): State<AppState>) -> Result<impl IntoResponse, AppError> {
    let content = tokio::fs::read_to_string(&state.config.dashboard_path)
        .await
        .map_err(|e| {
            AppError::FileNotFound(format!("{}: {}", state.config.dashboard_path.display(), e))
        })?;
    let headers = [
        (
            CACHE_CONTROL,
            "no-store, no-cache, must-revalidate, max-age=0",
        ),
        (PRAGMA, "no-cache"),
        (EXPIRES, "0"),
    ];
    Ok((headers, Html(content)))
}
