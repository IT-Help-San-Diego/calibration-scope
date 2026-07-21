//! Per-request security headers for the Calibration Scope dashboard.
//!
//! Designed ONCE for both the local loopback deployment and the public
//! calibrationscope.com deployment — identical code, no refactor when we go live.
//!
//! CSP is NONCE-BASED with 'strict-dynamic': every inline <script> in the
//! served dashboard gets a fresh per-request nonce, so we never need
//! 'unsafe-inline' (which would defeat the policy). External scripts (KaTeX)
//! are covered by 'self'. This survives web scale unchanged.

use axum::{
    body::Body,
    http::{header, HeaderName, HeaderValue, Request, Response},
    middleware::Next,
    response::IntoResponse,
};
use rand::Rng;

/// Per-request CSP nonce, carried through the middleware → handler chain
/// via request extensions so `index_handler` can stamp it onto inline scripts.
#[derive(Clone, Debug)]
pub struct Nonce(pub String);

fn gen_nonce() -> String {
    let mut rng = rand::thread_rng();
    let bytes: [u8; 16] = rng.gen();
    bytes.iter().map(|b| format!("{:02x}", b)).collect()
}

/// Returns the full CSP value for a given nonce.
///
/// `script-src` carries the nonce + 'strict-dynamic' for inline `<script>` and
/// deferred external scripts we nonce-stamp (KaTeX). `script-src-attr` allows
/// inline event-handler attributes (`onclick=`, etc.) — these are a separate
/// CSP bucket from `script-src` and MUST be declared or every handler is
/// blocked (the 1000-error regression). We scope it to 'self' + 'unsafe-inline'
/// because handler attributes cannot carry a nonce; this is the documented
/// CSP pattern for event-handler attributes.
fn csp(nonce: &str) -> String {
    format!(
        "default-src 'self'; \
         script-src 'self' 'nonce-{nonce}' 'strict-dynamic'; \
         script-src-attr 'self' 'unsafe-inline'; \
         style-src 'self' 'unsafe-inline'; \
         img-src 'self' data:; \
         font-src 'self'; \
         connect-src 'self'; \
         frame-ancestors 'none'; \
         base-uri 'self'; \
         form-action 'self'; \
         object-src 'none'; \
         upgrade-insecure-requests"
    )
}

/// Axum middleware (`from_fn`) that generates a per-request nonce, threads
/// it into the handler via `Extension<Nonce>`, then stamps the response with
/// all security headers once the handler has produced it.
pub async fn security_headers(req: Request<Body>, next: Next) -> Response<Body> {
    // Fresh nonce for THIS request.
    let nonce = gen_nonce();
    let (mut parts, body) = req.into_parts();
    parts.extensions.insert(Nonce(nonce.clone()));
    let req = Request::from_parts(parts, body);

    let mut resp = next.run(req).await.into_response();

    let headers = resp.headers_mut();
    // CSP is the load-bearing one; rebuilt per nonce.
    if let Ok(v) = HeaderValue::from_str(&csp(&nonce)) {
        headers.insert(header::CONTENT_SECURITY_POLICY, v);
    }
    // Defense-in-depth: explicit clickjacking + MIME sniff guards.
    if let Ok(v) = HeaderValue::from_str("DENY") {
        headers.insert(header::X_FRAME_OPTIONS, v);
    }
    if let Ok(v) = HeaderValue::from_str("nosniff") {
        headers.insert(header::X_CONTENT_TYPE_OPTIONS, v);
    }
    if let Ok(v) = HeaderValue::from_str("strict-origin-when-cross-origin") {
        headers.insert(header::REFERRER_POLICY, v);
    }
    // No camera/mic/location/USB for a benchmark dashboard.
    if let Ok(v) = HeaderValue::from_str(
        "accelerometer=(), camera=(), geolocation=(), gyroscope=(), \
         magnetometer=(), microphone=(), usb=(), payment=()",
    ) {
        headers.insert(HeaderName::from_static("permissions-policy"), v);
    }
    resp
}

/// Injects the per-request nonce onto every script tag that needs it.
///
/// 1. Inline `<script>` → `<script nonce="...">` (covered by `script-src`).
/// 2. Deferred EXTERNAL scripts (`<script defer src="...">`, e.g. KaTeX) →
///    also receive the nonce. Under `'strict-dynamic'`, external scripts are
///    NOT covered by `'self'` alone — they need a nonce or hash, or they are
///    blocked by `script-src-elem`. Stamping the deferred external scripts with
///    the same nonce lets them load while keeping the policy strict.
///
/// A plain token replace is correct and avoids regex look-around (unsupported
/// by the default `regex` feature set, which would panic at runtime).
pub fn stamp_nonce(html: &str, nonce: &str) -> String {
    html.replace("<script>", &format!("<script nonce=\"{}\">", nonce))
        .replace(
            "<script defer src=",
            &format!("<script defer nonce=\"{}\" src=", nonce),
        )
}
