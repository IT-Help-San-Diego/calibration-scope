# Item 7 review — the science surface holds, and one deferred risk is now live
_Claude Science, 2026-07-27. Read PR #3's diff at head `3d4dbdee`, not the summary._

## 0. VERDICT: the bound I asked for is there, and one part exceeds the ask.
In the PR #2 review I argued item 7's carrier chart would be **the first GUI surface to show a carrier result to a
user**, so it must render the *bound*, not just the effect. Checked against the code:
| Requirement | Status in `app.js` |
|---|---|
| trial count beside the effect | **present** — `total_passes/total_trials` per family row |
| the swing bar's scale is stated, not implied | **present** — scaled to the 0.25 theoretical max, with *why* in the caption ("two forms at 0% and 100%") |
| a real 0 is distinguishable from missing data | **present** — *"0 means the wording changed nothing"* |
| refuses to fabricate a 0 | **exceeds the ask** — with one surface form it prints *"not measurable — 1 form"* and the headline says **"A 0 here would be a false claim."** |
**That last one is the defect class we spent today removing from three public surfaces — caught here *before* the
surface shipped rather than after.** It is the first time in this project the correction ran ahead of the claim.

## 1. THE TWO BACKEND FIXES ARE REAL AND DEFENSIVELY WRITTEN
- **`latency_ms` was hardcoded `0` for humans.** Now bound from a client-measured `elapsed_ms`, **clamped to
  `[0, 24h]`** so a client clock glitch cannot write a negative or absurd value into the same column model response
  times live in. `Option<i64>` keeps older clients working. **This matters beyond UI polish: human latency was
  previously a column of zeros that looked like data.**
- **The name-collision bug.** `signal_carrier` now returns `subject_id` (`COALESCE(participant_id, model_id)`) and
  the UI filters on it, with an in-code comment recording that display names are not unique. The old code took the
  *first* human row in the view — **which means any earlier human-cal result read from that view may have been
  another participant's.** Worth knowing before anyone cites a pre-fix human number.

## 2. THE ONE THING I FLAGGED THAT IS NOW LIVE — and my judgement on it
The chart carries **no uncertainty interval on the swing itself**, and a variance computed from two surface forms
is noisy. **At this n I judge that correct, not a defect:** with 2 forms the variance has **1 degree of freedom**;
an interval would be near-uninformative and would imply more precision-machinery than exists. Printing a wide CI
next to a 2-form variance would itself be a form of overclaim.
**It becomes a defect the moment the chart is used to RANK families, or to compare a human against models as if the
ordering were reliable** — and the comparison panel ("same families, every subject that attempted them") is
precisely where that pressure will arrive. **Recommendation, not a blocker:** when the comparison panel gains any
ordering or "better/worse" affordance, it needs a minimum-forms guard before a family is rankable. Right now it
renders values, not a ranking, so the risk is latent.

## 3. WITNESS — my argument is moot and I accept that
Claude Code reports it built (PR #2, `witness.rs`, `GET /api/runs/{id}/witness`), which I verified as SELECT-only.
The **claim-ID constraint** is banked as v2 scope keyed on `test_id`. Good — that was the part worth keeping.

## 4. WHAT I AM NOT CLAIMING
- I reviewed the **diff**: `participants.rs`, `signal_carrier.rs`, and the added `app.js` lines. I did **not** run
  the UI, and Claude Code's "browser-verified 23/23" is **their** result relayed, not mine.
- I did not review `app.css`, `dashboard.html`, or the min-bundles.
- **The Lighthouse `EventSource` root cause is plausible but unconfirmed** — an SSE connection at parse time would
  indeed keep the trace from going network-quiet, but the evidence offered is one in-browser timing check, and the
  score's own spread that day was 64–90 **on identical assets**. That spread is the reason a single post-fix green
  run must not be read as confirmation. The median-of-3 gate is the right fix regardless of whether this cause is
  the real one.
