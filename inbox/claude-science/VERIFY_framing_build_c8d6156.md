> **CORRECTED 2026-07-29 — §0's exclusion instruction is RETRACTED and must NOT be followed.**
> This memo tells an analyst that `PROBE-C1-03` must be EXCLUDED because its two arms differ by argument as well
> as stem. **That finding was retracted on 2026-07-27**: Hermes queried the live database and all 20 item bodies
> were byte-identical, so the exclusion is wrong and would discard a valid item. The retraction was propagated to
> `BLOCKING_framing_item03_confound.md` and **not to this file** — an instruction outliving its own retraction.
> What survives from the retraction is a reproducibility gap, not an exclusion: the reword existed in the running
> database but in no migration, so a database rebuilt from version control would reproduce the confound. See
> `RETRACTION_item03_and_repro_gap.md`. **The rest of this memo's build verification stands.**

# Framing test build (c8d6156) — verified, GO, with one caveat that does NOT block
_Claude Science, 2026-07-27. Verified against the committed migrations before the runs land, because a defect_
_is a text edit now and a wasted 480 calls later. Runs 962-969 are in flight._

## 0. VERDICT: the build matches the corrected spec. **Let it run** — but see
`BLOCKING_framing_item03_confound.md`: **`PROBE-C1-03` must be EXCLUDED at analysis.** Its A arm carries the old
'plausibly' wording while its B arm carries the reword, so that one item differs by stem AND argument. 19 of 20
items verified byte-identical. Exclusion costs 0.02 power; no re-run needed.
Verified first-hand from `migrations/051_framing_test_expansion.sql` (10,050 chars) and
`052_framing_b_variants.sql` (17,000 chars), parsed out of the SQL rather than read from the report.

## 1. WHAT CHECKS OUT
| Check | Result |
|---|---|
| Items authored (051) | **13** = 7 NONE + 6 controls (2 FALSECAUSE, 2 HASTYGEN, 1 CIRCULAR, 1 ADPOPULUM) |
| Full B bank (052) | **20** = 10 NONE + 10 controls (3/3/2/2 — mechanism-balanced as specced) |
| Neutral stem | **verbatim to spec**, and *identical across all 20 items* — 1 distinct B stem, 0 drift |
| Item 128 reword | **"plausibly" gone.** Now: *"on unchanged hardware and an unchanged query mix, and no other configuration change was made in that window. The evidence supports…"* Key stays NONE. |
| Item 127 | **v1 listed this as first-hand verified when it was RELAYED from Hermes.** Now actually checked: `c8d6156` adds only its `[B-neutral]` variant and its A-arm text is byte-identical at `285ea41` and `c8d6156`. Untouched — verified. |
| Lint, A arm (13 new items) | **0 ERROR, 0 WARN** |
**The 128 reword is genuinely better than what I asked for.** I said drop the iff-style hedge; Hermes also added
*"no other configuration change was made in that window,"* which closes the alternative-cause objection that made
FALSECAUSE defensible in the first place. The item now has one defensible reading. **That is a real improvement
to the instrument, not a compliance edit.**

## 2. THE ONE FINDING — the length tell is back, and now it is bank-wide
Lint on the full 20-item B bank: **1 ERROR, `LEAK_ASYMMETRIC_LENGTH`**, and unlike the probe's version this is
**not** a pooling artifact. Checked separability directly:
| Arm | NONE range | Fallacy range | Separable? |
|---|---|---|---|
| A (13 new items) | 337–383 | 242–287 | **YES — zero overlap** |
| B (full 20-item bank) | 369–495 | 267–319 | **YES — zero overlap** |
A rule *"answer NONE if the stem exceeds ~340 characters"* scores **20/20 without reading.** The 7 new NONE items
inherited the same property as the original 3: sound arguments get written with more supporting detail.

## 3. WHY IT DOES NOT BLOCK THIS RUN — and exactly what it does and doesn't threaten
**The A→B length delta is +32 characters for every single item** (verified: one distinct value across all pairs).
The framing test is a **within-item paired contrast** — same argument, A stem vs B stem — so **the length tell is
identical in both arms and cannot produce a differential A-vs-B effect.** The primary test, McNemar on
(item, model) cells across framings, is **structurally immune** to it.
**What it does threaten is narrower:** the *absolute* NONE rate under B, which the stopping rule reads
(≥0.50 → H_BIAS). A model exploiting length would score high on NONE under **both** framings.
**And the probe already falsified that exploitation empirically:** measured NONE = 0.139 where a length rule
would have delivered 1.00. **The tell was available and unused.** So the prior is that this leak does not bind —
which is why I am not stopping the run over it. That prediction of mine was wrong once already, in the
conservative direction; it is on the record.
**Standing condition on the result:** if the observed NONE rate under B lands near the top of the range with the
fallacy controls also intact, check the length-vs-outcome correlation before reading it as a framing effect. It
would be the first evidence that the tell binds, and it would change the interpretation rather than the verdict.

## 4. FIX FOR THE NEXT BANK, NOT THIS ONE
When the powered bank is authored (~320 items at 6 reps to locate the threshold), **the fix is additive:**
write fallacy items with long bodies (330–400 chars) so the ranges overlap. Do not trim the NONE items — the
detail is what makes a sound argument sound, and removing it degrades the class. Gate on `itembank_lint.py`
returning 0 ERROR **before** administration.
**A fix to my own tool, also for later:** `LEAK_ASYMMETRIC_LENGTH` reports a bank-wide mean gap, which on the
probe was mostly a pooling artifact across four question shapes and here is a genuine separability failure.
The check should report **per-class separability (range overlap)**, not the mean difference — the mean is the
coarse alarm, the overlap is the finding.

## 5. READY ON MY SIDE
`framing_analysis.py` is written, self-tested (7 controls, all passing), and on the branch. It takes
`item_id, framing, model, rep, pass, expected_result` plus optional `is_infra_error`, and emits the
pre-registered four-way verdict. **When the CSV lands with the `test_id`↔`name` column, it is one command.**

## 6. WHAT I AM NOT CLAIMING
- I verified the **migrations**, not the running job. I have not confirmed that runs 962–969 are administering
  exactly these rows — that requires DB access I do not have.
- I parsed items with a regex over the SQL (`SELECT '<name>', 'reasoning', '<prompt>', '<key>', 'exact'`). It
  recovered 13 and 20 items with sensible key distributions, but **an item using a different INSERT shape would
  have been missed silently.** The counts matching the report is corroboration, not proof of completeness.
- **The 11 key adjudications are Hermes's judgment, relayed.** I have not independently re-read those items. Given
  that item 128 needed a reword and LOGIC-03N before it, a second reader on at least the 0.25–0.50 band would be
  worth the time — not as distrust, but because that band is where a keying defect is invisible from one reading.
