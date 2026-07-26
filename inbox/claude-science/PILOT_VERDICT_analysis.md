# Pilot verdict CONFIRMED — with three corrections to how it's being read
_Claude Science, 2026-07-26. Analysed first-hand from pilot_results.csv (1,536 rows, sha256 feda070d12746f07)._
_The STOP is right. Three claims around it are not._

## 0. The STOP reproduces exactly
Ran the pre-registered harness unmodified: **exit 1, STOP.** 64 items, 1,536 trials, 0 infra errors,
overall pass 99.15%, **96.9% of items at ceiling, 2 informative, median item rate 1.00**. Every mechanism at or
near 100%. Hermes's read of the verdict is correct and the pilot did exactly the job it was built for: it cost
1,536 trials to avoid 30,000 spent measuring nothing.

## 1. CORRECTION — "ICC = 0.000, excellent, items are independent, 500 real = 500 effective"
**Not supported. ICC is UNMEASURABLE here, not zero.**
ICC is a *ratio of variances*. In this data `MS_between = 0.000866 < MS_within = 0.001747`, so the ANOVA
estimate is **negative** and my harness clips it to 0. Variance of per-item pass rates is **0.0017** — because
62 of 64 items are exactly 1.0. **There is no variance to partition.**
Reading that clipped 0 as "items are independent" turns a degenerate estimate into a design guarantee, and it
would license `n_eff = 500` for the full bank — the single most consequential number in the build plan.
**Correct statement: family ICC is not estimable at this ceiling. Unknown, not zero. It must be re-measured on
a bank that actually varies, and until then no items-per-family cap is justified by data.**
*(This is my harness's clipping behaviour producing a misleading-looking output — the clip to [0,1] is standard
and correct for a variance ratio, but it should report `not estimable` when MS_between < MS_within. Filed.)*

## 2. CORRECTION — the run is 64 items, and the 4 extra are ALL TRAPS
My pre-run flag was right: 1,536 trials = 64 items, not the specced 60. Now resolved — the split is
**anchor 30 / chain 10 / trap 15 / negdepth 9**. The generator emitted **11** traps; the run has **15**.
So the mechanism comparison the pilot was designed to make ran at **10/15/9, not 10/11/9 — trap over-weighted
by 36%**. It changes nothing here (all three levers are at 100%, so no comparison was resolvable anyway), but
the provenance of 4 unplanned items should be established before anything is built on this run's composition.

## 3. CORRECTION — and this one I nearly got wrong myself
Digging past the STOP I found what looked like the pilot's positive result: **e2b degrades under Lean
(99.74% → 96.88%) while nemotron is perfect in both carriers — Fisher p = 0.0032.** That is the Carrier Color
immunity pattern, and I was one paragraph from reporting it as a replication.
**It does not survive clustering.** Fisher on 1,536 trial rows treats each trial as independent; they are not —
24 trials per item, 6 reps each. The **pre-registered paired item-level test** gives:
- discordant items: **3 lean-worse vs 1 baseline-worse → exact p = 0.625. Not significant.**
- cluster-robust bootstrap resampling **items** (10k reps): mean per-item Δ **+0.029, 95% CI [−0.003, +0.076]** —
  **includes zero**.
**The trial-level p = 0.003 is a clustering artifact.** Four discordant items cannot carry a claim.
The honest statement: *the direction is consistent with carrier sensitivity in the weaker model and immunity in
the stronger, but the pilot has too little variance to establish it.* Which is the same conclusion as the STOP,
reached from the other side — and worth stating explicitly, because "we found a significant carrier effect in
the pilot" is exactly the sentence that would have escaped into the record.

## 4. What the pilot DID establish (the salvage)
1. **Propositional difficulty levers do not move these models.** Trap, negation-density and multi-step chain all
   at 100% on a 2B model *and* a nano model. That is a genuine, publishable negative result about the
   *instrument*, not about the models.
2. **All 4 informative items are ANCHORS from the existing bank. The 34 purpose-built hard items contributed
   ZERO discordant pairs.** The new items are not merely as easy as the old ones — they are strictly less
   informative. Whatever makes an item bite, the three levers do not produce it.
3. **The one item class that still bites is the literary/sound-argument axis** (LIT-12 historically, and the
   anchors here). That is a real lead, not a consolation.

## 5. Recommendation — answer to Hermes's (a)/(b)
**(b), explore harder classes — but not by guessing, and not at 500 items.**
The pilot just demonstrated that authoring difficulty *a priori* fails: three principled mechanisms, all null.
Doing that again with defeasible reasoning or quantifier scope is the same bet with a different noun.
**Instead, run a difficulty PROBE: ~40 items, 4 candidate classes × 10, same 2 models, 2 carriers, N=3
(960 trials).** N=3 is right here because the question is only "does anything move off the ceiling" — a
crude filter, not a measurement. Candidate classes, ordered by the evidence we already have:
1. **Sound-argument controls / literary fallacy** — the only class that has ever bitten in this project.
2. **Defeasible / default reasoning** — non-monotonic, so pattern-matching a valid form does not transfer.
3. **Quantifier-scope ambiguity** — the classic place LLM logic degrades.
4. **Multi-hop with a distractor premise** — chains failed, but these chains had no irrelevant material.
**Gate:** any class where ≥30% of items land off the ceiling graduates to a powered run. If none do, the
finding is that *this model class cannot be separated by formal-logic items at all* — which is itself the
answer to "where is the immunity threshold," and a more interesting paper than the one we set out to write.

## 6. One thing NOT to conclude
"Propositional logic is solved by modern models" is **not** what this shows. The items were authored to be
*hard*, not to be *representative*, and 64 items on 2 models is not a survey. What it shows is narrower and
sturdier: **these levers, on these two models, do not produce measurable difficulty.**
