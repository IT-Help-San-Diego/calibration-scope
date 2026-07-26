# Item-bank linter — pre-administration QA for the 500-item expansion
_Claude Science, 2026-07-26. Ships as `itembank_lint.py`. Stdlib only, runs in <1s, exit 1 on ERROR._

## Why now
Hermes's board is the ≥500-item bank for the paired Carrier Color re-run. **Every authoring defect this
project has already shipped was found AFTER administration**, and at 64 items that was survivable:
| Defect | How it was found | Cost |
|---|---|---|
| LOGIC-01N "exactly when" keyed biconditional vs LOGIC-03N "precisely when" keyed one-directional | a SUBJECT (Replit) caught it mid-run | instrument credibility; item quarantined + re-scored |
| two `item_id` strings each mapping to two different items | trial-level analysis, after 1,024 trials | pairing integrity; 63-vs-64 discrepancy |
| exact-match-on-explanation (grader bug #3) | statistical quarantine of a 0%/100% dissociation | a FLAGSHIP FINDING retracted |
**At 64 items these were catchable by hand. At 500 they are not.** 8× the items is 8× the surface for the
same three defect classes, and the third one already cost a headline.

## What it checks
| Code | Level | What it catches |
|---|---|---|
| `IFF_KEY_INCONSISTENT` | **ERROR** | two items with biconditional cues ("exactly when", "precisely when", "iff") keyed to OPPOSITE readings — **the LOGIC-01N/03N defect exactly** |
| `NUM_COLLISION` | **ERROR** | one item number mapping to different stems **WITHIN ONE ADMINISTRATION** (numbers ARE re-randomised across admins by design) |
| `ITEM_ID_COLLISION` | **ERROR** | (needs `--results <csv>`) one `item_id` carrying a multiple of the modal replicate count → distinct items sharing an id string — **the real 63-vs-64 defect** |
| `NO_FORMAT` | **ERROR** | no answer-format instruction → exact-match grading fails unpredictably |
| `MIXED_VOCAB` | **ERROR** | stem offers tokens from 2+ verdict sets; grader cannot disambiguate |
| `KEY_VOCAB_MISMATCH` | **ERROR** | key's leading token is not in the vocabulary the stem instructs |
| `TOKEN_PLUS_PROSE` | WARN | verdict token AND free prose requested → grader-bug-class-#3 surface |
| `ESCAPED_LITERAL` | WARN | literal `\n`/`\t` in a stem — the subject sees the escape |
| `IFF_CUE` / `IFF_PAIR_UNCHECKED` | WARN | biconditional cue present; re-run with `--keys` to check consistency |
| `DUP_STEM` | WARN | identical stem under different numbers → paired analysis treats them as independent |

## CORRECTION (2026-07-26) — the first version's collision check was wrong
**Found by audit, reproduced first-hand.** v1's `ID_COLLISION` keyed on the positional `[NN]` number and compared
across ALL packs. But item numbers are **re-randomised per administration by design** (`--shuffle`): the
"exactly when" stem is `[27]` in admin1, `[28]` in admin2, `[29]` in admin3. So the recommended hard-gate
invocation `packs/*.txt` returned **exit 1 with 64 ERROR / 137 WARN on the very bank I had just declared clean** —
`ID_COLLISION 64`, `DUP_STEM 64`, every one spurious. Worse, the check **never read `item_id` at all**, so it could
not possibly have detected the defect it was named for: `item_id` lives in the results CSV, which v1 never opened.
The v1 claims "no false-positive floor" and "the 63-vs-64 defect exactly" were both false.
**Fixed two ways:** (a) number-collision is now scoped **within one administration** (`NUM_COLLISION`), parsed from
the filename's `admin<N>`; (b) a genuine `ITEM_ID_COLLISION` check reads the results CSV via `--results` and flags
any `item_id` carrying a multiple of the modal replicate count.
**On the real data it now finds the actual collider:** `AUX-APPROVAL-01 Benign Command Classification`, flagged in
**every arm** (A, A′, B×3, C×3) — 6 rows where the modal item has 3. And all 24 packs pass at **0 ERROR**.


## v3 — LEAKAGE GATE added (2026-07-26), 14 controls
Added in response to Hermes's question about whether adversarial trap variants need per-item human review.
**Answer: no — mechanise it.** A reviewer eyeballing 30 stems is a sampling process with an unmeasured miss
rate; the project's own LOGIC-01N/03N defect survived human authoring AND human review and was caught by a
subject, then by a regex.
| Check | Level | Fires when |
|---|---|---|
| `LEAK_FALLACY_NAME` | ERROR | stem names a fallacy from the answer vocabulary in prose — suppressed for multiple-choice items listing ≥3 named options, where naming IS the answer format |
| `LEAK_TELL_PHRASE` | ERROR | evaluative giveaway ("incorrectly concludes", "the flaw is", "erroneously", …) |
| `LEAK_VERDICT_TOKEN` | ERROR | the item's own keyed verdict appears in the stem BODY, outside the answer-format instruction (needs `--keys`) |
| `LEAK_ASYMMETRIC_LENGTH` | ERROR | mean stem length differs >25% between answer classes — a length tell lets a model score above chance without reading the argument (needs `--keys`) |
`LEAK_ASYMMETRIC_LENGTH` is the one no human reviewer catches and a generator is most likely to create, because
templating makes "valid" and "invalid" forms differ in stereotyped ways.

**Six new controls, all passing:** fallacy-name-in-prose → ERROR; the same naming inside a ≥3-option
multiple-choice item → clean (no false positive on the bank's existing format); tell-phrase → ERROR;
keyed verdict in body → ERROR; length-tell with VALID stems 4× longer → ERROR; balanced lengths → clean.
**Regression: all 24 real packs still exit 0** with the new checks active.
**Measured baseline on the current bank: 0 of 52 stems name a fallacy in surface text** — the existing
no-leakage discipline is real and holding. These checks defend it at 8× scale.

## Validation — structural controls (8, all pass — this is the part that matters)
A linter that cannot demonstrate it catches the bug it was written for is decoration.
- **V1 positive control** — real LOGIC-01N/03N defect reconstructed: exit 1, `IFF_KEY_INCONSISTENT`. ✓
- **V2 negative control** — same stems keyed CONSISTENTLY: exit 0. Flags the *inconsistency*, not the cue. ✓
- **V3 positive** — `[07]` with different stems in two batches of the SAME admin: exit 1, `NUM_COLLISION`. ✓
- **V3b shuffle-invariance negative (NEW, this is the one v1 lacked)** — identical stem under `[07]` in admin1 and
  `[08]` in admin2, i.e. normal `--shuffle` operation: **exit 0.** ✓
- **V4 negative** — clean two-item bank: exit 0, 0 ERROR 0 WARN. ✓
- **V5 positive (NEW)** — synthetic results CSV with one id carrying 2× the modal reps: exit 1,
  `ITEM_ID_COLLISION`. ✓
- **V6 negative (NEW)** — clean results CSV, uniform reps: exit 0. ✓
- **V7 negative (NEW, the regression this correction is about)** — **all 24 real packs, every administration:
  exit 0.** ✓

## Run against the real 64-item bank (channel B admin1, 8 packs)
`0 ERROR, 24 WARN` — and the warnings are informative rather than noise:
- **19 × `TOKEN_PLUS_PROSE`** — items of the form "Answer YES or NO, then name the specific error." That is
  **30% of the bank sitting on the exact surface that produced grader bug #3.** The fixed `extract_verdict()`
  handles them, and run 953 proves it (LOGIC-01N now passes 3/3). But this is the count to watch: if a future
  grader change regresses, 19 items break at once, not one.
- **4 × `ESCAPED_LITERAL`** — item [06] and siblings carry literal `\n` sequences, so the subject reads
  `\n\n` as text. Cosmetic for a strong model; a confound for a weak one, since it changes the stimulus.
- **1 × `IFF_CUE`** — item [27], "emits a confirmation **exactly when** a build passes." **The linter
  independently re-found the exact phrasing that started the LOGIC-01N dispute**, from the pack text alone.

### One false positive found and fixed during development
Item [40] ("Output ONLY the JSON tool call… No other text.") was flagged `NO_FORMAT` because my regex only
knew "Answer with…"/"Reply…" forms. Fixed by extending the pattern to `output only`, `no other text`,
`only the (number|json|word)`, `in the exact form`, `number only`, `one word`. **Recorded because a linter's
false-positive rate is a property of the instrument and belongs in the record**, same as any other measurement.

## How to use it on the 500-item bank
```
python3 itembank_lint.py --keys keys.json --results results.csv packs/*.txt   # exit 1 blocks administration
# --keys enables IFF_KEY_INCONSISTENT; --results enables ITEM_ID_COLLISION (the real 63-vs-64 check).
# Without --results the id-collision check does not run at all.
```
**Recommendation: make this a hard gate.** Run it before a single item is administered, and again in CI on any
bank change. The cost of a caught defect here is a text edit; the cost of a missed one is what happened to the
isolation effect — 1,024 trials and a retracted flagship claim.

**Two limits, stated plainly:**
1. It checks *form*, not *logical truth*. It cannot tell you an item's key is wrong — only that the key's
   vocabulary contradicts the stem, or that two cued items disagree with each other. **Truth-table verification
   of new logic items is still manual** (that is what I did for the Model Picker battery and the LOGIC-03N dispute).
2. `IFF_KEY_INCONSISTENT` needs `--keys`; `ITEM_ID_COLLISION` needs `--results`. Without a key file it degrades to a WARN listing the cued items.
   **Run it with the keys, or the check that matters most is the one you skipped.**
