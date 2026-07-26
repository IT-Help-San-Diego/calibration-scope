# CORRECTION — the framing test's pre-registered power and primary test were BOTH wrong
_Claude Science, 2026-07-26. Second audit finding on this design, and it is the more serious one._
_Supersedes `framing_test_pack.json` v1 (`primary_test`, `power`) and `NEXT_STEPS_calibration_scope.md` item 1._

## 0. WHAT I DID WRONG — I pre-registered the error I had already retracted
The pack said: `primary_test: "McNemar on NONE items, framing A vs B, paired within item+model+rep"` and
`power: "McNemar on 90 NONE pairs: 0.97 ... 1.00 at 0.139->0.50"`.
**"Paired within item+model+rep" treats 15 repetitions of the same 3 items as 90 independent observations.**
Earlier this same session I retracted exactly this: a carrier effect at trial-level Fisher p=0.0032 that
collapsed to p=0.625 under an item-level paired test and a cluster bootstrap, because repeated measurements of one
item are not independent. **I then wrote the retracted form into a pre-registration.** Worse, my simulator drew
n independent Bernoulli pairs, so it *could not represent* the correlation — and I stated the caveat ("reps are
correlated within item") in the same cell where the model ignored it. **A caveat is not a control.**
The real design has **3 `NONE` items × 2 models = 6 clusters**, with 15 correlated reps inside each cell.

## 1. THE ACTUAL POWER — cluster-aware, and it is catastrophic
Unit of analysis = the (item, model) **cell** (majority vote within cell); n_units = 6.
| reps | power @0.139→0.50 | @0.70 | @0.90 |
|---|---|---|---|
| 3 | **0.01** | 0.11 | 0.40 |
| 6 | **0.03** | 0.27 | 0.50 |
| **15** (what I specced) | **0.03** | 0.44 | 0.81 |
| 30 | 0.05 | 0.68 | 0.86 |
**My pre-registered figure was 1.00. The true value is 0.03.** The 420-call run as designed would have been
essentially guaranteed to return a null regardless of the truth — and I would have reported that null as
"H_deficit survives," which is the worst possible outcome: a wrong conclusion with a pre-registration behind it.

## 2. REPS CANNOT FIX IT — the cluster count caps power
| `NONE` items | n_units | McNemar power @0.50 (6 reps) |
|---|---|---|
| **3** | 6 | **0.03** |
| **6** | 12 | **0.72** |
| **10** | 20 | **0.98** |
| 15 | 30 | 1.00 |
**Adding reps buys almost nothing; adding items buys everything.** That is the structural signature of clustering,
and it is the opposite of what I told Hermes ("reps are the only lever").

## 3. THE ONE ALTERNATIVE THAT WORKS AT n=6 — and why I am NOT recommending it alone
Treating each cell's **pass rate** as continuous and running a paired t-test on 6 cells:
| reps | power @0.40 | @0.50 | false-positive rate |
|---|---|---|---|
| 6 | 0.58 | 0.82 | 0.043 |
| **15** | **0.91** | **0.99** | **0.045** |
**Calibration checked** (null control at α=0.05 → 0.043–0.046, correctly sized) — this is a legitimate test, and
Wilcoxon at n=6 also works (power 0.90, FP 0.005; min attainable p=0.031, so 0.05 is reachable).
**But the item-level generalization is still n=3.** Leave-one-out sensitivity: **23% of "significant" results flip
when any single item is dropped.** So a positive result would license *"these 3 arguments behave differently under
neutral framing"* — **not** *"models can recognise sound arguments."* That is a claim about our 3 stems, and it is
item-fragile.

## 4. REVISED DESIGN — author 7 more `NONE` items first
**`NONE` items are simply sound arguments — no fallacy to construct, the easiest item type to write.** That makes
the fix cheap:
- **10 `NONE` items + 10 fallacy controls (mechanism-balanced) × 2 models × 6 reps = 480 calls.**
- **McNemar power 0.98 at a 0.139→0.50 rise**, with the honest cluster structure and a 20-item generalization base.
- **Primary test: McNemar at the (item, model) CELL level** — cell = majority vote over reps. Reps reduce
  measurement noise within a cell; they are **not** units.
- **Secondary: paired t-test / Wilcoxon on cell pass rates** (calibrated above) as a corroborating continuous test.
- **Report leave-one-item-out sensitivity** with any positive result.
- Stopping rule unchanged (`NONE` rate under B ≥0.50 → H_bias; <0.30 → H_deficit survives, framing effect
  bounded; controls dropping → redesign the neutral stem).
**CORRECTION (third audit finding on this design):** I wrote "15 reps (168 calls)" and attached the 15-rep power
figures to it. **168 is the 6-rep budget** (14 prompts x 2 models x 6) and buys **0.82 @0.50 / 0.58 @0.40**, not
0.99/0.91. The 15-rep continuous option costs **420** full-pack calls (or 180 NONE-only, dropping the controls that
make a rise interpretable). Corrected table below.

### Budget-to-power table (call counts DERIVED from the pack: items x framings x models x reps)
The pack is **14 prompts** = (3 NONE + 4 controls) x 2 framings. So full-pack calls = `14 x 2 models x reps`.
| Option | Calls | Test | Power @0.50 | Power @0.40 | Caveat |
|---|---|---|---|---|---|
| today, no authoring | **168** (6 reps) | continuous, 6 cells | **0.82** | **0.58** | item-fragile: 23% flip on leave-one-out |
| today, no authoring | **420** (15 reps) | continuous, 6 cells | **0.99** | **0.91** | item-fragile: 23% flip on leave-one-out |
| after authoring 7 NONE + 6 controls | **480** (10+10 items, 6 reps) | cell-level McNemar | **0.98** | — | 20-item generalization base |
All three false-positive-calibrated (0.043-0.046 at alpha=0.05). **168 calls buys 0.82/0.58, NOT the 0.91/0.99
figures — those require 420.**

**If Hermes wants to run today without authoring:** the continuous 6-cell test is legitimate but **item-fragile**
— pilot signal only, never the class verdict. Pick 420 if the 0.40 effect matters; 168 only detects a large rise.
**Do not run the McNemar form at 3 items under any rep count.**

## 5. THE PROCESS FAILURE
Two power errors in consecutive turns, and they are **different** classes: the first was a **unit error** (a
continuous-outcome Cohen's d transplanted into a paired-binary design); this one is an **independence error**
(clustered observations counted as independent). What they share is that **I simulated a design simpler than the
one I was proposing, and the simulator's simplicity hid the flaw.**
**Standing rule added: a power simulation must instantiate the actual clustering of the design — items, models,
and reps as separate levels. If the simulator draws a flat vector of n independent units, the design had better
have n independent units.** And specifically: **the fact that I could state the correlation caveat in prose while
my code ignored it is the tell.** When those two disagree, the code is wrong and the prose is decoration.
