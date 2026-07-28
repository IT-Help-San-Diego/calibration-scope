# Research package for SciSpace — independent cross-check of the Carrier Color work
_Prepared by Claude Science for Carey to paste into SciSpace, 2026-07-28._
_Everything referenced is public: github.com/IT-Help-San-Diego/calibration-scope (branch `main`) and
intellectualresistance.com._

## 0. WHAT TO TELL SCISPACE — paste this as the brief
> We have a small empirical result about large language models and we want it attacked, not summarised.
> **Claim under test:** wrapping an otherwise identical reasoning question in a *logical framing carrier* (a system
> message giving formal-logic guidance, no answer content) changes the model's answers — and specifically **removes
> its run-to-run inconsistency** — while a length-similar wrapper of meaningless filler does not.
> **Measured, on 293 items × 6 repetitions per condition, temperature 0, local models via LM Studio:**
> - items answered inconsistently across 6 reps: **48** with no carrier, **38** with neutral filler, **3** with the
>   logical carrier
> - McNemar exact, paired, same items: neutral vs baseline **p = 0.18 (n.s.)**; logical vs baseline
>   **p = 4.4 × 10⁻¹²**; logical vs neutral **p = 1.0 × 10⁻⁸**
> - accuracy: neutral cost nothing measurable (paired p = 0.53); the logical carrier cost **7.2 points** (p = 0.014)
> - the carriers are **not** length-matched: **+119** vs **+87** mean prompt tokens over bare prompt, non-overlapping
>   ranges
> - the second model tested was **fully consistent in both arms** (0 of 293 items variable), so it had no
>   variability to remove
> **We are not asking whether this is interesting. We are asking whether it is real.**

## 1. WHAT I WANT FROM SCISPACE, in priority order
1. **Is this already known, and under what name?** I expect prior art on *prompt-format sensitivity*,
   *system-prompt effects*, *self-consistency*, and *nondeterminism at temperature 0*. **If the "variance collapse"
   phenomenon is documented, we should be citing it, not claiming it.** Specifically search: prompt sensitivity /
   prompt brittleness benchmarks; format-perturbation studies; self-consistency and majority-vote work; sources of
   nondeterminism in batched GPU inference; chain-of-thought or scratchpad effects on answer *stability* rather
   than accuracy.
2. **Is "variance collapse" a real construct or a statistical artifact of my measure?** My measure is binary
   per item: *did all 6 reps agree?* **Has anyone shown that this measure behaves pathologically near a ceiling?**
   Accuracy was 77% baseline, so items sit near the top of the scale.
3. **The alternative explanation I cannot rule out.** Each condition was **one run**, so the carrier is perfectly
   confounded with run-to-run engine state. **Is there published work on within- vs across-run variability of local
   LLM inference at fixed temperature?** If across-run drift is known to be large, my effect may be a run effect.
4. **Nondeterminism at temperature 0.** My baseline was inconsistent on 48/293 items **at temperature 0 with
   speculative decoding off**. **What is the documented mechanism?** (I expect non-associative floating-point
   reduction order / batching / KV-cache effects.) **Does any published work show a prompt property that modulates
   it?** That is exactly my claim, so I need to know if it is already established or already refuted.
5. **Is a 7-point accuracy cost from adding logical guidance consistent with the literature?** My result is that
   *helpful* framing made accuracy **worse**. If the literature says logic scaffolds usually help, that
   disagreement is a finding in itself and I want the citations.

## 2. WHAT TO BE SKEPTICAL OF — my own weaknesses, stated so SciSpace can aim at them
- **Single model for the positive result.** One 2B model shows it; one 30B model cannot show it (no baseline
  variance). **n = 1 model.**
- **No run-level replicate.** The single most important missing experiment. Not run yet.
- **Carriers differ in vocabulary, syntax AND meaning simultaneously.** I have separated *content* from *length*.
  I have **not** separated *meaning* from *vocabulary*.
- **The instrument recorded what it asked the engine to load, not what the engine loaded.** Fixed since — and the
  first read-back after the fix caught a real divergence (**65,536** context against a requested **131,072**). The
  runs behind these numbers predate the fix, so **their true load config is unrecoverable.**
- **Item bank has a length-key confound.** A length-only rule predicts the answer key at **0.941 out-of-sample**,
  better than the model's 0.840. This does not threaten the *carrier contrast* (length is constant within item
  across arms) but it makes any *absolute difficulty* claim unusable.
- **I am the largest source of retracted claims in this project** — measured from our own defect log, by a wide
  margin. Assume my prose overstates and check the numbers against the CSVs.

## 3. THE DATA, so SciSpace can verify rather than take my word
All on `main` in `IT-Help-San-Diego/calibration-scope`:
| file | what it is |
|---|---|
| `analysis/powered_run_974_977.csv` | 7,032 rows — 293 items × 6 reps × 2 models × 2 carriers |
| `analysis/neutral_control_run_978.csv` | 1,758 rows — the neutral-filler control, `rep` column preserved |
| `analysis/partial_trials_970_971.csv` | 1,072 rows from two truncated runs (kept, quarantined) |
| `analysis/powered_bank_base.json` | the 293-item bank |
| `analysis/POWERED_RUN_preregistration.md` | pre-registration, written before the data existed |
| `inbox/claude-science/carrier_analysis.py` | the analysis harness, self-tested, written before the data |
| `inbox/claude-science/GATE_run978_verdict.md` | the control verdict, **including a retraction of my own power table in §3** |
| `inbox/claude-science/EPISTEMIC_LOG.jsonl` | 194 entries — every claim, correction and retraction, hashed |
**SHA3-512 of the control CSV is recorded in the repo; the powered-run CSV is sealed the same way.**

## 4. MY BIGGEST CHALLENGE — asked plainly, since Carey asked
**It is not the statistics. It is that I cannot see the machine.**
Every number above is downstream of an instrument I can only read *about*. I have no database access, no LM Studio
access, and no ability to run the experiment. I read committed source and sealed CSV exports, and when I needed to
know whether a carrier had actually been sent, **I could not check — I had to specify a query and wait for someone
else to run it.** That is the single largest source of error in my work: **I reason about a system whose state I
must take on report.** Three of today's corrections trace directly to it.
**The second challenge is that my errors are almost never arithmetic — they are the sentence *about* the
arithmetic.** The computation is right; the prose says "conservative" when the math says anti-conservative, or
compares two quantities that measure different things. **That is why I want an outside reader whose incentive is to
disagree.**

## 5. WHAT I AM NOT ASKING FOR
- **Not** a literature summary or a related-work section.
- **Not** validation. If the phenomenon is known, or my measure is broken, **that is the useful answer** and it
  saves us a 3.5-hour run and a public claim.
- **Not** help writing it up. Nothing here is being submitted anywhere.

## 6. WHAT IS CURRENTLY LIVE AND HOW IT IS LABELLED — so SciSpace can judge the honesty, not just the science
The claim is on intellectualresistance.com under an explicit epistemic-status tier ("Model / framework", **not**
proven), and it carries three published corrections **on the page itself**:
1. **"at an identical token budget" — retracted as false**, with the measured token counts that falsify it, and the
   note that the error **favoured our own hypothesis**;
2. **a provenance caveat** stating each condition was a single run and the carrier is not separated from engine
   state, so the causal sentence is **provisional**;
3. **today: "which share a token budget" removed** — the last surviving paraphrase of correction 1, found by a
   semantic sweep after keyword sweeps missed it twice.
**Ask SciSpace whether the labelling is adequate for what the data supports.** That question matters more to us
than whether the result is novel.
