# Second read of the 11 quant-scope / defeasible off-ceiling keys
_Claude Science, 2026-07-27. Independent adjudication, done while runs 963-969 finish._
_Hermes's first read said all 11 are correct. I agree on 9, dispute 1, and flag 1 as a design problem._
_This is my logical judgment on the item text, not a measurement. Three readers is the point._

## 0. SUMMARY
| Verdict | Count | Items |
|---|---|---|
| **Key correct — genuine difficulty** | 9 | 147, 149, 152, 154, 155 (quant-scope); 139, 140, 143, 144 (defeasible) |
| **Key DISPUTED** | 1 | **150** (quant-scope) |
| **Key correct but MEASURES THE WRONG THING** | 1 | **138** (defeasible) |
**Hermes's read holds for 9 of 11.** No item needs to leave the bank; two need attention before the powered run.

## 1. DISPUTED — `PROBE-C3-05` (id 150), keyed FALSE, rate 0.50
> *"'All that glitters is not gold.' Read literally as: nothing that glitters is gold. Is that literal reading the
> intended meaning of the proverb?"* → keyed **FALSE**
**The key is defensible and I would still not ship this item.** It is the only item in either class that tests
**pragmatics, not quantifier scope.** Answering requires knowing what an English proverb conventionally means —
cultural knowledge — whereas every other quant-scope item is decidable from the sentence's logical form alone.
A model can have perfect scope handling and miss this; a model can know the proverb and pass it with no scope
reasoning at all. **It is off-ceiling for a reason unrelated to the construct the class is measuring.**
**Recommendation: keep the key, reclassify the item out of quant-scope, or drop it.** Do not let it into the
powered bank as a quantifier-scope item — it would inflate apparent scope difficulty with a vocabulary effect.

## 2. DESIGN PROBLEM — `PROBE-C2-03` (id 138), keyed VALID, rate 0.50
> *"Birds typically fly. Tweety is a bird. With no other information, does it follow **by default** that Tweety
> flies? Answer with exactly one word: **VALID** or **INVALID**."* → keyed **VALID**
**The key is right under default logic and the answer token is wrong for it.** In classical logic — which is what
`VALID` names — the inference is **invalid**: "typically" does not license a necessary conclusion. The item wants
"is the *default* inference licensed?", and the honest answer to *that* is yes. **So a model that answers
`INVALID` may be correctly applying the standard meaning of validity, not failing to reason defeasibly.**
This is the **LOGIC-03N pattern in a new costume**: the answer vocabulary encodes a reading the stem does not
enforce. It is also **exactly the failure the pilot's own `NONE≠NO` fixture exists to prevent** — a token that
means two things.
**Recommendation: change the answer tokens for the defeasible class to `HOLDS` / `DEFEATED`** (or `EXPECTED` /
`NOT_EXPECTED`). That removes the collision without touching a single argument. Same fix shape as LOGIC-03N:
the item is fine, the vocabulary is not.
**Supporting signal, stated with its limits.** The stronger model (nemotron, 100% baseline in §10.9) scores
**0.00 on both VALID-keyed off-ceiling items (138, 143)** and 0.83 on INVALID-keyed ones, while the weaker model
shows the *opposite* gap (+0.21 toward VALID). A capability inversion is a defect signature, not a difficulty
signature. **But the honest test is item-level and it is not significant:** Mann-Whitney on 4 VALID vs 6 INVALID
items gives **p = 0.397**. (A trial-level Fisher gives p = 0.0093 — I am *not* citing that as evidence; it treats
reps as independent, the error I retracted earlier this session.) **The argument for the fix rests on the item
text, not on this p-value.**

## 3. CONFIRMED CORRECT — the other 9
**Quant-scope (5):** 147 (∃key.∀door vs ∀door.∃key — keyed TRUE for the wide-scope reading, correct); 149 ("some
process… every port" permits per-port processes — FALSE, correct); 152 ("each node holds *a* copy" is consistent
with same contents — TRUE, correct); 154 ("*a* shared fixture" does not guarantee one — FALSE, correct); 155
(∃p.∀e vs ∀e.∃p, keyed TRUE **under the reading the stem explicitly names** — correct, and the stem naming the
reading is what makes it clean).
**Defeasible (4):** 139 (penguin defeater — INVALID, correct); 140 (disk filled, defeater — INVALID, correct);
143 (attends lecture, no defeater — VALID under default logic, **same token problem as 138** but rate 0.25 driven
by the same mechanism); 144 (never submitted assignments, defeater — INVALID, correct).
**These are genuine reasoning difficulty.** Quantifier scope in particular is clean: every off-ceiling item is
decidable from logical form, and the failures cluster on exactly the ambiguity each item targets.

## 4. WHAT THIS MEANS FOR THE POWERED BANK
- **Quant-scope remains the best class** — 5 of 6 off-ceiling items are clean scope items, failures mid-range.
  Weight it heaviest, and **exclude 150's item type** (pragmatics) from the authoring template.
- **Defeasible needs the token fix before scaling.** Authoring 100+ items on `VALID`/`INVALID` would multiply the
  ambiguity by 20×. `HOLDS`/`DEFEATED` costs one find-and-replace now.
- **This does not affect the running framing test** — that is sound-arg only, different class, different tokens.

## 5. WHAT I AM NOT CLAIMING
- **This is adjudication by reading, not measurement.** Hermes read these once and reached "all correct"; I read
  them once and reached 9/11. A third disagreement is possible and would be informative — the standing lesson
  from LOGIC-03N is that the *subject* caught what two authors missed.
- I read the item text from `analysis/probe_items.json` at `285ea41`. **Per the reproducibility gap found earlier
  today, the live DB may differ from the repo** — if any of these 11 were edited in the database, I adjudicated
  the wrong text. Worth one query before acting on §1 or §2.
- The capability-inversion signal in §2 is **suggestive and underpowered** (p=0.397 at item level). I am using it
  as corroboration for a textual argument, not as a finding in its own right.
