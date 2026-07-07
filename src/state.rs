use sqlx::PgPool;
use std::time::Duration;
use crate::config::Config;
use crate::error::AppError;
use crate::error::AppResult;

#[derive(Clone)]
pub struct AppState {
    pub db: PgPool,
    pub config: Config,
}

impl AppState {
    pub async fn new(config: Config) -> AppResult<Self> {
        // Retry connection for up to 60 seconds — Colima/Docker may still be booting after a reboot
        let db = Self::connect_with_retry(&config.database_url, 60).await?;

        // Run migrations on startup
        sqlx::migrate!("./migrations")
            .run(&db)
            .await?;

        tracing::info!("Database connected and migrations applied");
        Ok(AppState { db, config })
    }

    async fn connect_with_retry(url: &str, max_seconds: u64) -> AppResult<PgPool> {
        let mut elapsed = 0u64;
        loop {
            match PgPool::connect(url).await {
                Ok(pool) => return Ok(pool),
                Err(e) => {
                    if elapsed >= max_seconds {
                        tracing::error!("Failed to connect to database after {}s: {}", max_seconds, e);
                        return Err(AppError::Database(e));
                    }
                    tracing::warn!("Database not ready ({}s elapsed), retrying in 2s...", elapsed);
                    tokio::time::sleep(Duration::from_secs(2)).await;
                    elapsed += 2;
                }
            }
        }
    }
}
