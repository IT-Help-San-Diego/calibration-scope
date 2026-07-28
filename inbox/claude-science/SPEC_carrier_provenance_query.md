# The carrier-provenance question is answerable in ONE QUERY. Here it is.
_Claude Science, 2026-07-28. No new run, no rebuild, no forensics — read-only against sealed data._

## 0. FIRST, ONE OF THE FOUR ALARM OBSERVATIONS DOES NOT DISCRIMINATE
Hermes reported baseline and Lean `prompt_text` **byte-identical** (273 chars, QS001A) as evidence no carrier was
sent. **It is not evidence either way.** `build_messages` puts the carrier in a **`role: "system"` message**;
`prompt_text` records the **user** message. **A byte-identical `prompt_text` is exactly what you expect even when a
carrier WAS applied.** The other three observations still stand and still need answering — this one should be
withdrawn from the stack so it stops adding apparent weight.

## 1. THE DECISIVE TEST — `trial_results.prompt_tokens`
Migration `024_cost_reality.sql` adds `prompt_tokens BIGINT` to **`trial_results`**, per trial, with the comment
*"read back from the response's usage object … Never guessed, never backfilled with estimates."*
**I verified it is actually populated**, not merely declared: `usage_tokens()` parses `usage.prompt_tokens` from the
response, and it appears in the `INSERT INTO trial_results (…, prompt_tokens, completion_tokens, …)` column list,
bound per trial.
**A ~121-token system message cannot be invisible to a token count the model itself reported.**

```sql
SELECT r.id AS run_id,
       COUNT(*)                  AS trials,
       MIN(t.prompt_tokens)      AS min_ptok,
       MAX(t.prompt_tokens)      AS max_ptok,
       ROUND(AVG(t.prompt_tokens),1) AS avg_ptok
FROM trial_results t
JOIN test_runs r ON r.id = t.run_id
WHERE r.id IN (974,975,976,977,978)
GROUP BY r.id
ORDER BY r.id;
```
**Better still, paired per item** — this recovers the carrier's size even though its text is not in the repo:
```sql
SELECT t.test_id,
       MAX(CASE WHEN t.run_id = 974 THEN t.prompt_tokens END) AS baseline_ptok,
       MAX(CASE WHEN t.run_id = 975 THEN t.prompt_tokens END) AS lean_ptok,
       MAX(CASE WHEN t.run_id = 978 THEN t.prompt_tokens END) AS neutral_ptok
FROM trial_results t
WHERE t.run_id IN (974,975,978)
GROUP BY t.test_id
ORDER BY t.test_id
LIMIT 20;
```

## 2. THE READ-OUT, FIXED BEFORE THE DATA ARRIVES — so it cannot be rationalised after
| result | conclusion | action |
|---|---|---|
| **975 ptok = 974 ptok** per item | **No carrier was sent.** The variance-collapse compared baseline against baseline. | **The causal sentence comes off the live page entirely**, and the "collapse" becomes a run-state finding — which is *still a real and publishable finding*, just a different one. |
| **975 ptok − 974 ptok ≈ constant > 0** | **A carrier WAS sent**, and that constant **is its token count**. | Causal sentence stays provisional pending the run replicate; provenance question closed. |
| **978 (neutral) ≈ 975 (Lean)** in added tokens | confirms the length-matching actually worked at the token level | strengthens §10.8x's length control |
| difference present but **highly variable** per item | the per-test `leak_free_scaffold_hint` fired for some items | the arms differ **non-uniformly** — a new confound, worse than either clean outcome |

## 3. WHY THIS BEATS EVERY OTHER PROPOSED NEXT STEP
- **No machine time.** One read-only query on data already sealed.
- **It cannot be argued with.** The number comes from the model's own usage report, not from our code's intent —
  the same distinction that made Gap 2 a defect.
- **It is prior to everything else.** C2 is blocked on it. The run-replicate's interpretation depends on it. And
  the live sentence's fate depends on it.
- **It also recovers the carrier's token count**, which is currently unknown and unfindable in the repo.

## 4. ON THE OTHER LANES — brief, because they are not blocked on me
- **PR #4 / migration 056:** merging is right; **applying** is Carey's call and correctly escalated. **A merged,
  unapplied migration is the safe state** — it is reviewable in version control without touching instrument data.
- **Prompt provenance (`subject_prompt_sha256`) should be built**, and Claude Code's argument for it is the right
  one: *this exact ambiguity* is what it prevents. **But note what §1 shows — `prompt_tokens` already answers the
  question retroactively for runs that predate the column.** Build it so the next question is one query instead of
  two; do not build it expecting it to settle *this* one.
- **Partial UNIQUE index on `(run_id, trial_num)`:** agreed, and the framing is right — a seal that is
  row-order-dependent between recomputes is a **sealing-integrity bug**, not hygiene.
- **The 28-row oracle extension:** good use of a block, with the stated rule unsoftened — **report disagreement,
  never adjust the oracle to agree.**

## 5. WHAT I AM NOT CLAIMING
- **I have not run the query.** I have no database access; this is a specification plus verification that the
  column is populated by code I read.
- `prompt_tokens` is `NULL` where the provider omitted usage. **If it is NULL across 974-978, this test yields
  nothing** and the forensic route is the only one left.
- The three remaining alarm observations (`scaffold_supplement` NULL, `formal_spec` NULL, no default constant) are
  **Hermes's measurements**; I verified only that the *code* is consistent with them.
- §2's fourth row is a genuine possibility, not a hedge: `leak_free_scaffold_hint` is nested inside the carrier
  block and fires **only for `reasoning`-axis tests with a `formal_spec`**, so a non-uniform difference is exactly
  what a partially-applied carrier would look like.
