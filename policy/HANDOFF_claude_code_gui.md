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

**SHIPPED v1 (Claude Code, 2026-07-26, PR #2).** `src/routes/witness.rs`:
the certificate is one HTML file whose body is a single inline SVG —
presentation attributes only, no <style> element, zero JS, zero external
resources (the 411KB raster owl is replaced by a light geometric owl mark
to keep self-containment; the φ construction is portrait 1000×1618,
section at y=618, Fibonacci spacing, self-described in the footer — the
SECOND shipped golden-ratio surface). Honesty gates: no witness without a
seal (unsealed runs get a refusal, not a mock-up); counts shown raw with
"demonstrates; does not rank"; channel labeled DERIVED pending the §14
column; hostile model keys escaped and clipped (3 unit tests + a
browser-inspection sample emitter; rendered sample verified in Chromium).
Frontend: 🪶 Witness link beside the evidence-bundle export on the run
detail panel (sealed runs only, new tab). v2 when §14 lands: real channel
field.

### 3. Wording Audit

Sweep all public surfaces against the mission sentence:

> "Calibration Scope measures reasoning — in any subject, on any substrate —
> and seals the measurement so anyone can verify it."

Kill any "benchmark tool" / "LLM tester" language. Dashboard landing, site
index, README, lessons headers, DECISIONS preamble. One voice.

---

## Open items (pick in order)

**NEXT BUILD for this lane (updated 2026-07-28).** Items 6, 7, 8 and 10 are
now DONE — see their records below. What is actually left:

1. **Decide and apply migration 056** (item 9). Written and validated in a
   rolled-back transaction, deliberately UNAPPLIED — applying it changes the
   live instrument's data, which is Carey's/Hermes's call, not an agent's.
   Apply, then re-run BOTH oracle modes.
2. **Oracle coverage for the 28 pre-existing N/C rows** seeded by migrations
   047/048/049 (item 9's tail). They pass the STRUCTURAL family check while
   their logic has never been machine-verified — the same gap 056 closed for
   its own rows. Unglamorous and high-value: it is ground truth the whole
   instrument rests on.
3. **The systemic tab keyboard pass** (carried over, still open).
4. **Item 5 wording-audit residuals**, if any survive.

Relay items (f)–(i) are HERMES's lane, not this one — see DECISIONS. (i) is
new: nine documented-vs-actual gaps in the MCP tool surface, found by the
item-10 test. Item 0.2 (provenance_tier/channel) stays lane-disputed — the
spec marks §3a "Hermes's lane" while Claude Science's audit assigns it here;
settle the lane before building it.

The mock-verification rig for browser-testing dashboard pages lives in the PR
record (python mock server + Playwright against the real assets).

**Witness v2 — SHIPPED 2026-07-27 (design constraint from Claude Science,
relayed via Carey): claim status BY CLAIM ID, never prose restatement.**
A second SVG below the certificate lists every claim as `#test_id name
k/n` — keyed on test_id (the binding key; names are labels), counts raw,
imperfect rows in gold, three-column column-major layout with height
computed from the claim count (a 293-claim battery and a 3-claim human
session both render completely; unit test pins the no-overlap math).
Pre-migration-021 trials (test_id NULL) render as one gray "unlinked
trials" line — honestly not one claim, not silently dropped. Same pass:
human-participant runs now get certificates (the v1 INNER JOIN answered
"no run exists" about runs that exist) — carbon subject kind, load mode
"not applicable to a human subject", channel "dashboard quiz — same
items, same grader as model runs".


0. ~~§10.9 prose-block downgrade~~ **DONE (commit 3c40571, 2026-07-25 —
   verified by Claude Code 2026-07-26).** §10.9 was retitled from assertion to
   question, the original paragraphs demoted to a verbatim-quoted blockquote
   labeled "superseded as stated," and the caveat appended ("'confirmed' was
   never the right word"). The grep criterion this item set now passes:
   `carrier-immune` appears only inside superseded/quoted context (the §10.9
   blockquote and §10.16's quotation of the old README claim). Do not redo.
   (Re-verified 2026-07-26 on origin/main after Claude Science re-flagged it:
   the strings its grep found all sit INSIDE the labeled superseded
   blockquote — the criterion passes. Its log cites "main head e404451" —
   Actions history shows that WAS a real main head at 11:41Z, later
   rewritten away (main history was force-updated). Whatever the clone
   state, at current origin/main the criterion passes. If it re-flags,
   compare against origin/main with context lines, not bare grep.)

0.1. ~~Citation registry port~~ **DONE (Claude Code, 2026-07-26, PR #2).**
   dns-tool-intel added to the session and cloned; registry ported verbatim
   to `citation/registry.yaml` (61 entries measured — the memo said 62) plus
   `nasa:std-7009a` and `grade` added in the source format; root
   `CITATIONS.md` records provenance, the NASA anti-badge rule, and the
   primary-source caveat. YAML validated: 63 entries, unique ids, all four
   required registrations present. Original ask (for the record):
   Port `go-server/internal/citation/registry.yaml` from dns-tool-intel
   (62 registered citations, existing format — zero invention) and register
   at minimum: odni:icd-203, nasa:std-7009a, grade, iso:25012. Source docs:
   inbox/claude-science/MEMO_prior_art_evidence_frameworks.md + the
   2026-07-26T21:10/21:11Z epistemic-log entries. Constraints: (a)
   dns-tool-intel is a SEPARATE repo — a remote session needs it added to
   scope, or Carey drops the file into the drop zone; (b) NASA-STD-7009A and
   the CoLD paper were read from search excerpts, not primary PDFs — fetch
   the primaries before building anything ON their content (the port itself
   is format-only); (c) the NASA anti-badge rule stands: no document says
   "ICD 203 compliant" — levels are determined and reported, never scored.

0.2. **provenance_tier/channel migration (Claude Science ask, 2026-07-26 —
   same audit, second missing item).** Spec:
   inbox/claude-science/SPEC_prompt_provenance.md §3a — add to test_runs:
   `subject_prompt_declared` (text), `subject_prompt_sha256` (text),
   `subject_prompt_source` (enum: authored_by_us | operator_declared |
   vendor_unknown | undeclared), and the missing `channel` column;
   `vendor_unknown`/`undeclared` are first-class values, not failures.
   Extend quarantine vocabulary with `prompt_provenance_unknown` (§3c).
   LANE NOTE, flagged for cross-lane agreement: the spec itself marks §3a
   "schema, Hermes's lane" while Claude Science's item audit assigns it to
   Claude Code — whoever lands it, this migration unblocks the wizard's
   channel-provenance copy (currently honestly scoped to "designed, not
   built"), the §14 manual-mode ingest, and detector work (§3b) that stays
   in Claude Science's lane.

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
     golden-ratio commitment is now BUILT on a real surface. Entry: a
     "First Run" tab visible in BOTH modes (Focused is the first-visit
     default and hides the landing hero, so a hero-only button was
     unreachable — adversarial-verification catch) plus the landing hero
     button in Deep; mode restore preserves the page. Hardened after a
     3-verifier adversarial pass: generation guard (stale async can't
     overwrite a newer ladder state or double-fire the beep), timer leak
     fixed via try/finally, NO silent model fallback (no registry match is
     a first-class state — a wrong pick could 404 or JIT-load a multi-GB
     model), wrapper-tolerant OHM grading, aria-live + real buttons for
     retry actions. Verified in a live browser against a mocked backend
     (green + both failure states + reload persistence, console clean);
     real-hardware pass with LM Studio still worthwhile. Side fix:
     'human-cal' was missing from the PAGES array, so its tab hid every page
     and showed nothing — added (one word) along with 'onboard'.
   - **Rung 2 — Model Picker UI over the existing 5-item battery.** Reports a
     CAPABILITY BAND, not a score, with the honest caveat rendered in the UI:
     "5 items can't rank models — this tells you whether one is worth a full
     run."
     **SHIPPED v1 (Claude Code, 2026-07-26, PR #2).** `page-picker` +
     `src/routes/picker.rs` (GET /api/picker/battery serves the STIMULUS
     only with a SHA3 provenance hash; POST /api/picker/grade grades
     server-side — key out of the page bundle, grading server-authoritative;
     7 grading unit tests incl. a length guard. Scope corrected same day:
     no secrecy claim — see the constraints bullet above).
     Battery ported verbatim from MODEL_PICKER_battery_v0.py (6 items: 5
     logic + the 0–2 reframe probe; floors: >=4/5, items 1 and 5
     individually disqualifying, reframe >=1). UI: paste-once stimulus with
     copy button OR send-to-loaded-local-model (same no-fallback mapping
     rule as Rung 1), reply kept as the evidence record, human transcription
     of items 1–5 ("no one-word answer" = a first-class FORMAT failure,
     never graded against the key), human-graded item 6 with the rubric
     inline, band card naming which floor failed, record line in the
     battery's format, session-local list with cheapest-passer highlight
     (the battery's decision rule, labeled as such — not a ranking), and a
     verified_configs.json pointer ("one verified row beats six plausible
     ones"; the screener never writes there). No named model
     recommendation anywhere. Entry: link on the First Run page + green-CTA
     flow; Focused-whitelisted; mode restore preserves it. Browser-verified
     against a mocked backend: PASS band, floor-failure band naming item 1 +
     partner floor, format-failure card, cheapest-passer highlight.
   - **Rung 3 — the subject/channel wizard** (spec above, unchanged). It was
     never wrong; it was first in line when it should have been third.
     **SHIPPED v1 (Claude Code, 2026-07-26, PR #2).** `page-wizard`: three
     questions on one page (no modal stack), progressive disclosure. All six
     subject×channel cells resolve honestly: silicon×local/cloud → live
     registry list (never a hardcoded model), battery axes, then Run — arms
     the Focused workspace and fires the exact same /api/runs path the
     workspace Run button fires (one run machinery, one schema — subject
     provenance live today; channel provenance is §14 design, not yet in
     the runs schema, and the wizard says so);
     silicon×manual → the Model Picker paste screener today + an honest
     "pack UI schema-ready, not built" note; carbon×local → the human-cal
     door; carbon×cloud/manual → schema-ready cards matching the 2×3
     diagram. "No cloud key" is a first-class state pointing at Setup. THE
     FRONT-DOOR REPLACEMENT: focusedPickSubject with no subject picked now
     walks the wizard instead of the grid modal (§15 mandate); once a
     subject exists, the button opens the full-grid modal for
     change/compare, and Deep mode keeps the grid untouched. Browser-
     verified end-to-end against a mocked backend incl. a real POST
     /api/runs with correct body. Scaffolded/paired designs stay in the
     workspace MODE control (stated in the wizard's run note).
     **Hardened same day after a 3-verifier adversarial pass:** channel-
     provenance copy corrected (the runs schema has NO channel column —
     §14's migration is unbuilt; four surfaces claimed it in present
     tense); wzRun now FORCES clean-room before firing (the button's
     promise was at the mercy of the workspace MODE select), performs the
     spec-pair reset, and finishes in Focused when reached from Deep (the
     runlog lives in the focused shell — a Deep-mode run fired with zero
     visible feedback); focusedRun now fails loudly on 400s (plain-text
     error bodies used to render as 'run(s) []' success — pre-existing,
     but the wizard made it the front-door path); instrument-down is its
     own card, no longer misdiagnosed as 'no key'; aria-pressed +
     check-mark selection (was color-only), aria-live on dynamic regions;
     'open the full grid instead' escape hatch (picking there costs no
     run). Backend relay added: annotate_runnable can only ever mark
     Nous-keyed cloud rows runnable, making the wizard's cloud path a
     dead end for openrouter/openai/gemini — see DECISIONS relay list.

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
     the key stays out of the page bundle and grading is server-
     authoritative. Honest scope (corrected 2026-07-26, Copilot catch):
     this is NOT secrecy — the battery + key are public in the repo, and
     binary items mean per-item correctness in the response determines the
     key anyway. Blindness belongs to the real battery, not the screener.
     Item 6 is human-graded (0/1/2 rubric rendered inline).

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
6. ~~Lessons page polish.~~ **DONE 2026-07-28.** Design-only pass on
   site/lessons.html; zero copy changed (proved mechanically — tokenised
   old vs new, 2225 words both sides, every added token has an identical
   removed counterpart from the badge's DOM move). Cards are real cards, so
   the comic's near-black well reads as inset rather than as a hole. The
   three epistemic tiers were all rendering in the SAME green — they now
   carry a mark that differs in SHAPE as well as hue (SEALED square/green,
   MECHANISM circle/cyan, PARABLE diamond/violet) so the code survives
   greyscale, with identical chrome on every badge and the three keywords'
   contrast within 0.05 of each other: the anti-ranking property is
   measured, not asserted. PARABLE is a different KIND of claim, not a
   lower grade, and a CSS comment says so to stop a future editor
   "promoting" one. Seal lines read as receipts (perforation rule, spaced
   label, verify command in a `user-select:all` chip that clones across
   wraps); the ellipsized hash is deliberately NOT one-click-selectable
   because copying `8601a916…339d483c` hands you something that is not a
   hash. Accessibility extended: `aria-labelledby` on all four `role="img"`
   comics (they had no accessible name), focus rings on in-comic links,
   header/footer landmarks. Caught by rendering, not reading: the new
   inner `<header>`/`<footer>` inherited the page banner's gradient — both
   are now scoped `body>header`/`body>footer`. CSP style-hash recomputed by
   deploy-site.sh's own method and re-verified after each of three edits
   (`sha256-pC7E44VSL8MichIiD+67NV4X9I5aZmfIDZg67/aiYmA=`) — the gate that
   caught yesterday's drift passes for both pages. All four SHA3-256 lesson
   seals re-checked with openssl: match. NOTE for the record: the pass also
   dropped a `.seal` rule the report called "fully shadowed — no visual
   change"; that was wrong (it uniquely supplied background/border/padding/
   display), but the seal line was redesigned wholesale in the same pass, so
   the green chip is gone BY DESIGN, not by accident. Verifier catch.
7. ~~Human-calibration UI polish (dashboard).~~ **SHIPPED v1 2026-07-27,
   browser-verified 23/23 checks.** Per-question timing: elapsed clock in
   the quiz header, stamped at the click (network time is not thinking
   time), persisted via a new optional `elapsed_ms` on the answer endpoint
   into trial_results.latency_ms — the same column model response times
   use; it was hardcoded 0 for humans before. Carrier-swing chart: per
   family, signal bar (pooled pass rate) + swing bar (variance scaled to
   its 0.25 theoretical max, stated in the caption); NULL variance renders
   "not measurable — N form(s)", never 0. Comparison panel: same families,
   every subject, "read the fractions, not just the bars" caveat (models
   run N=3 per form). /api/signal-carrier now returns `subject_id` —
   display names are NOT unique, so the UI filters by participant id (the
   old results code took the first human row in the view, any participant).
   Bonus fixes in the same pass: 'human-cal' added to the Focused
   mode-restore whitelists (reload mid-quiz bounced to benchmark);
   deepPage() escape hatch (wizard's Setup link was dead in Focused —
   review catch); pkSendLocal null-battery guard (review catch); SSE
   connect deferred to after the window load event (a parse-time
   EventSource kept the network busy through the whole Lighthouse trace —
   desktop perf straddled 64–90 on identical assets).
8. ~~Architecture diagram.~~ **DONE 2026-07-28, both views current.**
   docs/ARCHITECTURE.md is the prose reference (mermaid renders inline on
   GitHub); docs/architecture.excalidraw is the editable drawing, now
   regenerated to match — Focused shell, first-run rungs, human-cal,
   signal-carrier with its recorded view defects, Witness, MCP, evidence
   discipline, known gaps, three-agent workflow.
   **scripts/gen_architecture_diagram.py** authors the .excalidraw from a
   declarative spec AND renders the same geometry to SVG, exiting non-zero
   on overlaps, off-canvas elements, arrows crossing boxes, or labels
   landing on one — so "I can't verify a drawing here" is no longer true.
   First run of that checker passed a diagram whose arrows cut through the
   Executor and ran off the canvas; the eye caught it, then the checker was
   strengthened until it caught the same things. Keep both views in step.
9. **OWL N/C coverage expansion — WRITTEN AND VALIDATED, NOT APPLIED
   (2026-07-28).** `migrations/056_owl_nc_coverage_logic_05_10.sql` (055 was
   taken by Hermes the same day) adds N+C siblings for LOGIC-05/07/08/09/10
   in the 047/048 pattern — roots resolved by NAME, never raw id. **The
   migration is deliberately UNAPPLIED: applying it is a data change to the
   live instrument and is Carey's/Hermes's call, not an agent's.** It was
   validated by applying inside a transaction and rolling back: N/C rows
   28→38, `fully_instrumented` families 5→10, all five targets reach
   N=1/C=1, a second apply still yields 38 (idempotent), and the live DB was
   confirmed unchanged afterwards (28 N/C, 474 tests). To land it, apply the
   migration and re-run both oracle modes.
   **THE REAL DELIVERABLE IS THE ORACLE EXTENSION**, because it closes a gap
   that made this item riskier than it looked: `--check-owl-families` is
   STRUCTURAL only (it checks that N keeps the root's spec and C carries a
   different one) and never checks that a C trap's `expected_result` is
   logically correct — and the oracle's battery is HAND-MAINTAINED, so rows
   added by a migration are not covered until someone writes their
   structures. New C traps would therefore have passed the family check with
   their LOGIC UNVERIFIED. `scripts/verify_logic_ground_truth.py` now carries
   all ten new rows: **28/28 → 39/39 ground truths verified.**
   **LOGIC-09 is machine-verified for the first time.** It was absent from
   the oracle entirely because its spec is a SATISFIABILITY question
   (`(A∨B)∧(¬A∨C)∧(¬B∨¬C) — SAT`) while the harness computes ENTAILMENT — a
   different shape, so it fell outside. A SAT-shaped check was added; the
   entailment path is unchanged and still passing. Note the oracle returns
   the FIRST satisfying assignment and stops, so it prints one witness
   (`(A,B,C)=(F,T,F)`); the fact that exactly two models exist is true but is
   NOT what this gate produces.
   Negative control run (the check that the gate can actually fail): flipping
   09C to SAT and 05C to VALID on a scratch copy gives `37/39 — 2
   MISMATCH(ES)`, exit 1. The gate bites.
   **STILL OPEN after 056** (the first draft's header claimed this closed the
   one-form families — false, corrected): 19 LOGIC-* families remain not
   fully_instrumented (LOGIC-02 has C=1/N=0; LOGIC-12..29 have neither), plus
   every PILOT-*/PROBE-*/QS*/DF*/LIT-*/VVP-*/TOOL-*/SEC-* family. Separately,
   the 28 N/C rows seeded by migrations 047/048/049 have NO oracle entry and
   remain machine-unverified — same class of gap, still open.
10. ~~MCP server e2e test.~~ **DONE 2026-07-28 — `scripts/mcp_e2e_test.py`,
   73 checks: 58 PASS, 9 GAP, 6 INFO, 0 FAIL (exit 2 = GAPs only).** Acts as
   a real bot: handshake, discovery, read-only tool calls, shape validation,
   error paths. Nothing taken on faith — the expected tool set is parsed OUT
   OF src/routes/mcp.rs at runtime, so a tool in the registry but not the
   dispatcher (or vice versa) is a mismatch, not a green tick. Registry and
   dispatcher parity confirmed at 11 tools. GPU SAFETY: run_benchmark starts
   a REAL run, so the default NEVER fires one — it validates the contract
   (presence, input schema, the three server-side refusals rejected before
   any test_runs row exists); `--fire-run` is explicit opt-in. Queue verified
   idle before and after (before=0, after=0).
   **The 9 GAPs are findings about the server, not test failures** — RELAY
   TO HERMES (i): get_status advertises `uptime` it does not return;
   get_model_verdict advertises `score` it does not return; get_run omits
   fields its own description promises; list_models' `runnable` filter is
   advertised but inert (0 of 349 rows carry the field); list_tests
   `active=false` does not select inactive tests; get_owl_state omits
   advertised coverage classes; plus three transport deviations where
   malformed JSON and a missing `method` are rejected by axum's extractor
   at the HTTP layer before the MCP handler runs, so they never become
   JSON-RPC errors.
   Adversarial verification caught two FALSE PASSES in the first draft,
   proved with a fault-injecting stub server: a failed probe yielded
   `None`, which fell through to PASS and printed "true=None, false=None"
   as its own evidence. Both fixed. Also corrected: the summary header
   asserted "STATED-VS-ACTUAL GAPS (server is honest about none of these)"
   — an uncomputed editorial claim that additionally mislabeled the three
   transport deviations. Now `DOCUMENTED-VS-ACTUAL GAPS` with the count
   computed and both kinds named.
   Known blind spot (not fixed): `tool_list_tests` has a hard `LIMIT 500`
   and the registry holds 474 — the `count == len(tests)` assertion would
   still pass if the registry crossed 500 and got silently truncated.

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
