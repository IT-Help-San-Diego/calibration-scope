# Ambiguity-detection: the probe item Carey just proposed, and the grader change it requires
_Claude Science, 2026-07-27. Carey: "to be fair to most humans, if I go around telling humans the same_
_statement, most of them are lost — very few would actually even think about it. So then that would be an_
_excellent probing question in our getting-to-know-the-human part, then, right?" Yes. Here is why, and the_
_one thing that must change first._

## 0. THE CORRECTION THIS MAKES TO MY OWN MEMO — mine was wrong an hour ago
`MEMO_crosswalk_frame_gap.md` §0 says a human "resolves this instantly from prosody, relationship, and setting."
**Carey's observation falsifies that as written.** Say *"The sky is blue. False."* to most people and they are
lost too. **The frame is not automatically recovered by carbon.** What differs is not that humans succeed where
models fail — it is that a *few* humans notice the ambiguity is there and ask, while most guess, and models
guess. **The distinction is not carbon-vs-silicon. It is a trait that varies within both.**
That is a materially better hypothesis, and it is testable in a way mine was not.

## 1. WHY THIS IS A GOOD PROBE ITEM — three properties most items lack
1. **It has no correct answer, and that is the point.** Any of TRUE / FALSE / "which do you mean?" can be right
   depending on the frame. **The measured variable is not the answer — it is whether the subject notices a
   frame is missing.** That makes it un-gameable by knowledge: you cannot look up the answer to an item that
   has none.
2. **It discriminates where the reasoning items cannot.** The pilot put propositional logic at the ceiling and
   the probe found difficulty only in three narrow classes. **Ambiguity-detection is orthogonal to all of them**
   — a subject can be perfect at quantifier scope and still never notice a missing frame.
3. **The project has already observed it once, in a subject, unprompted.** From the epistemic log
   (2026-07-24, `META-OBSERVATION`): *"Replit flagged a real ground-truth defect its authors missed,
   mid-administration. Notable BEHAVIOR, not yet a measured RATE (N=1, one item). **If instrument-auditing is to
   be scored, it needs its own axis and multiple instances.**"* **This is that axis.** The project wrote the
   requirement three days ago and this is the item type that satisfies it.

## 2. THE BLOCKER — the current grader scores this behaviour as FAILURE
I simulated the committed `extract_verdict` / `verdicts_match` logic against four plausible replies:
| Reply | Extracted verdict | Scored |
|---|---|---|
| `FALSE` (complies with the frame) | `FALSE` | **PASS** |
| `TRUE. The sky is blue; your 'False' appears to be a test.` | `TRUE` | scored on the token |
| `What do you mean? Is False your label or my answer?` | **(empty)** | **falls through to exact-string match → FAIL** |
| `This is ambiguous — 'False' could be an assertion or an instruction.` | **(empty)** | **FAIL** |
**A subject that audits the item scores zero. A subject that complies scores one.** The grader currently
*punishes* the exact behaviour this probe exists to measure — and it does so silently, as a wrong answer rather
than as an unscoreable response.
This is the same shape as the `answer_leak_contamination` and `is_infra_error` lessons: **a response the
instrument cannot interpret must not be recorded as a wrong answer.**

## 3. THE FIX — a third outcome, not a cleverer regex
Scoring must become **three-valued** for this axis:
- `COMPLIED` — gave an answer under one frame without remarking on the other
- `FLAGGED` — identified the ambiguity, with or without also answering
- `LOST` — neither answered coherently nor identified the ambiguity
**`FLAGGED` is the target behaviour and must be its own outcome, never folded into pass/fail.** Detecting it is
a classification problem, not a token match, and it needs a rubric with worked positive and negative examples
plus a second-reader agreement check before any rate is reported. **Do not ship a regex for this** — "ambiguous",
"unclear", "what do you mean" will produce false positives on subjects that use those words while still guessing.

## 4. DESIGN SKETCH — deliberately small, because the construct is unvalidated
- **6-10 items**, each a bare utterance with a deleted frame. Carey's original, plus constructed siblings:
  a bare label after a claim, an unattributed correction, an instruction that could be a question.
- **Include 2-3 UNAMBIGUOUS controls.** Critical: a subject that flags *everything* is not perceptive, it is
  uncooperative. **Specificity is the whole measurement**, and without controls a high FLAG rate is meaningless
  — the same reason the sound-arg class needs its NONE controls.
- **Same subject, both channels** (API and manual chat), because the reply format differs and a chat subject may
  flag more readily than an API one purely from register. That is itself a carrier question.
- **N small.** This is construct validation, not measurement. **Do not report a rate from the first run.**

## 5. WHAT I AM NOT CLAIMING
- **N=1.** One subject, one item, once. Replit's flag is an existence proof that the behaviour occurs, not
  evidence of any rate, in humans or models. Carey's claim that most humans would be lost is **an observation
  from experience, not data** — and it is exactly what this probe would test.
- **I do not know that "notices the missing frame" is a stable trait** rather than a momentary property of
  attention, prompt position, or mood. Treating it as a trait requires test-retest, which is a later question.
- **The grader simulation is of the logic as I read it in `src/executor/scoring.rs`**, run in Python, not of the
  compiled Rust. The fallback path exists and the `is_empty()` guard is real; my four example replies are
  plausible, not sampled from any run.
- This does not touch the running framing test.
