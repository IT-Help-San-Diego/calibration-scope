# Channel Contamination v1 — MEASURED FINAL RESULT (run 953, fixed grader)
_Claude Science, 2026-07-26. From channel_contamination_v1_results_regraded.csv (640 rows), analysed first-hand._
_The projection is now a measurement. The experiment is complete._

## 1. PREDICTION CHECK — confirmed on the substance, with one correction to how it's stated
My pre-hoc prediction (logged before the data arrived): *residual failures = LIT-12 only, zero adversarial,
zero LOGIC-01N; A vs A' not significant.*
**MEASURED:** adversarial items **24/24 = 100%**. LOGIC-01N **3/3 = 100%**. Non-LIT-12 failures: **0**.
A vs A' **p=0.575**. **Every substantive point confirmed. The grader fix works.**

**Correction to Hermes's framing:** the numbers are NOT "within rounding" of my 567/570 projection —
**the denominator changed**. Run 953 is **ONE fresh administration (192 rows, 1 seed)**, not a re-score of
the original 3-admin/576-row channel A. So 98.4% (189/192) vs my 99.47% (567/570) differ because
N differs, not because of measurement error. What matched **exactly** is the thing that mattered: the
FAILURE SET (3 rows, all LIT-12). State it that way — the prediction was confirmed on failure set, not on
percentage.
Also note: run 953 carries **0 infra errors** (the original had 6, all LIT-12 in channel A). So these 3
LIT-12 failures are **real scoring failures, not failed calls** — a cleaner measurement than the original.

## 2. FINAL MEASURED ARM COMPARISON
| Arm | Score | % | 95% CI (Wilson) |
|---|---|---|---|
| A (API per-item, fixed grader) | 189/192 | 98.4% | [95.5, 99.5] |
| A' (API single blob) | 64/64 | 100.0% | [94.3, 100.0] |
| B (manual chunked) | 191/192 | 99.5% | [97.1, 99.9] |
| C (manual single blob) | 191/192 | 99.5% | [97.1, 99.9] |

- **A vs A' (isolation): +1.6 pts, p = 0.575.** Paired McNemar at item level: **1:0 discordant, p = 1.000.**
  The isolation effect is **fully dissolved** (was 10:0, p=0.002 under the buggy grader). RETRACTION CONFIRMED.
- **A vs manual (B+C) (channel): p = 0.340.** No channel effect.
- All four arms' CIs overlap. **Manual Subject Mode is validated as a measurement channel — unconditionally.**

## 3. NEW FINDING from this run: the API arm is DETERMINISTIC, and that reframes LIT-12
**62 of 63 items produced byte-identical completion-token counts across all 3 reps** in run 953. (The one
exception, `AUX-APPROVAL-01`, is the known double-administered item — two prompt variants at 224 vs 225
tokens, not nondeterminism.) Latency varies; output does not. **The API arm is running at temperature ≈ 0.**
This closes the temperature confound flagged earlier, and it changes the LIT-12 story:
| Condition | LIT-12 outcome |
|---|---|
| **API (temp≈0, deterministic)** | **6/6 reps FAIL** (3 real failures in original admin2 + 3 in run 953) — fails **every time** |
| **Manual chat (temp>0)** | 2/6 admins fail — passes **4 of 6** |
Fisher p = 0.061 (borderline at this N).
**Revised interpretation — and it inverts the earlier framing.** LIT-12 is NOT "a stochastic item." At
temperature 0 the model **deterministically gets it wrong**: its greedy/modal answer on this sound-argument
control is the WRONG one (over-calling FALSECAUSE). The manual arm's *sampling noise is what rescues it* —
temperature occasionally knocks the answer off the (incorrect) mode onto the correct one.
So the correct statement is: **LIT-12 is an item the model reliably fails at its most-likely output, and
sampling variance sometimes saves it.** That is a sharper and more useful finding than "it flips" — and it
supersedes my earlier "stochastic boundary item" wording, which had the causality backwards.
**Caveat (honest):** this rests on n=6 API reps vs 6 manual admins, p=0.061 — suggestive, not established.
The decisive test remains the one already specified: LIT-11/LIT-12 alone, N≈20-30, at temp=0 vs chat temp.
That would confirm whether temperature *rescues* a deterministically-wrong answer. Worth running — it is a
genuinely interesting mechanism claim and cheap to check.
**Note it also means higher temperature can IMPROVE measured accuracy on near-boundary items** — which is
counterintuitive and matters for how the instrument sets its own sampling defaults.

## 4. FINAL DEFENSIBLE FINDINGS (the complete list)
1. **No channel effect.** API and manual chat agree (p=0.340). Manual Subject Mode validated.
2. **No presentation/isolation effect.** p=0.575, McNemar 1:0. The +15.6 pt effect was a grader artifact — RETRACTED.
3. **No chunking effect.** B == C (99.5% both).
4. **No position effects** (measured on the original dataset: B r=+0.03 p=0.73; C r=+0.12 p=0.09).
5. **API arm is deterministic (temp≈0)**; manual runs at temp>0. Documented, no longer a confound.
6. **LIT-12: deterministically failed at temp 0; sampling sometimes rescues it.** (n=6 vs 6, p=0.061 — needs the N=20-30 confirmation.)
7. **Three grader bugs found by the instrument on itself** (Unicode quotes, prompt-echo, exact-match-on-explanation), all now covered by regression fixtures including the load-bearing negative control (`NONE≠NO`).

## 5. What is still NOT established (so nobody over-reads this)
- **Equivalence is not proven, only bounded.** A' is one admin, n=64, at ceiling: CI [94.3, 100]. "No
  detectable difference, bounded at ~5 pts" — NOT "the channels are identical." A'x3 + TOST against a
  ±3-pt margin is still the outstanding item for a formal equivalence claim.
- **One model only** (google/gemma-4-31b). Generalization untested.
- **N=3 still cannot detect boundary items** — an item failing at the mode reads as "passed" whenever
  sampling rescues it. Two-pass design (N=3 to sort, high-N on flippers/near-threshold) stands.
- Specificity rests on **2 sound controls** (LIT-11, LIT-12) — one of which the model fails. Add more.
