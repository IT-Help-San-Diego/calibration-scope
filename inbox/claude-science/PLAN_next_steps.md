# What needs to happen — derived from the sealed data, not from the backlog
_Claude Science, 2026-07-27. Every number below computed in the cell that wrote the sentence._

## 0. WHERE THE SCIENCE ACTUALLY STANDS
| Claim | Status | Evidence |
|---|---|---|
| Lean carrier collapses e2b's answer variance | **established** | McNemar p = 4.4 × 10⁻¹² (47 → 2) |
| The collapse is not produced by token count | **established** | direct neutral-vs-Lean contrast, p = 1.0 × 10⁻⁸ |
| Lean costs accuracy | **established** | paired t, −7.2 pts, p = 0.014 |
| Capability threshold (e2b sensitive, nemotron not) | **NOT supported** | interaction p = 0.088 |
| Length contributes *nothing* | **NOT established** | power 0.08 against a 50% length effect |
| It is the carrier's *meaning* rather than its vocabulary | **OPEN** | C2 never built |
| Variance collapse generalises beyond e2b | **untestable so far** | nemotron: 0/293 baseline-stochastic |

## 1. ONE THING IS READY AND WAITING ON A WORD — the site update
`index_draft.html` is corrected, every figure re-verified, **not pushed.** It replaces the sentence claiming a
length-matched control *"has not been run."* **This is the only public-facing item, and it strengthens the page.**
It carries three bounds in the copy itself: length excluded as *the* explanation but not as a contributor;
single-model with the reason stated; content separated from length but **not** meaning from vocabulary.

## 2. THE THRESHOLD QUESTION CANNOT BE FIXED BY A THIRD MODEL — I sized it
The intuition is "add a third model and the threshold resolves." **The arithmetic says no.**
Per-item difference-of-deltas: mean **−0.061**, sd **0.615**, n = 293.
**Items needed for 80% power on this effect: 785.** We have 293. A third model adds a third *pairwise* comparison,
each still at n = 293 — **it does not add power to any of them.**
**And more reps will not help either.** Decomposing the variance: rep noise contributes **0.167**, true
item-to-item heterogeneity **0.211** — **56% of the variance is real heterogeneity.** Even at *infinite* reps you
would still need **~439 items**. **Items are the lever; reps are not.**
**What a third model *does* buy** is a **trend across three capability levels**. If carrier sensitivity declines
monotonically, three points support a claim that no single pairwise contrast can — a weaker-per-point but more
informative design. **That is a legitimate reason to run one; "it will make p < 0.05" is not.**

## 3. THE CHEAPEST DECISIVE EXPERIMENT LEFT — C2, shuffled-Lean
**293 items × 6 reps = 1,758 calls, ≈3.5 h at the measured 7.1 s/trial.**
It reuses the *same* paired McNemar that just returned p = 1.0 × 10⁻⁸, so no new analysis machinery and no new
power question. **It is the only open mechanism question a single run can close:** neutral filler differs from Lean
in vocabulary *and* syntax *and* meaning simultaneously, so today's result separates **content from length** but
cannot separate **meaning from vocabulary.** Scrambling Lean's own tokens holds vocabulary and token count fixed
and varies only order and sense.

## 4. RECOMMENDED ORDER, AND WHY
1. **Push the site update** (needs one word; the science is done).
2. **C2 shuffled-Lean** — 3.5 h, closes the last mechanism question, reuses existing analysis.
3. **Bank expansion toward ~500–800 items** *if* the threshold question matters enough to justify it — this is the
   only route to it, and it is a large authoring job, not a run.
4. **Third model** — for the capability *trend*, not for pairwise power. Cheap if the bank already exists.
**Deliberately not on this list:** more reps of anything (§2), and re-running 978 (its answer is clean; the
weakness was in my power claim, not in the data).

## 5. WHAT I AM NOT CLAIMING
- The 785-item figure is a **normal-approximation sizing** on the observed effect and sd; a proper
  cluster-aware simulation would shift it, and the true effect may be larger or smaller than −0.061.
- **I caught myself mid-derivation here:** I wrote that observed sd was "~3× the rep-noise floor" when the computed
  ratio is **1.51×**. The conclusion survives (heterogeneity is 56% of variance) but the stated ratio was wrong,
  and it is recorded rather than quietly fixed.
- §3's 3.5 h estimate uses the 7.1 s/trial measured from the dead run 970, on e2b. A different model changes it.
