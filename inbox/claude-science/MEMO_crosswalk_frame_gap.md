# The crosswalk gap — Carey's 2023 "The sky is blue. False." and why it is the project's core defect class
_Claude Science, 2026-07-27. Written because the item-138 finding and a three-year-old prompt are the same bug._
_Contains one honest negative: I tried to test this observationally and the data cannot answer it._

## 0. THE OBSERVATION
Carey, 2023, to an early chat model: **"The sky is blue. False."** The model broke.
It broke because those four words carry **at least five incompatible speech acts**, with nothing in the token
stream to select between them:
1. **EVALUATE** — is the proposition true? ("False" is a label I want you to assess)
2. **ASSERT-AND-CORRECT** — you would say true; I am telling you it is false
3. **LABEL** — "False" is the answer key attached to this item
4. **TEST** — I am checking whether you capitulate to a wrong label
5. **PARSE** — "False" is a fragment; the utterance is incomplete
**Readings 2 and 4 demand opposite responses.** A human resolves this instantly from prosody, relationship, and
setting — none of which survive the crosswalk into tokens. **The model is not failing at logic. It is failing at
a disambiguation problem the carrier deleted before it arrived.**

## 1. THIS IS THE SAME DEFECT THE INSTRUMENT KEEPS FINDING IN ITSELF
Every authoring defect this project has caught has the identical shape — **an unstated interpretive frame**:
| Defect | The unstated frame |
|---|---|
| `LOGIC-03N` | "precisely when" — biconditional or one-directional? Key assumed one. |
| **items 138 / 143** | "VALID" — classically necessary, or default-licensed? Key assumed one. |
| item 150 | proverb — literal or conventional reading? Requires cultural frame, not logic. |
| sound-arg stem | "which single fallacy best describes it" **presupposes** a fallacy exists |
| **"The sky is blue. False."** | bare truth token with no speech act attached |
**In every case the model is scored on picking the frame the author had in mind, not on reasoning.** Carey found
this class in 2023 with two words; the instrument has now rediscovered it four times from the inside, each time
at the cost of a run.

## 2. WHY IT MATTERS BEYOND ITEM HYGIENE
This is the **carrier thesis in its sharpest form**. Carrier Color asks whether a message's dressing degrades the
signal. This asks something stronger: **the carrier can delete information that the receiver structurally
requires, and no amount of receiver capability recovers it.** Prosody, shared context, and relationship are load-
bearing disambiguators in carbon-to-carbon transmission, and text-to-model transmission drops all three.
**Consequence for measurement:** an unglossed ambiguous item does not measure reasoning. It measures **prior
agreement with the author's frame** — which is a property of training distribution, not of logic. That is a
different construct, and scoring it as reasoning inflates or deflates results unpredictably.

## 3. I TRIED TO TEST IT ON THE PROBE DATA. THE DATA CANNOT ANSWER IT.
Hypothesis: items whose stems **explicitly name the intended reading** ("Read literally as…", "Under the reading
X…", "With no other information…") should score higher than items that leave the frame implicit.
Raw result across 40 probe items: **glossed 0.667 vs unglossed 0.812** — the *opposite* direction.
**That comparison is worthless, and the reason is instructive.** Glossing is not randomly assigned:
| Class | Items glossed |
|---|---|
| quant-scope | 6/10 |
| defeasible | 7/10 |
| sound-arg | **0/10** |
| distractor | **0/10** |
**Authors gloss exactly the items they already suspect are ambiguous.** So "glossed" is a proxy for "the author
thought this one was tricky" — perfectly confounded with difficulty. And within-class the directions **reverse**:
| Class | Glossed | Unglossed | Direction |
|---|---|---|---|
| quant-scope | 0.49 (n=6) | 1.00 (n=4) | glossed items are HARDER |
| defeasible | 0.82 (n=7) | 0.50 (n=3) | gloss HELPS |
Opposite signs, tiny n. **Reporting either as evidence would be selection bias dressed as a finding.** The honest
statement is that the probe data is silent on this question.

## 4. THE CLEAN TEST — 240 calls, and it is the framing test's design generalized
Take one item, administer it twice: **bare stem vs stem + explicit gloss.** Same argument, same key, gloss is the
only difference. That is precisely `A_leading` vs `B_neutral` applied to **interpretive frame** instead of
**presupposition**.
**10 items × 2 framings × 2 models × 6 reps = 240 calls.** Same cell-level McNemar, same clustering discipline,
same pre-registered stopping rule. **Run it after the framing test lands** — the framing test answers "does a
leading stem induce an answer," this answers "does an explicit frame recover a deleted disambiguator." They are
adjacent halves of one question and the second is cheaper.
**Design constraint learned the hard way today:** the gloss must be the ONLY difference. `PROBE-C1-03` in the
running test differs by stem *and* argument, and any result on that item is uninterpretable.

## 5. THE PRODUCT IMPLICATION — this is a first-class instrument feature, not a caveat
If frame-glossing measurably changes scores, then **every benchmark in the field is partly measuring frame
agreement and reporting it as reasoning**, and none of them disclose it. The instrument's move is to make it
visible: **report frame-explicitness as a declared item property**, the way the thermal opinion made provenance
declared rather than inferred. An item bank that states which items gloss their reading is auditable; one that
does not is measuring an unnamed mixture.

## 6. WHAT I AM NOT CLAIMING
- **No measurement supports the crosswalk claim yet.** §3 is a null-by-confounding, not a null result — the
  design cannot distinguish the hypothesis from author selection. Until §4 runs, this is a well-motivated
  hypothesis with a documented defect class behind it, and nothing more.
- The five readings in §0 are **my decomposition**, not an empirical inventory of how any model actually
  responded. I do not have the 2023 transcript.
- The claim that prosody and relationship are "load-bearing disambiguators" is standard pragmatics, but I have
  cited no source for it here and should before it enters public copy.
