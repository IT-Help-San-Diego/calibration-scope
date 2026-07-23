use std::path::PathBuf;

#[derive(Clone, Debug)]
pub struct Config {
    pub database_url: String,
    pub dashboard_path: PathBuf,
    pub assets_dir: PathBuf,
    pub project_root: PathBuf,
    pub listen_addr: String,
    pub listen_port: u16,
    /// LM Studio REST base (local executor). Override with LMSTUDIO_BASE_URL.
    pub lmstudio_base_url: String,
    /// Cloud API keys — read from env, never persisted. None = cloud runs refuse honestly.
    pub nous_api_key: Option<String>,
    pub openrouter_api_key: Option<String>,
    pub openai_api_key: Option<String>,
    /// Gemini (Google AI Studio) API key — read from env, never persisted.
    /// Used for the permanent-free multimodal tier (gemini-3.5-flash), which
    /// needs no credit card / prepay. Each deployer supplies their own key via
    /// the GEMINI_API_KEY env var; nothing is baked into source.
    pub gemini_api_key: Option<String>,
}

impl Config {
    pub fn from_env() -> Self {
        // No hardcoded fallback — a real secret belongs in the environment
        // (launchd EnvironmentVariables locally, .env for dev), never in source.
        // Fails loudly and immediately if unset rather than silently using a
        // baked-in credential that would otherwise sit in git history forever.
        let database_url = std::env::var("DATABASE_URL").expect(
            "DATABASE_URL must be set (see .env.example) — no default is baked into source",
        );

        let project_root = resolve_project_root();
        let assets_dir = project_root.join("assets");
        let dashboard_path = assets_dir.join("dashboard.html");

        let listen_addr = std::env::var("LISTEN_ADDR").unwrap_or_else(|_| "127.0.0.1".to_string());
        let listen_port: u16 = std::env::var("LISTEN_PORT")
            .ok()
            .and_then(|p| p.parse().ok())
            .unwrap_or(8768);

        let lmstudio_base_url = std::env::var("LMSTUDIO_BASE_URL")
            .unwrap_or_else(|_| "http://localhost:1234".to_string());

        Config {
            database_url,
            dashboard_path,
            assets_dir,
            project_root,
            listen_addr,
            listen_port,
            lmstudio_base_url,
            nous_api_key: std::env::var("NOUS_API_KEY").ok().filter(|s| !s.is_empty()),
            openrouter_api_key: std::env::var("OPENROUTER_API_KEY")
                .ok()
                .filter(|s| !s.is_empty()),
            openai_api_key: std::env::var("OPENAI_API_KEY")
                .ok()
                .filter(|s| !s.is_empty()),
            gemini_api_key: std::env::var("GEMINI_API_KEY")
                .ok()
                .filter(|s| !s.is_empty()),
        }
    }

    pub fn bind_addr(&self) -> String {
        format!("{}:{}", self.listen_addr, self.listen_port)
    }
}

/// Where the instrument's data files (assets/, including the SHA3-pinned test
/// stimuli) live at runtime.
///
/// Prebuilt binaries run on machines that never saw the build tree, so the
/// compile-time CARGO_MANIFEST_DIR path — which on a GitHub runner is
/// /home/runner/work/... and exists nowhere else — must be the LAST resort,
/// not the only answer (it used to be baked in unconditionally, which made
/// every prebuilt binary hunt for the build machine's paths). Resolution
/// order:
///   1. CALIBRATION_SCOPE_ROOT env var — packaged installs (install.sh,
///      launchd plist, systemd unit) say exactly where they put things.
///   2. The executable's own directory, when assets/dashboard.html is there —
///      the release-tarball layout (binary and assets side by side).
///   3. <exe>/../share/calibration-scope — the Unix/Homebrew layout
///      (bin/calibration-scope-dashboard + share/calibration-scope/assets).
///   4. CARGO_MANIFEST_DIR — the dev checkout that built this binary
///      (`cargo run` keeps working with zero configuration).
///
/// Misresolution cannot corrupt the science: attachment bytes are re-hashed
/// against their SHA3 pins after every read, and files missing on disk fall
/// back to the byte-identical embedded copy (src/embedded.rs) — so a wrong
/// root degrades to embedded assets or a loud error, never a silent wrong
/// stimulus.
fn resolve_project_root() -> PathBuf {
    if let Ok(root) = std::env::var("CALIBRATION_SCOPE_ROOT") {
        if !root.trim().is_empty() {
            return PathBuf::from(root);
        }
    }
    if let Ok(exe) = std::env::current_exe() {
        // Canonicalize so a symlinked bin entry (Homebrew links bin/ into the
        // Cellar) resolves to the real install tree before we look around it.
        let exe = exe.canonicalize().unwrap_or(exe);
        if let Some(bin_dir) = exe.parent() {
            if bin_dir.join("assets").join("dashboard.html").is_file() {
                return bin_dir.to_path_buf();
            }
            let share = bin_dir.join("..").join("share").join("calibration-scope");
            if share.join("assets").join("dashboard.html").is_file() {
                return share.canonicalize().unwrap_or(share);
            }
        }
    }
    PathBuf::from(env!("CARGO_MANIFEST_DIR"))
}

#[cfg(test)]
mod tests {
    use super::*;

    /// ONE test, not two: both cases touch the process-global env var, and
    /// cargo runs #[test] fns on parallel threads — split, they race.
    ///
    /// Case 1 — the env override must win over everything, even when the path
    /// does not exist: packaged installs are trusted to know their own layout,
    /// and a wrong value should fail loudly downstream, not be silently
    /// "corrected". Case 2 — with no override (and the test exe living in
    /// target/, so no packaged layout beside it), resolution must land on the
    /// checkout that built the binary: `cargo test`/`cargo run` behavior is
    /// unchanged from the pre-portability code.
    #[test]
    fn resolution_order() {
        std::env::set_var("CALIBRATION_SCOPE_ROOT", "/nonexistent/for-test");
        assert_eq!(
            resolve_project_root(),
            PathBuf::from("/nonexistent/for-test")
        );

        std::env::remove_var("CALIBRATION_SCOPE_ROOT");
        assert_eq!(
            resolve_project_root(),
            PathBuf::from(env!("CARGO_MANIFEST_DIR"))
        );
    }
}
