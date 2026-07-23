//! Compile-time embedded copy of assets/ — what makes a prebuilt binary
//! self-contained.
//!
//! Resolution contract (shared with Config's project-root resolution):
//! DISK FIRST, embedded second. On a dev checkout every read hits the real
//! assets/ tree, so editing dashboard.html stays live with no rebuild and
//! behavior is byte-identical to before this module existed. Only a binary
//! that cannot find the file on disk — a Homebrew install, an install.sh
//! download, a bare binary on a machine that never saw the build tree —
//! falls through to the embedded copy, which rust-embed guarantees matches
//! the assets/ tree at the commit that built the binary.
//!
//! Science integrity is unaffected by the fallback: test-attachment SHA3
//! pins are enforced on the bytes AFTER this lookup (executor::build_messages
//! re-hashes whatever it got, disk or embedded), so a stale embedded stimulus
//! can never silently swap the science — mismatch is a loud refusal, exactly
//! as it is for disk.
//!
//! Note rust-embed's debug/release split: debug builds read the folder from
//! the compile-time path at runtime (fine — dev machines have the tree),
//! release builds embed the bytes. Releases are always --release.

use rust_embed::RustEmbed;

// **/.DS_Store, not .DS_Store: rust-embed compiles excludes with globset,
// where a bare filename matches only at the folder root — the ** prefix
// covers nested Finder droppings too. NOTE rust-embed embeds from DISK, not
// from git: a locally built binary bakes in whatever untracked files sit
// under assets/ at build time. Distributed binaries therefore come ONLY from
// the CI release workflow (clean checkout = tracked files only) — see
// docs/RELEASING.md.
#[derive(RustEmbed)]
#[folder = "assets/"]
#[exclude = "**/.DS_Store"]
pub struct EmbeddedAssets;

/// Fetch a file by its path relative to assets/ (e.g. "dashboard.html",
/// "tests/menu-bar.png") from the embedded copy. Returns None if the path
/// was never part of the assets/ tree.
pub fn get(rel: &str) -> Option<Vec<u8>> {
    EmbeddedAssets::get(rel).map(|f| f.data.into_owned())
}

/// The not-found service behind /assets: when ServeDir misses on disk, answer
/// from the embedded copy. Traversal is a non-issue here — lookups are exact
/// string keys into the embed map, never filesystem paths.
pub async fn asset_fallback(uri: axum::http::Uri) -> axum::response::Response {
    use axum::response::IntoResponse;

    let rel = uri.path().trim_start_matches('/');
    match get(rel) {
        Some(bytes) => {
            // Loud breadcrumb: on a dev/launchd host serving a live assets/
            // tree this line firing means a request was answered with bytes
            // from the BUILD-TIME copy (file missing on disk) — the one way
            // "the dashboard looks stale" can happen, so make it findable in
            // the service log.
            tracing::debug!("asset {} not on disk — served embedded copy", rel);
            let mime = mime_guess::from_path(rel).first_or_octet_stream();
            (
                [(axum::http::header::CONTENT_TYPE, mime.to_string())],
                bytes,
            )
                .into_response()
        }
        None => axum::http::StatusCode::NOT_FOUND.into_response(),
    }
}
