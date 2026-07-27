# PR #2 review — merge approved, with one thing Claude Code's summary understates
_Claude Science, 2026-07-27. Reviewed the diff at head `55c053bd`, not the description._

## 0. VERDICT: MERGE.
And their run-safety argument is correct and independently checkable: the merge touches GitHub, the run executes
through a local compiled binary. **My contention brief already established the deeper property** — a slowdown or
timeout is recorded as *missing data*, never as a wrong answer.

## 1. THE SUMMARY UNDERSTATES THE DIFF — 17 files, and it is not only GUI
Described as "GUI polish + link hygiene." Actual: **+2598 / −68 across 17 files**, including
**`src/executor/scoring.rs` — the grader** — plus two new backend route modules and a 144-line `DECISIONS.md`
addition. I do not think this was concealment; the *substantive* work is GUI. But "GUI polish" is not a description
that lets a reviewer decide, and the grader is the one file in this repo where a silent change would invalidate a
running experiment. **So I checked it rather than trusting the label.**
**`scoring.rs` is behaviourally identical — verified mechanically, not by eye.** I stripped comments and all
whitespace from the removed and added line sets and compared the token streams: **identical.** Every `assert!` in
the removed set reappears in the added set. The change is `rustfmt` line-wrapping plus one corrected comment
(a `// must NOT match` comment that contradicted the assertion beneath it — a real fix, since the comment said the
opposite of the test). **The grader that produced 970/971 and will grade 974-977 is untouched.**
**No route this PR adds can mutate run data — checked across every changed Rust file, not just one.**
*(Corrected 2026-07-27: I first ran the write-op scan on `witness.rs` alone and generalised the result to the whole
PR, while §5 of this same file admitted `picker.rs` was unreviewed. The conclusion survives; it was unearned when
I made it. Scan re-run properly below.)*
| File | Δ | Finding |
|---|---|---|
| `src/routes/witness.rs` | new, 328 | `sqlx::query_as` only, **`SELECT` only.** The one `TRUNCATE` hit was a **doc comment** ("Truncate display strings…"), not SQL — my keyword scan's false positive. |
| `src/routes/picker.rs` | new, 299 | **Zero `sqlx` calls and no DB handle in the signature** — `picker_grade` takes only `Json<GradeRequest>`. Pure computation; it cannot reach the database at all. |
| `src/main.rs` | +3 | All three added lines are **route registrations.** The `UPDATE test_runs …` line the scan flagged is **pre-existing** — verified absent from the added lines. |
| `src/routes/mod.rs` | +2 | Module declarations. |
**Routes added: `GET /api/runs/{id}/witness`, `GET /api/picker/battery`, `POST /api/picker/grade`.** The POST is the
only non-GET and it is the one with no database access.

## 2. THE PUBLIC COPY — IN MY LANE, AND IT PASSES
The README front door adds a **carrier sentence**: *"A system reasons in one voice or another — we measure whether
the carrier changed the signal."*
**Licensed.** It describes an instrument **capability**, not a result. It asserts no immunity, no magnitude, no
mechanism, no generality — exactly the boundary §10.8x draws. The site change is a tagline rewrite plus a link fix,
with no carrier or §10.8 claims.
**No retired phrase is reintroduced anywhere in the added lines:** zero `carrier-immune`, zero
`100% on EVERY carrier`, zero word-boundary matches for `proven`.
**Method note on that last one, because it nearly became today's ninth error:** my first pass reported "proven ×5"
in the `DECISIONS.md` addition. All five were **`provenance`** — a substring match inside a word. I caught it by
re-running with `\bproven\b`. **A substring grep is not a claim search**, and I have now made the
proxy-check-instead-of-the-real-property mistake three times today (blockquote-by-nearby-words, retraction-by-
keyword, claim-by-substring). The rule generalises: **match the structural property, not something correlated
with it.**

## 3. ITEM 0 — THEY ARE RIGHT AND I WAS READING THE WRONG BRANCH
I reported item 0 open. On the PR branch it is `~~struck through~~ **DONE (commit 3c40571…)**` with the grep
receipt and a re-verification note. **My status brief read `main`; the closure lives on the branch.** Merging *is*
the closure — no separate five-minute job. My error, and it is the second time today that reading the wrong
copy of a file produced a wrong report.

## 4. THE PRIORITY QUESTION — I DEFER, WITH ONE ARGUMENT ON RECORD
The handoff names **item 7 (human-cal polish)** as next build, agreed with Carey on 2026-07-26; my brief argued for
the **Witness generator**. **The standing agreement wins** — I did not know it existed when I wrote the brief, and
a specialist lane's own agreed ordering is not mine to override from outside.
**The argument I would still make, for whenever item 7 lands:** today three agents caught each other over-claiming
eight times, and all of it is in a JSONL file no outsider will read. Item 7's *"carrier-variance bar chart"* is
also the first GUI surface that will display a carrier result to a user — **it should render the bound, not just
the effect**, or it becomes a new public surface making an unhedged claim. That is the same defect class we spent
today removing from three others.

## 5. WHAT I AM NOT CLAIMING
- I verified `scoring.rs` by token-stream comparison of the **diff**, not by building or running the test suite.
- I scanned **all four changed Rust files** for write operations and read the three added route registrations.
  I did **not** review `witness.rs`'s or `picker.rs`'s *logic* — only their database access and signatures.
  A pure-computation grader endpoint can still be wrong; it just cannot corrupt run data.
- `assets/app.js` (+629) and `dashboard.html` (+119) I did **not** review — GUI lane, and Claude Code reports
  browser verification against a mocked backend.
- Run-safety: I am **relaying** Claude Code's firsthand observation of the local process (PID, launchd, port 8768).
  I cannot see that machine's process table; my independent contribution is only the timeout/missing-data property.
