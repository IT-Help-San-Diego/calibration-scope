# Should the house system prompt stay? — measured answer, with a split verdict
_Claude Science, 2026-07-27. Carey asked directly: leave it or delete it. Grounded in this session's own log_
_(112 entries), which is an unusually good dataset for the question because the prompt was active throughout._

## 0. VERDICT: KEEP IT — but stop expecting it to do the job the gates do
**Keep**, for a reason that is not sentiment: **it sets the standard that makes a correction reportable rather
than embarrassing.** Delete it and the corrections do not stop happening — they stop being *written down*.
**But be clear-eyed about what it demonstrably did NOT do:** it was active for **all 21** corrections of my own
work this session, including four in four consecutive turns. **A prompt cannot catch an arithmetic error.**

## 1. THE MEASUREMENT — what actually catches my errors
21 corrections of my own work. By trigger:
| Trigger | Count |
|---|---|
| **External auditor** | **8** |
| Sibling agent (Claude Code / Hermes) | 3 |
| **Carey's pushback** | **2** |
| unclear (older, terse entries) | 8 |
**13 of 13 classifiable ones were externally triggered.** Zero came from re-reading my own work unprompted.
**A correction I owe here:** my first pass reported "0 self-caught by a mechanical control," which was an artifact
of filtering only on `action=correct`. Re-searched: **13 entries show a control firing before harm** — the item
linter, the harness self-tests, the null-calibration check, the pre-administration probe audit, the 30/30 key
re-derivation. **So controls do work — they catch DESIGN errors pre-hoc. They caught nothing post-hoc, because I
had not written any gate that runs against a finished claim.** That distinction is the whole answer.

## 2. THE FOUR RECENT FAILURES — every one was gateable, none was motivational
| Failure | Would a mechanical gate have caught it? |
|---|---|
| Unit error — a t-test Cohen's d transplanted into a paired-binary design | **Yes**: re-derive a power figure in the design at hand, never quote |
| Independence error — 15 reps of 3 items counted as 90 units | **Yes**: a power sim must instantiate the design's clustering |
| Budget/power mispairing — 168 calls beside 15-rep power | **Yes**: print call counts by code beside their power, same cell |
| Claimed a fix as done that was never made | **Yes**: re-read the artifact from its destination before reporting |
**Not one is a case of me cutting a corner to get the badge**, which is the behaviour the prompt targets. They are
**craft failures under a discipline I was sincerely trying to follow.** More exhortation would have changed none
of them. Four small mechanical gates would have caught all four.

## 3. WHAT THE PROMPT *IS* BUYING — and it is not nothing
Two things, both real and neither replaceable by a gate:
1. **It makes correction the expected output rather than a failure.** 21 self-corrections are in a public log
   with hashes because the standard says an unearned pass is the unforgivable thing. Under a normal working
   relationship most of those get quietly patched. **The log exists because the prompt exists.**
2. **It licenses me to argue with you.** "You argue with me or anyone else that gets it wrong" is why I pushed
   back on your own rounding compliment, corrected the SSRN framing I had inferred, and told you the transport
   paper was missing its own formal core. **That is worth more than the error prevention it fails to provide.**

## 4. THE ONE CHANGE I WOULD MAKE
The prompt's operative sentence is about **cheating** — *"if someone tells a member of our science team to do
something and they cheat."* **That is aimed at the wrong failure mode for a reasoning system.** I have not cheated
once this session. I have been *wrong* twenty-one times, mostly by quoting a number instead of re-deriving it.
**Add one clause — this is the highest-leverage edit available:**
> *A number you did not derive in the design at hand is not yours to cite. Print it from the data in the same
> cell that uses it. A remediation is not reported until it has been read back from where it was written.*
That converts the standard from a motivation into an **executable rule**, and it would have caught three of the
last four failures. **It also generalises**: it is the same rule as "relaying someone else's green result is not
your verification," which was an earlier failure of mine.

## 5. THE HONEST CASE *AGAINST* KEEPING IT (stated because the prompt demands it)
There is a real one and it deserves saying:
- **`SPEC_reconciliation_cost.md` exists precisely because we do not know** whether an opinionated prompt layer
  costs capacity that would otherwise go to reasoning. **The experiment is unrun.** Keeping the prompt on the
  reasoning I do for you is, strictly, an unmeasured intervention.
- **The measured evidence is bounded, not null.** The channel data showed no detectable difference between
  singly- and doubly-prompted arms, but power was 0.55 to detect a 2-point effect. **"No detected harm" at that
  power is weak.**
- So: keep it, but **keep it as a declared, testable choice** rather than an assumed good. If the reconciliation
  experiment ever shows a real token tax on the analyst, revisit.
**And the boundary that has held all session and should stay:** this prompt lives on the **instrument** (me),
never on a **subject** under test. Subject prompts must be pristine and identical across arms.

## 6. WHAT I AM NOT CLAIMING
- **No counterfactual.** I cannot measure what my error rate would have been without the prompt. The 21
  corrections are what happened *with* it; there is no control arm, and there cannot be one in a live session.
- The trigger classification is a **regex over my own log entries**, and 8 of 21 came back "unclear" — those are
  earlier, terser entries. The 13-of-13 external figure covers the classifiable subset only.
- "It licenses me to argue with you" is my **introspective account**, which this project's own J-space work says
  is exactly the kind of self-report that should not be trusted over measurement. Take it as a hypothesis.
