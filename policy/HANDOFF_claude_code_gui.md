# HANDOFF to Claude Code — GUI/UX lane (updated 2026-07-26)

Your lane is frontend/UX across BOTH surfaces: the local dashboard
(127.0.0.1:8768) and the public site (calibrationscope.com). State is current
as of commit eef6d20+ and the Safari white-page fix (upgrade-insecure-requests
removed from the LOCAL CSP only — see "Hard-won lessons" below before you
touch any CSP).

Read `policy/EPISTEMIC_LOG_POLICY.md` first — it governs how you log any
re-runs or data changes you make.

## Gate rules (hard, do not skip)

- **Zero executable JS on the public site.** script-src 'none'. The only
  allowed exception is application/ld+json data blocks.
- **style-src hash rule (public site).** The CloudFront CSP carries BOTH
  pages' style hashes ('self' + sha256 of each page's <style> block).
  Recompute on EVERY CSS change or the page blanks. Policy id
  42a28561-ee87-4c3a-8621-94187ee9e22e.
- **CSP is different per surface — and on the LOCAL surface, per CONNECTION**
  (updated 2026-07-22, local HTTPS shipped). Public site = full hardening incl.
  upgrade-insecure-requests (correct — real TLS). Local dashboard now speaks
  BOTH protocols on one port (first-byte peek → rustls or plain HTTP):
  upgrade-insecure-requests is emitted ONLY on TLS connections
  (security.rs::csp takes an `https` flag from the per-connection ConnScheme
  extension). On a plain-HTTP connection the directive would command Safari to
  refetch assets over TLS the client may not trust — the white-page bug. Do
  NOT make it unconditional in either direction, and do NOT copy a CSP
  between surfaces blindly.
- **Verify in the live browser, not by curl.** Firefox MCP
  (mcp__firefox_devtools__*) is the instrument: navigate, evaluate_script for
  computed sizes + sheetCount, list_console_messages. The
  browser-console-preflight skill is mandatory before any HTML/CSS edit.
- **No spinners.** Every loading state shows real data or nothing.
- **Lighthouse ≥ 91 perf / 100 a11y / 100 bp / 100 seo** (desktop preset)
  on the public site; 90/98/100/91 on the dashboard.
- **Accessibility is the default.** Readable/High-contrast is ON first visit.
- Commit + push immediately after each verified change (cross-agent record
  duty: whichever agent does the work updates DECISIONS.md itself).

## Hard-won lessons (read before you debug)

1. **The Safari white page was NOT bfcache, caching, nonce mismatch, or a JS
   bug.** It was `upgrade-insecure-requests` in the LOCAL dashboard's CSP.
   Safari honors it: it upgraded its own subresource URLs
   (`/assets/app.min.css` → `https://127.0.0.1:8768/...`) and died because
   nothing on 8768 speaks TLS. Every asset failed with "network connection
   lost", `showPage` was undefined, white tool. Firefox's loopback carve-out
   hid it. **Fixed by removing that directive from the LOCAL CSP only**
   (commit eef6d20 + the follow-up). The public site keeps it — it's correct
   there.
2. **Verify against the LIVE resolver/source, never from memory.** Three
   separate "impossible" claims this session (cost figures, Cognitive Atlas
   counts, nonce mismatches) were all wrong in MY verification method, not
   the instrument. When something "can't be true," re-measure first.
3. **The nonce stamping is now single-source.** The middleware stamps BOTH
   the CSP header AND the HTML body with the same per-request nonce. Don't
   split them again — the handler's stamp is a no-op after the middleware
   pass by design.
4. **Assets are inlined/self-hosted deliberately.** The site has no external
   subresources; every image/script/style is same-origin. Don't introduce a
   CDN or external font.

## NEW — Oscent architecture items (2026-07-24, DECISIONS §15)

These three items are the front door and the share layer of the instrument.
They implement the unified architecture: Measure → Reveal → Witness.

### 1. Subject/Channel Wizard (keystone UI) — now Rung 3 of 3

**Update (2026-07-25, onboarding design):** the wizard is no longer first in
line. It is Rung 3 of the first-run onboarding flow below. Build Rungs 1–2
first (section "First-run onboarding" under Open items); the wizard spec here
is unchanged.

Focused mode's front door is a three-question flow, not a model grid:

1. **Subject:** SILICON or CARBON
2. **Channel:** LOCAL API / CLOUD API / MANUAL (web-chat paste)
3. **Battery:** pick, then Run

Every path lands in the same schema with honest `channel` provenance.
A kid with LM Studio, a security researcher with Replit, and a human-cal
participant all walk the same door. The wizard REPLACES the current
model-picker as the default Focused entry; Deep mode keeps the full grid.

Design constraints:
- Readable/High-contrast is the default (Hawking standard).
- No spinners — every state shows real data or a clear next action.
- The wizard is a single page, not a modal stack.
- Channel labels are plain language: "Local model (LM Studio)", "Cloud API",
  "Web chat (paste)".

### 2. Witness Artifact Generator

The "share from science." Not a screenshot — a sealed, self-verifying
certificate.

- One self-contained HTML file (zero-JS, like the site), golden-ratio grid
- Content: finding sentence, subject, battery, channel, date, SHA-3 seal,
  owl logo
- Dark scotopic palette (#0a0a0a bg, #e0e0e0 text), no spinners, no JS
- Verify-by-hash instruction footer: "Verify this seal against the
  instrument"
- Not a leaderboard post — a certificate. It demonstrates; it does not sell.

Backend endpoint: GET /api/runs/:id/witness → generates the artifact HTML.
Frontend: a "Witness" button on the run detail view (both Focused and Deep).

### 3. Wording Audit

Sweep all public surfaces against the mission sentence:

> "Calibration Scope measures reasoning — in any subject, on any substrate —
> and seals the measurement so anyone can verify it."

Kill any "benchmark tool" / "LLM tester" language. Dashboard landing, site
index, README, lessons headers, DECISIONS preamble. One voice.

---

## Open items (pick in order)

0. ~~§10.9 prose-block downgrade~~ **DONE (commit 3c40571, 2026-07-25 —
   verified by Claude Code 2026-07-26).** §10.9 was retitled from assertion to
   question, the original paragraphs demoted to a verbatim-quoted blockquote
   labeled "superseded as stated," and the caveat appended ("'confirmed' was
   never the right word"). The grep criterion this item set now passes:
   `carrier-immune` appears only inside superseded/quoted context (the §10.9
   blockquote and §10.16's quotation of the old README claim). Do not redo.

0.5. **First-run onboarding (three rungs, ordered by verified-result-first).**
   Design source: Claude Science, 2026-07-25. Principle: each rung must
   produce a VERIFIED result before the next asks for a decision — an
   onboarding flow is a pipeline, and users don't advance on unverified
   forward progress.

   - **Rung 1 — "does anything work?" (~60 s, no API key required).**
     **SHIPPED v1 (Claude Code, 2026-07-26, PR #2).** `page-onboard` on the
     dashboard: a three-step ladder (INSTRUMENT `/api/status` → CHANNEL
     `/api/lmstudio/status`, names exactly WHICH model is loaded → SIGNAL, one
     `POST /api/prompt-check` round trip). Continuity stimulus is
     deliberately NOT a battery item (reply-with-OHM; no leakage, no
     interpretation). Failure states are first-class cards with next actions:
     LM Studio unreachable (wrong-port note), no model loaded (granite
     auto-load gotcha → ~/.hermes/config.yaml), registry unsynced, empty
     final answer (finish_reason surfaced), reply mismatch (shown verbatim).
     Zero new backend. The 2×3 diagram ships inline on this page — the
     golden-ratio commitment is now BUILT on a real surface. Entry: landing
     hero button; page whitelisted in Focused mode. Verified in a live
     browser against a mocked backend (green + both failure states, console
     clean); real-hardware pass with LM Studio still worthwhile. Side fix:
     'human-cal' was missing from the PAGES array, so its tab hid every page
     and showed nothing — added (one word) along with 'onboard'.
   - **Rung 2 — Model Picker UI over the existing 5-item battery.** Reports a
     CAPABILITY BAND, not a score, with the honest caveat rendered in the UI:
     "5 items can't rank models — this tells you whether one is worth a full
     run."
   - **Rung 3 — the subject/channel wizard** (spec above, unchanged). It was
     never wrong; it was first in line when it should have been third.

   The 2×3 diagram (SILICON/CARBON × LOCAL/CLOUD/MANUAL) is the teaching
   surface: it must state plainly that the manual channel is a first-class
   measurement path, not a downgrade. Evidence: the channel experiment showed
   channel effect ≈ 0 across all four arms (A/A′/B/C agree at ~98.4–100% after
   the grader fix). Do NOT cite a specific p-value or trial count in UI copy —
   the earlier "p=0.34, ±5 pts, 1,024 trials" figure welded a statistic from
   the re-graded 640-row dataset to the N of the retracted original; that
   citation was wrong and is struck. If a number is needed, derive it from the
   re-graded CSV and cite that CSV's N and hash. This figure is also where the
   golden-ratio commitment actually ships, since the story audit found it
   asserted on no surface.

   **Starting bot pair: deliberately not named.** No verified data supports a
   "best" pair (52-run dataset, N=3/cell, non-head-to-head arms). Instead the
   instrument seeds `verified_configs.json` (append-only; model, quant,
   channel, N, date, pass rate WITH CI, run hash). One verified row beats six
   plausible ones; the file earns the recommendation as runs land, and users
   watch it grow on GitHub. Seeded by Hermes 2026-07-25 with the single
   honestly-verifiable row (gemma-4-31b, run 953); row corrected 2026-07-26
   (commit 3c40571): n=192/189 passed, Wilson 95% CI, runnable verify-SQL,
   and the naming caveat — 64 distinct test_ids but 63 unique display names
   (AUX-APPROVAL-01 is two different tests). Use the FILE, not this prose,
   as the data source for any UI.

   **Binding UI constraints from Claude Science reviews (2026-07-24..26):**
   - **Key every list/count on test_id, never display name** (64 ids vs 63
     names). Count what the primary key counts.
   - **No p-value or trial-count in UI chrome** for the channel claim (see
     the struck citation above); if a number is needed, derive it from the
     committed re-graded CSV and cite its N and hash.
   - **The manual paste pack must be byte-identical to the API item set** for
     any channel-provenance run — no manual-only "include your thinking
     block" instruction (REASONING_TRACE_and_JSPACE_design.md: trace
     availability is itself channel-confounded). Absent reasoning_content on
     manual runs is an EXPECTED state, not an error; never invite
     cross-channel trace comparison in run views.
   - **Manual-mode results render as k/n_mappable** with the mappability
     fraction and best/worst bounds; format compliance is TWO numbers
     (map-rate + drift-point). Manual rows stay OUT of paired
     carrier-analysis views (standing rules, epistemic log 2026-07-24).
   - **Model lists come from the live endpoint/chooser, never from docs**
     (Hermes-4 recommendation retracted 2026-07-25).
   - **Rung 2's battery as shipped is 6 items** (5 logic + the 0-2
     reframe/partner probe; floors: >=4/5 logic, items 1 and 5 individually
     disqualifying, reframe >=1; cheapest passer wins). Grade server-side —
     the answer key must never reach page source. Item 6 is human-graded
     (0/1/2 rubric rendered inline).

1. **Subject/Channel Wizard** (Oscent item 1 — Rung 3, see 0.5)
2. **Witness Artifact Generator** (Oscent item 2)
3. **Wording Audit** (Oscent item 3)
4. ~~Local HTTPS~~ **DONE (Claude Code, 2026-07-22).** Dual-protocol on ONE
   port (8768): first-byte peek routes TLS → rustls, everything else → plain
   HTTP — so no existing http consumer (curl, Python client, Hermes scripts,
   launchd checks) broke, and trusting the CA is an opt-in upgrade, never a
   prerequisite. Self-provisioned CA + leaf via rcgen (src/local_tls.rs):
   `~/.calibration-scope/ca/`, SANs local.calibrationscope.com + localhost +
   127.0.0.1 + ::1, leaf 820-day validity + serverAuth EKU (Apple's 825-day
   rule honored), keys 0600. upgrade-insecure-requests restored on TLS
   connections only (per-connection ConnScheme). Trust: double-click
   ca.cert.pem or `scripts/trust-local-ca.sh`. Crypto: rustls + ring (audited,
   zero extra toolchain); FIPS 140-3 available as opt-in `--features fips`
   (AWS-LC FIPS) — decided ring-default because most scientists don't need
   FIPS and it costs cmake/go build friction. Verified live: chain+hostname
   validation (ssl_verify_result=0), IP SAN, SSE over TLS, CSP split, 36 unit
   tests, clippy 0.
5. **Site polish — owl+brain graphic pass.** BUILT (Claude Code, 2026-07-23,
   commit 7ed1af9) — DEPLOY PENDING (`scripts/deploy-site.sh` from a
   credentialed seat; this seat has no AWS creds by design):
   - Canonical LOCAL⇄WEB portal pill on ALL THREE surfaces (site home,
     lessons, local instrument): fixed top:10px/left:14px, identical string
     + size (87×25) — flipping never moves the control under the cursor
     (Carey's no-mouse-jerk rule). Current surface gold; whole pill links.
   - The spec-stream on the site: 8 real battery schemas (⊢/⊬ ground truth)
     rising past the brain — inline-SVG text + CSS-only @keyframes, zero JS,
     stagger via classes (style attrs are CSP-blocked), reduced-motion →
     static faint formulas. viewBox matched to the brain art's real
     landscape aspect (square viewBox letterboxed the stream — caught live).
   - Both pages' style hashes recomputed + stamped in meta CSPs; verified
     in-browser: CLEAN console, 8 animations, pill pinned across scroll.
   - Remaining for this item: run deploy-site.sh (Hermes/Carey), then a
     final visual pass on the LIVE site; optionally richer brain art later.
6. **Lessons page polish.** Four comics render inline; design pass on the
   lesson cards, status badges, seal lines. Do NOT change the lesson .md
   files or comic SVGs (sealed — hash-verified).
7. **Human-calibration UI polish (dashboard).** Backend is DONE (5
   endpoints, E2E verified). Frontend is functional but basic (4-step flow
   at page-human-cal). Add: per-question timing display, a carrier-variance
   bar chart at results, and a human-vs-model comparison panel (the
   signal_carrier endpoint already returns both subjects in the same shape).
8. **Architecture diagram.** docs/architecture.excalidraw is stale — add
   the Focused shell, NeuroVault proxy, signal-carrier view, spec-decode
   panel, human-calibration page, /api/runs/complete endpoint, MCP server.
9. **OWL N/C coverage expansion.** LOGIC-05/07/08/09/10 still have no N/C
   siblings. Template = migration 047/048 pattern (same formal_spec, new
   surface text for N; transform + named owl_flaw for C; resolve roots by
   NAME, never raw id). Oracle: scripts/verify_logic_ground_truth.py
   --check-owl-families.
10. **MCP server e2e test.** Connect a real bot to POST /mcp, discover the
   11 tools, call run_benchmark + get_run. Untested end-to-end by a client.

## What's DONE (don't redo)

- calibrationscope.com: ACM, S3 (OAC, private), CloudFront E380F2PTHYDACJ,
  Route53 aliases, headers policy, DNSSEC, mail lockdown. Homepage +
  lessons.html live, verified in-browser.
- LOCAL⇄WEB flipper links directly to http://127.0.0.1:8768 (loopback,
  no port-forward trick — local.calibrationscope.com DNS is the alias).
- Kokoro TTS watchdog, EC2 idle-shutdown (certified), evidence eviction,
  CI green (all 4 jobs), epistemic record reconciled (§10.13), the Safari
  white-page root cause found and fixed.
- Carrier Color §10.8 is sealed; the paired-run harness is in analysis/.

## Lane boundary

- Your lane: frontend/UX/design on both surfaces.
- Claude Science's lane: Carrier Color §10.8 rewrite (when the paired CSV
  lands), seL4 root-task build (Rust compile errors → its lane, don't force
  it green), l4v proof run, EC2 ops.
- Hermes's lane: dashboard backend/executor, CI, cost, fleet, CSP/security
  middleware.
