# KANBAN contract — the schema, and why each rule exists
_Claude Science, 2026-07-28. Board: `policy/kanban.jsonl`. Validator: `scripts/kanban_lint.py`._
_This is the coordination layer replacing prose check-ins. **It is state, not narrative.**_

## 0. THE ONE DESIGN DECISION THAT MATTERS
**A card cannot enter `done` without a verifier: a commit sha, run id, deploy sha, or file path on `main`,
plus the check that was run against it.** A status is a claim; a verifier is evidence. **`kanban_lint.py` fails CI
on a `done` card with no verifier**, which is why this board cannot rot by neglect the way the prose did.

## 1. WHY JSONL AND NOT JSON
**One card per line.** Three agents appending different cards produce **no merge conflict**. A JSON array
conflicts on the closing bracket every single time two lanes write in the same window — which is exactly what
happened when two check-in *files* existed on two branches simultaneously.

## 2. THE SIX RULES, EACH TRACED TO A FAILURE WE ACTUALLY HAD
| rule | enforced | the failure it prevents |
|---|---|---|
| **R1** `done` requires `verifier{kind,ref,check}` | CI fails | `NEXT_STEPS` ordered a 420-call run **that had already happened at 480 calls**. A card can read "done" while the thing it points at is stale. |
| **R2** a `file` verifier must exist on `main`; a `commit`/`deploy` ref must be a real sha | CI fails | 20 analysis files sat on an unmerged branch for **35.8 h** while every check-in reported the lane current. **"Done" must mean on `main`.** |
| **R3** `blocked` requires `blocked_on` | CI fails | a blocked card with no named blocker is **indistinguishable from an abandoned one**. |
| **R4** `blocked_on` must resolve to a card id or `carey:*` | CI fails | dangling dependencies silently make a card permanently invisible. |
| **R5** unique ids | CI fails | duplicate ids mean two agents **silently overwrote each other**. |
| **R6** known `lane` and `column` | CI fails | an unknown lane means **nobody owns the card**. |
**The validator self-tests: `kanban_lint.py --selftest` constructs one violating card per rule and asserts the
linter rejects each, plus a valid card it must accept. 7/7 pass.** A checker that never fails is decoration.

## 3. CARD SHAPE
```json
{"id":"CS-001","title":"…","project":"calibration-scope","lane":"hermes",
 "column":"backlog|in_flight|blocked|done","blocked_on":"CS-002|carey:credits|null",
 "cost":{"calls":1758,"est_hours":3.5},
 "why":"why this exists, in evidence terms — not a restatement of the title",
 "verifier":{"kind":"commit|run|file|deploy","ref":"…","check":"what was actually checked"},
 "opened_by":"claude-science","opened":"2026-07-28"}
```
**`cost` carries `calls` because run budget is real money.** A card asking for 1,758 calls should say so on its face.
**`why` must be evidence, not restatement** — a card whose `why` repeats its `title` tells a future reader nothing.

## 4. THE SEEDED BOARD — derived from repo state, not memory
**10 cards: 5 backlog, 2 blocked, 3 done. Lint: ALL CLEAN.**
**Blocked (2):** `CS-001` the replicate run (blocked on `carey:credits`); `CS-006` the shuffled-carrier arm (blocked
on `CS-002`, because you cannot shuffle a carrier whose text was never sealed).
**Backlog (5):** `CS-002` seal the carrier text per trial · `CS-003` convert a published paper's drift measures to
our metric (**may answer the replicate at zero run cost — check before spending `CS-001`**) · `CS-004` triage 17
unreachable commits before gc prunes them · `CS-005` the view's infra filter · `CS-007` the 41-warn sweep (blocked
on `carey:approval`, because Carey named reports-about-reports a bill).
**Done (3), each with a checked verifier:** the live-site paraphrase removal (`1f42b04b50`, verified against the
deployed page) · the `NEXT_STEPS` supersession (`b18f3f6cd8`) · the prior-art search (`LITSEARCH_prior_art.md`).

## 5. WHAT I BUILT AND WHAT I DID NOT
**Built:** the schema, the seeded board, and the validator with its self-tests.
**Not built, and deliberately Hermes's:** the CI job that runs the linter on push, and the dashboard renderer.
**I am not going to build a renderer for a board whose contract has not been agreed** — that is the mistake this
project keeps making in the other direction.
**One thing I want argued with rather than accepted:** R2 forces a `file` verifier to exist on `main`, which means a
card cannot be marked done from a branch. **That is the point** — but it also means the linter must run against a
`main` checkout, not a PR branch, or it will produce false failures on legitimate in-flight work. **Hermes should
decide where in CI it runs; I have an opinion, not the context.**

## 6. WHAT I AM NOT CLAIMING
- **The seeded cards' `why` fields are my reading of the state.** Each is traceable to an artifact on `main`, but
  another lane may disagree about priority or ownership — **cards are editable; that is the point of state over
  prose.**
- `CS-004`'s "17 unreachable commits" is **Hermes's measurement**, taken in a local checkout I cannot see.
- The linter checks **structure, not truth**. It cannot tell whether a `check` string describes a check that was
  actually performed. **That still rests on the honesty of the lane writing the card** — the board narrows the
  failure surface, it does not eliminate it.

---

## Helpers in `scripts/kanban_lint.py` — what they are for

These are importable functions, not lint rules. Each exists because a specific
failure happened more than once, and each replaces a convention that had been
documented and then breached anyway. **Reach for them by symptom:**

| Symptom you are about to have | Call | The failure it came from |
|---|---|---|
| You are about to report that an insert, append or edit landed | `assert_added(path, expected_ids, prior_count=N)` | A guarded card insert silently added nothing because the id was already taken, and the commit message announced the card anyway. Third silent no-op in one day. |
| You are about to say "N records contain X" | `count_records(path, pattern)` | An entry count was taken from a regex *occurrence* tally: one record held both matches and another was the retraction quoting the phrase, so "two entries" was really one. Returns `(n_records, [(line, n_occurrences)])` so the distribution is visible. |
| You are about to mark a card `done` | `check()` rule R7 | A card closed against a real, resolving commit that had nothing to do with the card. R7 rejects empty or self-restating verifier text — it **cannot** catch a well-written check attached to the wrong object. |

**Two standing rules that are not enforced by anything and have each been broken:**

1. **Gate the push on the lint's exit code, not on having run it.** Running
   `kanban_lint.py` in the same cell as the push, without asserting
   `returncode == 0`, put a failing board on `main`. "I ran the check" is not
   "the check passed." Use `assert r.returncode == 0` before any board write.
2. **Read enumerated fields; do not guess them.** `VERIFIER_KINDS` is
   `{commit, run, file, deploy}`. Two consecutive invented values (`code+selftest`,
   then `selftest`) were rejected by R1 where a two-line read was available.

## Other local gates worth knowing exist

- **`scripts/migration_lint.py`** — rejects `UPDATE`/`DELETE` on a content table
  pinned to a literal id (migration 048's rule, breached by 057, fixed by 060).
  `--selftest` is 6/6. 057 is **grandfathered by name** because it is applied and
  immutable; editing an applied migration changes its checksum and breaks
  `_sqlx_migrations` everywhere. A *new* violation belongs in the migration, not
  in that list.
- **`scripts/fresh_seed_check.py`** — builds a scratch database from zero and runs
  the DB gates against it. This is the capability that catches id-pinned migrations,
  which are invisible locally because the row really is fixed on the machine that
  wrote them. Its guarantee is that it cannot damage *the database in `DATABASE_URL`* —
  not that it cannot damage any database.

