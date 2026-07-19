//! Live GPU telemetry — sampled from IOKit while benchmark runs are active.
//!
//! Source: `ioreg -r -d 1 -c IOAccelerator` → PerformanceStatistics, the same
//! counters Activity Monitor's GPU history reads. Sampled at 1Hz ONLY while
//! at least one run is executing (an idle dashboard takes zero samples), each
//! sample broadcast over the SSE channel as a `gpu_sample` envelope:
//!   {type:"gpu_sample", device_util_pct, renderer_util_pct, tiler_util_pct,
//!    in_use_gpu_bytes, alloc_gpu_bytes, sampled_at}
//!
//! Measured cost on the dev machine (2026-07-09): ~21ms per ioreg invocation.
//! At 1Hz while runs are active that's ~2% of one core — negligible next to
//! inference, and zero when idle.
//!
//! Fields are Options end-to-end: if ioreg's shape changes, the sample says
//! null rather than inventing a number (host reality contract).
use std::sync::atomic::{AtomicUsize, Ordering};
use std::sync::Arc;

use crate::state::AppState;

/// Count of currently-executing benchmark runs. Incremented/decremented by
/// the executor via RunGuard; the sampler only measures while > 0.
#[derive(Clone, Default)]
pub struct ActiveRuns(Arc<AtomicUsize>);

impl ActiveRuns {
    pub fn new() -> Self {
        Self::default()
    }
    pub fn count(&self) -> usize {
        self.0.load(Ordering::Relaxed)
    }
    /// RAII guard: holds +1 on the active-run counter for as long as a run
    /// executes. Drop-based so early returns/errors/aborts can't leak a
    /// stuck counter (which would leave the sampler running forever).
    pub fn guard(&self) -> RunGuard {
        self.0.fetch_add(1, Ordering::Relaxed);
        RunGuard(self.0.clone())
    }
}

pub struct RunGuard(Arc<AtomicUsize>);

impl Drop for RunGuard {
    fn drop(&mut self) {
        self.0.fetch_sub(1, Ordering::Relaxed);
    }
}

/// One parsed sample of the accelerator's performance counters.
#[derive(Debug, serde::Serialize)]
pub struct GpuSample {
    pub device_util_pct: Option<i64>,
    pub renderer_util_pct: Option<i64>,
    pub tiler_util_pct: Option<i64>,
    pub in_use_gpu_bytes: Option<i64>,
    pub alloc_gpu_bytes: Option<i64>,
}

/// Extract `"<key>"=<int>` from ioreg's PerformanceStatistics dict text.
/// ioreg emits a flat single-line dict — plain string scanning is exact
/// here and avoids dragging in a plist parser for five integers.
fn stat(raw: &str, key: &str) -> Option<i64> {
    let needle = format!("\"{}\"={}", key, "");
    let start = raw.find(&format!("\"{}\"=", key))? + needle.len();
    let tail = &raw[start..];
    let end = tail
        .find(|c: char| !c.is_ascii_digit())
        .unwrap_or(tail.len());
    tail[..end].parse().ok()
}

pub async fn sample() -> Option<GpuSample> {
    let out = tokio::process::Command::new("/usr/sbin/ioreg")
        .args(["-r", "-d", "1", "-c", "IOAccelerator"])
        .output()
        .await
        .ok()?;
    if !out.status.success() {
        return None;
    }
    let raw = String::from_utf8_lossy(&out.stdout);
    let perf = raw.lines().find(|l| l.contains("PerformanceStatistics"))?;
    Some(GpuSample {
        device_util_pct: stat(perf, "Device Utilization %"),
        renderer_util_pct: stat(perf, "Renderer Utilization %"),
        tiler_util_pct: stat(perf, "Tiler Utilization %"),
        in_use_gpu_bytes: stat(perf, "In use system memory"),
        alloc_gpu_bytes: stat(perf, "Alloc system memory"),
    })
}

/// Background sampler: 1Hz while runs are active, dormant otherwise.
/// Spawned once at startup from main().
pub async fn sampler_loop(state: AppState) {
    let mut ticker = tokio::time::interval(std::time::Duration::from_secs(1));
    ticker.set_missed_tick_behavior(tokio::time::MissedTickBehavior::Skip);
    loop {
        ticker.tick().await;
        if state.active_runs.count() == 0 {
            continue; // idle: measure nothing, spend nothing
        }
        if let Some(s) = sample().await {
            let envelope = serde_json::json!({
                "type": "gpu_sample",
                "device_util_pct": s.device_util_pct,
                "renderer_util_pct": s.renderer_util_pct,
                "tiler_util_pct": s.tiler_util_pct,
                "in_use_gpu_bytes": s.in_use_gpu_bytes,
                "alloc_gpu_bytes": s.alloc_gpu_bytes,
                "sampled_at": chrono::Utc::now().to_rfc3339(),
                "source": "ioreg -r -d 1 -c IOAccelerator (PerformanceStatistics)",
            });
            if let Ok(json) = serde_json::to_string(&envelope) {
                let _ = state.events_tx.send(json);
            }
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    const SAMPLE_LINE: &str = r#"    "PerformanceStatistics" = {"In use system memory (driver)"=0,"Alloc system memory"=39751368704,"Tiler Utilization %"=11,"recoveryCount"=0,"Renderer Utilization %"=18,"Device Utilization %"=18,"In use system memory"=2939338752}"#;

    #[test]
    fn parses_real_ioreg_shape() {
        assert_eq!(stat(SAMPLE_LINE, "Device Utilization %"), Some(18));
        assert_eq!(stat(SAMPLE_LINE, "Tiler Utilization %"), Some(11));
        assert_eq!(stat(SAMPLE_LINE, "In use system memory"), Some(2939338752));
        assert_eq!(stat(SAMPLE_LINE, "Alloc system memory"), Some(39751368704));
    }

    #[test]
    fn exact_key_does_not_match_driver_variant() {
        // "In use system memory" must not accidentally parse the
        // "(driver)"-suffixed key's value. Find matches the exact quoted
        // key followed by '=' — the driver variant has " (driver)" before
        // the quote so the plain key's first match is the driver row's
        // PREFIX only if the plain key appears there first. Verify the
        // parsed value is the standalone key's 2939338752, not 0.
        assert_eq!(stat(SAMPLE_LINE, "In use system memory"), Some(2939338752));
    }

    #[test]
    fn missing_key_is_none_not_zero() {
        assert_eq!(stat(SAMPLE_LINE, "No Such Counter"), None);
    }

    #[test]
    fn guard_counts_and_releases() {
        let runs = ActiveRuns::new();
        assert_eq!(runs.count(), 0);
        let g1 = runs.guard();
        let g2 = runs.guard();
        assert_eq!(runs.count(), 2);
        drop(g1);
        assert_eq!(runs.count(), 1);
        drop(g2);
        assert_eq!(runs.count(), 0);
    }
}
