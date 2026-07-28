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

## 4. THE CARRIER DAMAGES ALREADY-CONFIDENT ITEMS TOO — and my first reading of this was wrong
**RETRACTED AND REWRITTEN 2026-07-27.** The first version of this section was headed *"the effect is not where the
mechanism story put it"* and concluded the carrier flips confident answers rather than resolving uncertain ones.
**That contradicted the table printed directly beneath it, and I committed the exact fallacy §2 of this same
document names.**
| e2b items | Δ per item | p vs 0 |
|---|---|---|
| stochastic at baseline (48) | **−0.125** | 0.171 |
| deterministic at baseline (245) | **−0.061** | 0.042 |
**Per item, the uncertain stratum is damaged twice as hard.** My claim rested on which stratum reached p < 0.05 —
which is driven by **n = 245 vs n = 48**, not by effect size — and that is "significant in A, not in B is not a test
of the interaction," the error I had just diagnosed in the threshold claim two sections earlier.
**The interaction I failed to run, now run:** Welch t = −0.67, **p = 0.504**; Mann-Whitney **p = 0.274.**
**The two strata are not distinguishable.** The point estimate favours the uncertainty story, not against it.
**The "71% of effect mass" figure was worse than unsupported — it pointed the other way.** Deterministic items are
**84%** of the bank and carry **71%** of the mass. Under equal per-item damage, mass share would equal headcount
share. **71 < 84 means that stratum is damaged *less* per item** — I quoted a number whose own arithmetic
contradicted the sentence it was supporting.
**What the data does support, stated at its actual strength:** **245 items that were fully deterministic at baseline
still lose 0.061 each under the carrier (p = 0.042).** So the carrier is **not acting only on uncertain items** —
confident answers move too. It does **not** follow that confident items are where the damage concentrates.

## 5. WHAT I AM NOT CLAIMING
- These are the pre-registered primary and the declared secondaries. **The family-level clustered secondary and the
  length-leak gate are not in this note** — next pass.
- p = 0.088 is **not** evidence of no interaction. It is insufficient evidence of one. A third model, or more items,
  could resolve it; nothing here says the threshold is false.
- §4's stratification is **post-hoc** — I did not pre-register a stochastic/deterministic split — **and the
  post-hoc caveat did not save me**: the first version's directional claim was contradicted by its own effect
  sizes, not merely under-powered. A caveat about provenance does not repair a conclusion that the numbers
  point away from.
- **978 (the neutral-carrier control) is still the deciding test for content-vs-length**, and nothing here touches
  it. Per the corrected spec, **C1 is the length test and a positive there retracts the variance claim.**
