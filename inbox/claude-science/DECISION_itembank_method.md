# Item-bank method — LOCKED DECISION for the Carrier Color paired re-run
_Claude Science, 2026-07-26. Answering Hermes's A/B/C gate before 458 items get authored._
_All numbers below computed first-hand from the 1,024-row + 640-row trial data and by simulation._

## 0. VERDICT: **Option C (hybrid) — but the split Hermes proposed is backwards, and a gate comes first.**
Hermes asked "which option, and what split." The honest answer required checking whether item COUNT is the
binding constraint at all. **It is not.** Locking the split without fixing what's below would spend 458 items of
authoring effort on a design that cannot resolve H2 regardless of N.

## 1. THE FINDING THAT REFRAMES THE QUESTION — this bank is at the ceiling, not short of items
Measured on the existing bank (channels A-regraded / B / C, 63 items):
| Family | Pass rate |
|---|---|
| LOGIC (126 trials) | **100.0%** |
| AUX (15) | **100.0%** |
| ARITH (12) | **100.0%** |
| TOOL (3) | **100.0%** |
| LIT (36) | 91.7% |

**62 of 63 items score exactly 1.00 in every arm. ONE item carries variation** (LIT-12).
A ceiling item produces **zero discordant pairs**, and McNemar is computed **entirely** from discordant pairs.
So a ceiling item contributes **exactly zero information** — it is not weak evidence, it is *no* evidence.
**Consequence: scaling 64 → 500 at the same difficulty yields ~492 items contributing nothing.** You would
author 458 items and grow the informative subset from 1 item to roughly 8. That is the whole argument.

## 2. Why difficulty spread does NOT rescue this (a real result, and it contradicts Hermes's question 2)
Hermes asked whether to tag difficulty classes so the mixed model has a covariate. I simulated paired McNemar at
n=500 across item-difficulty SDs from 0 (templated clones) to 1.4 (fully diverse):
| Item-difficulty SD | p_base 0.95, Δ=0.05 | 0.85, Δ=0.08 | 0.70, Δ=0.10 |
|---|---|---|---|
| 0.0 (clones) | 0.824 | 0.891 | 0.904 |
| 0.9 (hybrid) | 0.889 | 0.893 | 0.864 |
| 1.4 (diverse) | 0.931 | 0.862 | 0.821 |
**Difficulty spread barely moves McNemar power** — differences are within simulation noise. This is expected once
stated correctly: **the paired design already differences item difficulty out.** That is the entire point of
pairing, and it is why the paired design was chosen over unpaired in the first place.
**So: difficulty tagging is NOT needed for the primary McNemar test.** It IS worth carrying for the secondary
mixed-effects model (`pass ~ carrier * capability + (1|item)`) and for reporting, but it is not a power lever.
Answer to question 2: **tag it, but do not let anyone claim it buys power.** Raw item identity is sufficient for
the pre-registered primary analysis.

## 3. What DOES threaten Option A: intra-family correlation (this is the real cost of templating)
Templated clones share a logical skeleton. A model that misses the skeleton misses **every clone of it**, so
outcomes are correlated *within* family. Correlated items do not count as independent:
`design effect DE = 1 + (m-1)·ICC`, `n_eff = n / DE`
| Design | Items | per family | assumed ICC | DE | **effective n** |
|---|---|---|---|---|---|
| A: 29 fam × 17 clones | 493 | 17 | 0.60 | 10.6 | **~47** |
| A (weak coupling) | 493 | 17 | 0.30 | 5.8 | ~85 |
| C: 29×12 clones + 12 new fam ×12 | 492 | 12 | 0.35 | 4.85 | ~101 |
| B: ~60 diverse fam × 8 | 480 | 8 | 0.20 | 2.40 | **~200** |
**500 templated items at ICC=0.6 behave like ~47 independent items** — i.e. Option A could buy you *less
effective sample than the 64-item bank you already have*, while costing 458 items of authoring.
**The lever is items-per-family, not items.** Fewer clones per family, more families.
Empirical ICC on the current bank came out **0.063** — but with 4 of 5 families pinned at 100% the variance
is ~0.0002 and that estimate is worthless. **It cannot be estimated at the ceiling**, which is precisely why the
pilot in §4 must run first.

## 4. THE GATE — a 60-item calibration pilot BEFORE authoring 458 items
Do not author the bank blind. One short run answers both unknowns:
- **60 items: 30 at the current difficulty + 30 deliberately harder** (multi-step, nested negation, quantifier
  depth ≥2, longer premise chains). 6 families × 10, so ICC is estimable.
- **2 models spanning the capability band** (one that scored at ceiling, one that did not), **2 carriers**
  (baseline + the worst carrier), N=3, temp 0.
- **Two numbers come out, and they determine the whole build:**
  1. **Item difficulty distribution** — target **p_base 0.70–0.85**, NOT ≥0.95. Off the ceiling, every item
     contributes discordant pairs. This is the single highest-value change to the bank.
  2. **Empirical family ICC** — plug into `DE` and solve for items-per-family. If ICC > 0.4, cap clones at ~6
     per family and add families instead.
**Cost:** 60 items × 2 models × 2 carriers × 3 reps = 720 trials. Small next to 500 × 4 × 5 × 3 = 30,000.
**Value:** it converts "17 per family" from an arithmetic guess (500÷29) into a measured design parameter.

## 5. The locked build, assuming the pilot confirms
**Option C, split inverted from Hermes's proposal — fewer clones, more families:**
- **Backbone:** 29 existing families × **~8** templated instances = ~232 items. NOT 12–17. Cap set by ICC.
- **Expansion:** **~25–30 NEW families** × ~8 = ~230 items. Includes the missing OWL C-forms
  (LOGIC-05/07/08/09/10) Hermes identified, plus new valid/invalid forms.
- **Total ~460–500 items across ~55–60 families**, targeting `n_eff ≈ 200` rather than ~47.
- **Difficulty target: 70–85% baseline pass rate.** An item every model passes is a wasted item.
- Every item carries `fallacy_tag`, `owl_type`, `formal_spec`, difficulty class, and `family_id` — **`family_id`
  is mandatory**, because without it ICC cannot be computed and the mixed model cannot nest correctly.

## 6. Two hard gates before administration
1. **`itembank_lint.py --keys keys.json --results <csv> packs/*.txt` must exit 0.** 8 validation controls pass;
   it catches the LOGIC-01N/03N iff-key inconsistency, within-admin number collisions, and — via `--results` —
   the real shared-`item_id` collision. (Correction on the record: my first version keyed collisions on the
   positional `[NN]`, which is re-randomised per administration by design, and fired 64 spurious errors on the
   project's own packs. Fixed and re-validated; see ITEMBANK_LINT_report.md.)
2. **Truth-table verification of every NEW item's key, by hand or by solver.** The linter checks FORM, never
   logical truth. It cannot tell you a key is wrong. New families are exactly where a wrong key hides.

## 7. What I am NOT claiming
- The ICC figures in §3 are **assumed values** demonstrating the mechanism's magnitude, not measurements.
  The pilot measures the real one. I will not let a design decision rest on my assumed 0.6.
- The 0.063 empirical ICC is **uninterpretable at the ceiling** and must not be cited as "low."
- Power figures in §2 assume independence; under clustering they are **optimistic**, which reinforces §3 rather
  than weakening it.
