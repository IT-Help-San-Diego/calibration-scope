# CORRECTION — the powered-run bank size was derived from the WRONG power calculation
_Claude Science, 2026-07-26. Audit finding confirmed with a margin. Supersedes ANALYSIS_probe_results.md §4,_
_NEXT_STEPS_calibration_scope.md item 4, and the EPISTEMIC_LOG decision entry of 22:48Z._

## 0. WHAT I DID WRONG
I wrote *"McNemar needs ~25 items at d=0.8, ~63 at d=0.5 (computed earlier this session)"* and built the
~120–130 item recommendation on it. **Those numbers are not a McNemar requirement.** They came from
`n_per_arm(d) = 2*((z_a+z_b)/d)**2` — a **two-sample t-test sizing for a CONTINUOUS completion-token outcome,
per arm**, computed for the entirely separate reconciliation-cost design. I transplanted a continuous-outcome
effect size (Cohen's d) into a **paired-binary** design where the effect is a difference in pass proportion and
power depends on the **discordant-pair supply**. Different test, different outcome type, different units.
**It also contradicted my own earlier McNemar work in this session, which used ~500 items to reach power ≈0.82–0.93
for carrier deltas of 0.05–0.10.** I had the right number in front of me and used the wrong one.

## 1. THE ACTUAL REQUIREMENT, driven by the probe's own measured rates
Off-ceiling item rates across the 3 graduating classes (n=14, measured):
`0.00, 0.00, 0.25, 0.25, 0.25, 0.25, 0.42, 0.50, 0.50, 0.50, 0.50, 0.50, 0.75, 0.92` → **mean p0 = 0.40**.
Simulated McNemar at the item level, one scoring per item per carrier:
| informative items | d=0.05 | d=0.10 | d=0.20 |
|---|---|---|---|
| 25 | 0.03 | 0.06 | 0.22 |
| **60** | 0.06 | **0.16** | 0.59 |
| 100 | 0.09 | 0.28 | 0.84 |
| 200 | 0.16 | 0.55 | 0.99 |
| 400 | 0.30 | 0.85 | 1.00 |
**My "~60 informative items" gives power 0.16 at d=0.10 — not 0.80.** The finding is confirmed with room to spare.

## 2. WHAT RESCUES IT — repeated scoring per cell, not more items alone
Majority-voting each item within carrier suppresses measurement noise, so discordance reflects true per-item
differences:
| informative items | reps=1 | reps=3 | reps=6 |
|---|---|---|---|
| **d = 0.10** | | | |
| 60 | 0.16 | 0.28 | 0.47 |
| 100 | 0.28 | 0.48 | 0.73 |
| **150** | 0.42 | 0.67 | **0.90** |
| 200 | 0.54 | 0.81 | 0.96 |
| **d = 0.20** | | | |
| **60** | 0.59 | **0.82** | 0.97 |
| 100 | 0.84 | 0.97 | 1.00 |
**Reps are the cheaper lever than authoring** — 6 reps at 150 items beats 1 rep at 400.

## 3. REVISED RECOMMENDATION
Measured off-ceiling yield across the 3 graduating classes: **14/30 = 47%**.
| Target | Informative items | Authored bank | Powered for |
|---|---|---|---|
| minimum defensible | 60 | **~128** | d≥0.20 at 3 reps (0.82) — a LARGE carrier effect only |
| recommended | **150** | **~320** | d≥0.10 at 6 reps (0.90) |
| d=0.05 resolution | 400+ | ~850 | not feasible; **state as out of scope** |
**So my ~120–130 number was not wrong as a floor — it was wrong about what it buys.** It supports a large-effect
test at 3 reps, and nothing finer. The honest framing:
- **If the question is "does a heavy carrier drag a weak model by ≥20 points?"** → ~128 items, 3 reps, adequate.
- **If the question is "where is the immunity threshold?"** (§10.9's actual question, which needs resolving
  differences of ~10 points) → **~320 items at 6 reps**, and there is no shortcut.
- **d=0.05 is out of reach** at any feasible bank size. Say so in the design rather than discovering it later.

## 4. THE PROCESS FAILURE, NAMED
This is a new class for me: **transplanting a power number across designs**. The prior corrections were
verify-a-subset-and-certify-the-set; this one is a *unit error* — a continuous-outcome Cohen's d used as a
paired-binary item count, and it drove the headline recommendation in two artifacts and a chat bottom line.
**Standing rule added: a power figure may only be cited with its test, its outcome type, and its units attached.
If a number is reused, re-derive it in the new design rather than quoting it.** The tell I should have caught:
"items per arm" (a between-groups quantity) appearing in a **within-item paired** design, where there are no arms.
