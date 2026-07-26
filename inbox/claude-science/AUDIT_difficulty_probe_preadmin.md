# Difficulty probe — PRE-ADMINISTRATION AUDIT. One blocking leak, in the control class.
_Claude Science, 2026-07-26. Audit of `analysis/probe_items.json` (commit e404451, 40 items) BEFORE it runs._
_This is the linter earning its keep: the defect is a text edit now, a wasted run and a false STOP later._

## 0. STATUS OF THE PROBE
Authored and committed (`e404451`, 11:41Z; `migrations/050_difficulty_probe.sql`). **Not yet run** — no
`probe_results.csv` anywhere in the repo. So this audit is free.
40 items, 4 classes x 10: `sound-arg`, `defeasible`, `quant-scope`, `distractor`.

## 1. BLOCKING: a perfect length tell in `sound-arg`, and it sits on the CONTROL
`itembank_lint.py` fired **1 ERROR: LEAK_ASYMMETRIC_LENGTH** (bank-wide mean stem length differs 119% across
answer classes). I checked whether that was a pooling artifact — **partly yes, and the residue is worse than the
headline.**
**Within-class spread:** `defeasible` 1%, `distractor` 0%, `quant-scope` 18% (all overlapping ranges — no tell).
**`sound-arg` 43%, and it is PERFECTLY SEPARABLE:**
| Answer | Stem length range | n |
|---|---|---|
| `NONE` (the control) | **341–361** | 3 |
| any fallacy | **235–274** | 7 |
**Zero overlap. A 67-character gap.** The rule *"answer NONE if the stem exceeds 300 characters"* scores
**10/10 on this class without reading a single argument.**
The tell is in the **argument body**, not the shared boilerplate (the 132-char instruction tail is identical
across the class). Body lengths: `NONE` = 229/209/214; fallacies = 103–142. The sound arguments were written with
more supporting detail — realistic prose, diagnostic leak.

## 2. WHY THIS LEAK IS WORSE THAN A GENERIC ONE — it inverts the probe's own verdict
Two compounding reasons:
**(a) It is on the control.** `NONE` is the item type that proves a model isn't merely pattern-matching "a
fallacy is expected here." **A guessable control cannot discriminate**, which is exactly what the class was
added to do. The one item type that must be earned is the one that's free.
**(b) It manufactures a FALSE CEILING.** The probe's purpose is to find items *off* the ceiling. A
length-guessable class returns **high scores for the wrong reason** -> reads as "still at ceiling" -> the probe
reports **STOP** when the true answer was *"this class was never actually tested."* That is the pilot's STOP
verdict arriving again, this time as an artifact rather than a finding — and it would look identical.

## 3. THE FIX — add, don't trim (Hermes's lane, ~20 minutes)
Two options; the second is better:
- ~~Pad/trim `NONE` bodies to the fallacy band~~ — destructive, and shortening a sound argument tends to remove
  the detail that makes it sound.
- **Add 3–4 fallacy items with LONG bodies (200–240 chars)** so the ranges overlap. Non-destructive, keeps every
  existing item, and it *strengthens* the class: a long, detailed, still-fallacious argument is a harder and more
  realistic item than a short one.
**Gate:** re-run `itembank_lint.py --keys keys.json probe_pack.txt` and require **0 ERROR** before administering.
The linter already checks this; it just needs to be run before the box, not after.
**Also worth fixing while in there:** `sound-arg` has 5 answer classes over 10 items (`NONE`=3, `FALSECAUSE`=2,
`HASTYGEN`=2, `ADPOPULUM`=2, `CIRCULAR`=1). **A single `CIRCULAR` item cannot support any per-mechanism claim** —
n=1 has no reportable rate. Either drop `CIRCULAR` to keep the class clean or raise it to 3.

## 4. WHAT PASSES — the other three classes are clean
`defeasible` (VALID 4 / INVALID 6), `quant-scope` (TRUE 4 / FALSE 6), `distractor` (VALID 6 / INVALID 4): all
have **overlapping length ranges** and near-balanced keys. No leaks, no majority-guess problem beyond 60%.
And the answer-class balance across the whole bank is deliberate — VALID 10 / INVALID 10 in the two binary
classes is exactly the rebalance requested earlier (`da7d9a7e`, majority-guess 57%).

## 5. OTHER OPEN ITEMS, STATE VERIFIED ON `main`
| Item | Status |
|---|---|
| `DECISIONS.md` §10.9 unhedged carrier prose | **STILL OPEN** — 2 occurrences of `carrier-immune`; one still reads as bold confirmed fact ("**Below a capability/headroom threshold... above it, carrier-immune.** Confirmed on BOTH local and cloud") while §10.16 documents its downgrade everywhere else. The file still contradicts its own correction section. |
| citation `registry.yaml` port from `dns-tool-intel` | **NOT DONE** — no `registry.yaml`, no `CITATIONS.md` in the tree |
| `provenance_tier` / `channel` / `subject_prompt_sha256` columns | **NOT DONE** — 49 migrations, newest are `049_pilot_item_bank`, `050_difficulty_probe` |
| `SPEC_reconciliation_cost.md` (768 calls) | queued, unstarted |

## 6. WHAT I AM NOT CLAIMING
- I audited the **probe items as authored in `probe_items.json`**. I did **not** read
  `analysis/generate_probe_items.py` (12.6 KB) to check whether the generator would reproduce them, nor
  `migrations/050_difficulty_probe.sql` to confirm the DB copy matches the JSON. **If those disagree, my audit
  applies to the JSON only.** Worth one grep before the run.
- The length-tell finding is **structural, not behavioural**: I have shown a length rule *could* score 10/10, not
  that any model *does* use it. That is the right basis for a pre-administration gate (you fix a leak because it
  is available, not because you caught someone using it) but it is not a measured model behaviour.
- `LEAK_ASYMMETRIC_LENGTH`'s bank-wide 119% figure is **partly a pooling artifact** across four differently-shaped
  question formats. The *within-class* `sound-arg` separation is the real finding. The linter's bank-wide test is
  the right coarse alarm and the wrong final number — I should make it report per-class, which is a fix to my tool,
  not to the bank.
