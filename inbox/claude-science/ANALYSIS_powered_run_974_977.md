# Powered run 974-977 — the pre-registered analysis, run on the sealed CSV
_Claude Science, 2026-07-27. `analysis/powered_run_974_977.csv`, sha256 `52c5db8323979466…`, 7,032 rows._
_I ran the harness I wrote before the data existed. Two of the three things I asked for are now answered,_
_and one of them goes against the headline._

## 0. GATES — ALL PASS
| Gate | Result |
|---|---|
| `EXPECTED_ROWS = 7032` | **7,032 — PASS.** No truncation. This is the gate that caught 970/971. |
| cells complete | **1,172 = 293 × 2 × 2**, exactly 6 reps in every cell |
| infra errors | **0** |
| items / families | 293 / 118, as specced |
**The data is clean. Hermes's execution was correct.**

## 1. THE REPORTED MEANS REPRODUCE EXACTLY
| Model | baseline | Lean | Δ | t | p |
|---|---|---|---|---|---|
| gemma-4-e2b | 0.771 | 0.699 | **−0.072** | −2.47 | 0.014 |
| nemotron-3-nano-omni | 0.867 | 0.857 | −0.010 | −0.42 | 0.675 |

## 2. THE THRESHOLD CLAIM IS **NOT** SUPPORTED — and I predicted the escape route that failed
I flagged that "significant in A, not in B" is not a test of the interaction, and estimated it at p ≈ 0.10 under
independence, noting that **cross-model correlation ρ ≳ 0.3 would rescue it.** Measured:
- **ρ = +0.104** — per-item carrier effects barely correlate across models. The rescue does not happen.
- **paired interaction: Δ-of-Δ = −0.061, t = −1.71, p = 0.088, n = 293.**
**So §10.9's threshold question is answered, and the answer is "not at this power."** The direction is right; the
evidence is not there. **`DECISIONS.md` and any copy must say *"consistent with a capability threshold, interaction
not significant (p = 0.088)"*, never "that's the threshold."**

## 3. THE VARIANCE COLLAPSE REPLICATES — AND ITS MEANING CHANGES
| Model | stochastic at baseline | under Lean | McNemar |
|---|---|---|---|
| **gemma-4-e2b** | **48 / 293** | **3 / 293** | **p = 4.4 × 10⁻¹²** |
| nemotron | **0 / 293** | 0 / 293 | no discordant pairs |
**The e2b collapse is real and far stronger than the 53-item preview** (47 items collapse, 2 go the other way).
**But nemotron is fully deterministic in *both* arms** — there was no variance to collapse. **So "the carrier
determines whether the model is uncertain at all" is, on this evidence, a property of one model that happens to be
stochastic at baseline.** It is not a general property of carriers, and the site copy's single-carrier scoping
should now also become **single-model** scoping.
**And the tempting rescue fails too:** "e2b stochastic/sensitive vs nemotron deterministic/immune = threshold" does
not hold, because **e2b is itself deterministic on 83.6% of items.** The models differ in *degree*, and degree is
confounded with accuracy (0.771 vs 0.867).

## 4. THE EFFECT IS NOT WHERE THE MECHANISM STORY PUT IT
If the carrier works by collapsing uncertainty, the accuracy damage should concentrate in the items that *were*
uncertain. It does not:
| e2b items | Δ | p |
|---|---|---|
| stochastic at baseline (48) | −0.125 | 0.171 |
| **deterministic at baseline (245)** | **−0.061** | **0.042** |
**Only 29% of the total effect mass comes from the stochastic items.** The significant accuracy loss is in items
that were already deterministic — the carrier is **flipping confident answers**, not merely resolving uncertain
ones. **That is a different mechanism from the one in circulation, and it is the more interesting finding.**
**Per-class:** the e2b damage is concentrated in **quant-scope (0.777 → 0.680)**; defeasible barely moves
(0.760 → 0.730). Nemotron's defeasible arm actually *improves* (0.883 → 0.901).

## 5. WHAT I AM NOT CLAIMING
- These are the pre-registered primary and the declared secondaries. **The family-level clustered secondary and the
  length-leak gate are not in this note** — next pass.
- p = 0.088 is **not** evidence of no interaction. It is insufficient evidence of one. A third model, or more items,
  could resolve it; nothing here says the threshold is false.
- §4's mechanism reading is **post-hoc** — I did not pre-register a stochastic/deterministic split. It should be
  treated as a hypothesis for the next run, not a result.
- **978 (the neutral-carrier control) is still the deciding test for content-vs-length**, and nothing here touches
  it. Per the corrected spec, **C1 is the length test and a positive there retracts the variance claim.**
