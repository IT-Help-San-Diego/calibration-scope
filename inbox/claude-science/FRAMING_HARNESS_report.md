# Framing-test analysis harness — pre-registered, written before the data
_Claude Science, 2026-07-27. Ships as `framing_analysis.py`. Seven controls, all passing._

## WHY THIS EXISTS BEFORE THE DATA
Choosing an estimator after seeing the result is how a null becomes a finding. This project has already paid
for that lesson twice — a clustering artifact published as a carrier effect, and an unmeasurable ICC read as
"items are independent." Fixing the analysis in code first makes the choice auditable.
It also carries the correction from `CORRECTION_framing_test_power.md` **in the code, not just in prose**: the
unit of analysis is the **(item, model) CELL**, majority vote over reps. Reps reduce measurement noise *within*
a cell; they are not units. An earlier version of this design pre-registered "paired within item+model+**rep**",
which counted 15 reps of 3 items as 90 observations and claimed power 1.00 where the truth was 0.03.

## WHAT IT COMPUTES
- **Primary:** McNemar on `NONE` cells, framing A vs B, exact two-sided binomial (stdlib only, no scipy).
- **Secondary:** paired test on cell *rates* — the continuous form whose false-positive rate I simulated at
  0.043–0.046, i.e. correctly calibrated.
- **Controls:** fallacy-item accuracy under B. If it drops more than 0.10, the neutral stem traded one bias for
  another and the run is inconclusive regardless of what the `NONE` items did.
- **Leave-one-item-out:** reported with every result, and flagged when significance depends on a single item.
- **Infra errors are MISSING, never WRONG** — the rule from `THERMAL_confound_opinion.md`, enforced in the reader.

## THE PRE-REGISTERED VERDICT FUNCTION
| `NONE` rate under B | Controls | Verdict |
|---|---|---|
| ≥ 0.50 | hold | **H_BIAS** — the difficulty was our stem; reword and re-run the class |
| < 0.30 | hold | **H_DEFICIT_SURVIVES** — not explained by wording (**not** proof of a deficit) |
| 0.30–0.50 | hold | **INDETERMINATE** — report the bound, pick nothing |
| any | drop > 0.10 | **INCONCLUSIVE** — redesign the neutral stem |
The four-way outcome matters: **there is a path where the data licenses no conclusion**, and it is written down
before anyone can be tempted to collapse it into one of the other three.

## VALIDATION — 7 controls, all pass
| # | Test | Result |
|---|---|---|
| T1 | strong framing effect → H_BIAS | PASS |
| T2 | **null control** — no effect must NOT invent a bias → H_DEFICIT_SURVIVES | PASS |
| T3 | controls collapse under B → INCONCLUSIVE *even with a large `NONE` rise* | PASS |
| T4 | mid-range → INDETERMINATE (must not pick a side) | PASS |
| T5 | **clustering** — 3 items × 2 models × 30 reps must yield **6 pairs, not 180** | PASS |
| T6 | infra errors treated as missing, not wrong | PASS |
| T7 | leave-one-out fragility detected at n=3 | reported (informational) |
**T5 is the one that matters.** It is a regression test against the exact error I pre-registered last turn: if a
future edit ever lets reps become units again, the suite fails.

## HOW TO RUN
```
python3 framing_analysis.py                      # self-test, no data needed
python3 framing_analysis.py framing_results.csv  # analysis + verdict
```
Required columns: `item_id, framing (A_leading|B_neutral), model, rep, pass, expected_result`;
optional `is_infra_error`. Stdlib only — no scipy, no pandas, runs anywhere.

## WHAT THIS DOES NOT DO
- It does **not** rescue an underpowered run. At 3 `NONE` items the design has 6 cells and McNemar power ~0.03;
  the harness will faithfully report a null that means nothing. **Author the 7 additional `NONE` items first.**
- It does **not** decide whether a `NONE` key is *correct* — that is item adjudication, done by reading.
- A `H_DEFICIT_SURVIVES` verdict is **failure to explain the effect away**, not evidence for a reasoning deficit.
  The harness says so in its own output text so the distinction cannot be lost downstream.
