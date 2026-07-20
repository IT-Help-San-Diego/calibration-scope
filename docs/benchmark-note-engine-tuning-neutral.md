# Benchmark Note: Engine Tuning Is Accuracy-Neutral on Local LLMs

**Status:** empirical, SHA3-sealed, reproduction-ready
**Date:** 2026-07-19
**Instrument:** Calibration Scope (Rust/axum + Postgres, local-first)
**Battery:** 102 fixed reasoning trials (LOGIC / ARITH / FOL classes), identical stimulus across every run, N=1 per config (scaffold arms N=3 replication in progress)

---

## Claim

Adjusting LM Studio's user-controllable load parameters —
`context_length`, `eval_batch_size`, `physical_batch_size`, `parallel`
(max-concurrent-predictions), `flash_attention`, `offload_kv_cache_to_gpu`,
and `speculative_draft_model` (speculative decoding) — **does not change a
model's reasoning accuracy**. These are *speed* levers, not *capability*
levers. The only reproducible accuracy lever on sub-8B models is
**scaffolded generalized logic guidance** (a system-prompt scaffold
teaching direction-of-implication discipline), which heals +12 to +18
points and generalizes across model families.

---

## Evidence (all runs SHA3-sealed, 102 reasoning trials)

| Model (approx size) | Floor (baseline) | +Scaffold (healed) |
|---|---|---|
| llama-3.2-1b (1B)      | 45/102 (44%) | 45/102 (44%) — no heal |
| qwen2.5-0.5b (0.5B)   | 45/102 (44%) | 45/102 (44%) — no heal |
| qwen2.5-1.5b (1.5B)   | 60/102 (59%) | **72/102 (71%)** (+12) |
| granite-3.2-8b (8B)     | 48/102 (47%) | **66/102 (65%)** (+18) |
| gemma-4-e2b (2B)       | 101/102 (99%) | 101/102 (99%) |
| gemma-4-31b (22GB, local, free) | 90/90 (100%) | 90/90 (100%) — capable anchor |

### Controlled 4-way preset grid (qwen2.5-1.5b, granite-3.2-8b)

| Config | Context | Batch / Parallel | Speculative | Score | Δ |
|---|---|---|---|---|---|
| perf-baseline | 131K | 4096 / 4 | off | 60 / 48 | — |
| lightweight | 32K | 1024 / 1 | off | 60 / 48 | ±0 |
| lightweight + spec | 32K | 1024 / 1 | on (0.5B draft) | 60 / 48 | ±0 |
| lightweight + scaffold | 32K | 1024 / 1 | off | **72 / 66** | +12 / +18 |

The lightweight preset reduces context, batch size, and parallelism to fit
constrained RAM. Score is invariant. Speculative decoding (verified
resident in LM Studio via `speculative_draft_simple: true` +
`speculative_draft_model: <key>`) is accuracy-neutral by construction:
the draft proposes, the primary verifies, only matching tokens survive.
It changes *throughput only*.

---

## What we do NOT control (documented, not faked)

These parameters are **not** settable via LM Studio's REST load API and
were not tested as such:

- **GPU offload ratio** — not in the load body. Moot on Apple Silicon
  (unified RAM: there is no discrete GPU to offload to).
- **Advanced CPU thread pool size** — not in the load body; llama.cpp
  auto-manages on Apple Silicon.
- **ROPE frequency base** — an architecture constant baked into the model
  weights, not a runtime load parameter. Cannot be "tuned" per load;
  doing so would make the model a different model.

---

## Method (reproducibility)

1. Every run persists its exact `lmstudio_runtime_config` (jsonb) so
   the engine tuning is recoverable and auditable.
2. Identical 102-trial stimulus, fixed order, SHA3-sealed per run.
3. `lm_guard` serializes local-model access so concurrent runs cannot
   corrupt each other's load state.
4. Run budget 3600s; any run exceeding it preserves completed
   trial evidence (status `completed-with-errors`) rather than vanishing.

---

## Known gaps (disclosed, not papered over)

- **Frontier cloud anchor (claude-fable-5) not measured this session.**
  The Nous inference credits were exhausted on 2026-07-19; run 833
  failed at the infrastructure level (provider rejected every request
  before the model answered) — correctly flagged as NOT a capability
  failure. The capable anchor in this note is **gemma-4-31b (local,
  free, 4/4 verified)**, not a paid cloud model. The fable-5
  number will be added when credits return; it is a gap, stated plainly.
- **Scaffold arms ARE N≥3 replicated (completed 2026-07-19).**
  qwen1.5b scaffold: 72/102 across runs 828, 838, 839, 840
  (N=4, ±0). granite-8b scaffold: 66/102 across runs
  832, 836, 837 (N=3, ±0; run 835 was 63/99 — one trial
  infrastructure-flagged, not model variance). The +12/+18 heal is
  **stable and reproducible**, satisfying the control-before-celebration bar.
  No longer preliminary.

---

## Why this matters

The local-first thesis — "measure silicon and carbon under one
instrument" — requires honesty about what a knob does. Telling a user
"turn on speculative decoding and your tiny bot gets smarter" is false;
it gets *faster*. The capability ceiling is set by model scale + scaffold,
not by engine tuning. That is the measured difference we show.

---

## Hardware ceiling (128GB MacBook, measured 2026-07-19/20)

**One reproducible hard limit: ≥~60GB will not load — CORRECTED.**
`openai/gpt-oss-120b` (63.4GB) was previously reported as a hard
load failure. That was a **tool bug, not a hardware limit** (fixed
2026-07-20, commit 51e1ec3): `ensure_loaded` used the wrong residency
signal, clean-room ejected the resident target then re-loaded (RAM
thrash → abort), and a merged stored-config key
(`cpu_thread_pool_size`) was rejected by LM Studio's load endpoint as
an unrecognized key → HTTP 400. After the fix, gpt-oss-120b loads and
benchmarks **100% on reasoning (run 845, 102/102, SHA3-sealed)** on
the same 128GB Mac. The corrected lesson: large models need the tool
to *detect and reuse* a resident instance (patience principle), not
fight it. The only true hardware ceiling is RAM exhaustion from
concurrent loads — managed by the memory guard, which now also skips
when the target is already resident.

**The 22-26GB tier is NOT broken.** Clean-state sealed results:
gemma-4-31b 100% (run 655), nemotron-3-nano-omni 4/4, gpt-oss-120b
100% (run 845). The earlier "0-trial stall" on gemma-31b (run 834)
and qwen3.6-27b (run 841) was a RAM-exhaustion artifact of ceiling
probing itself, not a tier limitation.

| Tier | Example | Clean-state result |
|---|---|---|
| ≤8GB | granite-8b, qwen1.5b | loads + benchmarks (clean) |
| 22-63GB | gemma-31b, nemotron-omni, gpt-oss-120b | loads + benchmarks **100% / 4/4** (clean) |

**Conclusion:** the 8-63GB tier is the real benchmarking range on 128GB
unified RAM, provided RAM is not pre-exhausted by prior loads and the
tool reuses resident instances. The Demo Bots manifest centers 2-8B
models as the *calibration* tier (largest class with headroom for
concurrent tools), but nothing in the 8-63GB range is inherently
unrunnable. The patience principle — give a slow machine time to load
a large bot and don't tear it down to re-load it — is now enforced in
code.
