use axum::Json;
use serde_json::json;

use crate::state::AppState;
use axum::extract::State;

/// GET /api/kanban — the cross-lane work board, read live from the repo file.
///
/// The board is state, not prose: `policy/kanban.json` at the project root,
/// committed by every lane. Reading it per-request (not cached, not baked
/// into the binary) means any lane's commit is visible on the next poll —
/// the dashboard renders the *current* board, and "did the other lanes
/// update their cards" is answerable without a rebuild or a redeploy.
/// Validated against policy/kanban.schema.json at write time by convention;
/// this endpoint serves whatever the repo currently holds, unfiltered.
pub async fn kanban_handler(State(state): State<AppState>) -> Json<serde_json::Value> {
    let path = state.config.project_root.join("policy/kanban.json");
    match std::fs::read_to_string(&path) {
        Ok(raw) => match serde_json::from_str::<serde_json::Value>(&raw) {
            Ok(board) => Json(board),
            Err(e) => Json(json!({
                "error": "kanban.json is not valid JSON",
                "detail": e.to_string(),
                "path": path.display().to_string(),
            })),
        },
        Err(e) => Json(json!({
            "error": "kanban.json not found",
            "detail": e.to_string(),
            "path": path.display().to_string(),
        })),
    }
}
