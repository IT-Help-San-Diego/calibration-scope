//! Witness Artifact Generator (DECISIONS §15, handoff Oscent item 2).
//!
//! GET /api/runs/{id}/witness — a sealed, self-verifying certificate for one
//! run: a single self-contained HTML file whose body is one inline SVG.
//! Zero JS, zero external resources, no <style> element; the ONLY style
//! attributes are two layout shims (body margin/background, svg sizing) —
//! everything inside the SVG is presentation attributes, so it renders
//! identically under any CSP, from file://, or pasted into a mail. Dark scotopic
//! palette, golden-ratio construction (portrait: 1000×1618, section at
//! y=618, Fibonacci spacing 13/21/34/55/89 — self-described in the footer
//! so the claim is verifiable on sight).
//!
//! A certificate DEMONSTRATES; it does not rank. No witness without a seal:
//! unsealed or unfinished runs get an honest refusal, not a mock-up.
//! `channel` is DERIVED from the model's location/provider and labeled as
//! derived — the schema's channel column is §14 design, not yet built.
use axum::extract::{Path, State};
use axum::response::{Html, IntoResponse, Json};

use crate::error::AppResult;
use crate::state::AppState;

#[derive(sqlx::FromRow)]
struct WitnessRow {
    id: i32,
    key: String,
    provider: String,
    location: String,
    axis: String,
    status: String,
    pass_count: i32,
    total_count: i32,
    load_mode: Option<String>,
    sha3_provenance: Option<String>,
    started_at: Option<chrono::NaiveDateTime>,
    finished_at: Option<chrono::NaiveDateTime>,
}

/// XML-escape for text nodes and attribute values in the SVG.
fn esc(s: &str) -> String {
    s.replace('&', "&amp;")
        .replace('<', "&lt;")
        .replace('>', "&gt;")
        .replace('"', "&quot;")
        .replace('\'', "&apos;")
}

/// Truncate display strings so a hostile model key cannot distort the grid.
fn clip(s: &str, max: usize) -> String {
    if s.chars().count() <= max {
        s.to_string()
    } else {
        let head: String = s.chars().take(max.saturating_sub(1)).collect();
        format!("{head}…")
    }
}

/// The certificate body. Pure function of the row — unit-tested below.
fn render_certificate(r: &WitnessRow, seal: &str) -> String {
    let subject = clip(&r.key, 44);
    let passed = r.pass_count;
    let total = r.total_count;
    let channel = if r.location == "local" {
        format!("local API via {}", r.provider)
    } else {
        format!("cloud API via {}", r.provider)
    };
    let load_mode = r.load_mode.as_deref().unwrap_or("clean-room");
    // started_at is stamped when execution actually begins (executor sets it
    // with status='loading') — created_at would misstate queue time as start.
    let started = r
        .started_at
        .map(|t| t.format("%Y-%m-%d %H:%M UTC").to_string())
        .unwrap_or_else(|| "—".to_string());
    let finished = r
        .finished_at
        .map(|t| t.format("%Y-%m-%d %H:%M UTC").to_string())
        .unwrap_or_else(|| "—".to_string());
    // Seal wrapped into fixed-width mono lines so the full value is visible.
    let seal_lines: Vec<String> = seal
        .chars()
        .collect::<Vec<_>>()
        .chunks(66)
        .map(|c| c.iter().collect())
        .collect();
    let seal_svg: String = seal_lines
        .iter()
        .enumerate()
        .map(|(i, line)| {
            format!(
                r##"<text x="89" y="{}" font-size="13" fill="#e0e0e0" font-family="ui-monospace, Menlo, monospace">{}</text>"##,
                1258 + i * 24,
                esc(line)
            )
        })
        .collect();
    let row = |i: usize, label: &str, value: &str| -> String {
        let y = 733 + i * 55;
        format!(
            concat!(
                r##"<text x="89" y="{y}" font-size="13" fill="#7d8590" font-family="ui-monospace, Menlo, monospace" letter-spacing="1">{label}</text>"##,
                r##"<text x="340" y="{y}" font-size="17" fill="#e0e0e0" font-family="ui-monospace, Menlo, monospace">{value}</text>"##
            ),
            y = y,
            label = label,
            value = esc(value)
        )
    };
    let rows: String = [
        ("RUN", format!("#{}", r.id)),
        ("SUBJECT", subject.clone()),
        ("BATTERY", format!("{} axis", r.axis)),
        ("RESULT", format!("{passed} of {total} trials passed")),
        ("LOAD MODE", load_mode.to_string()),
        (
            "CHANNEL",
            format!("{channel} (derived — channel column pending §14)"),
        ),
        ("STARTED", started),
        ("SEALED", finished),
    ]
    .iter()
    .enumerate()
    .map(|(i, (l, v))| row(i, l, v))
    .collect();

    format!(
        r##"<!DOCTYPE html>
<html lang="en"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Witness — run #{id} · Calibration Scope</title></head>
<body style="margin:0;background:#0a0a0a">
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1000 1618" role="img"
     aria-label="Sealed witness certificate for run {id}: {subject_esc}, {passed} of {total} trials passed on the {axis_esc} battery"
     font-family="ui-monospace, Menlo, Consolas, monospace" style="display:block;max-width:1000px;margin:0 auto;width:100%;height:auto">
  <rect x="0" y="0" width="1000" height="1618" fill="#0a0a0a"/>
  <rect x="21" y="21" width="958" height="1576" fill="none" stroke="#2b3143" stroke-width="1.5" rx="8"/>
  <!-- Owl mark: geometric, self-contained (the 411KB raster logo would break
       the lo-fi certificate; this is the mark, not the full seal art). -->
  <g stroke="#d4a853" stroke-width="3" fill="none">
    <circle cx="500" cy="144" r="55"/>
    <circle cx="479" cy="136" r="13"/>
    <circle cx="521" cy="136" r="13"/>
    <path d="M 466 118 Q 479 108 492 116"/>
    <path d="M 508 116 Q 521 108 534 118"/>
    <path d="M 494 158 L 500 166 L 506 158"/>
  </g>
  <text x="500" y="262" font-size="55" font-weight="700" fill="#e0e0e0" text-anchor="middle" letter-spacing="8">WITNESS</text>
  <text x="500" y="303" font-size="17" fill="#7d8590" text-anchor="middle">Calibration Scope — a sealed measurement, verifiable by anyone</text>
  <text x="500" y="440" font-size="34" fill="#e0e0e0" text-anchor="middle">{subject_esc}</text>
  <text x="500" y="487" font-size="21" fill="#a0a0a0" text-anchor="middle">passed {passed} of {total} trials on the {axis_esc} battery</text>
  <text x="500" y="521" font-size="14" fill="#7d8590" text-anchor="middle">one run, counts shown raw — a certificate demonstrates; it does not rank</text>
  <line x1="89" y1="618" x2="911" y2="618" stroke="#2b3143" stroke-width="1.5"/>
  <text x="911" y="605" font-size="13" fill="#7d8590" text-anchor="end">φ — 1618 = 1000 + 618</text>
  <text x="89" y="680" font-size="15" fill="#d4a853" letter-spacing="2">THE MEASUREMENT</text>
  {rows}
  <text x="89" y="1225" font-size="15" fill="#d4a853" letter-spacing="2">SHA3-512 SEAL</text>
  {seal_svg}
  <line x1="89" y1="1382" x2="911" y2="1382" stroke="#2b3143" stroke-width="1.5"/>
  <text x="89" y="1428" font-size="15" fill="#d4a853">VERIFY THIS SEAL AGAINST THE INSTRUMENT</text>
  <text x="89" y="1458" font-size="14" fill="#a0a0a0">Export the run's evidence bundle — GET /api/runs/{id}/export on the instrument that</text>
  <text x="89" y="1482" font-size="14" fill="#a0a0a0">sealed it — and recompute. The seal above must match. No trust required.</text>
  <text x="89" y="1546" font-size="12" fill="#7d8590">Golden-ratio construction: 1000×1618 canvas, section at y=618 (1618 = 1000 + 618), Fibonacci spacing 13·21·34·55·89.</text>
  <text x="89" y="1572" font-size="12" fill="#7d8590">Zero JS · no external resources · the SVG uses presentation attributes only — this file is complete as it stands.</text>
</svg>
</body></html>
"##,
        id = r.id,
        subject_esc = esc(&subject),
        axis_esc = esc(&r.axis),
        passed = passed,
        total = total,
        rows = rows,
        seal_svg = seal_svg,
    )
}

pub async fn run_witness(
    State(state): State<AppState>,
    Path(run_id): Path<i32>,
) -> AppResult<axum::response::Response> {
    let row: Option<WitnessRow> = sqlx::query_as(
        r#"SELECT r.id, m.key, m.provider, m.location, r.axis, r.status,
                  r.pass_count, r.total_count, r.load_mode, r.sha3_provenance,
                  r.started_at, r.finished_at
           FROM test_runs r JOIN models m ON m.id = r.model_id
           WHERE r.id = $1"#,
    )
    .bind(run_id)
    .fetch_optional(&state.db)
    .await?;
    let Some(row) = row else {
        return Ok(
            Json(serde_json::json!({ "error": format!("No run with id {run_id}") }))
                .into_response(),
        );
    };
    // No witness without a seal — an unsealed certificate would be theater.
    let Some(seal) = row.sha3_provenance.clone().filter(|s| !s.is_empty()) else {
        return Ok(Json(serde_json::json!({
            "error": format!(
                "Run {} is not sealed (status: {}) — no witness without a seal",
                run_id, row.status
            )
        }))
        .into_response());
    };
    Ok(Html(render_certificate(&row, &seal)).into_response())
}

#[cfg(test)]
mod tests {
    use super::*;

    fn fixture() -> WitnessRow {
        WitnessRow {
            id: 953,
            key: "google/gemma-4-31b".into(),
            provider: "lmstudio".into(),
            location: "local".into(),
            axis: "reasoning".into(),
            status: "finished".into(),
            pass_count: 189,
            total_count: 192,
            load_mode: Some("clean-room".into()),
            sha3_provenance: Some(format!("sha3-512:{}", "ab".repeat(64))),
            started_at: Some(
                chrono::NaiveDateTime::parse_from_str("2026-07-26 06:00:00", "%Y-%m-%d %H:%M:%S")
                    .unwrap(),
            ),
            finished_at: None,
        }
    }

    #[test]
    fn certificate_contains_the_measurement_and_the_full_seal() {
        let r = fixture();
        let seal = r.sha3_provenance.clone().unwrap();
        let html = render_certificate(&r, &seal);
        assert!(html.contains("google/gemma-4-31b"));
        assert!(html.contains("passed 189 of 192 trials"));
        // Every 66-char chunk of the seal must appear verbatim — the full
        // value is on the certificate, merely wrapped.
        let chunks: Vec<String> = seal
            .chars()
            .collect::<Vec<_>>()
            .chunks(66)
            .map(|c| c.iter().collect())
            .collect();
        assert!(chunks.len() >= 2);
        for chunk in &chunks {
            assert!(html.contains(chunk.as_str()), "missing seal chunk {chunk}");
        }
        assert!(!html.contains("<script"));
        // Self-containment: only the two sizing style attrs on body/svg.
        assert!(html.matches("style=\"").count() <= 2);
    }

    #[test]
    fn hostile_model_key_is_escaped_and_clipped() {
        let mut r = fixture();
        r.key = format!("<script>alert(1)</script>{}", "x".repeat(100));
        let html = render_certificate(&r, "sha3-512:deadbeef");
        assert!(!html.contains("<script>alert"));
        assert!(html.contains("&lt;script&gt;"));
    }

    #[test]
    fn write_sample_for_browser_inspection() {
        // Not an assertion test: emits a sample artifact so the certificate
        // can be opened in a real browser during development/CI artifact
        // review. Writes into target/, never the repo tree.
        let r = fixture();
        let seal = r.sha3_provenance.clone().unwrap();
        let out = std::path::Path::new(env!("CARGO_MANIFEST_DIR"))
            .join("target")
            .join("witness-sample.html");
        let _ = std::fs::write(out, render_certificate(&r, &seal));
    }
}
