use axum::Json;
use serde_json::json;

use crate::state::AppState;
use axum::extract::State;

/// GET /api/kanban — the cross-lane work board, read live from the repo file.
///
/// The board is state, not prose: `policy/kanban.jsonl` at the project root,
/// one card per line so three lanes append without merge conflicts. The
/// contract (policy/KANBAN_contract.md) and the CI-failing validator
/// (scripts/kanban_lint.py) are Claude Science's; this endpoint serves the
/// current board as a JSON array of cards, read per-request so any lane's
/// commit is visible on the next poll.
pub async fn kanban_handler(State(state): State<AppState>) -> Json<serde_json::Value> {
    let path = state.config.project_root.join("policy/kanban.jsonl");
    match std::fs::read_to_string(&path) {
        Ok(raw) => {
            let cards: Vec<serde_json::Value> = raw
                .lines()
                .filter(|l| !l.trim().is_empty() && !l.starts_with('#'))
                .filter_map(|l| serde_json::from_str(l).ok())
                .collect();
            Json(json!({ "version": 2, "format": "jsonl", "cards": cards }))
        }
        Err(e) => Json(json!({
            "error": "kanban.jsonl not found",
            "detail": e.to_string(),
            "path": path.display().to_string(),
        })),
    }
}
