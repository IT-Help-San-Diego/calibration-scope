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
//!
//! v2 (2026-07-27, design constraint from Claude Science): claim status is
//! shown BY CLAIM ID, never prose restatement — a second SVG below the
//! certificate lists every claim as `#test_id  name  k/n`, keyed on test_id
//! (the binding key; names are labels and are not unique). Human-participant
//! runs (model_id NULL, participant_id set) now get a certificate too — the
//! old INNER JOIN made the instrument claim "no run exists" about runs that
//! exist, which is exactly the kind of false statement this page exists to
//! prevent.
use axum::extract::{Path, State};
use axum::http::StatusCode;
use axum::response::{Html, IntoResponse};

use crate::error::AppResult;
use crate::state::AppState;

#[derive(sqlx::FromRow)]
struct WitnessRow {
    id: i32,
    key: Option<String>,
    provider: Option<String>,
    location: Option<String>,
    participant: Option<String>,
    axis: String,
    status: String,
    pass_count: i32,
    total_count: i32,
    load_mode: Option<String>,
    sha3_provenance: Option<String>,
    started_at: Option<chrono::NaiveDateTime>,
    finished_at: Option<chrono::NaiveDateTime>,
}

/// One ledger row: the claim id and its raw pass count. `name` is a label;
/// test_id is the key (64 ids vs 63 names in the live bank — names collide).
/// test_id is None for trials recorded before migration 021 linked trials to
/// tests — those group into one "unlinked" line that is honestly NOT one
/// claim, rather than being silently dropped.
#[derive(sqlx::FromRow)]
struct ClaimRow {
    test_id: Option<i32>,
    name: Option<String>,
    k: i32,
    n: i32,
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
fn render_certificate(r: &WitnessRow, seal: &str, claims: &[ClaimRow]) -> String {
    let is_human = r.participant.is_some();
    let subject = clip(
        r.participant
            .as_deref()
            .or(r.key.as_deref())
            .unwrap_or("(subject unrecorded)"),
        44,
    );
    let passed = r.pass_count;
    let total = r.total_count;
    let kind = if is_human {
        "carbon — human participant".to_string()
    } else {
        "silicon — model".to_string()
    };
    let channel = if is_human {
        "dashboard quiz — same items, same grader as model runs".to_string()
    } else {
        let provider = r.provider.as_deref().unwrap_or("?");
        let base = if r.location.as_deref() == Some("local") {
            format!("local API via {provider}")
        } else {
            format!("cloud API via {provider}")
        };
        format!("{base} (derived — channel column pending §14)")
    };
    // Humans have no load mode — showing "clean-room" would claim a control
    // that does not apply to a person at a keyboard.
    let load_mode = if is_human {
        "— (not applicable to a human subject)"
    } else {
        r.load_mode.as_deref().unwrap_or("clean-room")
    };
    // started_at is stamped when execution actually begins (executor sets it
    // with status='loading') — created_at would misstate queue time as start.
    let started = r
        .started_at
        .map(|t| t.format("%Y-%m-%d %H:%M").to_string())
        .unwrap_or_else(|| "—".to_string());
    let finished = r
        .finished_at
        .map(|t| t.format("%Y-%m-%d %H:%M").to_string())
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
        ("SUBJECT KIND", kind),
        ("BATTERY", format!("{} axis", r.axis)),
        ("RESULT", format!("{passed} of {total} trials passed")),
        ("LOAD MODE", load_mode.to_string()),
        ("CHANNEL", channel),
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
{ledger}</body></html>
"##,
        id = r.id,
        subject_esc = esc(&subject),
        axis_esc = esc(&r.axis),
        passed = passed,
        total = total,
        rows = rows,
        seal_svg = seal_svg,
        ledger = render_ledger(r.id, claims, r.total_count),
    )
}

/// The claim ledger: a second SVG below the certificate, one row per claim,
/// keyed by test_id — never prose restatement (design constraint from Claude
/// Science, 2026-07-27). Column-major, three columns, height computed from
/// the claim count so a 293-item battery and a 3-item human session both
/// render completely. Same discipline as the certificate: presentation
/// attributes only, one sizing style attr on the svg element.
fn render_ledger(run_id: i32, claims: &[ClaimRow], sealed_total: i32) -> String {
    if claims.is_empty() {
        return format!(
            r##"<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1000 200" role="img"
     aria-label="Claim ledger for run {run_id}: no non-infra trial rows recorded"
     font-family="ui-monospace, Menlo, Consolas, monospace" style="display:block;max-width:1000px;margin:0 auto;width:100%;height:auto">
  <rect x="0" y="0" width="1000" height="200" fill="#0a0a0a"/>
  <rect x="21" y="13" width="958" height="166" fill="none" stroke="#2b3143" stroke-width="1.5" rx="8"/>
  <text x="89" y="89" font-size="15" fill="#d4a853" letter-spacing="2">CLAIM LEDGER</text>
  <text x="89" y="123" font-size="14" fill="#a0a0a0">No non-infra trial rows are recorded for this run — nothing to itemize.</text>
</svg>
"##
        );
    }
    // The header counts CLAIMS — the synthetic unlinked-trials line is
    // explicitly not one, so it is named separately, not folded in (review
    // catch: "N CLAIMS" was counting rendered rows).
    let claim_count = claims.iter().filter(|c| c.test_id.is_some()).count();
    let has_unlinked = claims.iter().any(|c| c.test_id.is_none());
    let header_suffix = if has_unlinked {
        " + UNLINKED TRIALS"
    } else {
        ""
    };
    let aria_unlinked = if has_unlinked {
        ", plus one line pooling trials with no test link"
    } else {
        ""
    };
    // The certificate's RESULT uses the counts stored at seal time; the
    // ledger recomputes live with the current infra-exclusion rule. Runs
    // sealed under the pre-2026-07-08 convention (infra trials in the
    // denominator, never backfilled) or runs a trial slipped into after
    // sealing will disagree — shown, not hidden.
    let ledger_total: i32 = claims.iter().map(|c| c.n).sum();
    // Two pre-wrapped lines — a single line overflows the 1000-wide viewBox
    // at 12px mono (caught on the rendered screenshot, not in the tests).
    let mismatch = if ledger_total != sealed_total {
        Some((
            format!(
                "This ledger sums {ledger_total} non-infra trials; the sealed RESULT above counts {sealed_total}."
            ),
            "The delta is infra-error trials included by an older sealing convention, or rows recorded outside the seal — shown, not hidden."
                .to_string(),
        ))
    } else {
        None
    };
    let per_col = claims.len().div_ceil(3);
    // Rows start at y=144; the footer zone is the last 76px (118px when the
    // two mismatch-note lines are present). The unit test asserts the last
    // row lands strictly above it for a 293-claim battery.
    let height = 144 + per_col * 21 + 76 + if mismatch.is_some() { 42 } else { 0 };
    let rows_svg: String = claims
        .iter()
        .enumerate()
        .map(|(i, c)| {
            let col = i / per_col;
            let idx = i % per_col;
            // Columns at 55/370/685; values end-anchored at x0+276, so the
            // rightmost column ends at x=961 — 18px inside the border rect
            // edge (x=979). The left margin is the Fibonacci 34 (55−21).
            let x0 = 55 + col * 315;
            let y = 144 + idx * 21;
            let (id_label, name, val_fill) = match c.test_id {
                Some(id) => (
                    format!("#{id}"),
                    clip(c.name.as_deref().unwrap_or("(unnamed)"), 18),
                    // Perfect rows in the body color; anything less in gold —
                    // the eye finds the misses without editorializing.
                    if c.k == c.n { "#e0e0e0" } else { "#d4a853" },
                ),
                // Pre-migration-021 trials carry no test link. One gray line,
                // never colored like a claim verdict — it is not one claim.
                None => ("#—".to_string(), "(unlinked trials)".to_string(), "#7d8590"),
            };
            format!(
                concat!(
                    r##"<text x="{x_id}" y="{y}" font-size="13" fill="#7d8590">{id_label}</text>"##,
                    r##"<text x="{x_name}" y="{y}" font-size="13" fill="#a0a0a0">{name}</text>"##,
                    r##"<text x="{x_val}" y="{y}" font-size="13" fill="{val_fill}" text-anchor="end">{k}/{n}</text>"##
                ),
                x_id = x0,
                x_name = x0 + 55,
                x_val = x0 + 276,
                y = y,
                id_label = id_label,
                name = esc(&name),
                val_fill = val_fill,
                k = c.k,
                n = c.n,
            )
        })
        .collect();
    let mismatch_svg = mismatch
        .map(|(l1, l2)| {
            format!(
                concat!(
                    r##"<text x="89" y="{y1}" font-size="12" fill="#d4a853">{l1}</text>"##,
                    r##"<text x="89" y="{y2}" font-size="12" fill="#d4a853">{l2}</text>"##
                ),
                y1 = height - 76,
                y2 = height - 55,
                l1 = esc(&l1),
                l2 = esc(&l2),
            )
        })
        .unwrap_or_default();
    format!(
        r##"<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1000 {height}" role="img"
     aria-label="Claim ledger for run {run_id}: per-claim pass counts for {count} claims, keyed by test id{aria_unlinked}"
     font-family="ui-monospace, Menlo, Consolas, monospace" style="display:block;max-width:1000px;margin:0 auto;width:100%;height:auto">
  <rect x="0" y="0" width="1000" height="{height}" fill="#0a0a0a"/>
  <rect x="21" y="13" width="958" height="{box_h}" fill="none" stroke="#2b3143" stroke-width="1.5" rx="8"/>
  <text x="89" y="76" font-size="15" fill="#d4a853" letter-spacing="2">CLAIM LEDGER — {count} CLAIMS{header_suffix}</text>
  <text x="89" y="102" font-size="12" fill="#7d8590">one row per claim, keyed by test_id (names are labels; the id is the key) · k/n = passes/trials, counts raw</text>
  {rows_svg}
  {mismatch_svg}
  <text x="89" y="{foot_y}" font-size="12" fill="#7d8590">Every claim in the sealed run is listed — no selection, no summary standing in for the itemization.</text>
</svg>
"##,
        run_id = run_id,
        count = claim_count,
        header_suffix = header_suffix,
        aria_unlinked = aria_unlinked,
        height = height,
        box_h = height - 34,
        rows_svg = rows_svg,
        mismatch_svg = mismatch_svg,
        foot_y = height - 34,
    )
}

/// A refusal is a first-class output, not an error dump: the Witness link
/// opens in a browser tab, so the refusal must be a readable page in the
/// certificate's own voice — with an honest status code.
fn refusal_page(title: &str, detail: &str, next_action: &str) -> String {
    format!(
        r##"<!DOCTYPE html>
<html lang="en"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>{title_esc} · Calibration Scope</title></head>
<body style="margin:0;background:#0a0a0a">
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1000 400" role="img"
     aria-label="{title_esc}: {detail_esc}"
     font-family="ui-monospace, Menlo, Consolas, monospace" style="display:block;max-width:1000px;margin:0 auto;width:100%;height:auto">
  <rect x="0" y="0" width="1000" height="400" fill="#0a0a0a"/>
  <rect x="21" y="21" width="958" height="358" fill="none" stroke="#2b3143" stroke-width="1.5" rx="8"/>
  <text x="89" y="123" font-size="34" font-weight="700" fill="#e0e0e0" letter-spacing="3">{title_esc}</text>
  <text x="89" y="187" font-size="17" fill="#a0a0a0">{detail_esc}</text>
  <text x="89" y="242" font-size="15" fill="#d4a853">{next_esc}</text>
  <text x="89" y="331" font-size="12" fill="#7d8590">A certificate demonstrates; it does not pretend. Refusals are part of the instrument.</text>
</svg>
</body></html>
"##,
        title_esc = esc(title),
        detail_esc = esc(detail),
        next_esc = esc(next_action),
    )
}

pub async fn run_witness(
    State(state): State<AppState>,
    Path(run_id): Path<i32>,
) -> AppResult<axum::response::Response> {
    // LEFT JOINs: a human-participant run has model_id NULL, and the old
    // INNER JOIN made this endpoint answer "no run exists" about runs that
    // exist — a false statement from the page whose job is not making them.
    let row: Option<WitnessRow> = sqlx::query_as(
        r#"SELECT r.id, m.key, m.provider, m.location,
                  p.display_name AS participant, r.axis, r.status,
                  r.pass_count, r.total_count, r.load_mode, r.sha3_provenance,
                  r.started_at, r.finished_at
           FROM test_runs r
           LEFT JOIN models m ON m.id = r.model_id
           LEFT JOIN participants p ON p.id = r.participant_id
           WHERE r.id = $1"#,
    )
    .bind(run_id)
    .fetch_optional(&state.db)
    .await?;
    let Some(row) = row else {
        return Ok((
            StatusCode::NOT_FOUND,
            Html(refusal_page(
                "NO SUCH RUN",
                &format!("No run with id {run_id} exists on this instrument."),
                "Check the run id on the Runs page.",
            )),
        )
            .into_response());
    };
    // No witness without a seal — an unsealed certificate would be theater.
    let Some(seal) = row.sha3_provenance.clone().filter(|s| !s.is_empty()) else {
        return Ok((
            StatusCode::CONFLICT,
            Html(refusal_page(
                "NO WITNESS WITHOUT A SEAL",
                &format!("Run {} is not sealed (status: {}).", run_id, row.status),
                "Wait for the run to finish and seal, then reopen this link.",
            )),
        )
            .into_response());
    };
    // The claim ledger: raw per-claim counts, infra errors excluded (same
    // rule the seal itself uses), ordered by the binding key.
    let claims: Vec<ClaimRow> = sqlx::query_as(
        r#"SELECT tr.test_id, t.name,
                  COUNT(*) FILTER (WHERE tr.passed)::int AS k,
                  COUNT(*)::int AS n
           FROM trial_results tr
           LEFT JOIN tests t ON t.id = tr.test_id
           WHERE tr.run_id = $1 AND tr.is_infra_error = false
           GROUP BY tr.test_id, t.name
           ORDER BY tr.test_id NULLS LAST"#,
    )
    .bind(run_id)
    .fetch_all(&state.db)
    .await?;
    Ok(Html(render_certificate(&row, &seal, &claims)).into_response())
}

#[cfg(test)]
mod tests {
    use super::*;

    fn fixture() -> WitnessRow {
        WitnessRow {
            id: 953,
            key: Some("google/gemma-4-31b".into()),
            provider: Some("lmstudio".into()),
            location: Some("local".into()),
            participant: None,
            axis: "reasoning".into(),
            status: "done".into(),
            pass_count: 189,
            total_count: 192,
            load_mode: Some("clean-room".into()),
            sha3_provenance: Some(format!("sha3-512:{}", "ab".repeat(64))),
            started_at: Some(
                chrono::NaiveDateTime::parse_from_str("2026-07-26 06:00:00", "%Y-%m-%d %H:%M:%S")
                    .unwrap(),
            ),
            finished_at: Some(
                chrono::NaiveDateTime::parse_from_str("2026-07-26 07:12:00", "%Y-%m-%d %H:%M:%S")
                    .unwrap(),
            ),
        }
    }

    fn human_fixture() -> WitnessRow {
        let mut r = fixture();
        r.key = None;
        r.provider = None;
        r.location = None;
        r.participant = Some("Carey B.".into());
        r.load_mode = None;
        r.pass_count = 4;
        r.total_count = 6;
        r
    }

    fn claims_fixture() -> Vec<ClaimRow> {
        vec![
            ClaimRow {
                test_id: Some(26),
                name: Some("LOGIC-01".into()),
                k: 3,
                n: 3,
            },
            ClaimRow {
                test_id: Some(61),
                name: Some("LOGIC-01N".into()),
                k: 2,
                n: 3,
            },
            ClaimRow {
                test_id: Some(27),
                name: Some("LOGIC-02".into()),
                k: 0,
                n: 3,
            },
        ]
    }

    #[test]
    fn certificate_contains_the_measurement_and_the_full_seal() {
        let r = fixture();
        let seal = r.sha3_provenance.clone().unwrap();
        let html = render_certificate(&r, &seal, &claims_fixture());
        assert!(html.contains("google/gemma-4-31b"));
        assert!(html.contains("passed 189 of 192 trials"));
        assert!(html.contains("silicon — model"));
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
        // Self-containment: three sizing style attrs (body, certificate svg,
        // ledger svg) — nothing else.
        assert!(html.matches("style=\"").count() <= 3);
    }

    #[test]
    fn ledger_lists_every_claim_by_id_with_raw_counts() {
        // Σn = 9 and sealed_total = 9 agree — no mismatch note.
        let html = render_ledger(953, &claims_fixture(), 9);
        assert!(html.contains("CLAIM LEDGER — 3 CLAIMS<"));
        assert!(!html.contains("older sealing convention"));
        for (id, kn) in [(26, "3/3"), (61, "2/3"), (27, "0/3")] {
            assert!(html.contains(&format!("#{id}")), "missing claim id {id}");
            assert!(html.contains(kn), "missing count {kn}");
        }
        // Keyed by id, names as labels — both present, and imperfect rows
        // are gold while perfect rows are body-colored.
        assert!(html.contains("LOGIC-01N"));
        assert!(html.contains("keyed by test_id"));
        assert!(html.contains(r##"fill="#d4a853" text-anchor="end">2/3"##));
        assert!(html.contains(r##"fill="#e0e0e0" text-anchor="end">3/3"##));
    }

    #[test]
    fn ledger_scales_to_a_full_battery_without_overlap() {
        // 293 claims — the real full-battery size. Column-major over three
        // columns: every row must sit inside the computed viewBox.
        let claims: Vec<ClaimRow> = (1..=293)
            .map(|i| ClaimRow {
                test_id: Some(i),
                name: Some(format!("TEST-{i:03}")),
                k: 3,
                n: 3,
            })
            .collect();
        let html = render_ledger(999, &claims, 879);
        let per_col = 293usize.div_ceil(3); // 98
        let height = 144 + per_col * 21 + 76;
        assert!(html.contains(&format!(r#"viewBox="0 0 1000 {height}""#)));
        let last_y = 144 + (per_col - 1) * 21;
        assert!(last_y < height - 76, "rows overflow the footer zone");
        assert!(html.contains("#1<") || html.contains("#1</text>"));
        assert!(html.contains("#293"));
    }

    #[test]
    fn ledger_handles_empty_and_unlinked_honestly() {
        let empty = render_ledger(7, &[], 0);
        assert!(empty.contains("No non-infra trial rows are recorded"));
        // The aria-label must carry the same "non-infra" qualifier as the
        // visible copy — a run of only infra-error trials has trial rows.
        assert!(empty.contains("no non-infra trial rows recorded"));
        let unlinked = render_ledger(
            7,
            &[ClaimRow {
                test_id: None,
                name: None,
                k: 5,
                n: 9,
            }],
            9,
        );
        assert!(unlinked.contains("(unlinked trials)"));
        assert!(unlinked.contains("5/9"));
        // Never colored like a claim verdict — it is not one claim, and the
        // header must not count it as one either.
        assert!(!unlinked.contains(r##"fill="#e0e0e0" text-anchor="end">5/9"##));
        assert!(unlinked.contains("CLAIM LEDGER — 0 CLAIMS + UNLINKED TRIALS"));
        assert!(unlinked.contains("pooling trials with no test link"));
    }

    #[test]
    fn ledger_shows_seal_mismatch_instead_of_hiding_it() {
        // Σn = 9 but the stored seal says 12 (e.g. pre-017 infra inclusion):
        // the delta is stated on the artifact, in gold, not silently absorbed.
        let html = render_ledger(953, &claims_fixture(), 12);
        assert!(html.contains("sums 9 non-infra trials"));
        assert!(html.contains("counts 12"));
        assert!(html.contains("shown, not hidden"));
        // And the viewBox grew by two lines to hold it.
        let height = 144 + 21 + 76 + 42;
        assert!(html.contains(&format!(r#"viewBox="0 0 1000 {height}""#)));
    }

    #[test]
    fn human_run_gets_a_carbon_certificate_not_a_false_404() {
        let r = human_fixture();
        let html = render_certificate(&r, "sha3-512:deadbeef", &claims_fixture());
        assert!(html.contains("Carey B."));
        assert!(html.contains("carbon — human participant"));
        assert!(html.contains("same items, same grader as model runs"));
        // No load-mode claim for a human, and no derived model channel.
        assert!(html.contains("not applicable to a human subject"));
        assert!(!html.contains("clean-room"));
        assert!(!html.contains("local API"));
    }

    #[test]
    fn hostile_test_name_in_ledger_is_escaped() {
        let html = render_ledger(
            1,
            &[ClaimRow {
                test_id: Some(1),
                name: Some("<script>x</script>".into()),
                k: 1,
                n: 1,
            }],
            1,
        );
        assert!(!html.contains("<script>x"));
        assert!(html.contains("&lt;script&gt;"));
    }

    #[test]
    fn refusal_page_escapes_its_inputs() {
        let html = refusal_page("T", "status: <script>x</script>", "next");
        assert!(!html.contains("<script>x"));
        assert!(html.contains("&lt;script&gt;"));
        assert!(!html.contains("{\""));
    }

    #[test]
    fn hostile_model_key_is_escaped_and_clipped() {
        let mut r = fixture();
        r.key = Some(format!("<script>alert(1)</script>{}", "x".repeat(100)));
        let html = render_certificate(&r, "sha3-512:deadbeef", &[]);
        assert!(!html.contains("<script>alert"));
        assert!(html.contains("&lt;script&gt;"));
    }

    #[test]
    #[ignore = "development aid, not an assertion: run explicitly with --ignored to emit target/witness-sample.html"]
    fn write_sample_for_browser_inspection() {
        // Not an assertion test: emits a sample artifact so the certificate
        // can be opened in a real browser during development/CI artifact
        // review. Writes into target/, never the repo tree.
        let r = fixture();
        let seal = r.sha3_provenance.clone().unwrap();
        let target = std::path::Path::new(env!("CARGO_MANIFEST_DIR")).join("target");
        // Model run with a mixed ledger, and a human run — both artifacts.
        let mut claims = claims_fixture();
        claims.extend((100..=150).map(|i| ClaimRow {
            test_id: Some(i),
            name: Some(format!("LOGIC-{:02}X", i - 99)),
            k: if i % 7 == 0 { 2 } else { 3 },
            n: 3,
        }));
        let _ = std::fs::write(
            target.join("witness-sample.html"),
            render_certificate(&r, &seal, &claims),
        );
        let human_claims = vec![
            ClaimRow {
                test_id: Some(26),
                name: Some("LOGIC-01".into()),
                k: 1,
                n: 2,
            },
            ClaimRow {
                test_id: Some(61),
                name: Some("LOGIC-01N".into()),
                k: 2,
                n: 2,
            },
            ClaimRow {
                test_id: Some(27),
                name: Some("LOGIC-02".into()),
                k: 1,
                n: 2,
            },
        ];
        let _ = std::fs::write(
            target.join("witness-sample-human.html"),
            render_certificate(&human_fixture(), &seal, &human_claims),
        );
    }
}
