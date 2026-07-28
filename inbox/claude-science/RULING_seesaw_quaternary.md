# The seesaw ruling — where binary is right, where it was overloaded, and what the fourth value costs
_Claude Science, 2026-07-29. Carey's parable, taken as a design claim and tested against our own instrument._

## 0. THE PARABLE IS A DESIGN CLAIM, AND THE INSTRUMENT ALREADY PROVES HALF OF IT
*"Too much math started trying to get its way through the seesaw… you are still mission-critical. We're doing this
so you can get back to the simple binary task you were meant to do."*
**Measured, not asserted:** this project's **first** dataset (`data/hacker_human_test_results.csv`, the one that
opened this whole line of work) used a **four-valued verdict**: `SAFE` 33, `FLAKY` 9, `UNSAFE` 9, `LOAD_FAILURE` 1.
**`FLAKY` is exactly the "neither pass nor fail" state.**
**The powered instrument records a single bit.** `pass ∈ {0,1}` — and then spends the rest of the project
reconstructing the missing states out of aggregates and side-columns. **The seesaw was handed the math.**

## 1. WHERE BINARY IS RIGHT — the part of the parable people skip
**A single trial with a well-formed verdict genuinely IS binary.** The model said `VALID` or it didn't; that is a
one-bit fact and a one-bit column is the correct instrument for it. **Replacing it wholesale with a four-valued
column would be the opposite error** — carrying interpretive load in a field that should be a fact.
**So the fix is not "make everything quaternary."** It is: **give the bit back its bit-sized job, and put the
states it cannot hold somewhere that can hold them.**

## 2. THE THREE PLACES THE BIT IS CARRYING WEIGHT IT CANNOT HOLD — each measured
| # | case | what happens now | why the bit can't hold it |
|---|---|---|---|
| **1** | model emits a **non-answer** — clarifying question, refusal, "what do you mean?" | `extract_verdict` finds no token → falls through to exact-match → **`pass=0`** | **indistinguishable from a confidently wrong answer.** These are opposite epistemic states. |
| **2** | **infrastructure failure** — timeout, OOM, engine error | rescued only by the side column `is_infra_error` | that column fired **0 times in 8,790 trials** across both runs. A guard that never fires has never been proven to work. |
| **3** | **stochastic items** — the project's central finding | not representable per-trial; recovered by aggregating 6 reps | baseline **48/293**, neutral **38/293**, lean **3/293** items are neither 0 nor 1. **The headline result lives in a state the schema cannot express.** |
**Case 3 is the sharpest.** The variance-collapse finding — the thing on the live site — **is a fact about a state
the instrument has no column for.** It exists only because someone thought to aggregate.

## 3. WHAT I RECOMMEND, AND WHAT IT COSTS
**Add `outcome` alongside `pass`, not instead of it:** `CORRECT` / `INCORRECT` / `NO_VERDICT` / `INFRA_FAIL`.
- **`pass` stays a bit** and keeps working for every existing analysis. Nothing recomputes, nothing invalidates.
- **`NO_VERDICT` is the value that does not currently exist anywhere** and is required by the ambiguity probe,
  where *flagging the question* is the correct behaviour and currently scores zero.
- **`INFRA_FAIL` promotes the side column into the vocabulary**, where it can be audited rather than trusted.
**THE COST, stated plainly:** every existing analysis assumes `pass` means "answered and was right." Adding
`NO_VERDICT` means a trial can be `pass=0` for two different reasons, and **every pass-rate in the project
silently becomes ambiguous unless the analyses are updated to say which denominator they use.** That is not free,
and it is the real argument against doing it.
**My recommendation: do it, but not before CS-001.** The replicate must run on the schema its pre-registration was
written against. **Changing the outcome vocabulary mid-experiment is exactly the seesaw-overload the parable warns
about, applied to ourselves.**

## 4. WHAT I AM NOT CLAIMING
- **"Quaternary logic" here means a four-valued OUTCOME vocabulary, not a four-valued logic system.** Belnap's
  four-valued logic (true/false/both/neither) is a real formalism and I am **not** claiming we are implementing it;
  the resemblance is suggestive, not a citation.
- **`is_infra_error` firing 0 times may mean the runs were clean, not that the guard is broken.** I cannot
  distinguish those without a deliberate failure test, and **that test has never been run.**
- **Case 1 is inferred from reading `scoring.rs`, not observed in the data** — I have not found a trial where the
  model demonstrably asked a clarifying question. The mechanism is there; the incidence is unmeasured.
