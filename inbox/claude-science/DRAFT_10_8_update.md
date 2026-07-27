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
2. **Speculative decoding is excluded** (`spec_decode_artifact_ruled_out.json`, `f255876`): zero
   `speculative_draft_model`, zero draft tokens, zero accepted draft tokens **in both arms**. This was the check I
   named as blocking; it came back clean, and with temperature fixed at 0.0 and configs byte-identical, **the
   execution-side confounds I can name are exhausted.**
3. **State the variance result on the PAIRED items, not on mismatched denominators.** The figures in circulation —
   "baseline stochastic on 31/66, Lean deterministic on 0/27" — are both correct but describe **different item
   sets**: 66 is the full baseline arm, 27 is only the TRUE-keyed subset the truncated Lean arm reached. The valid
   comparison uses the same items in both arms:
   | Arm | TRUE-keyed paired items with a stochastic cell |
   |---|---|
   | baseline | **13 of 27 (0.481)** |
   | Lean | **0 of 27 (0.000)** |
   **McNemar exact (paired) p = 2.4 × 10⁻⁴**, on 13 discordant pairs — 13 items stochastic under baseline and
   deterministic under Lean, **0 in the reverse direction.**
   **Test correction (2026-07-27):** an earlier version of this section reported *Fisher exact p = 3.6 × 10⁻⁵*.
   **Fisher treats the two arms as independent samples, which this design is not** — the same 27 items appear in
   both arms. The paired test is McNemar, and it gives a p roughly 7× larger. The conclusion is unchanged and the
   direction is perfectly asymmetric, but **2.4 × 10⁻⁴ is the number that may appear in print; 3.6 × 10⁻⁵ was
   anti-conservative.** (This is the same independence-versus-pairing error class retracted earlier in this
   session; it recurred in a cell whose own header said "paired.")
4. **One residual mechanism I cannot exclude, and it is not in the confound ladder.** With temperature at 0 and no
   draft model, residual nondeterminism comes from float non-associativity in batched matrix multiplication, which
   is **sequence-length dependent**. The Lean wrapper necessarily changes the wrapped prompt's token count, so the
   two arms may sit in different numerical regimes. That could produce a determinism difference **without any
   carrier effect on reasoning.** The exported `prompt_len` is the *base item* length (identical across arms by
   design), so it cannot test this. **Logging the wrapped prompt's token count per trial would settle it**, and
   until then "the carrier changes whether the model commits" has a live mechanical alternative: "longer prompts
   land in a more stable numerical regime."
5. **No mechanism is established.** An earlier reading — that the carrier pushed the model onto a stem-length
   heuristic — is **retracted**: among TRUE-keyed items, flipped and unflipped stems are indistinguishable in
   length (269 vs 272 characters, Mann-Whitney *p* = 0.369). Length is confounded with the answer key across the
   bank (§10.8y) but has no discriminating power within the responsive half.
6. **The bank has a known defect.** A length-only rule predicts this bank's keys at 0.941 out-of-sample. The
   *within-item* carrier contrast is structurally immune to it — length is identical in both arms — but the
   effect is concentrated in exactly the half where length and key are confounded, so **generalisation to a
   leak-free bank is unestablished.**
7. **One model, one class, one truncated arm.** The Lean arm covered only the lowest item ids (199–251).
   Selection checks are reassuring (baseline accuracy 0.840 in both reached and unreached subsets,
   Mann-Whitney *p* = 0.835; TRUE-share 0.509 vs 0.527) but are not proof against an unconsidered
   id-correlated property.
8. **This does not resolve the §10.9 threshold question.** That requires the `nemotron` arms — the immune
   control — which are queued.

**E. What §10.8 may now assert, and what it may not.**
May assert: *in a controlled paired test where the carrier was the only variable, the carrier changed the
verdict on identical logical content, and under one carrier the model's answers became fully deterministic where
they had been stochastic.*
May **not** assert: that the mechanism is known, that the effect is a directional degradation, that it holds
beyond this model and bank, or that the variance collapse reflects reasoning rather than a sequence-length-dependent numerical regime (temperature and speculative decoding ARE excluded; wrapped-prompt length is not).
**The phrase "carrier-immune" remains retired** (§10.16). Nothing here reinstates it: FALSE-keyed items were
unaffected, but that is a property of one *stratum of items*, not of a model.
