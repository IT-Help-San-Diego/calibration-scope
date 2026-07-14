//! Global SSE endpoint — the dashboard's single live-data pipe (zero polling).
//!
//! Event contract (JSON envelopes, `type` discriminant, matching dashboard.html):
//!   initial       — full model-registry snapshot, sent once on connect
//!   refresh       — full snapshot, re-sent periodically and after runs mutate state
//!   run_started / phase / trial_result / verdict / run_complete / error
//!                 — run telemetry, forwarded verbatim from the executor via the
//!                   AppState broadcast channel.
use axum::{
    extract::State,
    response::sse::{Event, KeepAlive, Sse},
};
use futures_util::stream::Stream;
use std::convert::Infallible;
use std::time::Duration;

use crate::db::queries;
use crate::executor::cloud;
use crate::state::AppState;

/// Snapshot cadence. SSE push means the browser never polls; the server refreshes
/// the registry snapshot at this interval so verdict changes land without reloads.
const REFRESH_INTERVAL: Duration = Duration::from_secs(5);

/// Runnable-status envelope, computed by asking the EXACT function the
/// executor calls before firing a request (`cloud::resolve_api_key`).
/// Deliberately not a second heuristic re-implementing that check — a grid
/// that says "runnable" while the executor says "no key" is worse than no
/// signal at all (bit us live 2026-07-10: an openrouter/claude-sonnet-5
/// duplicate had no working credential in this service's env and errored on
/// every click, while its nous sibling worked fine — indistinguishable in
/// the UI). Shared by both the SSE registry push and the plain /api/models
/// fetch so the two paths can never disagree.
/// Local models are always runnable here — LM Studio residency is checked at
/// run time, not sync time; that's a different, cheaper class of "can run."
pub fn annotate_runnable(models: Vec<crate::models::model_entry::ModelEntry>) -> Vec<serde_json::Value> {
    models
        .into_iter()
        .map(|m| {
            let (runnable, reason) = if m.location == "local" {
                (true, None)
            } else {
                match cloud::resolve_api_key(&m.provider, &None) {
                    Ok(_) => (true, None),
                    Err(e) => (false, Some(e.to_string())),
                }
            };
            let mut v = serde_json::to_value(&m).unwrap_or_default();
            if let Some(obj) = v.as_object_mut() {
                obj.insert("runnable".to_string(), serde_json::json!(runnable));
                obj.insert("runnable_reason".to_string(), serde_json::json!(reason));
            }
            v
        })
        .collect()
}

/// Serialize the full model-registry snapshot as an SSE envelope.
/// `pub` because sync routes (lmstudio_sync, cloud_sync) broadcast a
/// `refresh` immediately after mutating the registry — instant grid
/// update over SSE, no reliance on the periodic tick.
pub async fn registry_envelope(state: &AppState, kind: &str) -> Option<String> {
    match queries::fetch_unique_models(&state.db).await {
        Ok(models) => {
            let annotated = annotate_runnable(models);
            match serde_json::to_string(&serde_json::json!({
                "type": kind,
                "models": annotated,
            })) {
                Ok(json) => Some(json),
                Err(e) => {
                    tracing::error!("SSE serialization failed: {}", e);
                    None
                }
            }
        }
        Err(e) => {
            tracing::error!("SSE registry fetch failed: {}", e);
            None
        }
    }
}

/// Background task: refresh the shared registry snapshot on a timer.
/// Spawned ONCE at startup (main.rs). This is the single owner of the heavy
/// registry query — every SSE connection reads the cached string it produces,
/// so N dashboard tabs cost ONE query per interval, not N. The snapshot holds
/// a `refresh`-typed envelope ready to yield verbatim.
///
/// The `refresh_now` broadcast lets mutating routes (lmstudio_sync, cloud_sync,
/// run completion) force an immediate rebuild so the grid updates without
/// waiting for the next tick.
pub fn spawn_registry_refresher(state: AppState) {
    tokio::spawn(async move {
        let mut ticker = tokio::time::interval(REFRESH_INTERVAL);
        ticker.set_missed_tick_behavior(tokio::time::MissedTickBehavior::Skip);
        loop {
            ticker.tick().await;
            if let Some(json) = registry_envelope(&state, "refresh").await {
                let mut guard = state.registry_snapshot.write().await;
                *guard = Some(json);
            }
        }
    });
}

/// Read the cached registry snapshot, re-typed to the requested envelope kind.
/// Falls back to a live query only if the cache is cold (first connection
/// before the refresher has run once) — a one-time cost, never the steady state.
async fn cached_envelope(state: &AppState, kind: &str) -> Option<String> {
    {
        let guard = state.registry_snapshot.read().await;
        if let Some(cached) = guard.as_ref() {
            // The cache stores a "refresh" envelope; re-tag to the requested
            // kind ("initial"/"refresh") without re-serializing the whole model
            // list — a cheap string replace on the type field prefix.
            if kind == "refresh" {
                return Some(cached.clone());
            }
            return Some(cached.replacen(
                "\"type\":\"refresh\"",
                &format!("\"type\":\"{}\"", kind),
                1,
            ));
        }
    }
    // Cache cold — do a one-time live build so the very first connection isn't blank.
    registry_envelope(state, kind).await
}

pub async fn sse_handler(
    State(state): State<AppState>,
) -> Sse<impl Stream<Item = Result<Event, Infallible>>> {
    let mut events_rx = state.events_tx.subscribe();

    let stream = async_stream::stream! {
        // 1. Initial snapshot on connect — from the shared cache, not a fresh DB scan.
        if let Some(json) = cached_envelope(&state, "initial").await {
            yield Ok::<_, Infallible>(Event::default().data(json));
        }

        // 2. Merge run telemetry (broadcast) with periodic registry refresh.
        let mut ticker = tokio::time::interval(REFRESH_INTERVAL);
        ticker.set_missed_tick_behavior(tokio::time::MissedTickBehavior::Skip);
        ticker.tick().await; // consume the immediate first tick (snapshot already sent)

        loop {
            tokio::select! {
                biased;

                recv = events_rx.recv() => {
                    match recv {
                        Ok(json) => yield Ok(Event::default().data(json)),
                        Err(tokio::sync::broadcast::error::RecvError::Lagged(skipped)) => {
                            tracing::warn!("SSE subscriber lagged, skipped {} events", skipped);
                            // Re-sync the grid after a lag gap — from cache, no DB scan.
                            if let Some(json) = cached_envelope(&state, "refresh").await {
                                yield Ok(Event::default().data(json));
                            }
                        }
                        Err(tokio::sync::broadcast::error::RecvError::Closed) => break,
                    }
                }

                _ = ticker.tick() => {
                    // Periodic grid refresh — reads the shared cache the
                    // background refresher maintains, NOT a per-connection query.
                    if let Some(json) = cached_envelope(&state, "refresh").await {
                        yield Ok(Event::default().data(json));
                    }
                }
            }
        }
    };

    Sse::new(stream).keep_alive(
        KeepAlive::new()
            .interval(Duration::from_secs(15))
            .text("heartbeat"),
    )
}
