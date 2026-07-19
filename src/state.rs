use sqlx::PgPool;
use std::sync::Arc;
use std::time::Duration;
use tokio::sync::broadcast;
use tokio::sync::RwLock;

use crate::config::Config;
use crate::error::AppError;
use crate::error::AppResult;
use crate::gpu_telemetry::ActiveRuns;
use crate::lm_guard::CancellationRegistry;

/// Capacity of the run-event broadcast channel. Slow SSE subscribers that lag
/// more than this many events behind simply skip ahead (documented tokio behavior);
/// grid state is self-healing because periodic `refresh` snapshots follow.
/// Raised 256 -> 1024 (2026-07-14): trial_start + trial_result are BOTH emitted
/// per trial now, so a 90-test x 3-trial run bursts ~1080 events; 1024 gives a
/// lagging browser tab a full run of headroom before it has to re-sync.
const EVENT_CHANNEL_CAPACITY: usize = 1024;

/// Shared, pre-serialized registry snapshot. ONE background task refreshes this
/// on a timer (see spawn_registry_refresher); every SSE connection reads the
/// cached string instead of each running its own full DB scan +
/// per-cloud-model credential check every 5s. This is the difference between
/// O(connections x heavy-query) load and O(1): before this, 5 open dashboard
/// tabs meant 5 LATERAL-join model scans + 5 credential sweeps every 5 seconds,
/// forever. The snapshot holds the `{"type":"refresh",...}` envelope ready to
/// yield verbatim.
pub type RegistrySnapshot = Arc<RwLock<Option<String>>>;

#[derive(Clone)]
pub struct AppState {
    pub db: PgPool,
    pub config: Config,
    /// Run telemetry fan-out: executors publish serialized event JSON
    /// (run_started / phase / trial_result / verdict / run_complete / error),
    /// every open SSE connection receives it. See routes::events.
    pub events_tx: broadcast::Sender<String>,
    /// Pre-serialized model-registry snapshot, refreshed by a single background
    /// task. SSE connections read this cache; they never run the heavy registry
    /// query themselves. See spawn_registry_refresher + routes::events.
    pub registry_snapshot: RegistrySnapshot,
    /// Per-run cancellation handles — lets POST /api/runs/:id/abort signal a
    /// specific in-flight run's executor task to stop. See lm_guard.rs for
    /// the full rationale (verified live: dropping the LM Studio connection
    /// genuinely halts GPU work, so cancellation here is a real abort, not
    /// a cosmetic one).
    pub cancellations: CancellationRegistry,
    /// Live LM Studio downloads we initiated (keyed by LM Studio job_id). The
    /// download poller tracks these and writes real size_gb on completion.
    /// Empty when idle → zero cost. See docs/lm-studio-api-notes.md.
    pub active_downloads: crate::routes::download::ActiveDownloads,
    /// Live count of executing runs — gates the GPU telemetry sampler
    /// (gpu_telemetry.rs): 1Hz samples while > 0, dormant at 0.
    pub active_runs: ActiveRuns,
}

impl AppState {
    pub async fn new(config: Config) -> AppResult<Self> {
        // Retry connection for up to 60 seconds — Colima/Docker may still be booting after a reboot
        let db = Self::connect_with_retry(&config.database_url, 60).await?;

        // Run migrations on startup
        sqlx::migrate!("./migrations").run(&db).await?;

        let (events_tx, _) = broadcast::channel(EVENT_CHANNEL_CAPACITY);

        tracing::info!("Database connected and migrations applied");
        Ok(AppState {
            db,
            config,
            events_tx,
            registry_snapshot: Arc::new(RwLock::new(None)),
            cancellations: CancellationRegistry::new(),
            active_downloads: Arc::new(tokio::sync::Mutex::new(std::collections::HashMap::new())),
            active_runs: ActiveRuns::new(),
        })
    }

    async fn connect_with_retry(url: &str, max_seconds: u64) -> AppResult<PgPool> {
        let mut elapsed = 0u64;
        loop {
            match PgPool::connect(url).await {
                Ok(pool) => return Ok(pool),
                Err(e) => {
                    if elapsed >= max_seconds {
                        tracing::error!(
                            "Failed to connect to database after {}s: {}",
                            max_seconds,
                            e
                        );
                        return Err(AppError::Database(e));
                    }
                    tracing::warn!(
                        "Database not ready ({}s elapsed), retrying in 2s...",
                        elapsed
                    );
                    tokio::time::sleep(Duration::from_secs(2)).await;
                    elapsed += 2;
                }
            }
        }
    }
}
