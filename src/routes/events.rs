use axum::{
    response::sse::{Event, Sse, KeepAlive},
    extract::State,
};
use std::convert::Infallible;
use std::time::Duration;
use futures_util::stream::{self, Stream};
use tokio_stream::StreamExt;
use crate::state::AppState;
use crate::db::queries;

pub async fn sse_handler(
    State(state): State<AppState>,
) -> Sse<impl Stream<Item = Result<Event, Infallible>>> {
    let db = state.db.clone();

    let stream = stream::repeat_with(move || {
        let db = db.clone();
        async move {
            let rows = queries::fetch_all_benchmarks(&db).await;
            match rows {
                Ok(r) => match serde_json::to_string(&r) {
                    Ok(json) => Event::default().data(json),
                    Err(_) => Event::default().data("[]"),
                },
                Err(_) => Event::default().data("[]"),
            }
        }
    })
    .then(|fut| async move { Ok::<_, Infallible>(fut.await) })
    .throttle(Duration::from_secs(2));

    Sse::new(stream).keep_alive(
        KeepAlive::new()
            .interval(Duration::from_secs(5))
            .text("heartbeat"),
    )
}
