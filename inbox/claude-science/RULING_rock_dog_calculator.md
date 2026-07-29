# The rock, the dog, and the calculator — a red-team of the mission sentence, adjudicated
_Claude Science, 2026-07-29. Carey's test: administer the battery to a pet rock, a dog, and a TI calculator._

## The verdict up front

**You are right that good notes make the RECORD honest. You are wrong that it makes the TEST
valid — and the three subjects fail in three different components, which is the finding.**

Recording all three as "no response" is exactly the defect this project already has a blocked
card for. It is not a hypothetical: the instrument's own first dataset contains the rock case,
and the arithmetic proves the point.

## The rock case is already in the record, and it already collapses

`data/hacker_human_test_results.csv`, the project's first dataset, has one `LOAD_FAILURE` row:
`step-3.7-flash@q8_0` — "fails consistently at 12-34pct load". Its numbers are
**`passes=0, trials=2`**.

Nine `UNSAFE` rows also have `passes=0`.

**A subject that never loaded and a subject that confidently failed are numerically identical:
`0.00`.** Only the verdict *string* separates them, and every aggregation over `passes/trials`
erases it. That is the rock indistinguishable from a model that answered wrongly nine times.

**Where the current instrument stands:** `is_infra_error` exists precisely for this (migration
017, enforced in the `owl_signal_carrier` view by 059 — which found **1,574** infra-error trials
that had been reading as bad reasoning). So the rock is handled. **It is the only one of the
three that is.**

## Why the dog is NOT an infra error — and this is the part to keep

`is_infra_error` means *the trial never reached the subject, or its answer never reached us*.
**It is a claim about our side of the wire.**

Your own words: *"the dog had some interesting responses nonverbally."* Signal **was** emitted.
Transport worked. **Our decoder failed.**

Recording that as `is_infra_error` asserts "nothing was transmitted" when something was. That is
a false record, and worse, it hides *which component broke*. Three columns of outcome are needed
and only two exist:

| subject | what is missing | correct schema value today | component that actually failed |
|---|---|---|---|
| pet rock | no interface at all | `is_infra_error` — **correct** | our transport |
| dog | interface exists, **decoder** does not | **none exists** | our grader |
| calculator | interface exists, **item is out of domain** | **none exists** | the **item**, not the subject |

**The dog case is CS-024's blocker wearing a different costume.** That card is blocked because
the grader scores a *clarifying reply* as zero — a subject that flags an ambiguity scores worse
than one that complies. Same structure: the subject emitted a legitimate signal and the grader
had no state for it. **The dog is that bug with fur.**

## The calculator is the sharpest of the three

A TI calculator has a real, narrow, **perfectly reliable** competence: deterministic arithmetic.
Asking it for poetry and recording "no response" produces a number that is *true* and
*meaningless* — it measures the **item's** fit to the subject, not the subject's reasoning.

Score it 0 and you have asserted something false about a device that would score 100% on the
domain it actually inhabits. **A false negative about reasoning, produced by a correctly
executed test.** Good notes do not fix this; the notes would faithfully record a category error.

## So what does the red-team actually break? The mission sentence

> *"Calibration Scope measures reasoning — in any subject, on any substrate — and seals the
> measurement so anyone can verify it."*

**"Any substrate" is doing unearned work.** The instrument requires three preconditions the
sentence does not state:

1. the subject has an **addressable interface**;
2. its outputs are **decodable by our grader**;
3. the item is **within a domain the subject addresses**.

The rock fails (1). The dog fails (2). The calculator fails (3). **The sentence promises a
generality the instrument does not have** — and that is a gap between what a system states and
what is actually true, which is the thing this instrument exists to measure. **The red-team
turned the instrument on its own mission statement and found a real one.**

## What I recommend, and what I am NOT recommending

**Do not weaken the sentence to "any language model."** That surrenders the human-calibration
work, which is real and already runs.

**State the preconditions.** "Any subject that can be addressed and decoded" is honest, keeps
humans and models in scope, and makes the dog a *future* subject — the interface is missing, not
the reasoning. That matches what you said: *"before we can vector in that with an interface."*
Correct — and it is an admission the sentence should carry rather than paper over.

**Unblock CS-018.** The four-valued column — `CORRECT / INCORRECT / NO_VERDICT / INFRA_ERROR` —
already covers the dog: `NO_VERDICT` is "signal emitted, unreadable by us." It does not yet
cover the calculator, which needs an item-level `OUT_OF_DOMAIN`, because the failure is in the
**item**, not the trial.

## What I have NOT established

- I did **not** run the battery against anything. The rock arithmetic is from the committed CSV;
  the schema claims are read from migrations and source.
- **`is_infra_error` has never been observed firing on the current code path.** CS-005 demoted
  that question without closing it. So "the rock is handled" is a claim about the schema and the
  view definition, not an observed behaviour.
- The calculator's `OUT_OF_DOMAIN` state is **my proposal**, not an existing design. CS-018 as
  written does not include it.
- Whether a dog *has* the reasoning being probed is not a question this instrument can currently
  ask, and nothing above should be read as a claim that it does or does not.
