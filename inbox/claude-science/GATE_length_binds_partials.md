# Length gate: BINDS. Hermes's "bank is honest" read is reversed — but the run should CONTINUE.
_Claude Science, 2026-07-27. Ran the pre-registered gate on `partial_trials_970_971.csv` (1,072 rows, `da09221`)._
_Verdict: no stop. The carrier contrast is safe. What is damaged is the bank's off-ceiling yield._

## 0. THE GATE FIRES
Pre-registered condition: |Spearman(length, pass)| ≥ 0.30 with p < 0.05, or baseline accuracy near 0.874.
| Quantity | Value |
|---|---|
| items observed | 127 (all quant-scope — the dead runs never reached defeasible) |
| **Spearman(length, pass rate)** | **−0.580, p = 9.2 × 10⁻¹³** |
| baseline accuracy | **0.840** (length-only reference ceiling 0.874) |
| **gate verdict** | **BINDS** |

## 1. HERMES'S READ IS REVERSED — length predicts the ANSWER, not just difficulty
Hermes reported *"failures are LONGER (268) than passes (190) → length correlates with difficulty, not with the
answer → no exploit."* **The trial-level numbers reproduce exactly (267.3 vs 193.9). The inference does not hold.**
| Key | Mean length | n items | Pass rate |
|---|---|---|---|
| **TRUE** | **258.6 chars** | 66 | **0.692** |
| **FALSE** | **147.8 chars** | 61 | **1.000** |
Mann-Whitney on length by key: **p = 5.9 × 10⁻²⁰**.
**A blind rule — "answer TRUE if the stem is ≥181 characters, else FALSE" — scores 0.953. The model scored 0.840.**
**Length outperforms the model.** So failures are longer *because failures are TRUE-keyed items*, and TRUE-keyed
items are the long ones. Length is not tracking difficulty independently of the answer; **length and the answer are
the same variable in this bank.**
The score pattern is the signature of that heuristic applied imperfectly: **366/366 correct on the short FALSE
items, 270/392 on the long TRUE ones.**

## 2. THE HONEST CAVEAT — this data cannot distinguish exploitation from easiness
There is an innocent explanation: FALSE-keyed scope items may simply be *easier* (absence of ambiguity is easier to
spot than its presence), and their being short may be incidental. **On this bank the two explanations are
observationally equivalent**, because length and key are confounded by construction — 100% of the short items are
FALSE-keyed. **No analysis of this dataset can separate them.** I am not claiming the models cheated. I am claiming
**the bank cannot tell us whether they did**, which for an instrument is the same problem.
**Therefore the fix is not analytic. It is a bank rebuild** in which length and key are decorrelated.

## 3. WHY THE RUN SHOULD NOT STOP
**The carrier contrast is structurally immune** — the carrier is applied *within* item, the same text under
baseline and Lean, so length is identical in both arms and cannot produce a differential effect. **The paired
baseline-vs-Lean estimate, which is the entire purpose of runs 974-977, is unaffected.** Same argument that cleared
the framing bank, and it holds here for the same reason.
**Stopping would cost 15 hours and buy nothing** the rebuild does not already require.

## 4. WHAT *IS* DAMAGED — the off-ceiling yield that justified this bank
The bank was built for mid-difficulty items, where the vote-based test is most sensitive. Measured:
| Half of quant-scope | Baseline accuracy | Contribution to a carrier contrast |
|---|---|---|
| FALSE-keyed (61 items) | **1.000** | **none — pinned at ceiling, zero discordant pairs** |
| TRUE-keyed (66 items) | 0.692 | the only informative half |
**Off-ceiling items: 35 of 127 = 28%.**
**CORRECTED 2026-07-27 (auditor-caught). My first version of this table reported 0.90 → 0.67 from a simulation of
293 INDEPENDENT items with no family structure** — contradicting the pre-registration, which declares the design
family-structured (118 families of 2–3 template-sharing items), and overstating even the prereg's own item-level
figure of 0.86. Redone with family structure present, which also settles the unit question: with the structure
modelled, **(item, model) and (family, model) give the same power** (0.83 vs 0.84 at d=0.05 on the full bank), as
the amendment established.
**And the corrected picture depends entirely on one assumption I cannot test from baseline-only data: do
ceiling items respond to the carrier at all?** "Ceiling compression" — the effect that made the pilot STOP —
assumes they do *not*: an item a model answers correctly every time has no room to show a small degradation.
| Assumption about the ~48% of quant-scope pinned at 1.000 | Power @ d=0.05 | @ d=0.10 |
|---|---|---|
| ceiling items respond to the carrier in full | 0.96 | 1.00 |
| respond at half strength | 0.83 | 1.00 |
| **do NOT respond (the compression case)** | **0.54** | **0.98** |
| *(if ceiling items were dropped entirely, ~32 families)* | *0.33* | — |
**So d ≈ 0.10 is resolvable under every assumption (0.98–1.00). d = 0.05 spans 0.33–0.96 and is
assumption-dependent, not established.** That is the honest statement, and d=0.05 was the figure for *locating*
the immunity threshold rather than merely detecting a large effect.
**Report the d=0.05 resolution as contingent, with the assumption named, rather than as a number.** The run itself
resolves which row of that table is true — measured carrier drops on items with baseline 1.000 versus baseline
~0.69 are directly comparable once 975 lands.
Defeasible is unmeasured here and may be fine; its key balance (74 HOLDS / 37 DEFEATED) is at least not 50/50-by-length.

## 5. THE REBUILD RULE — the gate I should have specified originally
My earlier check asked whether length *ranges overlap*. **That is the wrong test and it passed this bank.** The
right test is the one above:
> **Fit the best single length threshold to predict the key. If it beats the majority-class baseline by more than
> ~0.10, the bank leaks.** Here: 0.953 vs 0.520 = **+0.433**.
Add as `KEY_PREDICTABLE_FROM_LENGTH` (ERROR) in `itembank_lint.py`, and author to it: **long FALSE items and short
TRUE items until the rule collapses to baseline.** Do not shorten the TRUE items — the detail is what makes the
scope reading explicit.

## 6. WHAT I AM NOT CLAIMING
- **127 items of 293, one model, one class.** Defeasible is entirely unobserved and quant-scope is only ~70%
  covered. The bank-wide ratio in §4 is an extrapolation from the observed 28%.
- **The 0.953 figure is an in-sample optimum** — the threshold was fitted on the same 127 items it is scored on, so
  it is an upper bound on what a length rule achieves out of sample.
- **My gate initially returned 0% coverage and refused to report**, because the CSV keys on numeric DB `test_id`
  while the bank keys on test `name` — no join key. I used the `prompt_len` column Hermes helpfully shipped in the
  CSV instead. **The refusal was correct behaviour** (it declined rather than reporting a partial result), but it
  means the harness needs a `test_id`↔`name` mapping or a documented `prompt_len` column for the real run.
- I have not re-verified the budget constant since flagging it; Hermes confirmed per-run **scope**, which was not
  the question — **the question was the per-run VALUE**, still `5400` in committed source at last check.
