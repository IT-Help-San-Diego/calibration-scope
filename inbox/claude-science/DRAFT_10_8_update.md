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
1. **Temperature is excluded as the explanation — verified in source, not accepted on report.**
   `src/executor/mod.rs` passes a literal to the local path: `lmstudio::chat(&client, …, 4096, 0.0)`. Temperature
   is **0.0 on every local trial in both arms**, so there was no temperature for the carrier to change. (The
   executor's own `verdict.rs` states the same design intent: *"Our harness is deterministic — temperature 0,
   pinned stimuli, SHA-3 sealed evidence."*)
   **This makes §C stronger and relocates the puzzle:** at temperature 0 the *baseline* should already be
   deterministic, and it is not — 13 of 53 cells vary across repetitions. So the baseline carries genuine
   sampler-level nondeterminism, and the Lean carrier **removes** it. That is a more specific claim than
   "the carrier reduces accuracy."
2. **ONE artifact remains open, and it is answerable from the database.** Temperature-0 nondeterminism has known
   sources: batching and KV-cache effects, GPU float non-associativity, and **speculative decoding**. This harness
   supports speculative decoding, and `migrations/033_speculative_decode_stats.sql` records
   `speculative_draft_model`, `total_draft_tokens_count`, and accepted/rejected draft-token counts **per trial**.
   **If a draft model was active in one arm and not the other, that alone would produce exactly this
   signature** — stochastic in one arm, deterministic in the other — with no carrier effect at all.
   The exported CSV omits these columns, so it cannot be settled from the sealed export. **One query settles it:
   per carrier arm, count trials with a non-null `speculative_draft_model`. §C should not be published until that
   count is reported and equal across arms.**
3. **No mechanism is established.** An earlier reading — that the carrier pushed the model onto a stem-length
   heuristic — is **retracted**: among TRUE-keyed items, flipped and unflipped stems are indistinguishable in
   length (269 vs 272 characters, Mann-Whitney *p* = 0.369). Length is confounded with the answer key across the
   bank (§10.8y) but has no discriminating power within the responsive half.
4. **The bank has a known defect.** A length-only rule predicts this bank's keys at 0.941 out-of-sample. The
   *within-item* carrier contrast is structurally immune to it — length is identical in both arms — but the
   effect is concentrated in exactly the half where length and key are confounded, so **generalisation to a
   leak-free bank is unestablished.**
5. **One model, one class, one truncated arm.** The Lean arm covered only the lowest item ids (199–251).
   Selection checks are reassuring (baseline accuracy 0.840 in both reached and unreached subsets,
   Mann-Whitney *p* = 0.835; TRUE-share 0.509 vs 0.527) but are not proof against an unconsidered
   id-correlated property.
6. **This does not resolve the §10.9 threshold question.** That requires the `nemotron` arms — the immune
   control — which are queued.

**E. What §10.8 may now assert, and what it may not.**
May assert: *in a controlled paired test where the carrier was the only variable, the carrier changed the
verdict on identical logical content, and under one carrier the model's answers became fully deterministic where
they had been stochastic.*
May **not** assert: that the mechanism is known, that the effect is a directional degradation, that it holds
beyond this model and bank, or that speculative decoding has been ruled out as the source of the variance difference (temperature has been).
**The phrase "carrier-immune" remains retired** (§10.16). Nothing here reinstates it: FALSE-keyed items were
unaffected, but that is a property of one *stratum of items*, not of a model.
