use serde::{Deserialize, Serialize};

#[derive(Debug, Serialize, Deserialize, sqlx::FromRow)]
pub struct BenchmarkRow {
    pub model: String,
    pub provider: String,
    #[serde(rename = "family")]
    pub test: String,
    pub verdict: String,
    pub detail: String,
    pub date: String,
}
