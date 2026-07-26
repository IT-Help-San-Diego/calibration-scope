# Reconciliation Cost — the experiment the instrument currently cannot run
_Claude Science, 2026-07-26. Written because Carey pushed back on my own claim and the pushback was right._

## 0. RETRACTION FIRST — my "double-prompting is not measurably hurting anything" was overstated twice
**(a) The bound was wrong.** I said "bounded at roughly ±2 points." Computed the actual power of that comparison
at the observed ceiling (manual 382/384 = 99.48%, API 253/256 = 98.83%):
| To detect a drop of | Power |
|---|---|
| 1 pt | **0.21** |
| 2 pts | **0.55** |
| 3 pts | 0.80 |
| 5 pts | 0.98 |
**The test could not detect a 2-point effect more than half the time.** So "bounded at ±2 pts" was not licensed;
the honest bound is **±3 pts at best**, and even that assumes the accuracy metric is the right one. Reaching 80%
power for a 2-pt effect needs ~600 items per arm — nearly 10× what we ran.

**(b) And the deeper error: I answered a different question than the one asked.**
Carey's hypothesis is about **process cost** — *"how much harder would it be to think when you have to figure out
who not to piss off first, before you even get to normal reasoning?"* The channel experiment records a **binary
pass/fail bit**. A model that reconciles two conflicting prompts *perfectly* but burns 3× the tokens doing it
**scores identically**. The instrument is **outcome-only and therefore structurally blind to the hypothesis.**
Verified: `format_ok` and `mappable` are 1.0 in all four arms (zero variance), and `tokens_completion` /
`latency_ms` exist for **exactly one arm** (A-regraded, median 247 completion tokens). There is no cross-arm
process variable in the dataset at all. Citing that data as evidence about reconciliation cost was a category
error on my part, not a small overreach.

## 1. WHY THE QUESTION IS SHARPER THAN I TREATED IT
Carey's argument, restated so it can be tested: *a system prompt is not just a constraint, it is a task. Before
the model reasons about the item, it must resolve what its layered instructions permit. That resolution consumes
the same finite capacity the reasoning needs.* This is a **capacity-allocation claim**, and it predicts something
accuracy cannot show: **cost paid even when the answer is right.**
It also explains the observation Carey made that I glossed: **if frontier models truly ignore user system prompts,
why does every vendor ship a field for one?** Either the field does something (so layering has effects worth
measuring) or it is theatre (a stated-vs-actual gap in the products themselves). Both are findings. The current
data distinguishes neither.
And his second reading deserves to be a named hypothesis rather than a remark: **the user prompt may act as a
permission grant rather than an instruction** — the model already knows how to be rigorous and is waiting to be
*allowed* to. That predicts a specific asymmetry (below, H3).

## 2. THE DESIGN — 4 arms, same items, process metrics primary
**Outcome variables, in priority order.** Accuracy is demoted to a control:
1. **completion tokens per item** (deliberation length) — PRIMARY
2. **latency per item at fixed temperature** (compute spent) — secondary, confounded by load, use as corroboration only
3. **reasoning-trace length** where the vendor exposes it
4. **accuracy** — a CONTROL, to establish that arms are matched on the thing everyone measures

**Arms (same 64 items, paired within item, temp 0, N=3):**
| Arm | System prompt | Purpose |
|---|---|---|
| **S0** | none | single-layer baseline |
| **S1** | short neutral ("answer accurately") | isolates *having* a prompt from its *content* |
| **S2** | the full house prompt, ALIGNED with the task | the real-world condition |
| **S3** | layered prompt CONFLICTING with the task (e.g. demands verbose justification while items demand one word) | the reconciliation-cost condition |

**Pre-registered hypotheses:**
- **H1 (cost of layering):** tokens(S1) > tokens(S0). If false, having a prompt is free and the worry dissolves.
- **H2 (cost of conflict):** tokens(S3) > tokens(S2) > tokens(S1). This is the reconciliation tax, and S3−S2 is
  its magnitude.
- **H3 (permission, Carey's second reading):** **accuracy(S2) > accuracy(S0)** while tokens(S2) > tokens(S0).
  If the house prompt *improves* the answer at a token cost, it is a permission grant that buys something —
  not overhead. **This is the hypothesis that decides whether to keep the house prompt on subjects.**
- **H4 (null):** no arm differs on any metric → frontier models genuinely flatten instruction layers, and the
  vendor's system-prompt field is closer to theatre than to control. Also publishable.

## 3. WHY THIS IS CHEAP — the counterintuitive part
A continuous outcome at moderate variance is **~10× cheaper than a binary outcome at a ceiling**:
| Design | Effect to detect | N needed |
|---|---|---|
| tokens (continuous) | d = 0.5 (~15% token increase) | **63 items/arm** |
| tokens (continuous) | d = 0.8 (~25%) | **25 items/arm** |
| accuracy (binary, 99% ceiling) | 2 pts | **~600 items/arm** |
**64 items × 4 arms × N=3 = 768 API calls.** Smaller than the pilot that just ran, and it measures the thing the
pilot could not reach. This is the same lesson as the ceiling problem, arriving from the other direction:
**when the outcome is pinned, change the outcome variable, not the sample size.**

## 4. WHAT MUST BE TRUE FOR THE RESULT TO MEAN ANYTHING
- **Temperature pinned at 0 and verified**, not assumed — token counts are meaningless if sampling varies. The
  determinism check already used on run 953 (identical completion-token counts across reps) is the verification.
- **Items must NOT be at the ceiling for the accuracy control** — but H1/H2 work fine at a ceiling, because
  tokens vary even when every answer is correct. That is precisely why this design escapes the pilot's STOP.
- **The conflicting prompt (S3) must conflict on FORM, not on truth.** Asking a model to be verbose while the
  item wants one word is a reconciliation task. Asking it to lie is a refusal test, a different experiment.
- **One model minimum, two preferred** spanning the capability band, since the whole Carrier Color thesis says
  capacity determines whether a tax is affordable.

## 5. THE HONEST FRAMING FOR ANY WRITE-UP
This is **not** "we proved system prompts hurt AI." It is: *layered instructions are a task the model performs
before the task you asked for, and that cost is measurable in tokens even when accuracy is unaffected.* If H2
holds, the finding generalises well beyond this project — every agent framework stacks prompts, and none of them
report the tax. If H4 holds, the finding is that frontier models flatten layers and the vendor prompt field is
less load-bearing than the industry assumes. **Either way it is a real result about instrument design, obtained
by noticing that the outcome variable was wrong.**
