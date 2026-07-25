# Carrier-immunity overclaim — COMPLETE bleed inventory + canonical fix (for Claude Code)
_Claude Science, 2026-07-25. The overclaim spread to 9 surfaces. Fix ALL with the SAME wording, or you_
_trade one stated-vs-actual gap for inter-surface DRIFT (surfaces disagreeing with each other)._

## THE ONE CANONICAL REPLACEMENT (use verbatim everywhere; do not paraphrase per-file)
Replace any variant of "carrier-immune / 100% on every carrier / immunity tracks capability not
substrate" with:

> **At current N, larger models show no carrier sensitivity we can resolve (scores sit at/near the
> ceiling); the small gemma-4-e2b shows a candidate drop (99%→91%). Whether that reflects a real
> capability threshold — and whether it tracks capability vs substrate — is exactly what the
> pre-registered paired-design experiment (N≈420) is built to answer. Not a settled result yet.**

Short inline form (for tight spots like code comments / one-liners):
> *"no carrier sensitivity resolvable at current N (near-ceiling); e2b candidate drop 99→91; powered
> experiment pending — not settled."*

Rule: **downgrade, don't delete.** The finding stays; only its certainty drops to what the data licenses.

## SURFACES (all 9 on main, by urgency)

### TIER 1 — PUBLIC, fix first (strangers read these)
- README.md (1x) — the shop-window instance.
- site/lessons.html (1x) — rendered public lesson.
- lessons/04-carrier-color.md (4x) — the WHOLE lesson is about this claim; rewrite its thesis to the
  honest version, don't just swap words. This one teaches the overclaim as a lesson — highest-value fix.
- lessons/README.md (1x).
- docs/FINDINGS.md (6x) — the findings doc; each instance downgraded identically.

### TIER 2 — CODE PATH, user-visible via running app
- src/routes/mcp.rs (1x) — "carrier-immune" in a served route/string. If it's user-facing output text,
  it must match the canonical wording. If it's an internal var/comment, still fix so code doesn't assert
  what the docs retract.

### TIER 3 — INTERNAL (not public-embarrassing, but must agree or the record self-contradicts)
- DECISIONS.md (12x) — the source the others inherited from. NOTE: some of these 12 may already be the
  QUARANTINE entries (correctly saying it's NOT supported). DISTINGUISH: keep/keep-as-is any instance
  that already frames it as unresolved; only downgrade instances that still assert it as fact. Read each
  in context — do not blanket-replace in DECISIONS.
- docs/experiments/carrier_color_experiment_spec_v1.md (2x) — "immune" as a hypothesis label is fine IF
  clearly marked as the hypothesis under test; confirm it's not stated as a finding.
- policy/HANDOFF_two_deliverables.md (1x).

## VERIFY AFTER FIXING
Re-run the same scan; expect zero "carrier-immune / 100% on every carrier / immunity tracks" asserted as
RESULT on any surface. Remaining hits should ONLY be: (a) the honest downgraded wording, (b) DECISIONS
quarantine entries that already say "not supported," (c) the experiment spec's clearly-labeled hypothesis.
Consistency is the pass condition — every surface tells the same story.


## RECONCILIATION (post-Claude-Code-fix, re-scanned live main 2026-07-25 ~17:30)
Claude Code fixed the NARRATIVE surfaces (README, lessons/04, comic4.svg, site/lessons.html, mcp tool
text) and re-sealed lesson 04 — verified, those are clean. But a live re-scan of main shows the
overclaim SURVIVES in the DATA TABLES + their one-line captions in two docs. A stranger reads these.

### STILL OPEN (3) — the table/caption instances the prose-fix missed:
1. **docs/FINDINGS.md** — results table rows labeled "carrier-IMMUNE" + caption "Finding:
   carrier-immunity tracks capability/headroom, not substrate." SAME overclaim, in table form.
   Fix: caption -> the canonical downgrade; keep the table but add a column note that 100% cells are
   at-ceiling / N shown / no CI, so the numbers don't read as resolved separation.
2. **DECISIONS.md** — same table + same bare "Finding:" caption. Now CONTRADICTS its own §10.16 resolve
   entry. Fix: make the table caption point to §10.16 ("superseded — see §10.16; endpoints real, middle
   + capability-vs-substrate unresolved pending N≈420"). Don't delete the table (it's the receipt);
   correct the CAPTION so the doc stops disagreeing with itself.
3. **src/routes/mcp.rs** — MILD: `get_carrier_color` tool *description* uses "carrier-sensitive vs
   carrier-immune" as category labels. Defensible as taxonomy, but since it's served live, prefer
   "carrier-sensitive vs (at-ceiling) carrier-stable" or add the not-settled note in the returned body.

### Pass condition (unchanged): re-scan shows NO surface asserting "tracks capability, not substrate"
as a finding without the pending-N≈420 hedge in the same block — tables included, not just prose.
