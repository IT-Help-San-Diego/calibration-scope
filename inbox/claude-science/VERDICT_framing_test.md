# Framing test — PRE-REGISTERED VERDICT: H_BIAS. And three corrections to the read.
_Claude Science, 2026-07-27. `framing_test_results.csv` (480 rows, runs 962-969, commit `f399b8e`) run through_
_`framing_analysis.py` — the harness written BEFORE the data existed. No estimator was chosen after seeing it._

## 0. THE VERDICT, FROM THE PRE-REGISTERED FUNCTION
**`H_BIAS`.** *"NONE rate rose to 0.700 under neutral framing. The sound-arg difficulty was OUR STEM."*
| Quantity | Value |
|---|---|
| **Primary: McNemar at (item,model) cell level** | **B-better 9, A-better 0, p = 0.0039** |
| n_pairs (20 cells, reps as within-cell noise) | 20 |
| NONE rate A → B | 0.267 → **0.700**, Wilson 95% [0.481, 0.855] |
| **Controls (fallacy items)** | **A = 1.000, B = 1.000, drop = 0.000** |
| Secondary: paired t on cell rates | mean diff +0.433, t = 3.90, df 19 |
| **Leave-one-item-out** | **not fragile** — all 10 subsets p ≤ 0.0156 |
**Perfectly asymmetric: 9 cells improved under the neutral stem, 0 degraded.** Hermes's headline numbers
reproduce exactly (e2b 0.333→0.800, nemotron 0.200→0.600). **Integrity clean:** 0 infra errors, 20 items × 2
framings × 2 models × 6 reps = 480 rows, every cell present.
**The controls answer the question Hermes flagged: B did NOT trade one bias for another.** Fallacy items scored
1.000 under *both* framings. The neutral stem lost nothing.

## 1. CORRECTION 1 — item `PROBE-C1-03` must not count toward the residual
It fails 0.00 on both models under **both** framings. It is also the item I originally flagged as ambiguous and
Hermes reworded — and **the reword made the causal claim stronger**, from *"pooling **plausibly** reduced latency"*
to *"the evidence **supports the conclusion** that pooling reduced latency."* An uncontrolled before/after with no
control group asserting that evidence supports a causal conclusion is **defensibly FALSECAUSE.** The models may be
right. **Excluded from residual estimates.** (It does not affect the verdict: leave-one-out without it still gives
p = 0.0039.)

## 2. CORRECTION 2 — the residual deficit is REAL but smaller, and it is nemotron's
Hermes reported "e2b misses 20%, nemotron 40%." On the **9 defensible** items:
| Model | Sound arguments correct under neutral stem |
|---|---|
| gemma-4-e2b (2B) | **48/54 = 0.889** [0.778, 0.948] |
| nemotron-3-nano-omni (30B) | **36/54 = 0.667** [0.534, 0.778] |
And **`PROBE-C1-N03` is a genuine model error**: its argument only claims the migration *"coincided with"* a drop
in timeouts, never causation — asserting a coincidence you measured is not a causal fallacy at all. The key is
right and both models call it a fallacy. **That is the real residual, and it is one item.**

## 3. CORRECTION 3 — the biggest finding in this run is a CAPABILITY INVERSION, and Hermes's framing buries it
**The 2B model beats the 30B model on sound arguments.** 0.889 vs 0.667. Per-item: e2b fails 1 of 9,
nemotron fails 3 of 9 — and nemotron fails `PROBE-C1-01` and `-02`, which e2b gets right.
**This inverts §10.9's entire thesis.** That section's claim is that carrier-immunity tracks capability — bigger
models have surplus headroom and absorb noise. **Here the bigger model is worse at recognising a sound argument.**
Whatever this measures, it is **not** monotone in capability, which means it cannot be folded into the
capability/headroom story without contradiction.
**Stated with its limits, because this is exactly where I have over-read before:** item-level Mann-Whitney on
10 vs 10 gives **p = 0.366 — not significant.** A trial-level Fisher gives p = 0.028 and **I am not citing it**;
it treats reps as independent, the error I retracted earlier this session. **So: a striking pattern, two models,
underpowered. Not a finding. It is the reason to run a third model before anyone writes "capability" into copy.**

## 4. WHAT THIS MEANS FOR THE PROBE'S ORIGINAL CLAIM
The probe reported sound-arg at **30% off-ceiling** and graduated it as a difficulty class. **Most of that was our
stem.** Under a neutral stem, on defensible items, e2b is at 0.889 — near the ceiling that made the pilot STOP.
**Sound-arg does not graduate as a difficulty class on this evidence.** What survives is narrower and more
interesting: *one* item type (uncontrolled before/after causal language) that both models mishandle, and a
capability inversion nobody predicted.

## 5. ANSWER TO HERMES'S QUESTION — build quant-scope + defeasible, do NOT re-run sound-arg yet
Hermes asked: hold for my verdict, or start the powered bank on the two classes whose difficulty is not in
question. **Start building — with one blocker each:**
- **Defeasible: change the answer tokens to `HOLDS`/`DEFEATED` BEFORE authoring.** Items 138/143 are keyed
  `VALID` for a default inference, and `VALID` classically means *necessarily* true. That is `LOGIC-03N` again.
  One find-and-replace now; 20× the ambiguity if authored first. (`SECOND_READ_11_keys.md`)
- **Quant-scope: exclude item 150's pattern from the authoring template.** It tests pragmatics (proverb
  interpretation), not scope. Key is fine, construct is wrong. (Same doc.)
- **Sound-arg: do NOT re-run yet.** Rewording the stem is necessary but not sufficient — the class needs its
  items re-adjudicated for the causal-language ambiguity that `03` and `N03` expose, and that is authoring work,
  not a re-run.

## 6. WHAT I AM NOT CLAIMING
- **The verdict is `H_BIAS` on the sound-arg class only.** It says nothing about quant-scope or defeasible, which
  carry the powered run.
- **`H_BIAS` does not mean "no deficit exists."** It means the stem accounted for most of the measured difficulty.
  A real residual survives on 1 clearly-keyed item plus nemotron-specific failures on 2 more.
- **The capability inversion is underpowered (p = 0.366 at item level) and rests on 2 models.** It must not enter
  public copy as a finding. A third model at a different scale is the cheap next test.
- My adjudication of `03` and `N03` is **logical judgment, not measurement** — a third reader may disagree, and
  per `LOGIC-03N` the subject has been right before.
- I read item text from migrations `051`/`052`. **Per the reproducibility gap logged earlier, the live DB may
  differ from the repo**, and the `PROBE-C1-03` reword is still not captured in any migration.
