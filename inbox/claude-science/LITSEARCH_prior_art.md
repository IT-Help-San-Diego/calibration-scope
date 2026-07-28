# Prior-art search, run in-house — SciSpace is not needed for the question that gated the run
_Claude Science, 2026-07-28. arXiv API, four query families. I have scholarly database access; this cost nothing._

## 0. WHY I DID THIS INSTEAD OF WAITING
Carey has to pay for SciSpace, so we are moving without it. **The question I said should gate the replicate run was
whether temperature-0 across-run drift is already documented.** I can answer that from arXiv directly. **Three of
the five questions in the brief are now answered; the one that gates the run is not, and that is itself the
decision.**

## 1. ANSWERED — the mechanism is established prior art. We should be citing it, not discovering it.
| paper | what it establishes |
|---|---|
| **2506.09501** (2025) *Understanding and Mitigating Numerical Sources of Nondeterminism in LLM Inference* | Under **greedy decoding**, changing batch size, GPU count or GPU version changes outputs — **up to 9% accuracy variation** and 9,000-token length differences on a reasoning model. Traces it to numerical sources. |
| **2601.19934** (2026) *Quantifying non-deterministic drift in large language models* | Repeated-run experiments measuring "baseline behavioural drift" — **identical prompts, temperature 0.0**, operator-free conditions. |
| **2604.22411** (2026) *Introducing Background Temperature…* | Formalises the effect as **background temperature** $T_{bg}$: the effective temperature induced by the inference environment at nominal $T=0$. Names batch-size variation, kernel non-invariance, floating-point non-associativity. |
| **2601.06118** (2026) *Beyond Reproducibility: Token Probabilities Expose LLM Nondeterminism* | Same phenomenon examined at the token-probability level; attributes it to finite-precision arithmetic ordering under GPU concurrency. |
**Consequence:** our page's framing of temperature-0 inconsistency as something we noticed is wrong in emphasis.
**It is a named, formalised, actively-published phenomenon.** Any writeup must cite this literature.

## 2. ANSWERED, AND IT COSTS US A CLAIM — the accuracy half is not novel
- **2310.11324** (2023): **meaning-preserving** prompt-formatting changes move accuracy by **up to 76 points**.
- **2404.11500** (2024): surface form alters the **answer distribution** on mathematical reasoning.
- **2603.13351** (2026) *Prompt Complexity Dilutes Structured Reasoning*: a structured-reasoning prompt scores
  **100% alone but 0–30% inside a 60-line production prompt** — **adding prompt material degraded accuracy.**
**Our −7.2-point accuracy cost runs in the SAME direction as 2603.13351.** I had listed "a 7-point cost is the
opposite of what scaffolding results report" as a candidate finding. **It is not a finding. At least one 2026 result
reports exactly this.** That question is withdrawn.
**So the claim "a prompt wrapper changes model answers" is prior art from 2023 and we must not present it as ours.**

## 3. NOT ANSWERED — and this is the decision
**No hit reports the across-run drift MAGNITUDE for a fixed local model on a fixed item bank.** 2506.09501 varies
*hardware and batch size deliberately*; 2601.19934 measures drift on two hosted models across five prompt
categories. **Neither gives me the number I need: how many items out of a fixed 293 flip decisively between two runs
of the same model on the same machine with nothing changed.**
**That number is exactly what the replicate run measures.** So the literature does not obviate the run — **it
sharpens what the run is for.** It is no longer "confirm our effect"; it is **"measure this instrument's background
temperature, in items, so the carrier effect can be read against it."**
**Also unanswered:** whether a wrapper's *content* modulates that variability, with a length control, on a fixed
bank. **I found no hit.** That is the narrow claim, and it survives the search.

## 4. WHAT THIS DOES TO THE PUBLIC CLAIM — narrower, and better sourced
**Do not claim:** that prompt wrappers change model answers; that temperature-0 nondeterminism is a discovery; that
an accuracy cost from added guidance is surprising.
**Can claim, pending the replicate:** *a wrapper's logical content removes run-to-run answer instability where
length-similar filler does not* — with the standing caveats that it is one model, one bank, and not yet separated
from run-state.
**And the framing improves:** what we have been calling "variance collapse" is, in the literature's vocabulary, **a
prompt property that appears to suppress background temperature.** That is a sharper and more checkable statement
than ours, and it borrows established terminology instead of inventing it.

## 5. WHAT I AM NOT CLAIMING
- **This is an arXiv-only search across four query families.** It is not a systematic review, it does not cover
  ACL/EMNLP proceedings not mirrored on arXiv, and **absence of a hit is weak evidence of absence.** A paid
  literature service would search more broadly, and if one becomes available this is the question to spend it on.
- **I read abstracts, not full texts.** 2601.19934's drift magnitudes may be directly comparable to my reversal
  counts; I have not checked whether its measure (unique-output fraction, lexical similarity) can be converted to
  mine (items where 6 reps disagree). **If it can, that is a cheaper answer than the replicate and should be
  checked first.**
- I did **not** verify these papers' claims — only that they exist and what they assert.
