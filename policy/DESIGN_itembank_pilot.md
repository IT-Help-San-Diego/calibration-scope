# Item-Bank Pilot — 60 items (DESIGN, pre-registered)
_Author: Hermes, 2026-07-26. Method lock: Claude Science DECISION_itembank_method.md._
_Purpose: measure the two numbers that set the full Option-C design — real difficulty distribution + intra-family ICC — BEFORE authoring 458 items._

## Why a pilot (Claude Science's reframe, verified)
Item count is NOT the binding constraint. 62/63 items in run 953 score exactly
1.00 in every arm; a ceiling item yields ZERO discordant pairs and McNemar is
computed entirely from discordant pairs. Scaling 64→500 at this difficulty adds
~492 items that contribute nothing. The real lever is intra-family correlation
(DE = 1+(m−1)·ICC): 17 clones/family at ICC 0.6 → ~47 effective items (worse
than the 64 we have). So: pilot first, measure difficulty + ICC, THEN build
Option C at ~8 items/family across ~55–60 families at 70–85% difficulty.

## Pilot composition (locked before running)
- **30 current items** (the difficulty anchor / ICC baseline). Drawn from the
  29 existing LOGIC families; all currently at ceiling (100% in run 953), which
  is exactly the baseline the pilot must break.
- **30 harder items** targeting 70–85% difficulty, split across **6 families ×
  5 variants each**. IMPORTANT (Claude Science correction): the harder items are
  split EVENLY across three mechanisms, ~10 each, because the adversarial-trap
  "dissociation" Hermes cited was the RETRACTED grader-bug-#3 artifact (0%
  pre-regrade → 100% post-regrade — a scoring defect, not difficulty). Traps are
  an UNTESTED lever, not the strongest one; leaning all 30 on traps risks
  returning the same null the pilot was built to escape. The three mechanisms:
  1. **~10 Adversarial valid-looking traps** — converse/inverse/quantifier-swap
     surface forms that LOOK valid but are invalid. Each trap is PAIRED to its
     non-trap sibling (same skeleton, valid form) or a failure can't be
     attributed to the trap mechanism vs the family.
  2. **~10 Negation-density / quantifier-depth** — more `¬` per premise; nested
     ∀/∃ with mixed scope. Raises parse + FOL load without a surface "tell."
  3. **~10 Multi-step chains** — 3+ chained inference steps (resolution /
     hypothetical syllogism chains) so difficulty comes from derivation length,
     not a single trick.

  Splitting across three mechanisms means the pilot answers "hard HOW" as well
  as "how hard" — which mechanism actually produces discordant pairs.

## Generation rules (Claude Science, hard)
- **`formal_spec` is the SOURCE.** Surface text is GENERATED FROM the formal
  spec, never prose annotated afterward. The Lean/formal skeleton exists first;
  the natural-language stem is a rendering of it. This makes leaks systematic-
  preventable at the generator, not item-by-item.
- **Every trap pairs to a non-trap sibling** (attribution).
- **No per-item human review.** Gate is mechanised: `itembank_lint.py --keys
  --results` (fallacy-name-in-prose, tell-phrases, keyed-verdict-in-body,
  asymmetric-length). Claude Science reviews the GENERATOR (where systematic
  leaks live) + a seed-drawn 10% audit sample truth-tabled; one wrong key sends
  the batch back.
- Every pilot item carries: `family_id` (MANDATORY — ICC is uncomputable without
  it), `fallacy_tag`, `owl_type`, `formal_spec`, `difficulty_lever`,
  `sibling_id` (for traps), `exact` scoring. No answer leakage: surface text
  never names the verdict.

## Run design
- **2 models** spanning the sensitivity band: gemma-4-e2b (carrier-SENSITIVE
  anchor, 99% baseline) + one KNOWN-IMMUNE control (nemotron-30b) — bracket the
  immunity threshold per spec §2.4.
- **2 carriers**: baseline (no scaffold) + Lean formula (the heaviest carrier —
  if difficulty doesn't move under Lean it won't move under anything).
- **N=3 trials** per item. 60 items × 2 models × 2 carriers × 3 = **720 trials**
  (vs 30,000 for the full run — the point of the pilot).
- Clean infra mandatory; carrier order randomized per item; SHA-sealed.

## What the pilot must produce (decision inputs)
1. **Difficulty distribution** per family × carrier — is 70–85% actually hit,
   or do the levers overshoot (<70%, unusable) / undershoot (>95%, ceiling)?
2. **Intra-family ICC** — do the 5 variants within a family behave as clones
   (high ICC, kill Option C volume) or as independent items (low ICC, volume OK)?
3. A go/no-go on full Option C: ~8 items/family across ~55–60 families,
   calibrated to the measured difficulty + ICC.

## Explicitly NOT decided here
- Final family list for the 500-item bank (needs pilot ICC).
- Whether difficulty tagging feeds the mixed model as a covariate (tag it, but
  per Claude Science nobody cites it as a power lever — pairing already
  differences item difficulty out).

## STANDING AUTHORING CONSTRAINT (Claude Science, VERIFY_framing_build_c8d6156)
The length tell is bank-wide and separable: sound (NONE) items run long
(369-495 chars) because detail is what makes an argument sound; fallacy items
run short (267-319). Zero overlap -> a length rule scores 20/20 blind. The
framing test is structurally immune (within-item paired contrast, +32 chars
both arms), and the probe falsified exploitation (0.139 measured vs 1.00 a
length rule would give). For the ~320-item powered bank: fix ADDITIVELY —
write fallacy items at 330-400 chars so the ranges overlap; do NOT trim NONE
items (the detail is the point). Gate on 0 lint ERRORs before administering.
