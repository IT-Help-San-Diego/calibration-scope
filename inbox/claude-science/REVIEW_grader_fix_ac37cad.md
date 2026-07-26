# Grader fix #3 (commit ac37cad) — independent code review
_Claude Science, 2026-07-26. Read src/executor/scoring.rs on main first-hand and SIMULATED the logic._
_Verdict: the fix is real, correctly scoped, and the dangerous failure mode is already guarded. Two smaller residual issues._

## VERIFIED GOOD (checked against committed bytes, not the report)
- Commit `ac37cad805`, single file `src/executor/scoring.rs` (+133/-26). `extract_verdict()` +
  `verdicts_match()` present as described.
- **Correctly scoped by MECHANISM, not allowlist** — the call site applies verdict extraction to all
  exact-scored items, exactly as requested. LOGIC-01N's case (`expected "confirmed"` vs model
  "Confirmation") is handled by the CONFIRMED=CONFIRMATION equivalence. Confirmed.
- **The false-positive hazard I went looking for is ALREADY GUARDED.** I checked whether two empty
  extractions could match everything (`verdicts_match("","")` returns true in isolation — a
  false-positive machine). The call site guards it:
  `if !actual_verdict.is_empty() && !expected_verdict.is_empty() { verdicts_match(...) } else { <original
  exact-match fallback> }`. So items whose expected text does not START with a verdict token fall back to
  the original logic instead of auto-passing. **Good defensive design — credit where due; I expected to
  find this bug and it isn't there.**
- Unicode normalization (curly quotes, en/em/non-breaking dashes) folded into the same function — closes
  grader bug #1's class in the same path.

## RESIDUAL ISSUE 1 (real, low severity): token-order prefix shadowing
`extract_verdict` returns the FIRST token in the list that the string `starts_with`. The list is ordered
longest-first for some families but "NO" sits near the end and still shadows longer strings it prefixes:
| input | extracts | should be |
|---|---|---|
| `NOT SATISFIABLE` | `NO` | `UNSAT` |
| `NO, IT FOLLOWS`  | `NO` | ambiguous (self-contradictory reply) |
| `NOT VALID`       | `NO` | `INVALID` (accidentally OK via the NO=INVALID equivalence) |
So a model answering "NOT SATISFIABLE" against expected `UNSAT` scores a **false NEGATIVE**. Not currently
triggered (LOGIC-09 SAT/UNSAT passed in every arm), so this is latent, not active.
**Fix:** sort candidate tokens by DESCENDING LENGTH before matching, and require a word boundary after the
token (next char is end-of-string or non-alphanumeric). One line each; kills the whole class.

## RESIDUAL ISSUE 2 (real, low severity): equivalence table is incomplete in one direction
`NO=INVALID` and `YES=VALID` are covered, but the FOLLOWS-family analogues are not:
- `NO` vs expected `DOESNOTFOLLOW` -> **no match** (false negative)
- `YES` vs expected `FOLLOWS` -> **no match** (false negative)
A model answering "NO" to "does that annotation follow?" is giving the right answer in the wrong
vocabulary — the same substitution `NO=INVALID` already forgives. Also unhandled: `APPROVE` vs `YES`.
**Fix:** add `NO=DOESNOTFOLLOW` and `YES=FOLLOWS` to the equivalence table.
**Caveat worth stating:** every equivalence added widens what counts as correct. `NO=INVALID` is safe
because both mean "the inference is bad." Do NOT add cross-family equivalences that could forgive a real
error (e.g. `NONE`=`NO` — "no fallacy present" vs "the argument is invalid" are opposite claims; correctly
NOT matched today, keep it that way). Each new equivalence should be justified item-type by item-type.

## RESIDUAL ISSUE 3 (design note, not a bug): equivalences are context-free
`NO=INVALID` is applied without knowing the question type. Today that's safe (I checked: a sound control
with expected `VALID` and a model answering `NO` still correctly FAILS). But as the equivalence table
grows, context-free matching gets riskier. The durable fix — for later, not now — is to carry the item's
allowed-answer set (already in the pack text: "Answer with exactly one word: VALID or INVALID") and
validate the extracted verdict against THAT set. That makes equivalences per-item rather than global.

## On the regression test
`exact_verdict_extraction_adversarial_items` covering all 9 known-affected items **plus negative controls
(wrong verdicts still fail)** is the right shape — the negative controls are the part that matters, since
a grader fix that makes everything pass would otherwise look like a success. 13/13 passing, clippy clean.
**Recommend adding as fixtures:** `NOT SATISFIABLE`/`UNSAT` and `NO`/`DOESNOTFOLLOW` (issues 1-2 above),
so the next fix can't silently reintroduce them.

## Bottom line
The fix is sound and I would ship it. Residual issues 1 and 2 are latent false-NEGATIVE risks (the safe
direction — they would under-credit a model, not over-credit it), so they are not blocking. No
false-positive path found. **Re-grade and re-run the arm analysis; I expect all four arms at ~99.5-100%
with LIT-12 as the only residual failure.**
