# §10.8 update — DRAFT for DECISIONS.md, written by Claude Science
_2026-07-27. Framing is the analysis lane, not the executor's. Hermes offered to draft this; the standing_
_division is that whoever ran the numbers writes the words about them. Carey to approve before it lands._
_Status: PREVIEW from a truncated arm. Every claim below is bounded by §D._

## 10.8x Carrier Color measured in a paired within-item test (PREVIEW, runs 970/971 partials)

**Design.** 53 quant-scope items administered to `gemma-4-e2b` under two carriers — baseline and Lean —
with identical argument text, identical decoding configuration, 6 repetitions per cell. The carrier is the
only manipulated variable. (These are the paired survivors of two runs that expired on a wall-clock budget;
they are a preview of the powered run 974-977, not its result.)

**A. What the carrier did.**
The carrier changed the model's classification on **13 of 53 items**. Overall accuracy fell from
**0.840 to 0.679** (paired *t* = 2.20, *p* = 0.032, *n* = 53).
The effect is entirely confined to one half of the bank: **FALSE-keyed items were unaffected — 26 of 26 scored
1.000 under both carriers** — while TRUE-keyed accuracy fell from **0.685 to 0.370**.

**B. The direction is not uniform.**
Of 27 TRUE-keyed items, 17 ended at 0.000 and 10 at 1.000 under the carrier. **Five moved from a near-zero
baseline to a perfect score.** The net effect is a loss, but the movement runs both ways, so this is
**not** a uniform degradation of reasoning.

**C. The unexplained result, and the most interesting one.**
**Under the Lean carrier every cell became deterministic.** At baseline, 13 of 53 items produced intermediate
rates (cell rates took the values 0.00, 0.17, 0.83, 1.00); under Lean, **0 of 53 did** — every cell was exactly
6/6 or 0/6. Were rep-to-rep variability unchanged, the probability of zero intermediate cells across 53 items is
**3.3 × 10⁻⁷**. The baseline arm is stochastic on both the items the Lean arm reached (13 of 53 intermediate) and
those it did not (18 of 74), so **the determinism is a property of the carrier arm, not of the item subset the
truncation selected.**
The carrier did not make the model worse so much as **collapse its answer distribution**: uncertain on a quarter
of items under baseline, certain on all of them under Lean — sometimes certainly right, sometimes certainly wrong.

**D. Bounds. Read these as part of the finding, not as disclaimers.**
1. **Sampling behaviour is not excluded.** A prompt wrapper can alter effective sampling. If the Lean carrier
   drove effective temperature toward zero, §C is an execution artifact and §A–B require re-reading. The results
   CSV carries no temperature, seed, or logprob columns, so this **cannot** be settled from the sealed evidence.
   **A re-run of a handful of these items with temperature, seed, and logprobs logged is required before §C is
   claimed anywhere public.**
2. **No mechanism is established.** An earlier reading — that the carrier pushed the model onto a stem-length
   heuristic — is **retracted**: among TRUE-keyed items, flipped and unflipped stems are indistinguishable in
   length (269 vs 272 characters, Mann-Whitney *p* = 0.369). Length is confounded with the answer key across the
   bank (§10.8y) but has no discriminating power within the responsive half.
3. **The bank has a known defect.** A length-only rule predicts this bank's keys at 0.941 out-of-sample. The
   *within-item* carrier contrast is structurally immune to it — length is identical in both arms — but the
   effect is concentrated in exactly the half where length and key are confounded, so **generalisation to a
   leak-free bank is unestablished.**
4. **One model, one class, one truncated arm.** The Lean arm covered only the lowest item ids (199–251).
   Selection checks are reassuring (baseline accuracy 0.840 in both reached and unreached subsets,
   Mann-Whitney *p* = 0.835; TRUE-share 0.509 vs 0.527) but are not proof against an unconsidered
   id-correlated property.
5. **This does not resolve the §10.9 threshold question.** That requires the `nemotron` arms — the immune
   control — which are queued.

**E. What §10.8 may now assert, and what it may not.**
May assert: *in a controlled paired test where the carrier was the only variable, the carrier changed the
verdict on identical logical content, and under one carrier the model's answers became fully deterministic where
they had been stochastic.*
May **not** assert: that the mechanism is known, that the effect is a directional degradation, that it holds
beyond this model and bank, or that sampling behaviour has been ruled out.
**The phrase "carrier-immune" remains retired** (§10.16). Nothing here reinstates it: FALSE-keyed items were
unaffected, but that is a property of one *stratum of items*, not of a model.
