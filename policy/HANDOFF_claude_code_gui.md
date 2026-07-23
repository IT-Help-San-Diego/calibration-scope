# HANDOFF to Claude Code — Calibration Scope GUI/UX lane (2026-07-22, Hermes)

Your lane is frontend/UX across BOTH surfaces: the local dashboard
(127.0.0.1:8768) and the public site (calibrationscope.com). State is
current as of commit 85eba92+. Read policy/EPISTEMIC_LOG_POLICY.md first —
it governs how you log any re-runs or data changes you make.

## Gate rules (hard, do not skip)

- **Zero executable JS on the public site.** script-src 'none'. The one
  allowed exception is application/ld+json data blocks.
- **style-src hash rule.** The CSP carries BOTH pages' style hashes
  ('self' + sha256 of each page's <style> block). Recompute on EVERY CSS
  change or the page blanks. CloudFront policy id 42a28561-… is updated
  with both hashes (see infra in DECISIONS §13+).
- **Verify in the live browser, not by curl.** Firefox MCP
  (mcp__firefox_devtools__*) is the instrument: navigate, evaluate_script
  for computed sizes + sheetCount, list_console_messages. The
  browser-console-preflight skill is mandatory before any HTML/CSS edit.
- **No spinners.** Every loading state shows real data or nothing.
- **Lighthouse ≥ 91 perf / 100 a11y / 100 bp / 100 seo** (desktop preset)
  on the public site; 90/98/100/91 on the dashboard.
- **Accessibility is the default.** Readable/High-contrast is ON first visit.
- Commit + push immediately after each verified change (cross-agent record
  duty: whichever agent does the work updates DECISIONS.md itself).

## Open items (pick in order)

1. **Site polish — owl+brain graphic pass.** Homepage has the working
   structure (owl semaphore nav/hero, brain+English→Lean→VERIFIED panel).
   Claude-designed: give it a design polish pass — better brain art, the
   Lean formulas "flying by" (CSS animation is allowed? NO — zero JS; if
   you want motion it must be CSS-only `@keyframes` on an inline SVG, and
   verify it survives CSP). Keep the owl-semaphore-logo.webp (do NOT
   regenerate it — it's the family-standard asset).
2. **Lessons page polish.** Four comics render inline; design pass on the
   lesson cards, status badges, seal lines. Do NOT change the lesson .md
   files or comic SVGs (sealed — hash-verified).
3. **Human-calibration UI polish (dashboard).** Backend is DONE (5
   endpoints, E2E verified). Frontend is functional but basic (4-step flow
   at page-human-cal). Add: per-question timing display, a carrier-variance
   bar chart at results, and a human-vs-model comparison panel (the
   signal_carrier endpoint already returns both subjects in the same shape).
4. **Architecture diagram.** docs/architecture.excalidraw is stale — add
   the Focused shell, NeuroVault proxy, signal-carrier view, spec-decode
   panel, human-calibration page, /api/runs/complete endpoint, MCP server.
5. **OWL N/C coverage expansion.** LOGIC-05/07/08/09/10 still have no N/C
   siblings. Template = migration 047/048 pattern (same formal_spec, new
   surface text for N; transform + named owl_flaw for C; resolve roots by
   NAME, never raw id). Oracle: scripts/verify_logic_ground_truth.py
   --check-owl-families.
6. **MCP server e2e test.** Connect a real bot to POST /mcp, discover the
   11 tools, call run_benchmark + get_run. Untested end-to-end by a client.

## What's DONE (don't redo)

- calibrationscope.com: ACM, S3 (OAC, private), CloudFront E380F2PTHYDACJ,
  Route53 aliases, headers policy, DNSSEC, mail lockdown. Homepage +
  lessons.html live, verified in-browser.
- LOCAL ⇄ WEB flipper links directly to http://127.0.0.1:8768 (loopback,
  no port-forward trick — local.calibrationscope.com DNS is the alias).
- Kokoro TTS watchdog, EC2 idle-shutdown (certified), evidence eviction,
  CI green (all 4 jobs), epistemic record reconciled (§10.13).

## Lane boundary

- Your lane: frontend/UX/design on both surfaces.
- Claude Science's lane: Carrier Color §10.8 rewrite (when the paired CSV
  lands), seL4 root-task build (Rust compile errors → its lane, don't force
  it green), l4v proof run, EC2 ops.
- Hermes's lane: dashboard backend/executor, CI, cost, fleet.
