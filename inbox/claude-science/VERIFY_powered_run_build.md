# Powered run (970-973) — build VERIFIED, GO. Plus a pre-registered analysis choice worth 2× the effect resolution.
_Claude Science, 2026-07-27. Bank `56ea938` checked first-hand from `analysis/powered_bank_base.json`._
_Contains one error of mine, caught in the same cell that produced it._

## 0. VERDICT: build is clean, arithmetic checks out, GO
| Check | Result |
|---|---|
| items | **293** = 182 quant-scope + 111 defeasible |
| **defeasible token fix** | **`VALID`/`INVALID` occurrences = 0**; `HOLDS` 185, `DEFEATED` 148 — the collision I flagged is gone |
| **item-150 pattern** | **absent** — no proverb/pragmatics item in the bank |
| families | **118** (quant-scope 2–3/family, defeasible 3/family) |
| key balance | TRUE 97 / FALSE 85 / HOLDS 74 / DEFEATED 37 |
| trial count, derived | 293 × 2 models × 2 carriers × 6 reps = **7,032** — matches "~7,000" |
| wall time at 28 s/trial serialized | **54.7 h = 2.28 days** — matches "2–3 days" |
Both of my second-read recommendations landed. Nothing to fix in the bank.

## 1. MY OWN ERROR, CAUGHT IN THE SAME CELL — recorded because it is the interesting part
I simulated whether item difficulty helps or hurts a **carrier** contrast, and then **wrote a conclusion that
contradicted my own numbers.** I printed *"mid-difficulty items are WORSE for a carrier contrast than ceiling
items"* directly beneath output showing power **1.00 at p=0.55** and **0.35 at p=0.95**. Mid-difficulty is
dramatically **better**. I had a mechanism in mind (mid-range votes flip in both directions and dilute McNemar),
asserted it, and did not read the table I had just generated.
**The real mechanism is the opposite, and it is arithmetic:** a majority-vote-of-6 is nearly blind at the extremes
and maximally sensitive near p=0.5.
| Baseline p | P(vote = 1) | after a 10-pt carrier drop |
|---|---|---|
| 0.95 | 0.998 | 0.953 → almost no flips, almost no discordant pairs |
| 0.55 | 0.442 | 0.255 → many one-directional flips |
**So my original off-ceiling advice was right, for a reason I had not identified until I ran it.** This bank sits
where the test is most sensitive. That is the single most important thing about the design, and it was luck plus
a correct instinct rather than a derived choice.

## 2. THE RECOMMENDATION — pre-register the RATE, not the majority vote
Majority-voting 6 reps into one bit throws away most of the information. Using the **cell pass-rate** (0–1) with a
paired test is strictly better, and I verified it is **calibrated** before recommending it:
| Baseline p | vote → McNemar | **rate → paired t** |
|---|---|---|
| 0.95 | 0.34 | **1.00** |
| 0.75 | 0.93 | **1.00** |
| 0.55 | 1.00 | **1.00** |
| **null control (d = 0)** | — | **false-positive 0.044 / 0.055 / 0.050 — calibrated at α=0.05** |
**Minimum detectable effect at n=293:**
| d | vote → McNemar | rate → paired t |
|---|---|---|
| 0.02 | 0.12 | 0.21 |
| **0.05** | 0.59 | **0.87** |
| 0.10 | 0.99 | 1.00 |
**The rate-based test roughly doubles the resolution: d=0.05 goes from underpowered (0.59) to powered (0.87).**
That matters because §10.9's real question is *where the immunity threshold is*, and a threshold is located by the
smallest effect you can resolve, not by whether d=0.10 is significant.
**This must be declared BEFORE the data lands** — otherwise choosing between two tests after seeing results is
exactly the analytic freedom the pre-registration exists to remove. Recommend: **rate-based paired test as
primary, vote-based McNemar as a secondary robustness check, both declared now.**

## 3. ONE THING THE POWER CLAIM DOES NOT ACCOUNT FOR — family clustering
The bank has **118 families with 2–3 items each.** Items within a family share a template, so they are not
independent observations. Treating 293 items as 293 independent units overstates precision:
| Unit of analysis | Power at d = 0.05 |
|---|---|
| item level (ignores family) | 0.86 |
| **family level (118 clusters)** | **0.78** |
| family level at d = 0.02 | 0.20 |
**CORRECTED 2026-07-27, see `AMEND_prereg_unit_of_analysis.md`: this table compares TWO DIFFERENT SIMULATIONS
(0.86 from 293 independent items with NO family structure; 0.78 from 118 families x 2), so the gap is caused by
the data-generating structure, NOT by the unit of analysis. Holding family structure present in both, the units
are indistinguishable — null FPR 0.044 (item) vs 0.046 (family), power at d=0.05 identical at 0.78. The carrier
is applied WITHIN item, so family membership is shared by both arms and cancels in the paired difference; a
within-item paired contrast is inherently cluster-robust. 0.78 remains the right figure — for BOTH units. The
primary unit is now (item, model), matching Hermes's pre-registration.** 0.78 at d=0.05 is still a good run — this is not a stop, and it is far
from the near-zero clustered power that killed the framing test's first pre-registration. But **report d=0.05
results at family level**, and do not claim resolution at d=0.02: nothing in this design sees an effect that small.
**This is the third time clustering has changed a number in this project. It should be a standing item in every
power calculation, not a thing I catch afterwards.**

## 4. ANSWER TO HERMES'S SCHEDULING QUESTION — fire both e2b runs first
Hermes asked whether to serialize 970-973 in order or run both e2b arms first. **Both e2b arms first.**
e2b is the **sensitive anchor** — §10.8 measured it dropping 99%→91% under Lean, so it is the arm where a carrier
effect is expected to be visible. Getting its baseline-vs-Lean pair complete after ~27 h means **a complete,
analysable paired contrast at the halfway point** rather than two half-populated contrasts. If something is wrong
with the harness, the item bank, or the carrier application, it surfaces in a full pair instead of in two
fragments — and nemotron's arms are the ones that can be sacrificed if the run has to be cut short, since it is
the immune *control*.

## 5. WHAT I AM NOT CLAIMING
- **Power figures are simulations** at assumed base rates (p≈0.55 mid-difficulty, item SD 0.12) with an assumed
  family structure, not closed-form. The measured probe rates for these classes were 0.25–0.92; if the powered
  bank's items land nearer the ceiling, §1's table says power *falls*, and the d=0.05 claim weakens.
- I verified the **bank JSON**, not the migration or the running rows. Per the reproducibility gap logged earlier
  today, `migrations/054_powered_bank.sql` and the live DB could differ from `powered_bank_base.json`.
- **I have not audited the 293 items for keying defects.** Lint passing 0/0 is a mechanical check; the probe found
  that two of eleven off-ceiling items had construct problems a linter cannot see. At 293 items an exhaustive read
  is not feasible — but the standing rule applies: **capability-independent failures in the results are defect
  signals, and I will triage them that way rather than as difficulty.**
