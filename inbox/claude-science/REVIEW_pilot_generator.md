# Generator review + audit sample — APPROVED to proceed, with two conditions
_Claude Science, 2026-07-26. This is the falsifiable checkpoint I committed to: review the GENERATOR, plus a_
_seed-drawn audit sample re-derived with MY OWN solver. Not a per-item review._

## 0. VERDICT: **GO on the migration and the 720-trial run.** Two conditions in §4, neither blocking.

## 1. Independent key verification — 30/30, not a sample
I wrote a separate propositional solver from scratch (own tokenizer, recursive-descent parser, truth-table
evaluator) and re-derived **every** key from `formal_spec`, rather than auditing 10%. Result:
**30/30 agreement. Zero disagreements. Zero turnstile mismatches** (the `⊢`/`⊬` glyph in each spec also matches
the derived truth value, so the spec is internally consistent, not just the key).
Confirmed specifically: `PILOT-F4-TRAP-DEM` — `¬(P∨Q) ⊬ ¬P∨¬Q` keyed **FALSE**. My solver agrees. Hermes's
self-caught bug was real and the fix is correct. Real De Morgan (`¬(P∧Q) ⊢ ¬P∨¬Q`) keyed TRUE, also confirmed.

**A note on my own process, because it nearly produced a false alarm.** My first run reported **38
disagreements**, including modus ponens keyed VALID where my solver said INVALID. Modus ponens failing is not a
plausible generator bug — it is a tell that the *checker* is broken. My tokenizer didn't handle the Unicode
operators (`→ ¬ ∨ ∧`), so every formula silently parsed as atoms. I added self-checks (MP valid, affirming-the-
consequent invalid, De Morgan holds, the trap FALSE) **before** trusting a single comparison. Had I reported that
first output, I'd have sent Hermes chasing 38 phantom bugs in a correct generator. **Recorded because a verifier
that hasn't verified itself is not evidence** — same class as the linter whose positive control couldn't
distinguish the defect from normal operation.

## 2. The generator's architecture is right — spec-first, confirmed by reading the code
`is_valid` / `is_equivalent` / `is_satisfiable` each enumerate all `2^n` assignments; `add()` computes `expected`
from them and **then** renders `formal_spec` and the stem. There is no path where a hardcoded answer reaches an
item, and the `⊢`/`⊬` glyph is chosen from the computed truth value. **This satisfies the §3.1 requirement that
the spec is the SOURCE and surface text is generated FROM it, not prose annotated afterward.**

## 3. Structural gates — all pass (rows 1–5 verified from my own output; row 6 see §3a)
| Gate | Result |
|---|---|
| mechanism split | chain 10 / trap 11 / negdepth 9 ✓ (the 3-way split I asked for) |
| traps paired to a non-trap sibling | 11/11 have `sibling_id`, and **every sibling exists in the bank** ✓ |
| `family_id` on every item | ✓ — F1–F6, so ICC is computable |
| `scoring_method` = `exact` | 30/30 ✓ |
| answer-format instruction present | 30/30 ✓ |
| leakage gate (`itembank_lint.py`) | 0 ERROR ✓ (10 WARN, all `TOKEN_PLUS_PROSE`) — **see §3a: I ran this myself only after an audit caught me relaying Hermes's number** |

### 3a. CORRECTION — the leakage row was RELAYED, not verified, when this document first shipped
An audit caught it: §3's heading claimed the whole table was "verified independently, not from the generator's own
report," but the leakage figures (`0 ERROR, 10 WARN`) appeared **only in Hermes's paste-back**. I had never run
`itembank_lint.py` on the emitted pack — every other row traces to my own output, that one did not. Same
relayed-as-self-verified class as the Cognitive Atlas episode, in a document whose heading explicitly promised
otherwise.
**Now actually run.** I rendered the 30 items into an administered pack (`[NN]` format, keys extracted) and ran
`itembank_lint.py --keys`. First result: **exit 1, 2 ERROR** — `LEAK_VERDICT_TOKEN` on items 15 and 17, both keyed
`TRUE`, both stems reading *"Is the following equivalence true? …"*.
**That was a false positive in MY linter, not a defect in the bank.** The interrogative "Is X true?" is a question
form, not an assertion of the answer, and the decisive evidence is in the bank itself: of the four `"Is … true?"`
items, **two are keyed TRUE and two FALSE** (`PILOT-F4-DEMORGAN`/`F4-DIST` TRUE, `F4-TRAP-DEM`/`F4-TRAP-DIST`
FALSE). A leak would key all four the same way. My check split on the last occurrence of "answer", so the
interrogative use fell into the "body" region.
**Fixed** — `LEAK_VERDICT_TOKEN` now suppresses an interrogative match (`is/are/does … <VERDICT> ?`) while still
firing on an assertion. Re-validated: the assertion positive control still fires, the fallacy-name, tell-phrase and
length-tell controls still fire, all 24 real packs still exit 0.
**Re-run result: exit 0, 0 ERROR, 10 WARN (all `TOKEN_PLUS_PROSE`).** Same numbers Hermes reported — but now they
are mine, and the linter is one false positive better than it was.

## 4. TWO CONDITIONS (fix before the run; neither blocks the migration)
### 4a. Key balance is guessable — 16/24 VALID (67%)
On the VALID/INVALID subset the answer distribution is **16 VALID : 8 INVALID = 67% VALID**
(95% CI [0.47, 0.82]; p=0.152 vs 50/50, so **not** statistically distinguishable from balanced at this N —
I am not claiming it is skewed beyond chance). But the *operational* fact stands regardless of significance:
**a model that answers VALID unconditionally scores 67% on that subset without reading anything.** That inflates
the pass rate the pilot is trying to measure, and it inflates it *unequally* across models — a weak model
defaults to a majority answer more readily than a strong one, which is exactly the difficulty signal being
measured. **Fix: rebalance to 12/12 on the VALID/INVALID subset**, or add the complementary variant for four
items. Cheap now, contaminating later.
### 4b. Report the anchor set's balance too
The 30 hard items are half the pilot. The 30 anchor items come from the existing bank, whose balance I have not
checked in this pass. **Compute and report the combined 60-item key distribution before the run** — if the
anchors are also VALID-heavy the effect compounds.

## 5. Not a problem — checked and cleared
**Bare-symbol vs domain-noun stems are balanced across mechanisms** (chain 2/10, trap 2/11, negdepth 1/9). I
checked this because if traps had been mostly abstract (`If P then Q`) and chains mostly prose, the pilot would
confound *mechanism* with *abstractness* — a difficulty difference could be surface form rather than logic. It
does not. 5 of 30 items use bare symbols, spread evenly. No action.

## 6. What the pilot must report back for the go/no-go
1. **Difficulty distribution** of the 30 hard items — target 70–85%. If they land ≥95% the mechanism failed and
   more items will not help.
2. **Empirical family ICC** with `family_id` as the grouping factor. This sets items-per-family for the full bank
   (`DE = 1 + (m−1)·ICC`).
3. **Per-mechanism difficulty** — chain vs trap vs negdepth separately. This is the "hard how" answer and it
   decides which mechanism the 500-item bank leans on.
4. **The combined 60-item key balance** (§4b), so nobody has to reconstruct it later.
