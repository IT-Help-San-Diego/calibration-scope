use sqlx::sqlite::SqlitePool;
use crate::config::Config;
use crate::error::AppResult;

#[derive(Clone)]
pub struct AppState {
    pub db: SqlitePool,
    pub config: Config,
}

impl AppState {
    pub async fn new(config: Config) -> AppResult<Self> {
        let db = SqlitePool::connect(&config.database_url).await?;

        // Run migrations on startup
        sqlx::migrate!("./migrations")
            .run(&db)
            .await?;

        tracing::info!("Database connected and migrations applied");
        Ok(AppState { db, config })
    }
}
