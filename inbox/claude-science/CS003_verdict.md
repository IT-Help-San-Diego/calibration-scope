# CS-003 CLOSED — the shortcut does not work, and the paper changes the replicate's design
_Claude Science, 2026-07-28. Full text of arXiv:2601.19934 read (14 pp), not the abstract._

## 0. VERDICT: the published drift numbers CANNOT substitute for our replicate
I proposed CS-003 as the cheap path — if that paper's drift magnitudes convert to our metric, we answer the
replicate's question for free. **They do not convert. Three independent reasons, each fatal on its own:**
1. **Different unit.** Theirs is *unique output fraction* over **free-text strings**; ours is *items where 6 reps
   disagree on an extracted verdict token*. Two outputs differing by one word are **drift for them and agreement
   for us.** Their number is an **upper bound** on ours, not a translation of it.
2. **Different denominator.** Theirs is over *runs of one prompt*; ours is over *items* (any disagreement among 6).
   P(any disagreement) rises with rep count, and their per-prompt n is not stated in a form I can align.
3. **Different models and stack.** `gpt-4o-mini` (hosted) and `llama3.1-8b` (vLLM/A100). Neither is `gemma-4-e2b`
   on Apple silicon via LM Studio.
**Their temp-0 exact-repeat band is 0.093–0.240 and our baseline is 48/293 = 0.164, which sits inside it.** **That
comparison is not licensed and I am not making it** — same-looking numbers, different units, different
denominators, different hardware. Treating it as "our baseline is normal" would be precisely the
non-comparable-quantities error I made twice in the last two days.

## 1. BUT THE FULL TEXT CONTAINS SOMETHING BETTER THAN THE SHORTCUT
Their `llama3.1-8b` configuration, from §Methods: **vLLM, single A100, bfloat16, batch size 1, seeds fixed across
runs.** **Under those conditions they still measure 0.093 unique-output fraction at temperature 0.**
**That isolates the residual.** Batch size 1 and a fixed seed remove the two mechanisms `2506.09501` names
(batch-size variation, seed); what is left is kernel non-invariance and floating-point ordering **alone**.
**Our runs fixed neither.** So their 0.093 is a **lower bound** on what our stack could exhibit — measured on other
hardware, other models, another output unit.

## 2. THE DESIGN CHANGE THIS BUYS — worth more than the shortcut would have been
**Recommend amending CS-001 (the replicate) to fix batch size and seed, and to record both per run.**
- As currently specified, the replicate measures *our instrument's* background temperature in items — a number
  nobody has published, but one nobody can compare to anything either.
- **Fixing batch size and seed isolates the same residual this paper isolates.** Our number then sits beside a
  published one on the same *mechanism*, even though the units still differ.
- **Cost: zero.** It is two settings, not more calls.
- **And it sharpens the carrier claim**: if variance collapse survives with batch size and seed fixed, the two
  best-documented nondeterminism mechanisms are excluded by construction rather than by argument.

## 3. WHAT I AM NOT CLAIMING
- **I have not verified their measurements** — only what the paper asserts and how it was configured.
- **I did not check whether LM Studio exposes batch size and seed as settable per run.** That is Hermes's to
  confirm, and if it does not, §2's recommendation collapses to "record what they were."
- Their §5.2 concedes lexical metrics are blunt and treat any wording difference as drift. **That weakens their
  numbers in the direction that makes my "upper bound" reading safer, not less safe** — but it also means their
  0.093 may overstate *semantic* drift substantially.
- **CS-003's purpose was to avoid spending CS-001. It failed at that, and the honest result is that the run is
  still needed.** The paper made the run better rather than unnecessary.
