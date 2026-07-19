use thiserror::Error;

#[derive(Debug, Error)]
pub enum AppError {
    #[error("Database error: {0}")]
    Database(#[from] sqlx::Error),

    #[error("Migration error: {0}")]
    Migration(#[from] sqlx::migrate::MigrateError),

    #[error("File not found: {0}")]
    FileNotFound(String),

    #[error("IO error: {0}")]
    Io(#[from] std::io::Error),

    #[error("JSON serialization error: {0}")]
    Json(#[from] serde_json::Error),

    #[error("HTTP client error: {0}")]
    Http(#[from] reqwest::Error),

    #[error("Executor error: {0}")]
    Executor(String),

    #[error("Run aborted by operator request")]
    Aborted,
}

impl axum::response::IntoResponse for AppError {
    fn into_response(self) -> axum::response::Response {
        let (status, message) = match &self {
            AppError::Database(e) => {
                tracing::error!("Database error: {}", e);
                let msg = format!("Database error: {}", e);
                (axum::http::StatusCode::INTERNAL_SERVER_ERROR, msg)
            }
            AppError::Migration(e) => {
                tracing::error!("Migration error: {}", e);
                let msg = format!("Migration error: {}", e);
                (axum::http::StatusCode::INTERNAL_SERVER_ERROR, msg)
            }
            AppError::FileNotFound(_path) => (
                axum::http::StatusCode::NOT_FOUND,
                "File not found".to_string(),
            ),
            AppError::Io(e) => {
                tracing::error!("IO error: {}", e);
                (
                    axum::http::StatusCode::INTERNAL_SERVER_ERROR,
                    "IO error".to_string(),
                )
            }
            AppError::Json(e) => {
                tracing::error!("JSON error: {}", e);
                (
                    axum::http::StatusCode::INTERNAL_SERVER_ERROR,
                    "JSON error".to_string(),
                )
            }
            AppError::Http(e) => {
                tracing::error!("HTTP client error: {}", e);
                (
                    axum::http::StatusCode::BAD_GATEWAY,
                    "Upstream HTTP error".to_string(),
                )
            }
            AppError::Executor(msg) => {
                tracing::error!("Executor error: {}", msg);
                return (axum::http::StatusCode::BAD_REQUEST, msg.clone()).into_response();
            }
            AppError::Aborted => (
                axum::http::StatusCode::OK,
                "Run aborted by operator request".to_string(),
            ),
        };

        (status, message).into_response()
    }
}

pub type AppResult<T> = Result<T, AppError>;
