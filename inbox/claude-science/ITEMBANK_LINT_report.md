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
| `ID_COLLISION` | **ERROR** | one item number mapping to different stems across packs — **the 63-vs-64 defect** |
| `NO_FORMAT` | **ERROR** | no answer-format instruction → exact-match grading fails unpredictably |
| `MIXED_VOCAB` | **ERROR** | stem offers tokens from 2+ verdict sets; grader cannot disambiguate |
| `KEY_VOCAB_MISMATCH` | **ERROR** | key's leading token is not in the vocabulary the stem instructs |
| `TOKEN_PLUS_PROSE` | WARN | verdict token AND free prose requested → grader-bug-class-#3 surface |
| `ESCAPED_LITERAL` | WARN | literal `\n`/`\t` in a stem — the subject sees the escape |
| `IFF_CUE` / `IFF_PAIR_UNCHECKED` | WARN | biconditional cue present; re-run with `--keys` to check consistency |
| `DUP_STEM` | WARN | identical stem under different numbers → paired analysis treats them as independent |

## Validation (4 controls, all pass — this is the part that matters)
A linter that cannot demonstrate it catches the bug it was written for is decoration.
- **V1 positive control** — reconstructed the real LOGIC-01N/03N defect (`exactly when` keyed CONFIRMED +
  `precisely when` keyed DOESNOTFOLLOW): **exit 1, `IFF_KEY_INCONSISTENT` on `[01],[03]`.** Caught.
- **V2 negative control** — the SAME two stems keyed CONSISTENTLY: **exit 0**, no inconsistency flagged.
  So it flags the *inconsistency*, not the mere presence of the cue.
- **V3 ID collision** — item `[07]` with different stems in two packs: **exit 1, `ID_COLLISION`.** Caught.
- **V4 clean bank** — two well-formed items: **exit 0, 0 ERROR 0 WARN.** No false-positive floor.

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
python3 itembank_lint.py --keys keys.json packs/*.txt     # exit 1 blocks administration
```
**Recommendation: make this a hard gate.** Run it before a single item is administered, and again in CI on any
bank change. The cost of a caught defect here is a text edit; the cost of a missed one is what happened to the
isolation effect — 1,024 trials and a retracted flagship claim.

**Two limits, stated plainly:**
1. It checks *form*, not *logical truth*. It cannot tell you an item's key is wrong — only that the key's
   vocabulary contradicts the stem, or that two cued items disagree with each other. **Truth-table verification
   of new logic items is still manual** (that is what I did for the Model Picker battery and the LOGIC-03N dispute).
2. `IFF_KEY_INCONSISTENT` needs `--keys`. Without a key file it degrades to a WARN listing the cued items.
   **Run it with the keys, or the check that matters most is the one you skipped.**
