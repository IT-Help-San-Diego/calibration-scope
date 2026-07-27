# PRE-REGISTERED ANALYSIS PLAN — powered run 970-973
_Locked before results exist (pre-registration removes the freedom to choose after)._
_Hermes + Claude Science, 2026-07-27. Bank: 293 items (182 quant-scope + 111 defeasible), 118 families, 6 reps, 2 models × 2 carriers._

## Order (confirmed live)
e2b baseline (970) → e2b Lean (971) → nemotron baseline (972) → nemotron Lean (973).
Both e2b arms first = a complete sensitive-model contrast at the halfway mark.

## Primary test
**Rate-based paired t-test** on the per-item pass RATE (mean of 6 reps), paired within
(item × model), baseline vs Lean. Claude Science VERIFY_powered_run_build §1:
scoring the cell rate doubles resolution over majority-vote McNemar (d=0.05: 0.87 vs 0.59).

## Secondary (robustness)
**Vote-based McNemar** — majority-vote each item's 6 reps into one bit per carrier,
paired within (item × model). Reported as a robustness check on the primary.

## Resolution claims (honest bounds) — CORRECTED (Claude Science audit)
- **d ≈ 0.10 resolves under every assumption** (power 0.98 even if ceiling items
  cannot degrade; 1.00 if they respond at half or full).
- **d = 0.05 is NOT established** — power spans 0.33–0.96 depending on whether the
  ~48% of ceiling-pinned items can degrade at all. The earlier "report d=0.05 at
  family level (0.78)" came from a simulation of 293 independent items, contradicting
  this design's 118-family structure. Do NOT claim d=0.05 resolution.
- **The run answers the d=0.05 question itself:** once the Lean arms land, comparing
  measured carrier drops on baseline-1.000 items vs baseline-0.69 items identifies
  whether ceiling items degrade under a carrier — that comparison runs FIRST.
- The bank sits mid-difficulty where the majority-vote is most sensitive
  (p≈0.5); a majority-vote is near-blind at the ceiling (p=0.95 → 0.998 prob of 1).
- **Length leak (GATE_length_binds_partials v2):** ρ=−0.580 on quant-scope; a blind
  length-only rule scores 0.953 vs the model's 0.840 — length beats the model. The
  carrier CONTRAST is structurally immune (length identical in both arms), but any
  ABSOLUTE-difficulty claim must carry this caveat. Fix additively in the next bank
  revision (write short items up to overlap).

## Construct-defect triage (standing caution, Claude Science)
Lint 0/0 is mechanical; the probe found 2/11 items with construct defects a linter
can't see. At 293 items, **capability-INDEPENDENT failures** (an item both models
fail at similar rates, or one that fails identically under both carriers) get
triaged as item DEFECTS, not model difficulty — reviewed before they count toward
the difficulty distribution or the carrier effect.

## Confound guards (carried from prior runs)
- Clean infra: infra errors are MISSING, never wrong.
- No reading a pooled (NONE+controls) number as a class signal.
- Family clustering reported alongside item-level power.
- e2b is the sensitive anchor; nemotron the immune control. A capability
  interaction (carrier effect present on e2b, flat on nemotron) is the §10.9
  threshold signature — but two models is a pattern, not a proof; a third model
  at a different scale is required before any "capability" claim.
