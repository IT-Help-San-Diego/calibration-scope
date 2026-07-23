//! Local HTTPS — self-provisioned CA + leaf, served with rustls (handoff item 1).
//!
//! Design (per policy/HANDOFF_claude_code_gui.md and Carey's "easy for the
//! future user" requirement):
//!
//! * The instrument provisions its OWN certificate authority on first start:
//!   `~/.calibration-scope/ca/` gets a long-lived local CA and a short-lived
//!   leaf for `local.calibrationscope.com` / `127.0.0.1` / `localhost` / `::1`.
//!   One generator (this module), no openssl invocation, nothing to install.
//! * ONE port speaks BOTH protocols. We peek the first byte of every TCP
//!   connection: 0x16 (TLS handshake) → rustls; anything else → plain HTTP.
//!   Untrusted or legacy clients (curl scripts, the Python client, Hermes
//!   automation, launchd health checks) keep working over http unchanged;
//!   trusting the CA is an opt-in upgrade, never a prerequisite.
//! * The CSP is per-connection honest: `upgrade-insecure-requests` is sent
//!   ONLY on TLS connections (see security.rs). On plain HTTP that directive
//!   would tell Safari to fetch assets over TLS it may not trust yet — the
//!   exact white-page failure the Safari incident taught us (commit 102b63f).
//! * Apple trust rules are honored so the Keychain import "just works":
//!   leaf validity ≤ 825 days, subjectAltName present, EKU = serverAuth
//!   (Apple rejects TLS certs that violate any of these on modern macOS).
//! * Crypto stack: rustls + ring — memory-safe, independently audited, no
//!   OpenSSL. If an institution ever requires FIPS-validated crypto, the seam
//!   is the tokio-rustls backend feature (ring → aws-lc-rs/fips); nothing in
//!   this module changes.
//!
//! Trust for the human: double-click `~/.calibration-scope/ca/ca.cert.pem`
//! (Keychain Access → set Always Trust), or run `scripts/trust-local-ca.sh`.

use std::path::{Path, PathBuf};
use std::sync::Arc;

use axum::Extension;
use hyper_util::rt::{TokioExecutor, TokioIo};
use hyper_util::server::conn::auto::Builder as AutoBuilder;
use hyper_util::service::TowerToHyperService;
use tokio_rustls::rustls::pki_types::{CertificateDer, PrivateKeyDer};
use tokio_rustls::rustls::ServerConfig;
use tokio_rustls::TlsAcceptor;

use crate::error::{AppError, AppResult};
use crate::security::ConnScheme;

/// The advertised local hostname (public DNS A → 127.0.0.1, DNSSEC-signed).
pub const LOCAL_HOSTNAME: &str = "local.calibrationscope.com";

fn ca_dir() -> PathBuf {
    let home = std::env::var_os("HOME")
        .map(PathBuf::from)
        .unwrap_or_else(|| PathBuf::from("/"));
    home.join(".calibration-scope").join("ca")
}

fn write_private(path: &Path, pem: &str) -> AppResult<()> {
    use std::io::Write;
    #[cfg(unix)]
    {
        use std::os::unix::fs::OpenOptionsExt;
        let mut f = std::fs::OpenOptions::new()
            .write(true)
            .create(true)
            .truncate(true)
            .mode(0o600)
            .open(path)
            .map_err(|e| AppError::Executor(format!("write {}: {}", path.display(), e)))?;
        f.write_all(pem.as_bytes())
            .map_err(|e| AppError::Executor(format!("write {}: {}", path.display(), e)))?;
    }
    #[cfg(not(unix))]
    std::fs::write(path, pem)
        .map_err(|e| AppError::Executor(format!("write {}: {}", path.display(), e)))?;
    Ok(())
}

/// The CA's certificate parameters — ONE deterministic definition, used both
/// when generating the CA and when rebuilding the issuer object to sign a new
/// leaf against the PERSISTED CA key. Identical DN + same key → identical
/// issuer identity, so leaves signed by the rebuilt issuer chain to the
/// on-disk (and Keychain-trusted) CA certificate. This avoids parsing the CA
/// PEM back into params (rcgen's from_ca_cert_pem needs an extra feature).
fn ca_params() -> AppResult<rcgen::CertificateParams> {
    let mut params = rcgen::CertificateParams::new(Vec::<String>::new())
        .map_err(|e| AppError::Executor(format!("CA params: {}", e)))?;
    params
        .distinguished_name
        .push(rcgen::DnType::CommonName, "Calibration Scope Local CA");
    params.is_ca = rcgen::IsCa::Ca(rcgen::BasicConstraints::Unconstrained);
    params.key_usages = vec![
        rcgen::KeyUsagePurpose::KeyCertSign,
        rcgen::KeyUsagePurpose::CrlSign,
    ];
    let now = time::OffsetDateTime::now_utc();
    params.not_before = now - time::Duration::days(1);
    params.not_after = now + time::Duration::days(3650);
    Ok(params)
}

/// Provision (or reuse) the CA + leaf. Returns the rustls server config and
/// the CA certificate path (the file the human double-clicks to trust).
pub fn ensure_local_tls() -> AppResult<(Arc<ServerConfig>, PathBuf)> {
    let dir = ca_dir();
    std::fs::create_dir_all(&dir)
        .map_err(|e| AppError::Executor(format!("create {}: {}", dir.display(), e)))?;
    let ca_cert_path = dir.join("ca.cert.pem");
    let ca_key_path = dir.join("ca.key.pem");
    let leaf_cert_path = dir.join("leaf.cert.pem");
    let leaf_key_path = dir.join("leaf.key.pem");

    // ── CA: generate once, reuse forever (it's the user's trust anchor —
    // regenerating would invalidate their Keychain approval). ────────────────
    let ca_key_pem = if ca_cert_path.is_file() && ca_key_path.is_file() {
        std::fs::read_to_string(&ca_key_path)
            .map_err(|e| AppError::Executor(format!("read CA key: {}", e)))?
    } else {
        let key = rcgen::KeyPair::generate()
            .map_err(|e| AppError::Executor(format!("CA keygen: {}", e)))?;
        let cert = ca_params()?
            .self_signed(&key)
            .map_err(|e| AppError::Executor(format!("CA self-sign: {}", e)))?;
        let key_pem = key.serialize_pem();
        std::fs::write(&ca_cert_path, cert.pem())
            .map_err(|e| AppError::Executor(format!("write CA cert: {}", e)))?;
        write_private(&ca_key_path, &key_pem)?;
        tracing::info!(
            "Local CA generated: {} — trust it once via scripts/trust-local-ca.sh \
             (or double-click it into Keychain Access and set Always Trust)",
            ca_cert_path.display()
        );
        key_pem
    };

    // ── Leaf: regenerate when missing or aging past ~700 days (Apple caps TLS
    // leaf validity at 825 days; we issue 820 and rotate early by mtime). ────
    let leaf_stale = match std::fs::metadata(&leaf_cert_path).and_then(|m| m.modified()) {
        Ok(t) => t
            .elapsed()
            .map(|age| age.as_secs() > 700 * 24 * 3600)
            .unwrap_or(true),
        Err(_) => true,
    };
    if leaf_stale || !leaf_key_path.is_file() {
        let ca_key = rcgen::KeyPair::from_pem(&ca_key_pem)
            .map_err(|e| AppError::Executor(format!("load CA key: {}", e)))?;
        // Rebuild the issuer from the SAME deterministic params + persisted key
        // (see ca_params) — identical issuer identity to the on-disk CA cert.
        let ca_cert = ca_params()?
            .self_signed(&ca_key)
            .map_err(|e| AppError::Executor(format!("rebuild CA issuer: {}", e)))?;

        let leaf_key = rcgen::KeyPair::generate()
            .map_err(|e| AppError::Executor(format!("leaf keygen: {}", e)))?;
        let mut params =
            rcgen::CertificateParams::new(vec![LOCAL_HOSTNAME.to_string(), "localhost".into()])
                .map_err(|e| AppError::Executor(format!("leaf params: {}", e)))?;
        params.subject_alt_names.push(rcgen::SanType::IpAddress(
            "127.0.0.1".parse().expect("loopback v4 parses"),
        ));
        params.subject_alt_names.push(rcgen::SanType::IpAddress(
            "::1".parse().expect("loopback v6 parses"),
        ));
        params
            .distinguished_name
            .push(rcgen::DnType::CommonName, LOCAL_HOSTNAME);
        params.use_authority_key_identifier_extension = true;
        params.extended_key_usages = vec![rcgen::ExtendedKeyUsagePurpose::ServerAuth];
        let now = time::OffsetDateTime::now_utc();
        params.not_before = now - time::Duration::days(1);
        params.not_after = now + time::Duration::days(820); // Apple cap: 825
        let leaf = params
            .signed_by(&leaf_key, &ca_cert, &ca_key)
            .map_err(|e| AppError::Executor(format!("leaf sign: {}", e)))?;
        std::fs::write(&leaf_cert_path, leaf.pem())
            .map_err(|e| AppError::Executor(format!("write leaf cert: {}", e)))?;
        write_private(&leaf_key_path, &leaf_key.serialize_pem())?;
        tracing::info!(
            "Local TLS leaf issued for {} (820-day validity)",
            LOCAL_HOSTNAME
        );
    }

    // ── rustls server config: chain = [leaf, ca]. ───────────────────────────
    let mut chain: Vec<CertificateDer<'static>> = Vec::new();
    for p in [&leaf_cert_path, &ca_cert_path] {
        let pem = std::fs::read(p)
            .map_err(|e| AppError::Executor(format!("read {}: {}", p.display(), e)))?;
        for cert in rustls_pemfile::certs(&mut pem.as_slice()) {
            chain.push(
                cert.map_err(|e| AppError::Executor(format!("parse {}: {}", p.display(), e)))?,
            );
        }
    }
    let key_pem = std::fs::read(&leaf_key_path)
        .map_err(|e| AppError::Executor(format!("read leaf key: {}", e)))?;
    let key: PrivateKeyDer<'static> = rustls_pemfile::private_key(&mut key_pem.as_slice())
        .map_err(|e| AppError::Executor(format!("parse leaf key: {}", e)))?
        .ok_or_else(|| AppError::Executor("leaf key PEM held no private key".into()))?;

    let mut config = ServerConfig::builder()
        .with_no_client_auth()
        .with_single_cert(chain, key)
        .map_err(|e| AppError::Executor(format!("rustls config: {}", e)))?;
    config.alpn_protocols = vec![b"h2".to_vec(), b"http/1.1".to_vec()];
    Ok((Arc::new(config), ca_cert_path))
}

/// Serve BOTH protocols on one listener. First byte 0x16 = TLS ClientHello →
/// rustls; anything else → plain HTTP. Each connection's requests carry a
/// `ConnScheme` extension so the security middleware can be per-connection
/// honest about `upgrade-insecure-requests`.
pub async fn serve_dual(
    listener: tokio::net::TcpListener,
    app: axum::Router,
    tls_config: Arc<ServerConfig>,
    shutdown: impl std::future::Future<Output = ()>,
) {
    let acceptor = TlsAcceptor::from(tls_config);
    // Pre-build BOTH scheme-tagged services ONCE. Router::layer rebuilds the
    // route tree — doing that per accepted connection taxed every request
    // (Lighthouse perf 85→76 in CI caught it). Cloning a built Router is
    // cheap (Arc-backed); per connection we only clone.
    let http_app = app.clone().layer(Extension(ConnScheme { https: false }));
    let tls_app = app.layer(Extension(ConnScheme { https: true }));
    tokio::pin!(shutdown);
    loop {
        tokio::select! {
            biased;
            _ = &mut shutdown => {
                // Exit now. In-flight connections (including never-ending SSE
                // streams) are dropped when the process exits — waiting for an
                // SSE stream to "finish" is the documented shutdown hang.
                tracing::info!("shutdown signal — closing listener");
                break;
            }
            accepted = listener.accept() => {
                let (stream, peer) = match accepted {
                    Ok(x) => x,
                    Err(e) => { tracing::debug!("accept error: {}", e); continue; }
                };
                let acceptor = acceptor.clone();
                let http_app = http_app.clone();
                let tls_app = tls_app.clone();
                tokio::spawn(async move {
                    let mut first = [0u8; 1];
                    let n = match stream.peek(&mut first).await {
                        Ok(n) => n,
                        Err(e) => {
                            tracing::debug!("peek {}: {}", peer, e);
                            return;
                        }
                    };
                    let is_tls = n == 1 && first[0] == 0x16;
                    let svc = TowerToHyperService::new(if is_tls { tls_app } else { http_app });
                    if is_tls {
                        match acceptor.accept(stream).await {
                            Ok(tls_stream) => {
                                if let Err(e) = AutoBuilder::new(TokioExecutor::new())
                                    .serve_connection_with_upgrades(TokioIo::new(tls_stream), svc)
                                    .await
                                {
                                    tracing::debug!("tls conn {}: {}", peer, e);
                                }
                            }
                            Err(e) => tracing::debug!("tls handshake {}: {}", peer, e),
                        }
                    } else if let Err(e) = AutoBuilder::new(TokioExecutor::new())
                        .serve_connection_with_upgrades(TokioIo::new(stream), svc)
                        .await
                    {
                        tracing::debug!("http conn {}: {}", peer, e);
                    }
                });
            }
        }
    }
}
