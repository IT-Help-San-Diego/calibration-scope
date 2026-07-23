use crate::error::AppError;
use crate::security::{stamp_nonce, Nonce};
use crate::state::AppState;
use axum::extract::State;
use axum::http::header::{CACHE_CONTROL, EXPIRES, PRAGMA};
use axum::response::{Html, IntoResponse};
use axum::Extension;

pub async fn index_handler(
    State(state): State<AppState>,
    Extension(nonce): Extension<Nonce>,
) -> Result<impl IntoResponse, AppError> {
    // Disk first (dev checkout: live-editable dashboard.html), embedded copy
    // second (prebuilt binary on a machine without the assets tree). Only a
    // MISSING file falls back — a permission or I/O failure on an existing
    // dashboard is a misconfiguration that must stay loud, not be papered
    // over with the build-time copy. See src/embedded.rs for the contract.
    let content = match tokio::fs::read_to_string(&state.config.dashboard_path).await {
        Ok(s) => s,
        Err(disk_err) if disk_err.kind() == std::io::ErrorKind::NotFound => {
            match crate::embedded::get("dashboard.html") {
                Some(bytes) => String::from_utf8(bytes).map_err(|e| {
                    AppError::FileNotFound(format!("embedded dashboard.html not UTF-8: {}", e))
                })?,
                None => {
                    return Err(AppError::FileNotFound(format!(
                        "{}: {} (and no embedded copy)",
                        state.config.dashboard_path.display(),
                        disk_err
                    )))
                }
            }
        }
        Err(disk_err) => {
            return Err(AppError::FileNotFound(format!(
                "{}: {}",
                state.config.dashboard_path.display(),
                disk_err
            )))
        }
    };
    // Stamp the per-request CSP nonce onto every inline <script> so the
    // nonce-based CSP (set by the security middleware) actually permits
    // our own code without 'unsafe-inline'.
    let content = stamp_nonce(&content, &nonce.0);
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
