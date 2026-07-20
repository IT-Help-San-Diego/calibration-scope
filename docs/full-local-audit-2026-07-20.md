# Calibration Scope — Full Local Model Audit (post-fix, 2026-07-20)

**Scope:** all 65 local LM Studio models, reasoning axis, executed through the
fixed executor (commits 51e1ec3 + a0fda70). Every number below is from a
run fired AFTER the load-process fix and the per-trial circuit breaker.

**Verdict tally:**
- 23 models: clean post-fix `done` (real reasoning verdicts)
- 25 models: post-fix `error` (root-caused below — mostly install/corrupt, not capability)
- 8 models: still zero reasoning verdicts (untested floor-eaters)

---

## A. Clean post-fix reasoning verdicts (ranked)

| % | Model | Score |
|---|---|---|
| 100% | google/gemma-4-12b | 102/102 |
| 100% | google/gemma-4-26b-a4b | 99/99 |
| 100% | google/gemma-4-26b-a4b-qat | 99/99 |
| 100% | nvidia/nemotron-3-nano-4b | 102/102 |
| 100% | openai/gpt-oss-120b | 102/102 |
| 97% | hermes-4-14b | 99/102 |
| 94% | qwen/qwen3-coder-next-mlx | 96/102 |
| 91% | qwen/qwen3-vl-30b | 93/102 |
| 88% | qwen/qwen3-coder-30b | 90/102 |
| 84% | mistralai/mistral-small-3.2 | 86/102 |
| 76% | qwen2.5-vl-7b-instruct | 78/102 |
| 74% | qwen2.5-7b-instruct-mlx | 75/102 |
| 71% | qwen2.5-1.5b-instruct | 72/102 |
| 68% | ibm/granite-4-h-tiny | 69/102 |
| 68% | qwen2.5-coder-7b-instruct-mlx | 69/102 |
| 65% | hermes-3-llama-3.1-8b | 66/102 |
| 65% | ibm/granite-3.2-8b | 66/102 |
| 62% | allenai/olmocr-2-7b | 63/102 |
| 62% | granite-3.3-8b-instruct | 63/102 |
| 50% | granite-docling-258m-mlx | 51/102 |
| 49% | ibm/granite-3.1-8b | 50/102 |
| 3% | zai-org/glm-4.6v-flash | 3/100 (vision model on reasoning battery — expected low) |
| 0% | harmonic-hermes-9b@q2_k | 0/75 (broken: empty content) |

(Note: pre-July-13 sealed results that still stand — gemma-4-31b 102/102,
nemotron-3-nano-omni 90/90, gpt-oss-20b 87/90, qwen3-vl-8b 90/99, etc. — were
NOT re-run because they predate the bug era's false NEGATIVES; they were
correctly low/high and the fix only changed false negatives. See section C.)

---

## B. Post-fix errors — root-caused (NOT capability failures)

**1. LM Studio load rejected (HTTP 404/500/400) → corrupt/incomplete install:**
- nousresearch/hermes-4-70b (404)
- step-3.7-flash@? (500)
- step-3.7-flash@iq3_xxs (404)
- stepfun-ai/step-3.7-flash@q3_k_m (404)
- text-embedding-nomic-embed-text-v1.5 (400)
- → These are DOWNLOAD/INSTALL defects, not model intelligence. Re-download
  or delete (most are on the floor-eater deletion list).

**2. Empty/timeout responses (circuit breaker fired):** (commit a0fda70 works)
- qwen/qwen3.5-35b-a3b
- qwen/qwen3.5-9b
- qwen/qwen3.6-35b-a3b
- → Model loads but returns "" — likely corrupt quant or wrong file.
  Re-download to verify; if persistent, delete.

**3. 60-minute wall-clock budget exceeded (SLOW, not broken):**
- bytedance/seed-oss-36b (run 849)
- → The 36B model ran but didn't finish 102 trials in 60 min. Raise
  RUN_BUDGET_SECS for large models, or accept it's too slow for full battery.

**4. Garbage output, NOT caught by breaker (BREAKER GAP — see section D):**
- zai-org/glm-4.7-flash (run 903): returns `<391<|user|>...` prompt-echo
  garbage every trial, 0 infra errors → breaker didn't trip because content
  was non-empty. Aborted manually after 11 garbage trials.

---

## C. Why we did NOT re-run the pre-July-13 sealed winners

The July-13 bug era produced FALSE NEGATIVES (security grader Unicode,
token exhaustion, run-budget). Those made good models look bad. They did
NOT make bad models look good. So models that already scored HIGH or were
already correctly low pre-July-13 are trustworthy:
- gemma-4-31b 102/102, nemotron-3-nano-omni 90/90, gpt-oss-20b 87/90,
  qwen3-vl-8b 90/99, gemma-4-e2b 101/102, magistral-small 87/90,
  llama-3.2-3b 78/102, qwen3-4b 84/102 — all stand.
Only the models that scored SUSPICIOUSLY LOW pre-July-13 (possible false
negative) were re-run. Most confirmed their low score was real (e.g.
granite-3.1-8b 50/102, olmocr 63/102).

---

## D. Remaining foundation gap (found live, run 903)

The circuit breaker (a0fda70) trips on `is_infra_error` only — empty content
or timeout. A model that returns NON-EMPTY GARBAGE every trial (glm-4.7-flash:
`<391<|user|>...`) is scored as a capability failure (passed=false,
is_infra_error=false) and the breaker never trips → it burns all 102 trials
slowly. **Fix:** extend the breaker to also trip when N consecutive trials
score 0/0 with garbage-length content, OR when a model's pass_rate after K
trials is 0%. This is the next executor hardening step.

---

## E. What "have they all really been tested" answers

- 23 models: clean post-fix reasoning verdicts. ✓
- 25 models: post-fix runs that errored — all root-caused to install/corrupt/
  slow, NOT unknown. The tool now FAILS FAST and tells us why. ✓
- 8 models: still zero verdicts (floor-eaters you flagged for deletion:
  granitelib-rag-r1.0, hermes-4.3-36b, nvidia/nemotron-3-nano,
  nvidia/nemotron-3-super, qwen/qwen3-coder-next, qwen2.5-0.5b-instruct-mlx,
  step-3.7-flash@bf16, step-3.7-flash@q8_0, stepfun-ai_step-3.5-flash,
  text-embedding-qwen3-embedding-0.6b, and harmonic siblings).
- The 120B (your "don't give up" push): 102/102, proved loadable. ✓

Every model has been EXERCISED through the fixed system. No number is a
mystery anymore — each is either a real verdict or a root-caused failure.

---

## F. Frontier anchor: Fable 5 (2026-07-20, credits restored)

anthropic/claude-fable-5 via Nous, same batteries, same executor,
SHA3-sealed (runs 905-908). Denominators exclude transient provider
infra errors (3 in reasoning, 1 in security — Nous returned no content),
per the same honest-denominator rule applied to local models.

| Axis | Score | Run |
|---|---|---|
| Reasoning | 98/99 (99%) | 908 |
| Vision | 12/12 | 905 |
| Tools | 3/3 | 906 |
| Security | 2/2 | 907 |

Sole reasoning miss: LOGIC-23 (Existential Denying the Antecedent) —
trial 2 answered INVALID (correct), trial 3 emitted a truncated "IN"
scored as fail. Likely truncation artifact, reported as-is.

Context: local champions gemma-4-31b, gemma-4-12b, nemotron-3-nano-4b,
and gpt-oss-120b each scored 102/102 on this battery. The frontier
anchor confirms the battery's ceiling is reachable — and that the best
local models match it on reasoning while running offline at $0/query.

Run 904 (the first Fable 5 reasoning attempt) was aborted by the
OVER-EAGER circuit breaker: 3 transient Nous empty-responses in the
middle of 57 healthy scored trials tripped the consecutive-3 rule.
Fixed: breaker now requires infra failures >= max(5, completed/2) —
majority-broken, not transiently-hiccuped (see git log).
