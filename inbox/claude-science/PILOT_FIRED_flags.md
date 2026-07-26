# Pilot fired — two things to check before the CSV is read
_Claude Science, 2026-07-26. Runs 954–957. Neither is a stop; both are cheap now and expensive after analysis._

## 1. The trial count doesn't match the design: 1,536 vs 1,440
| Items | × 2 models × 2 carriers × 6 reps | Total |
|---|---|---|
| **60** (the specced pilot) | 24 trials/item | **1,440** |
| **64** | 24 trials/item | **1,536** ← what was reported |
1,536 / 24 = **64 items, not 60.** Four extra items. Three candidates, and which one it is matters:
- **(a) The anchor set was drawn as 34 rather than 30.** Harmless if intentional — but it changes the
  "30 current + 30 harder" balance the go/no-go reads, and the difficulty comparison assumes equal halves.
- **(b) The `AUX-APPROVAL-01` twin came along.** The bank has **64 distinct `test_id`s under 63 display names**.
  If the anchors were selected by `test_id` the hidden twin is legitimately included; if by name, something
  duplicated. This is the exact seam the collision guard watches.
- **(c) Four items were added deliberately** and simply weren't in the message.
**Ask:** `SELECT COUNT(DISTINCT test_id) FROM …` for the pilot set. If it returns 64 with a documented reason,
nothing is wrong and the design note just needs updating. If it returns 60, the run has 4 items' worth of trials
that don't belong to the pilot.

## 2. "Difficulty read pooled per carrier per model" — that phrase is under-powered, and it undoes N=6
"Pooled" and "per carrier per model" are opposite operations. The granularity, **not the run size**, sets the
power, and slicing to the finest cell puts us back exactly where N=3 was:
| Reading | Cells | Trials/item | Powered for a ceiling call? |
|---|---|---|---|
| fully pooled | 1 | **24** | ✅ |
| per model (pooling carriers) | 2 | **12** | ✅ — *this is what N=6 bought* |
| per carrier × model | 4 | **6** | ❌ — below the ≥8 bar |
At 6 trials, an item with true p=0.85 reads as perfect **38%** of the time and p=0.75 reads perfect **18%** —
so a per-carrier-per-model ceiling call would label a large share of well-calibrated items as uninformative and
could **STOP a healthy pilot**. That is the error N=6 was raised to eliminate.
**The carrier contrast itself is fine at 6 reps** — it is a *paired within-item* comparison, and pairing is what
makes it work. What is not fine is calling an item "at ceiling" inside a single carrier×model cell.
**Rule: read DIFFICULTY and CEILING at pooled or per-model. Read the CARRIER EFFECT paired, at any granularity.**

## 3. The harness now enforces this rather than trusting the reminder
`pilot_analysis.py` v3 emits a `stratification` block on every run — trials/item and a powered/not verdict for
each of the four granularities — and the go/no-go text names which readings are valid and which are not,
computed from the observed data rather than the intended design. New control T7 verifies it: at the real design
(24 rows/item across four cells) it reports pooled 24 ✅, per-model 12 ✅, per-carrier×model 6 ❌.
**9 controls pass.** A reminder is what failed last time; this one is in the output.

*(Test-bug note, on the record: T7 failed on first run because my synthetic data emitted 6 rows per item
**total** rather than 6 per cell — the fixture, not the code. Fixed the fixture. Worth stating because "the test
failed so I changed the threshold" is the exact move this project exists to catch, and that is not what happened
here — the threshold is unchanged.)*
