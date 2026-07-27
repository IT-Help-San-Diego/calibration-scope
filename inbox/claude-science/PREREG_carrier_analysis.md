# Powered-run analysis harness — PRE-REGISTERED, written before runs 970-973 produced output
_Claude Science, 2026-07-27. `carrier_analysis.py`, 6/6 self-tests pass. Commit BEFORE the CSV lands._
_Also: migration 054 verified against the bank JSON, one real leak measured, and my own second reading error._

## 0. WHY THIS EXISTS
I recommended the rate-based test as primary and then had not written it. **A pre-registration that lives only in
a recommendation is not a pre-registration.** This is the executable version, self-tested against synthetic data
with known ground truth, committed before any of runs 970-973 emits a row.

## 1. DECLARED NOW, SO IT CANNOT BE CHOSEN LATER
**PRIMARY:** paired t on **cell pass-rates**, unit = **(family, model)**, contrast = baseline vs Lean.
- *Rate, not majority vote* — simulated resolution roughly 2× (d=0.05: power 0.87 vs 0.59), and calibrated
  (null false-positive 0.044–0.055 at α=0.05).
- *Family, not item* — 118 families of 2–3 template-sharing items are not independent. Family-level power at
  d=0.05 is **0.78**, item-level 0.86. **The clustered figure is the honest one.** This is the third time
  clustering has moved a number in this project.
**SECONDARY (always reported):** vote-then-McNemar at (item, model). Lossy by design; robustness only.
**THE TEST §10.9 ACTUALLY NEEDS — an interaction.** Two separately-significant within-model drops do **not**
establish that the drops *differ*. The harness computes a paired test on per-family drops between models, and
**only a significant interaction licenses "carrier sensitivity differs by model."** §10.9's downgraded claim
requires exactly this, and nothing in the project has run it yet.

## 2. GATES THAT FIRE BEFORE ANY VERDICT IS READ
| Gate | Behaviour |
|---|---|
| missing columns | **BLOCK** |
| any `is_infra_error` row | **BLOCK** — infra errors are MISSING, never failures |
| unpaired (item,model) cells | **BLOCK** — the paired invariant, the thing that bit `PROBE-C1-03` |
| **length leak** | Spearman(item length, pass) at baseline, per class — reports `length_leak_binds` |
| **defect triage** | items failing on **all** models flagged for KEY REVIEW, not reported as difficulty |
Self-test coverage: real effect, null control, single-model effect (interaction), infra-error block, unpaired-cell
block, and unit-of-analysis assertion (`n_units` must be 236 = 118 × 2). **6/6 pass.**

## 3. REPO CONSISTENCY — the `PROBE-C1-03` gap does NOT exist for this bank
Compared `migrations/054_powered_bank.sql` against `analysis/powered_bank_base.json`, all 293 items:
| Check | Result |
|---|---|
| item name sets identical | **yes** (293 = 293) |
| expected_result mismatches | **0 of 293** |
| prompt_text mismatches | **0 of 293** |
| old tokens in the migration | `'VALID'` 0, `'INVALID'` 0; `'HOLDS'` 74, `'DEFEATED'` 37 |
**The migration is a faithful, replayable source.** A database rebuilt from version control reproduces this run —
the defect that made `PROBE-C1-03` unreproducible is absent here.

## 4. ONE REAL LEAK, MEASURED PROPERLY THIS TIME
The framing bank's length tell was caught by range overlap. **Overlap is the wrong test** — these ranges overlap
and the leak is still there. So I measured what a length-only classifier actually scores:
| Class | Best length-only rule | Majority-class baseline | Lift |
|---|---|---|---|
| **quant-scope** | **0.874** (threshold 193 chars → TRUE) | 0.533 | **+0.341** |
| defeasible | 0.667 | 0.667 | **+0.000** |
**Defeasible is clean. Quant-scope is not** — a rule reading only stem length scores 0.874 on the class carrying
most of the bank.
**Does it bind? Three checks:**
1. **The carrier contrast is structurally immune.** The carrier is applied *within* item — same text, baseline vs
   Lean — so length is constant across arms and cannot produce a differential effect. Same argument that cleared
   the framing bank, and it holds here.
2. **Measured evidence says the tell goes unexploited**: probe quant-scope accuracy was 0.692, *below* the 0.874 a
   length rule would deliver. Indirect — probe items are not powered items.
3. **What it threatens is the ABSOLUTE off-ceiling rate.** A model exploiting length would score ~0.874 on
   quant-scope, pushing the class toward the ceiling and reintroducing the compression that made the pilot STOP.
**PRE-REGISTERED WATCH CONDITION:** if baseline quant-scope accuracy lands near 0.874 **and** Spearman(length,
pass) is ≥0.30 with p<0.05, the class is partly being scored on length and its off-ceiling yield is illusory.
**The gate runs automatically and prints before the verdict.**
**Fix for the next bank, additive:** author long FALSE items and short TRUE items until the length-only rule drops
to the majority baseline. Do not shorten the existing TRUE items — the detail is what makes the scope reading
explicit.

## 5. MY SECOND READING ERROR OF THE SESSION — same class, one hour after writing the rule against it
I printed *"powered bank: quant-scope 0.75-0.80 range"* in a cell whose own output above it read **0.874.** I
hardcoded a remembered range into a narration line instead of reading the computed value — and I had written the
standing rule against exactly this an hour earlier ("print the numbers and the verdict separately, read the
numbers before writing the verdict"). **Two instances in one session makes this my most frequent failure mode, and
exhortation has now demonstrably failed to prevent it twice.**
**The mechanical fix, which is the only kind that works:** narration lines must not contain literal numbers.
Interpolate from the variable (`f"...{best[0]:.3f}..."`) or say nothing numeric. A hardcoded figure in a print
statement is a claim with no derivation, which is precisely what this project exists to eliminate.

## 6. WHAT I AM NOT CLAIMING
- **Power figures are simulations** at assumed base rates (p≈0.55, item SD 0.12, family SD 0.12) and an assumed
  family structure. If the powered items land nearer the ceiling, power **falls** — §1's own table shows
  vote-based power collapsing to 0.34 at p=0.95.
- **The harness is self-tested on synthetic data**, which validates that the estimators behave, not that they are
  the right estimators for whatever the real data looks like. A deviation I have not anticipated will need a
  documented, dated amendment — not a quiet switch.
- **The length-leak measurement is of the bank, not of behaviour.** Whether models exploit it is unknown until
  run 970's baseline lands; that is what the gate is for.
- **I have not read the 293 items for keying defects.** Lint 0/0 is mechanical; the probe found 2 of 11
  off-ceiling items with construct problems no linter could see. `defect_triage` is the compensating control.
