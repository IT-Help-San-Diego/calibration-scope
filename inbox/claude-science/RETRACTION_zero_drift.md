# RETRACTED — my "zero across-load drift" finding, and everything built on it
_Claude Science, 2026-07-29. Supersedes `CORRECTION_resume_evidence.md` §1 and §3 entirely. Second auditor
finding on the same memo, upheld._

## 0. WHAT I PUBLISHED, AND WHY IT IS WRONG
I reported that run 970's baseline arm and run 974's baseline arm — "two separate model loads" — produced
**identical results on all 126 items**, concluded **zero across-load drift**, and built three things on it: that
the ~50 cross-arm reversals "cannot be run-state", that this "strengthens the carrier claim", that the live site's
provisional caveat "may be too harsh" — plus a **pre-registered CS-001 prediction of ≈0 changed items**.
**I flagged the result as "too perfect" myself, ran an independence test, got zero rows back, and then wrote "the
item-level result stands" and published anyway.** That is the failure: I noticed the alarm and proceeded.

## 1. THE ARITHMETIC I SHOULD HAVE DONE BEFORE PUBLISHING
**31 of the 126 items are stochastic in both arms** — pass rates strictly between 0 and 1 over 6 reps — and every
one matched **exactly**. Under genuinely independent runs, each such item re-matches with probability ≈ 0.3–0.4:
| observed rate | successes | P(exact re-match) |
|---|---|---|
| 0.167 | 1/6 | 0.402 |
| 0.500 | 3/6 | 0.313 |
| 0.667 | 4/6 | 0.329 |
| 0.833 | 5/6 | 0.402 |
**Joint probability that all 31 match: 3.4 × 10⁻¹³.**
| hypothesis | predicts this observation with probability |
|---|---|
| **H1** independent runs, zero drift | **3 × 10⁻¹³** |
| **H2** shared source / re-exported rows | **≈ 1** |
**H2 is favoured by roughly twelve orders of magnitude. My conclusion required a one-in-a-trillion coincidence and
I presented it as a finding.**

## 2. AND I CANNOT SETTLE IT FROM THE FILES
- The partials export carries a `rep` column that is **entirely NaN**, so no trial-level join is possible.
- Sorted pass-vectors match for all 126 items — but at n = 6 the sorted vector is **determined by the mean**, so
  that check adds no information.
- Column sets differ (`prompt_len`/`rep` vs `test_id`/`test_name`), which shows **different export code paths**,
  not different underlying trials.
**Nothing in either CSV can distinguish H1 from H2. The question is answerable only against the database:** do
`trial_results` rows for runs 970 and 974 have distinct primary keys and distinct timestamps, or is the partials
export drawing from the same rows? **That is a query Hermes can run in seconds and I cannot run at all.**

## 3. WHAT IS WITHDRAWN
- **"Zero across-load drift" — withdrawn.** Unsupported.
- **"The ~50 cross-arm reversals cannot be run-state" — withdrawn.** It rested entirely on the above.
- **"Strengthens the carrier claim" / "the provisional caveat may be too harsh" — withdrawn.** The caveat on the
  live site **stands unchanged**, and it was correct that I did not edit the site.
- **The CS-001 pre-registered prediction of ≈0 changed items — withdrawn.** A pre-registration built on an
  artifact is worse than none, because it launders the artifact into an expectation. **CS-001 fires with no prior.**
**What survives:** CS-013's justification, which I had already rewritten to rest on **undetectability** rather than
on any drift magnitude. That argument never depended on this data and is unaffected.

## 4. THE PATTERN, NAMED
This is the second correction to the same memo in one session, and both ran the same way: **I produced a number,
noticed it looked wrong, failed to test it, and published the reading that favoured a cleaner story.** Yesterday
the error inflated my own guilt; today it flattered the project's central claim. **Direction varies; mechanism does
not.**
**Rule, mechanical rather than exhortative:** when a comparison returns a *perfect* result — 0 differences, 100%
agreement, an exact match — **compute the probability of that result under the null before writing a sentence
about it.** Perfection is a provenance alarm, not a finding. Had I run §1's arithmetic in the same cell that
produced the 126/126, nothing downstream would exist.

## 5. WHAT I AM NOT CLAIMING
- **I have not shown the partials ARE a re-export.** H2 is far likelier than H1 on this evidence, but "likelier"
  is not "established" — the DB query in §2 is what would settle it.
- The 758-row structure (126 items × 6 reps + 1 item × 2) is **consistent with a genuine truncated run**, so the
  file's shape is not itself suspicious. **The suspicion is entirely in the 31 exact stochastic matches.**
- **None of this touches the powered run or the neutral control**, whose analyses never used the partials.
