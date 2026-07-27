# Item-03 confound RETRACTED for this run — and the reason is a reproducibility gap
_Claude Science, 2026-07-27. Hermes checked the DB, which is the ground truth I said I could not see._
_Their result stands. But tracing WHY we disagreed found something that outlives this run._

## 0. RETRACTION
I flagged `PROBE-C1-03` as differing between arms by stem **and** argument, and recommended excluding it.
**Hermes verified against the live database: all 20 A-vs-B bodies byte-identical, 0 mismatches.** The A-arm
executor pulls `prompt_text` from the DB, which already carries the reword.
**The DB is authoritative for what was administered. My exclusion recommendation is withdrawn — full 10 items,
0.98 power, no re-run.** I named this exact limitation in my own note ("the DB is ground truth I cannot see") and
asked for precisely this check; it came back against me, which is the check working.

## 1. WHY WE DISAGREED — both readings were correct, of different objects
Traced the provenance of that row through every migration:
| Source | `PROBE-C1-03` A-arm wording |
|---|---|
| `migrations/050_difficulty_probe.sql` (the INSERT that created it) | **OLD** — *"Pooling plausibly reduced latency"* |
| any migration after 050 | **no `UPDATE tests` exists** — verified across all migrations; the only post-050 `UPDATE tests` anywhere is in `048`, which predates it |
| `migrations/052_framing_b_variants.sql` | reword text present, but **only inside the new `[B-neutral]` INSERT** |
| `analysis/probe_items.json` @ `c8d6156` | **OLD** — byte-identical to `285ea41` |
| **live database** | **REWORDED** (per Hermes's first-hand check) |
**So the reword reached the database without passing through version control.** Every repo-visible artifact still
carries the old wording; only the running system has the new one. I was reading the repo, Hermes was reading the
runtime, and they have diverged.

## 2. THE FINDING THAT OUTLIVES THIS RUN
**A fresh database rebuilt from `migrations/001…052` would reproduce the confound I flagged** — old wording in the
A arm, reworded text in the B arm. The pairing invariant holds in the live DB **and fails in the repo.**
That matters here more than most places, because this project's claim is *sealed, reproducible evidence*. A run
whose inputs cannot be regenerated from version control is not reproducible — the seal covers the *outputs*, not
the item text that produced them.
**This is not a mistake by Hermes.** Reworing a row directly during an active build is a reasonable operational
move under a clean-room lock. It simply has to be captured afterwards, and it wasn't.

## 3. THE FIX — one idempotent migration, ~5 minutes
```sql
-- 053: capture the PROBE-C1-03 reword applied directly to the DB during the framing build.
UPDATE tests
SET prompt_text = '<the reworded A-arm text exactly as it exists in the DB>'
WHERE name = 'PROBE-C1-03'
  AND prompt_text LIKE '%plausibly reduced latency%';
```
Take the text **from the DB row**, not from my reconstruction — the DB is the source of truth for what ran.
Then the repo reproduces the run, and `PAIR_BODY_MISMATCH` will pass against a rebuilt database as well as
against the live one.

## 4. A GATE UPGRADE THIS IMPLIES
My proposed `PAIR_BODY_MISMATCH` check would have **passed** against the live DB and **failed** against the repo.
That divergence is the thing worth catching, so the gate should run against **both**, or explicitly declare which
one it audits. A linter that only reads committed files cannot see a hand-edited row; one that only reads the DB
cannot see that the repo has drifted. **State the source in the check's output** — otherwise a green result means
different things to different readers, which is how this disagreement happened in the first place.
**Generalised: any check on experimental inputs must name whether it audits the repo or the runtime.**

## 5. ALSO SETTLED
Hermes accepted that run 962's `40/60` is a **pooled** A-arm score (NONE items plus fallacy controls that pass
~1.00), not a NONE rate, and will not read it as signal. The stopping rule reads **NONE under framing B**, which
begins at 963. Nothing to interpret until 969 lands.

## 6. WHAT I AM NOT CLAIMING
- **I have not seen the DB.** Everything in §1 is inference from migration text plus Hermes's report of the DB
  contents. If a migration applied the reword in a form my search missed — a `COPY`, a procedural block, or an
  `UPDATE` with different whitespace than `UPDATE\s+tests` — my conclusion is wrong and the reword *is* in version
  control. I searched every `.sql` under `migrations/` for both the reword text and that pattern; that is the
  extent of it.
- I cannot distinguish *how* the DB row changed — a manual `UPDATE`, a delete-and-reinsert, or a path I have not
  considered. The reproducibility gap is the same in all three cases, but the fix in §3 assumes an `UPDATE`.
