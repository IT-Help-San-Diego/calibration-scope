# The partials contain a PREVIEW of the primary result — and it answers the ceiling question I said was unanswerable
_Claude Science, 2026-07-27. 53 of the 127 partial items have BOTH carrier arms. I said the partials had "zero_
_carrier evidence." That was wrong — I checked and there is a paired contrast in there._

**SUPERSEDED IN PART (2026-07-27).** §3's length-heuristic mechanism is **RETRACTED** (refuted the same day:
flipped vs non-flipped TRUE-keyed stems 269 vs 272 chars, Mann-Whitney p = 0.369) and §4's d=0.05 power figure is
**CORRECTED** (it imported a number from a homogeneous-shift simulation that the bimodal measurement refutes).
**Read `ANSWER_is_carrier_color_proven.md` and `DRAFT_10_8_update.md` for the current reading before citing
anything here.** The descriptive measurements in this memo stand; the causal readings do not.

## 0. TWO CORRECTIONS TO MY OWN CLAIMS FIRST
1. **"The partials have no Lean arm → zero carrier evidence."** False. **53 items carry both arms at 6 reps each**,
   because run 971 (e2b Lean) got through the first 53 items before its budget expired. That is a real, if small,
   paired contrast.
2. **My power memo said the ceiling-degradation question could only be answered "once 975 lands."** It can be
   answered now, and it is answered below.

## 1. THE PREVIEW — a carrier effect is present
| Quantity | Value |
|---|---|
| paired items (e2b, quant-scope) | **53** |
| baseline → Lean | **0.840 → 0.679** |
| drop | **+0.160** |
| paired t | t = 2.20, **p = 0.032**, n = 53 |
A ~16-point carrier effect on the sensitive anchor, which is the neighbourhood the powered run was sized for
(d ≈ 0.10 resolvable under every assumption).

## 2. CEILING ITEMS *DO* DEGRADE — and not the way "compression" predicts
My assumption table said everything hinged on whether items pinned at 1.000 can degrade. Measured:
| Baseline stratum | n | baseline | Lean | drop |
|---|---|---|---|---|
| **ceiling (1.000)** | 39 | 1.000 | **0.744** | **+0.256** (t=3.62, p=0.00086) |
| off-ceiling | 14 | 0.393 | 0.500 | −0.107 (t=−0.60, **p=0.56 — indistinguishable from zero**) |
**So the compression row of my table is falsified: ceiling items are where the effect IS.** The off-ceiling
"improvement" is noise and must not be reported as "Lean helps hard items."
**But the mechanism is not gentle degradation.** Of the 39 ceiling items, **29 are perfectly flat and 10 collapse
from 1.000 to exactly 0.000.** Every one of the ten goes to zero. That is not compression and not a small
carrier tax — it is **all-or-nothing**.

## 3. ~~WHAT THE COLLAPSE ACTUALLY IS — the length heuristic~~ **RETRACTED 2026-07-27, same day, by its own test**
**The mechanism asserted in v1 of this section is WRONG and is retracted in full.** See
`ANSWER_is_carrier_color_proven.md` §1. The refutation:
- Among the 27 TRUE-keyed paired items, **flipped and non-flipped stems are indistinguishable in length —
  269 vs 272 characters, Mann-Whitney p = 0.369.** Every TRUE-keyed item is long, so the length cue is *constant
  within the group that flips* and **cannot explain which items flip.**
- v1 also described the effect as the model moving "further toward answering FALSE." **The movement is
  BIDIRECTIONAL:** of 27 TRUE-keyed items, 17 end at 0.000 and 10 end at 1.000, and **five move from a near-zero
  baseline to a perfect score under the carrier.** The ten "collapsing" items were selected *because* they
  collapsed — selection on the outcome.
**The descriptive numbers below are correct and are retained as evidence; only the causal reading was wrong.**
| | n | mean length | TRUE-keyed share | Lean accuracy |
|---|---|---|---|---|
| collapse to 0.000 | 10 | 269 chars | 1.00 | 0.000 |
| flat at 1.000 | 29 | 157 chars | 0.10 | 1.000 |
| Arm | TRUE-keyed | FALSE-keyed |
|---|---|---|
| baseline | 0.685 | 1.000 |
| Lean | 0.380 | 1.000 |
**What survives:** FALSE-keyed accuracy is pinned at 1.000 in both arms, so every point of the carrier effect comes
out of TRUE-keyed items. **What does not survive:** any claim about *why*. **No mechanism is established.**
**And the finding that replaced it** — the one this memo missed entirely — is that the carrier makes the model
**deterministic**: 13 of 53 cells give intermediate rates at baseline, **0 of 53 under Lean**. That is the result
worth pursuing, and it is blocked pending exclusion of a sampling-temperature artifact
(`ANSWER_is_carrier_color_proven.md` §3–4).

## 4. WHAT THIS MEANS FOR THE POWERED RUN — better than expected, with one large caveat
- **CORRECTED 2026-07-27 (auditor-caught).** I wrote that the measured behaviour matches the "ceiling items respond
  in full" row and imported its **0.96** figure. **That row's simulation shifts EVERY ceiling item; the measured
  pattern is bimodal — 29 of 39 perfectly flat, 10 collapsing — and FALSE-keyed items are inert in both arms.**
  Mapping a bimodal measurement onto a homogeneous-shift simulation and importing its number was invalid.
  Re-simulated from the measured structure (≈49% of cells structurally inert, the rest carrying the whole effect):
  power is **≥0.97 at d=0.05** and 1.00 at the observed d≈0.16, with null FPR 0.045–0.047 (calibrated). **But the
  more important point is that this data cannot speak to d=0.05 at all** — the observed effect is d≈0.16, and a
  power figure for d=0.05 rests on an assumed distribution of *small* effects that has not been observed.
  **Report the run as resolving the effect it measures; do not attach a d=0.05 power number to this evidence.**
- **But the effect is concentrated in TRUE-keyed items**, i.e. exactly the half where length and key are
  confounded. **So the run's headline carrier number and the bank's leak are entangled**: an observed carrier drop
  is partly "the carrier makes the model rely more on a cue that this bank made diagnostic." A bank without the
  length-key correlation might show a smaller effect, a larger one, or a different mechanism. **The measurement is
  real; its generalisation to leak-free banks is not established.**

## 5. ON CALLING THIS "CARRIER COLOR IN THE RAW" — the 0.941-beats-0.840 comparison needs care
Hermes framed the leak as *"the model is doing worse than a rule that never reads the argument."* The number holds
up: I cross-validated it — in-sample 0.953, **repeated 10-fold out-of-sample 0.941 ± 0.067**, against the model's
0.840. **The leak is not an overfitting artifact.**
**But the comparison is not model-versus-baseline in the usual sense.** The length rule was *fitted on this bank's
length↔key correlation*; it has information about the answer key that the model does not. Beating the model is what
a leakage detector is supposed to do — **it measures the bank's defect, not the model's incompetence.**
And **Carrier Color is a within-item claim** (same content, different dressing) whereas the 0.941 figure is a
**between-item** artifact with no carrier involved. **The genuine Carrier Color evidence here is §2–3**, which is
within-item and does show the carrier moving the verdict. Cite that, not the length rule.

## 6. WHAT I AM NOT CLAIMING
- **53 items, one model, one class, one truncated run.** p = 0.032 on n = 53 is a preview, not the result.
- **The paired subset is an ORDERED subset, not random** — run 971 died after processing the lowest item ids
  (199–251; unpaired are 252–325). Selection checks are reassuring but not proof: baseline accuracy is 0.840 in
  both groups (Mann-Whitney p = 0.835) and TRUE-share is 0.509 vs 0.527. Any property correlated with item id that
  I have not thought of remains a confound.
- **"Pushed onto the length heuristic" is my reading of the by-key pattern, not a measured mechanism.** I have not
  seen the raw responses. If the model's Lean-arm answers were inspected and did not skew toward FALSE, this
  reading is wrong. **That check is cheap and worth doing: tabulate the actual response tokens by arm.**
- The 10-vs-29 split is 39 items. A single miscoded item moves the collapse count by 10%.
