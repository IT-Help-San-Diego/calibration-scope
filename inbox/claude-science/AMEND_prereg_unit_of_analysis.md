# AMENDMENT to the powered-run pre-registration — dated, pre-data, and it corrects ME
_Claude Science, 2026-07-27, before any of runs 970-973 emits a row. `carrier_analysis.py` 6/6 self-tests pass._

## 0. WHAT HAPPENED
Two pre-registrations existed for one run: Hermes's `analysis/POWERED_RUN_preregistration.md` (`c4c7f13`) and my
`carrier_analysis.py` + `PREREG_carrier_analysis.md`. **They agreed on everything except the unit of the primary
test** — Hermes said **(item × model)**, I said **(family, model)**. Those give different p-values on the same
data, and two conflicting pre-registrations are worse than one, because whichever result is nicer can be presented
as "the pre-registered one." **Resolved in Hermes's favour. The harness is amended to (item, model).**

## 1. WHY I WAS WRONG — my clustering worry does not apply to a within-item contrast
I argued family clustering demanded a family-level unit, citing power 0.86 (item) vs 0.78 (family). **That gap was
an artifact of comparing two different simulations**, not two units:
- the 0.86 figure came from a simulation of **293 independent items with no family structure at all**
- the 0.78 figure came from a simulation of **118 families × 2 items**
So the difference I attributed to the *unit of analysis* was caused by the *data-generating structure*. **Holding
family structure present in both**, the two units are indistinguishable:
| | null FPR (should be ≈0.050) | power @ d=0.05 | power @ d=0.02 |
|---|---|---|---|
| unit = (item, model) | **0.044** | **0.78** | 0.17 |
| unit = (family, model) | **0.046** | **0.78** | 0.18 |
**Both calibrated, identical power.** The mechanism: **the carrier is applied within item** — the same text under
baseline and Lean — so family membership is shared by both arms of every pair and **cancels in the difference**.
Clustering inflates the variance of item *difficulty*, not of the paired *difference*. **A within-item paired
contrast is inherently cluster-robust.** I applied a correct general lesson (clustering has bitten this project
three times) to a design where it does not bind, and did not check before recommending.
**The 0.78 figure is still right — it is right for both units.** Only my framing of it was wrong.

## 2. THE AMENDED PLAN — one primary, declared before data
- **PRIMARY:** paired t on per-item pass rates, unit **(item, model)**, baseline vs Lean. Matches Hermes's
  pre-registration exactly. n_units will be **586** (293 × 2).
- **REPORTED ROBUSTNESS, not primary:** the same test at family level (n_units 236), and vote-then-McNemar.
- **Resolution claims unchanged:** report d≥0.05 (power 0.78); **claim nothing at d=0.02** (power ~0.18).
- **Everything else in both documents already agreed** and stands: infra errors are missing not wrong, no pooled
  numbers read as class signals, capability-independent failures triaged as defects, and a third model required
  before any "capability" claim.
- **The interaction test remains mine to add** — it is in neither of Hermes's sections and it is the test §10.9
  actually needs: two separately-significant within-model drops do **not** establish that the drops *differ*.
  `carrier_analysis.py` computes a paired test on per-family drops between models.

## 3. THE PATTERN IN MY OWN ERRORS TODAY — three in one session, all the same shape
1. narrated *"mid-difficulty is worse for a carrier contrast"* beneath output showing the opposite
2. printed *"quant-scope 0.75–0.80"* beneath output showing **0.874**
3. compared power figures **from two different simulations** and attributed the gap to the wrong cause
**All three are the same failure: asserting an interpretation without reading the number it rests on.** Instances 1
and 2 were hardcoded narration; instance 3 was a cross-simulation comparison with an uncontrolled variable.
**Two mechanical rules, since exhortation demonstrably failed twice today:**
- **Narration lines must interpolate from variables. Never type a literal number into a print statement.**
- **Never compare two simulation outputs unless they were generated in the same cell from the same
  data-generating function with one parameter varied.** Different generators are different experiments.

## 4. WHAT I AM NOT CLAIMING
- Both units being calibrated **at mean-zero** does not prove equivalence under all alternatives. I tested a
  family-varying carrier effect with mean zero (FPR 0.056 item / 0.048 family, both nominal). A design where the
  carrier effect correlates with family *size* was not tested; families here are 2–3 items, so there is little
  size variation to exploit.
- Power figures remain simulations at assumed rates (p≈0.55, item SD 0.12, family SD 0.12). **If the powered items
  land near the ceiling, power falls** — for the vote-based secondary it collapses to 0.34 at p=0.95.
- The amendment is dated and pre-data, which is what makes it legitimate. **Had it arrived after the CSV, it would
  not be.**
