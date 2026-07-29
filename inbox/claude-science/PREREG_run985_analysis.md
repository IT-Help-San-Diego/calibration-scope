# PRE-REGISTERED analysis for run 985 — written BEFORE the CSV exists
_Claude Science, 2026-07-29. Fixed before seeing 985's data. CS-001 / CS-051._

**Why this document exists:** the export is in flight. Writing the analysis now means the CSV
lands into a committed spec rather than into my discretion — which matters here because I have
already computed one number from 985 (`+4.14 points`, unpaired) and explicitly disowned it. If the
decision rule is written after the data arrives, the rule is a choice about the data.

## The baseline, measured now from the committed CSV

`analysis/powered_run_974_977.csv`, `model = google/gemma-4-e2b`, `carrier = baseline`:

| quantity | value |
|---|---|
| trials | **1758** |
| items × reps | **293 × 6** (every item exactly 6, verified) |
| infra errors | **0** |
| trial-level pass rate | **0.7708** |
| item-level accuracy | mean **0.7708**, sd **0.3910** |
| deterministic items (all 6 reps agree) | **245 / 293 = 0.8362** |
| stochastic items | **48** |

## Gate 0 — admissibility. Runs BEFORE any comparison.

1. **Row count and rep structure.** Report `n_rows`, `n_items`, and the distribution of rows per
   item. **If items do not all carry the same rep count, the run is ragged** and every
   per-item statistic below is computed on the reps present, stated as such.
2. **Which of the three structures is 2439?** `2439 = 3 × 813`; `2439/6 = 406.5`. Report the
   answer from the data, not from the headline.
3. **Infra errors.** Report the count. **If > 0, exclude them and report both denominators** —
   the baseline arm has zero, so any nonzero count is itself a difference between the runs.
4. **Item overlap.** Report `|shared|` = items present in both 985 and the baseline arm, by
   `test_id` joined on `name`. **The paired analysis runs on the shared set only.**

## The pre-registered test — paired, on shared items only

**Primary:** paired t-test on per-item accuracy difference (985 − baseline) over shared items.
Report mean difference, 95% CI, n_items.

**Secondary (the stability question CS-001 actually asks):** McNemar on
*stochastic-vs-deterministic* status per item — an item that is deterministic in one run and
stochastic in the other is run-to-run instability, which a mean accuracy difference can hide
entirely.

**Reported regardless:** the count of items whose accuracy moved by ≥ 1/reps in each direction.

## Decision rule — fixed now

| outcome on shared items | verdict | action on the live site sentence |
|---|---|---|
| CI contains 0, McNemar n.s. | **replicated** | un-provisional |
| CI excludes 0 **in either direction** | **not replicated** | keep provisional; the run-to-run shift is the finding |
| shared set < 100 items | **inconclusive** | keep provisional; power too low (see table) |

**"In either direction" is load-bearing.** A replicate that comes back *better* is not a
confirmation — it is evidence the setup changed, and it fails the replicate identically to one
that comes back worse. I am fixing that now precisely because 985's headline is higher.

## Power, simulated from the baseline's own item distribution

Paired design, resampling the 293 measured item accuracies, 3,000 sims, α = 0.05:

| shared items | δ=0.00 | δ=+0.02 | δ=+0.05 | δ=+0.10 |
|---|---|---|---|---|
| 100 | 0.049 | 0.105 | 0.387 | 0.874 |
| 200 | 0.050 | 0.152 | 0.625 | 0.990 |
| **293** | 0.058 | 0.216 | **0.808** | 0.999 |
| 406 | 0.048 | 0.286 | 0.916 | 1.000 |

**Calibrated at the null** (≈0.05 across all n — the design is not inflating false positives).
**At 293 shared items the test detects a 5-point true shift with 0.81 power, and a 2-point shift
with only 0.22.** So: a null result at full overlap **excludes a 5-point run-to-run shift and does
NOT exclude a 2-point one**, and that bound must be stated with any "replicated" verdict rather
than being discovered afterwards.

## What this document does NOT do

- **It does not analyse 985.** No 985 data existed when this was written; every number above is
  from the committed baseline CSV or simulated from it.
- It does not commit to killing the site sentence. Two of the three outcomes keep it provisional;
  **none of them silently upgrades it.**
- The power table assumes 985's item difficulty distribution resembles the baseline's. **If Gate 0
  shows 813 different items, that assumption is untested** and the realized power is unknown —
  in which case report the observed difference distribution and treat the power figures as
  indicative only.
