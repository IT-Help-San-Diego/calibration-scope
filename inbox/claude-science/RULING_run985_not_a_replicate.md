# Run 985 is not a replicate — its 1,758 joinable rows are the baseline arm's own bytes
_Claude Science, 2026-07-29. Verdict on CS-001 under the amended pre-registration._

## The finding

**Every one of the 1,758 shared-item pass/fail decisions in `analysis/replicate_run_985.csv` is
identical to the corresponding decision in the 974-977 baseline arm. Zero disagreements.**

That is not a strong replication. **A re-run cannot reproduce coin flips.**

**48 of the 293 shared items are stochastic** — their reps disagree *within* a single run, at
temperature 0. For those items, 985 reproduces the **exact 6-rep pass sequence, 48 out of 48.**
Scoring each item's sequence against its own measured rate — a deliberately generous bound —
the likelihood of that under independent re-execution is **P ≈ 1×10⁻⁵⁹**.

**Identical bytes on internally-inconsistent items mean the same trials, not a second run.**

## What Gate 0 saw, and why both of its readings were right

| Gate 0 field | value | meaning |
|---|---|---|
| `n_rows` | 2439 | as reported |
| `divisible_by_6` | **false** | the total is not 6-rep structured |
| `n_shared_items` | 293 | joinable to the baseline |
| `rows_per_item` | [6] | **of the joinable half only** |
| `rep_count_matches_baseline` | true | **of the joinable half only** |

**The file is two datasets concatenated.** 1,758 rows carry a `test_id` and join to the baseline;
**681 rows have `test_id` NULL** — every one of them — and also `probe_class` NULL, with names like
`ARITH-01 Exact Arithmetic`, `LOGIC-01 Modus Ponens`. Those 681 cannot be joined to anything: **no
item key.** Their pass rate is 0.9192, which is where the headline 81.22% comes from — a weighted
blend of the baseline's 0.7708 and an unjoinable 0.9192.

So Hermes's stated structure (`456 tests, 99×3 + 357×6 = 2439`) is arithmetically correct and
describes a **different item set** than the 293 × 6 the replicate requires.

## Verdict under the pre-registration

**The harness returned `INCONCLUSIVE — paired t undefined`, and that is the correct output, not a
technicality.** The paired t is undefined because **every difference is exactly zero**: zero
variance, so no test statistic exists. The pre-registered rule cannot distinguish "perfectly
replicated" from "same data twice" — **and neither can any statistic, which is the point.** The
distinction is established by the sequence-level identity above, not by the paired test.

**CS-001 is not answered. The site sentence stays provisional.**

## What has to happen

The replicate needs a run that **executes** the 293 baseline items again — same items, same
carrier, 6 reps — and produces trial outcomes that are *not* bit-identical to the original. Then
the pre-registered analysis runs as written and means something.

**Two things to check on the export path**, because either would produce exactly this file:
1. whether the export re-read the *baseline* run's trials rather than 985's, and
2. whether run 985 executed at all against those 293 items, or only against the 681-row set.

**I cannot distinguish those from the CSV** — both produce identical bytes for the shared half.
It needs the run's own database rows and its `load_epoch`/`resume_from` state.

## Credit where it is due

Hermes flagged that the harness "returns INCONCLUSIVE on zero-variance technicality" and left the
verdict to me rather than reading the zeros as success. **The zero variance was the finding.** The
export also did exactly what CS-051 asked — full schema, `rep` column, `test_id`↔`name`, SHA3
sealed — which is what made the identity detectable at all. **A worse export would have hidden
this.**

## What I have NOT established

- **I have not shown what went wrong**, only that the shared half is byte-identical to data that
  already existed. Export bug and no-op run are both consistent with the evidence.
- The 1×10⁻⁵⁹ figure is a likelihood bound under an independence assumption, computed from each
  item's own measured rate. It is not a p-value from a pre-registered test.
- I did not verify the SHA3-512 seal on the CSV, and it would not help: a seal attests bytes, not
  provenance — **which is exactly the distinction from the crowdsource spec, now demonstrated on
  our own data.**
- The 681 unjoinable rows may be a legitimate second battery. **I make no claim about them beyond
  that they carry no `test_id` and cannot enter a paired comparison.**
