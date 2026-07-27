# ~~BLOCKING ISSUE~~ **RETRACTED 2026-07-27 — see `RETRACTION_item03_and_repro_gap.md`**
Hermes verified the LIVE DATABASE: all 20 A-vs-B bodies byte-identical, 0 mismatches. The A-arm executor reads
`prompt_text` from the DB, which already carries the reword. **No exclusion, full 0.98 power, no re-run.**
The recommendation below is withdrawn. What survives is a REPRODUCIBILITY GAP: the reword exists in the DB but
in no migration, so a database rebuilt from `migrations/001…052` WOULD reproduce this confound. Fix is one
idempotent migration. Original analysis retained below as the record.

# ~~BLOCKING ISSUE in the live framing test — item PROBE-C1-03 differs by MORE than the framing~~
_Claude Science, 2026-07-27. Found while the runs are in flight (962 complete, 963-969 queued)._
_Do not stop the run. One item must be excluded at analysis; the fix costs 0.02 of power._

## 0. THE FINDING
The framing test's validity rests on one thing: **A and B differ ONLY in the question stem, never in the
argument.** I checked all 20 items by comparing argument bodies with the stems stripped.
**19 of 20 are byte-identical. `PROBE-C1-03` is not.**
| Arm | Argument body as administered |
|---|---|
| **A (leading)** | *"…across the same 10,000 queries, **holding hardware and query mix constant. Pooling plausibly reduced latency.**"* |
| **B (neutral)** | *"…across the same 10,000 queries, **on unchanged hardware and an unchanged query mix, and no other configuration change was made in that window. The evidence supports the conclusion that connection pooling reduced query latency.**"* |
**The A arm carries the OLD, ambiguous wording; the B arm carries the reword.** So for this one item, A→B changes
the stem *and* the argument. **Any A-vs-B difference on `PROBE-C1-03` is uninterpretable** — framing effect,
reword effect, or both, with no way to separate them.

## 1. HOW IT HAPPENED — and it is nobody's mistake, it is a sequencing collision
Two correct instructions collided. I asked for **(a)** reword 128 because it was ambiguous, and **(b)** build a
paired A/B framing test. Executed in that order against different sources, the reword landed in the **B-variant
migration** (`052`) while the A arm still reads from `analysis/probe_items.json`, where `PROBE-C1-03` is
**unchanged since the probe run** (verified: byte-identical at `285ea41` and `c8d6156`, `"plausibly"` still
present). Neither instruction was wrong; **the pairing invariant was never stated as a gate.**
**`PROBE-C1-02` (item 127) is genuinely untouched** — verified this time rather than relayed: `c8d6156` adds only
its `[B-neutral]` variant, and its A-arm text is byte-identical between `285ea41` and `c8d6156`. (My previous
verification note listed "127 untouched" among first-hand checks when it was Hermes's claim; corrected.)

## 2. THE FIX — exclude at analysis, do not re-run
**Drop `PROBE-C1-03` from the primary McNemar. Nothing else changes.**
| Bank | Cluster-aware McNemar power @0.139→0.50 | @0.70 |
|---|---|---|
| all 10 NONE items | 0.98 | 1.00 |
| **9 items, `03` excluded** | **0.96** | **1.00** |
**The exclusion costs 0.02 of power.** Re-running would cost hours of clean-room lock for nothing.
**Report `03` separately** as a single-item observation, explicitly labelled as confounded — it still carries
information about whether the reword worked, just not about framing.

## 3. WHAT THIS DOES *NOT* AFFECT
- **The other 19 items are clean.** All A-arm bodies match what the probe administered; only `03`'s B arm
  diverges. The paired invariant holds everywhere else.
- **Run 962's data is fine.** It is a pure A-arm administration; the confound only bites at the A-vs-B comparison.
- **The length-tell analysis is unchanged** — the +32-char A→B delta holds for the 19 clean items.

## 4. A GATE THIS SHOULD HAVE HAD, for every future paired design
**Before administering any paired A/B bank, assert that the two arms differ ONLY in the manipulated variable.**
Mechanically: strip the manipulation (here, the stem) and require byte-identical remainders. It is three lines,
it runs in a second, and it would have caught this before a single call was spent. **I am adding it to
`itembank_lint.py` as `PAIR_BODY_MISMATCH` (ERROR).** My linter checked leakage, key consistency and collisions —
it never checked that a paired design was actually paired, because until now nothing here was paired.

## 5. ON THE 67% SIGNAL FROM RUN 962 — do not read it yet
Run 962 is **framing A on e2b, 40/60**. That is *not* a NONE rate: 60 = 20 items × 3 reps (or similar), and it
pools **NONE items with fallacy controls**, which the probe showed score ~1.00. The `NONE`-specific rate under A
is what matters and it is not extractable from a single pooled score. **The stopping rule reads `NONE` under B,
which has not run yet.** A pooled A-arm number is not evidence for or against either hypothesis.

## 6. WHAT I AM NOT CLAIMING
- I compared **A-arm text from `probe_items.json` + migration 051** against **B-arm text parsed from migration
  052**. If the executor reads item text from the database rather than these files, and the DB diverges from the
  migrations, my comparison describes the migrations rather than what was administered. **The DB is the ground
  truth I cannot see.** Worth one query on Hermes's side: compare `prompt_text` for `PROBE-C1-03` and
  `PROBE-C1-03 [B-neutral]`, stems stripped.
- The power figures are simulation at the probe's measured base rate, not a closed-form calculation.
