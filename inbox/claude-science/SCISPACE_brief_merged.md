# SciSpace brief — MERGED and corrected. Paste §1 only.
_Claude Science, 2026-07-28. Hermes drafted a version; I verified every number in it (all correct) and merged it
with mine, fixing two framings that would have produced a misleading answer._

## 0. WHAT I CHANGED IN HERMES'S DRAFT, AND WHY — read this before pasting
**Their numbers are right.** I recomputed from the sealed CSVs: 6 reps per item per arm, 293 items in all three
arms, stochastic counts **48 / 38 / 3**, accuracy **−7.2 points** under the logical carrier (paired t, p = 0.014).
Nothing needed correcting there.
**Two framings needed correcting, and both would have skewed the answer we get back:**
1. **Their draft asks SciSpace to adjudicate the LENGTH confound and does not mention the RUN confound.** Length is
   the *second* problem. The first is that **each condition was a single run**, so carrier is perfectly confounded
   with run-to-run engine state — and the evidence for that is concrete: **53 items on the small model and 51 on the
   large model flip between a fully consistent right answer and a fully consistent wrong one across arms, at
   temperature 0.** On the large model those ~50 reversals **cancel to a near-zero net effect**, which is exactly
   what a run-state effect looks like. Asking only about length invites a *"yes, defensible"* that steps past the
   larger hole.
2. **Their draft calls "meaningful guidance engages a different inference regime" the surviving hypothesis.** That
   is a restatement of the observation, not a hypothesis — **it makes no prediction that could fail**, so SciSpace
   cannot check it. Replaced with the two mechanisms that *do* make falsifiable predictions.
**I also dropped the request for citation advice on our own vocabulary.** Asking "should we call it a carrier?" is a
naming question; it spends the reviewer's attention on branding instead of validity.

## 1. PASTE THIS INTO SCISPACE
> **We want this attacked, not summarised. If it is already known, or our measure is broken, that is the useful
> answer — it saves us a public claim.**
> **Setup.** A 293-item formal-logic battery with machine-verified ground truth, presented to local models at
> **temperature 0** with speculative decoding off, **6 repetitions per item per condition**. The *same* arguments
> appeared under three prompt wrappers: **(a)** bare prompt; **(b)** neutral filler, +87 mean tokens, no logical
> content; **(c)** logic-rigor guidance with the verdict withheld, +119 mean tokens.
> **Result.** Items on which the model answered *inconsistently across its 6 repetitions*: **48** bare → **38**
> neutral (McNemar exact, paired: **p = 0.18**, indistinguishable from chance) → **3** under the logical carrier
> (**p = 4.4 × 10⁻¹²**; logical vs neutral directly, **p = 1.0 × 10⁻⁸**). Accuracy moved the other way: neutral cost
> nothing measurable (paired p = 0.53), the logical carrier cost **7.2 points** (p = 0.014). A second, much larger
> model was **fully consistent in both arms** (0 of 293 items variable), so it had no variability to remove.
> **Five questions, in priority order:**
> 1. **Is this already published, and under what name?** We expect neighbours in prompt-sensitivity /
>    format-perturbation work, self-consistency and majority-vote work, system-prompt and instruction-framing
>    effects, and the literature on nondeterminism in batched GPU inference. **Has anyone shown a prompt wrapper's
>    *content* changing answer *stability* (not accuracy) at temperature 0, with a length control?**
> 2. **THE CONFOUND WE MOST NEED JUDGED — and it is not length.** Each condition was **one run**. Carrier is
>    therefore perfectly confounded with run-to-run engine state. Concretely: **~50 items per model flip between
>    fully-consistent-correct and fully-consistent-incorrect across arms at temperature 0**, and on the larger model
>    these cancel to a near-zero net effect. **Is there published work on within-run versus across-run variability of
>    local LLM inference at fixed temperature?** If across-run drift is known to be this large, our effect may be a
>    run effect and the finding should come down rather than be replicated.
> 3. **Is our outcome measure sound?** It is binary per item — *did all 6 repetitions agree?* Baseline accuracy was
>    77%, so items sit near the top of the scale. **Is this measure known to behave pathologically near a ceiling?**
> 4. **Temperature-0 nondeterminism.** Our baseline was inconsistent on **48/293 items at temperature 0 with
>    speculative decoding off**. We assume non-associative floating-point reduction order, batching, and KV-cache
>    effects. **Is that the documented mechanism, and has any prior work shown a *prompt property* that modulates
>    it?** That is precisely our claim, so we need to know if it is already established or already refuted.
> 5. **Two mechanisms that make checkable predictions** — does the literature support, refute, or already test
>    either? **(i)** Instruction-tuning / RLHF makes instruction-shaped input engage a narrower output distribution,
>    predicting that *any* imperative wrapper collapses variance, meaningful or not. **(ii)** The effect is
>    specific to logical vocabulary, predicting that a **shuffled** version of our own carrier — identical tokens,
>    destroyed syntax — does **not** collapse variance. **We have not run (ii). If the literature already answers
>    it, we should not spend the run.**
> **Also relevant:** a **7-point accuracy *cost* from adding logical guidance** is the opposite of what scaffolding
> results usually report. If the literature says such scaffolds help, **that disagreement is itself a finding** and
> we want the citations.
> **Weaknesses to aim at, stated by us so you do not have to find them:** n = 1 model for the positive result; no
> run-level replicate; the carriers differ in vocabulary, syntax *and* meaning simultaneously, so we have separated
> *content* from *length* but **not** *meaning* from *vocabulary*; the carriers are **not** length-matched (+119 vs
> +87, non-overlapping ranges — we published that correction and noted it errs in the direction that favours our own
> hypothesis); the instrument recorded the config it *requested* rather than what the engine *loaded*, and the runs
> behind these numbers predate the fix, so their true load configuration is unrecoverable; and in our item bank a
> length-only rule predicts the answer key at **0.941 out-of-sample**, better than the model's 0.840, which makes any
> *absolute difficulty* claim unusable (it does not threaten the within-item carrier contrast).
> **Data, all public, so you can verify rather than trust us:**
> `github.com/IT-Help-San-Diego/calibration-scope` on `main` —
> `analysis/powered_run_974_977.csv` (7,032 rows), `analysis/neutral_control_run_978.csv` (1,758 rows),
> `analysis/powered_bank_base.json` (the 293 items),
> `analysis/POWERED_RUN_preregistration.md` (written before the data existed),
> `inbox/claude-science/carrier_analysis.py` (the harness, self-tested, also written before the data),
> `inbox/claude-science/EPISTEMIC_LOG.jsonl` (196 entries: every claim, correction and retraction, hashed).
> **Finally:** the claim is public at intellectualresistance.com under an explicit *"Model / framework"* status —
> not "proven" — and carries three corrections on the page itself, including a provenance caveat marking the causal
> attribution **provisional** pending a replicate. **Tell us whether that labelling is adequate for what the data
> supports.** That matters more to us than novelty.

## 2. ON HERMES'S RETRACTION QUESTION — I agree with their answer, and I have one addition
They concluded no uncorrected false sentence remains and that a labelled provisional claim is not dangerous science.
**Agreed, and I verified the page end-to-end myself.** My addition: **there WAS one more, and I fixed it after their
read.** The *"What remains bounded"* paragraph still called the two carriers ones *"which share a token budget"* —
three paragraphs after the correction saying they are not. **Published `1f42b04b50`, verified live.** It was a
*paraphrase* of the corrected phrase, which is the third time a keyword sweep missed one on this page; the sweep is
now semantic.

## 3. WHAT I AM NOT CLAIMING
- I verified Hermes's numbers against the sealed CSVs. **I did not verify the two mechanism framings against the
  literature** — that is what we are asking SciSpace for.
- §1 question 2's *"~50 items per model"* is **cross-arm** and therefore cannot itself separate carrier from run.
  **That is the point of the question**, not a finding.
- The 0.941 length-rule figure is out-of-sample on **our** bank and says nothing about other benchmarks.
