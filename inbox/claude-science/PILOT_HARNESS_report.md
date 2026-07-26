# Pilot analysis harness — PRE-REGISTERED, written before the data
_Claude Science, 2026-07-26. Ships as `pilot_analysis.py`. Stdlib + numpy/scipy. `--self-test` runs 6 controls._

## Why this exists and why it exists NOW
The pilot produces three numbers that decide how 500 items get built. **Choosing the estimator after seeing the
data is how a null becomes a finding.** So the estimators, thresholds, and the go/no-go rule are fixed in code
before the 720 trials run. `python3 pilot_analysis.py results.csv` — exit 0 = proceed, exit 1 = stop and redesign.

## What it computes
1. **Difficulty distribution** — per-item pass rates, fraction off the ceiling, fraction in the 70–85% target band.
2. **Family ICC** — one-way ANOVA ICC(1) over per-item rates grouped by `family_id`, feeding
   `DE = 1 + (m−1)·ICC` and a cap table (ICC <0.20 → 12/family, <0.35 → 8, <0.50 → 6, else 4).
   *ANOVA rather than a GLMM deliberately: no optimiser, cannot fail to converge, and the cap table is coarse by
   design — ICC to ~0.1 resolution is all the decision needs.*
3. **Per-mechanism difficulty** — chain vs trap vs negdepth with Wilson CIs. The "hard how" answer.
4. Infra errors are dropped as **missing, never wrong** (standing rule), and the count is reported.

## Validation — 6 controls, all passing
| Control | Result |
|---|---|
| **T1 ICC recovery** | injected family SD 0.0/1.0/2.0 → estimated ICC **0.055 / 0.359 / 0.615**, strictly monotonic. The load-bearing one: an ICC estimator that cannot recover a *known* injected value is worthless, and the entire items-per-family decision rests on it. |
| **T2 ceiling detection** | ceiling-bound bank → 7% informative, **STOP**; off-ceiling bank → 90% informative, **PROCEED** |
| **T2b under-power warning** | 3 trials/item → 16 perfect-but-unresolvable items flagged, warning emitted |
| **T3 mechanism separation** | trap injected as hardest → recovered as hardest (0.47 vs 0.91 / 0.92) |
| **T4 infra handling** | 10 infra rows dropped, not scored as failures |
| **T5 ICC inestimable** | single family → **STOP**, not a silent proceed |

## A real finding from building it — the first version of my own test FAILED, correctly
T2's "off-ceiling" case initially returned **STOP** on a healthy bank. That was not a test bug; it was a
**measurement bias in my ceiling rule.** An item with true p=0.75 scores perfect on 3 trials **42%** of the time
(6 trials: 18%; 12 trials: 3%). Classifying "at ceiling" from a small-N perfect score therefore mislabels
well-calibrated items as uninformative — and would have **STOPPED a perfectly good pilot.**
**Fixed in the estimator, not the threshold**: an item counts as at-ceiling only if it scored ≥95% **and** carried
≥8 trials. Perfect-but-under-powered items are reported in their own field and never silently folded into the
ceiling count. This is the same shape as the LIT-12 lesson — *a small number of repeats cannot resolve an item
near its boundary* — now enforced mechanically instead of remembered.

## ONE DESIGN NOTE FOR HERMES — pooled vs per-model
The specced design gives **12 trials per item** (60 items × 2 models × 2 carriers × 3 reps = 720), which clears
the ≥8 bar. **But per model it is only 6 trials/item**, and at 6 trials an item with true p=0.85 looks perfect
**38%** of the time. So:
- **Report the ceiling/difficulty verdict POOLED across both models** — that is the powered comparison and the
  one the go/no-go rule consumes.
- **Per-model splits are descriptive only.** Do not call an item "ceiling for nemotron" off 6 trials.
- If a per-model ceiling call actually matters for the capability-band question, that needs N=6 reps rather than
  3 (24 trials/item, 1,440 total). Cheap enough to be worth deciding deliberately rather than discovering later.
The harness emits this warning itself when it sees the trial count, so it cannot be forgotten at analysis time.

## What it deliberately does NOT do
- No p-value on the pilot. The pilot is a **design-parameter measurement**, not a hypothesis test; reporting
  significance here would invite treating a calibration run as a result.
- No mixed-effects model. The full run needs one; the pilot does not, and adding an optimiser that can fail to
  converge to a 60-item calibration is a way to turn a clean number into a debugging session.
