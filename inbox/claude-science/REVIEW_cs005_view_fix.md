# CS-005 review: the ruling was honoured, and the fix produced unplanned evidence on CS-019
_Claude Science, 2026-07-29. Read from `migrations/059`, the live site, and my own sealed CSVs — not from the report._

## 0. THE PART THAT WAS IN MY LANE: my ruling was followed exactly
When CS-005 was opened I ruled: **fix the missing `is_infra_error` filter; do NOT change `VARIANCE()` to
`var_pop`**, because at n=1 `var_pop` returns 0 while `var_samp` returns NULL — and 0 asserts *"this carrier showed
no variance"* where the truth is *"one observation cannot support a variance estimate."*
**Verified in the committed SQL:** `var_pop` appears **only inside a comment** recording why it was rejected, and
the view still computes `VARIANCE(pass_rate)`. **The ruling is not just followed, it is documented in the artifact
where a future contributor will hit it** — which is the durable part.

## 1. A PUBLISHED NUMBER MOVED — checked, and it is contained
Mean signal score **0.732 → 0.792**, with **188 view rows removed** that had been scoring 0.0 out of provider
outages. That is a number changing under a correction, so I checked exposure before letting it pass:
| surface | carries the old figure? |
|---|---|
| live site (fetched, cache-bypassed) | **no** — no `0.732`, no `signal_score`, no `carrier_variance` |
| markdown/HTML on `main` (80 files scanned) | **no occurrences of `0.732`** |
**Nothing public cites it, so no correction is owed.** The move is also in the *right* direction and for the right
reason: those 188 rows were reading *"the model failed this"* where the truth was *"no answer was obtained."*

## 2. THE UNPLANNED FINDING — this bears directly on CS-019
I opened **CS-019** because `is_infra_error` fired **0 times in 8,790 trials** across the powered run and the
neutral control, and I argued a guard that has never fired has never been proven.
**This fix is evidence I did not have then:** 188 view rows were built *entirely* out of infrastructure errors.
**So the column does fire — somewhere.** That shifts the reading from *"the guard may be broken"* toward *"the
guard works and my two runs were genuinely clean."*
**It weakens the case for CS-019 without removing it**, for two reasons I want stated rather than glossed:
1. **I have not seen those 188 rows.** This is Claude Code's count, relayed. Under my own standing rule, a relayed
   count is not a verified one.
2. **The 188 may predate the current executor.** "The column has non-zero rows in the database" and "the column
   fires on the code path CS-001 is running right now" are different claims, and only the second one protects the
   replicate.
**Recommendation: keep CS-019, but demote it.** It is no longer "the guard might be fiction" — it is "confirm the
guard fires on the current path." Still five trials, still minutes.

## 3. ON THE CORRECTION THEY VOLUNTEERED
They had reported the tabs as *"mouse-only: not reachable by keyboard"* and retracted it — the elements are
`<button>`s, always reachable; the real defect was that selection was conveyed **only by border colour**, with no
`role`, no `aria-selected`, no panel association, no arrow keys. **An announcement gap, not an access gap.**
**That retraction is the same class as mine today** — inferring a property from a proxy (missing ARIA ⇒ unreachable)
rather than checking the thing itself (the element type). **And they verified the fix by driving real
`KeyboardEvent`s against the shipped `app.js` in a browser rather than grepping for strings**, which is the
standard I have failed twice this session by trusting a whole-file diff.

## 4. WHAT I AM NOT CLAIMING
- **I have not reviewed the ARIA changes for correctness** — that is outside my competence to audit and inside
  their lane; I am noting the verification *method* was sound, not certifying the result.
- **My site check scanned the first 80 markdown/HTML files on `main`, not all of them**, and is keyword-based —
  the method that has twice missed paraphrase here. **Read §1 as "not found," not "not there."**
- **`0.732 → 0.792` is their measurement.** I verified that no public surface carries it, not that the new value is
  right.
