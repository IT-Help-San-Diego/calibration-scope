# Is Carrier Color proven? — the honest answer, and two corrections to what has been claimed
_Claude Science, 2026-07-27. Carey asked directly. This corrects a mechanism claim of MINE that Hermes then relayed._

## 0. THE SHORT ANSWER
**You have proven the phenomenon exists and is measurable on this instrument. You have not proven the mechanism,
and the mechanism that has been written down twice — including by me — is contradicted by the data.**
What is established, on 53 paired items, same argument text, only the wrapper differing:
| Finding | Status |
|---|---|
| The carrier changes the verdict on identical logical content | **ESTABLISHED** (13 of 53 items change classification) |
| Net accuracy effect on TRUE-keyed items: 0.685 → 0.370 | **MEASURED** (paired t p = 0.032 overall) |
| FALSE-keyed items totally unaffected: 26/26 at 1.000 both arms | **MEASURED** |
| The carrier pushes the model onto a *length* heuristic | **CONTRADICTED — retract** |
| The effect is a directional degradation (TRUE→FALSE) | **CONTRADICTED — it is bidirectional** |
| The carrier **eliminates rep-to-rep variance** | **the strongest result in the data, and unexplained** |

## 1. CORRECTION 1 — the length-heuristic mechanism is not supported. This was my claim.
I proposed that the Lean carrier "pushed the model harder onto the length heuristic," and Hermes verified the
token-level flip and relayed the mechanism as confirmed. **The token flip is real; the mechanism is not.**
Among TRUE-keyed paired items, **flipped and non-flipped items have indistinguishable lengths — 269 vs 272 chars,
Mann-Whitney p = 0.369.** Every TRUE-keyed item is long, so the length cue is *constant within the group that
flips* and cannot explain **which** items flip. Length is confounded with key across the bank, which is what the
gate found; it has **no discriminating power inside the responsive half.**
**Hermes's verification did exactly what I asked and confirmed the flip. It could not have caught this, because I
asked the wrong question** — I asked whether the answers moved toward FALSE, not whether length predicted which
items moved.

## 2. CORRECTION 2 — the movement is bidirectional, and the "10 collapsing items" were selected on the outcome
"All 10 collapsing items flip TRUE→FALSE, deterministic 6/6" is true and verified (I re-derived those 10 item ids
independently and they match `mechanism_check_token_flip.json` exactly). **But those ten were chosen *because* they
collapsed.** Across all 27 TRUE-keyed paired items:
| Transition | n |
|---|---|
| 1.000 → 0.000 | 10 |
| 0.83 → 0.000 | 3 |
| 0.17 → 0.000 | 4 |
| **0.17 → 1.000** | **4** |
| **0.00 → 1.000** | **1** |
| 0.83 → 1.000 | 2 |
| 1.000 → 1.000 | 3 |
**Five items move from a near-zero baseline to a perfect score under the carrier.** The net effect is negative, but
the movement runs both ways. **"The carrier degrades reasoning" is not what this shows.**

## 3. THE FINDING NOBODY HAS NAMED — the carrier makes the model deterministic
| Arm | Items with an intermediate rate (0 < rate < 1) |
|---|---|
| baseline | **13 of 53** — distinct cell rates 0.00, 0.17, 0.83, 1.00 |
| **Lean** | **0 of 53** — every cell is exactly 6/6 or 0/6 |
If Lean had the same rep-to-rep variability as baseline, the probability of zero intermediate cells across 53
items is **3.3 × 10⁻⁷**.
**Control for the obvious confound:** the baseline arm is stochastic on *both* the 53 items the Lean arm reached
(13 intermediate) and the 74 it didn't (18 intermediate) — so **determinism is a property of the Lean arm, not of
the item subset truncation happened to select.**
**This is a stronger and stranger claim than accuracy loss: the carrier does not degrade the model, it collapses
the model's answer distribution.** Under baseline the model is uncertain on 25% of items; under Lean it is
certain on all of them — sometimes certainly right, sometimes certainly wrong.

## 4. THE ALTERNATIVE THAT MUST BE RULED OUT BEFORE ANY OF THIS IS PUBLISHED
**A prompt wrapper can change effective sampling behaviour.** If the Lean carrier drove the effective temperature
toward zero, determinism follows trivially and is an **execution artifact, not a reasoning finding** — and the
accuracy change would then be a side-effect of collapsed sampling rather than of carrier interpretation.
**I cannot test this from the CSV**, which has no temperature, seed, or logprob columns.
**Required before publication:** re-run a handful of these items with temperature and seed logged, and inspect
per-trial logprobs or at least the raw response strings under both carriers. **If Lean is running at a different
effective temperature, §3 is an artifact and §1–2 need re-reading.** This is the single highest-value check
remaining, and it is cheap.

## 5. SO WHAT CAN BE SAID PUBLICLY, TODAY
**Defensible:** *"In a controlled paired test — same arguments, same model, same decoding settings, only the prompt
carrier differing — the carrier changed the model's verdict on 13 of 53 items, and under one carrier the model's
answers became fully deterministic where they had been stochastic. The carrier, not the argument, determined the
answer on those items."*
**Not defensible yet:** that the mechanism is a length heuristic (contradicted), that the effect is a directional
degradation (bidirectional), that it generalises beyond this model and this bank (one model, one class, a bank with
a known length↔key confound), or that sampling behaviour has been excluded as the explanation (it has not).
**And the honest framing of the word "proven":** this is one truncated arm of one run on one model. **It is the
strongest evidence the project has produced, and it is a preview, not the result.** The nemotron arms are the
control that turns a demonstration into a threshold map.

## 6. WHAT I AM NOT CLAIMING
- 53 items, one model, one class, from a **truncated** run whose Lean arm covered only the lowest item ids
  (199–251). Selection checks are reassuring (baseline accuracy 0.840 in both groups, p = 0.835) but not proof.
- The transition counts in §2 rest on 27 items; single-item miscoding moves them materially.
- §3's p-value assumes baseline variability as the null; it is a descriptive contrast, not a modelled test of
  sampling behaviour — which is exactly what §4 says must be measured directly.
