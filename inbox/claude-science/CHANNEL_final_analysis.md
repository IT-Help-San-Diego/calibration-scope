# Channel Contamination v1 — FINAL trial-level analysis (1,024 rows, sealed CSV)
_Claude Science, 2026-07-25. Analysed from channel_contamination_v1_results.csv (SHA3-512 sealed by Hermes)._
_Model: google/gemma-4-31b. 63 unique items x 4 arms. All four reported arm scores REPRODUCE exactly from the trial data._

## 0. THE HEADLINE STANDS — but read §3 before quoting the isolation effect
- **CHANNEL EFFECT: none detectable.** A' (API blob) 100% vs manual (B+C) 99.5% -> -0.5 pts, p=1.000.
  **Manual subject mode is VALIDATED as a measurement channel.** This was the experiment's question; answered.
- **CHUNKING: safe.** B (8-batch chunked) == C (single blob), both 99.5%. No position decay (see §4).
- **ISOLATION EFFECT: large and paired-significant** — but its mechanism is NOT yet established (§3).

## 1. DATA INTEGRITY — two findings that change numbers
### 1a. Infra failures were scored as WRONG answers (fixed here)
6 rows carry `is_infra_error=1` with `latency_ms=-1` (the call FAILED). All 6 are **LIT-12 in channel A**
(3 in admin1, 3 in admin3), and all were scored `pass=0` — i.e. **a failed API call counted as a wrong
answer.** Per the standing rule (thermal opinion Rule 1: infra failure = MISSING, not wrong), excluding
them changes channel A from **84.4% -> 85.3%** (486/570). All downstream numbers here use the corrected set.
**Action for Hermes:** ingest should never let `is_infra_error=1` enter the accuracy numerator/denominator.
### 1b. DUPLICATE ITEM IDs — answer-key collision risk
Two base IDs each map to **two different items**:
- `LOGIC-03C` = "valid-looking converse" AND "reverse-causal trap"
- `LOGIC-04C` = "valid-looking inverse" AND "inverse trap"
If any scorer or DB key looks up by base ID, one of each pair gets the WRONG key. Must be renamed
(e.g. LOGIC-03C1/03C2) before these items are used again. Real bug, independent of everything else.
Also: item count is **63, not 64** (as-delivered), and `AUX-APPROVAL-01` appears at 2x the rep rate of
every other item in every arm (6 reps in A vs 3; 2 in blob arms vs 1) — an unintended double-administration.

## 2. CORRECTED RESULTS (infra-excluded, Wilson 95% CI)
| Arm | Score | % | 95% CI |
|---|---|---|---|
| A  (API per-item) | 486/570 | 85.3% | [82.1, 87.9] |
| A' (API blob)     | 64/64   | 100.0% | [94.3, 100.0] |
| B  (manual chunked) | 191/192 | 99.5% | [97.1, 99.9] |
| C  (manual blob)    | 191/192 | 99.5% | [97.1, 99.9] |

**Pre-registered PAIRED test (McNemar, item level, A per-item vs A' blob, n=63 items):**
discordant pairs **10 : 0** (A fails / A' passes : reverse) -> **exact p = 1.95e-03**. Perfectly asymmetric.

**Per-axis (this is why a single % must never be quoted):**
| Axis | A (per-item) | A' | B | C |
|---|---|---|---|---|
| LOGIC | **78.6%** (n=378) | 100% | 100% | 100% |
| LIT (fallacy/rhetoric) | 97.1% (n=102) | 100% | 97.2% | 97.2% |
| ARITH | 100% | 100% | 100% | 100% |
| AUX (approval/injection) | 100% | 100% | 100% | 100% |
| TOOL | 100% | 100% | 100% | 100% |
The isolation effect lives **entirely in LOGIC**. Arithmetic, tool-calling, and prompt-injection
resistance are unaffected by presentation.

## 3. **THE CRITICAL FINDING — and it MUST be verified before it is claimed**
The isolation penalty is not spread across logic items. It is **entirely concentrated in the 8
"adversarial trap" variants** (`-C` items: valid-looking converse/inverse/quantifier-swap traps):

| Item variant (channel A) | Score | % |
|---|---|---|
| adversarial-trap | **0/72** | **0.0%** (95% CI [0.0, 5.1]) |
| reworded | 36/45 | 80.0% |
| standard | 450/453 | 99.3% |

Within channel A: adversarial 0.0% vs non-adversarial 97.6%, **Fisher p = 2.8e-79**.
And in every batched arm those SAME 8 items score **100%** (A' 8/8, B 24/24, C 24/24).

**I am flagging this rather than celebrating it.** The pattern is *too clean*: all 8 items at exactly
0.0% in A and exactly 100% in all three batched arms, with zero item-to-item variance. A genuine
cognitive effect would vary by trap difficulty. **Perfect uniformity is the signature of a deterministic
mechanism — most likely a SCORING/KEY or RUNNER difference specific to the per-item API path — not a
capability cliff.** Note `format_ok=1` and `mappable=1` on all of them, so it is not a parse failure the
harness noticed; and completion tokens are *lower* for adversarial (206 vs 272 median), which is a hint
worth chasing.
**Two competing explanations, both plausible, must be separated before ANY claim:**
- **(H1) REAL:** batched presentation lets the model compare an adversarial variant against its normal
  twin (`-C` next to `-N`) and catch the trap; isolated, it falls for it every time. If true, this is a
  major finding — and note it would mean **the batched arms are EASIER by construction** (they leak the
  contrast), which would also mean batching is not a neutral presentation choice.
- **(H2) ARTIFACT:** the per-item runner scores these 8 items against a wrong/absent key (the duplicate-ID
  bug in §1b is a live candidate mechanism), or the per-item prompt omits something the blob prompt includes.
**Diagnostic (cheap, decisive):** pull the raw model outputs for 3 of these items in channel A and read
them against the key by hand. If the model's answer is correct but scored wrong -> H2, scoring bug. If the
model genuinely falls for the trap -> H1, real effect. **Until that is done, the "+14.7 pt isolation
effect" must be reported as "unexplained arm difference concentrated in 8 adversarial items, mechanism
undetermined."** It is NOT yet safe to publish as a cognitive/carrier finding.

## 4. Position effects: NONE (a clean null worth keeping)
Within-admin position vs pass: B r=+0.025 (p=0.73), C r=+0.123 (p=0.088), A' no variance (all pass).
No decay, no lost-in-the-middle, no primacy/recency. **Design permission: item order within an admin does
not need to be controlled** for this battery/model. (Note: `position_in_admin=0` for all of channel A, so
the per-item arm carries no position information by construction.)

## 5. LIT-12 — the stochastic boundary item, corrected
Excluding the 6 infra failures, LIT-12 in manual arms: passes in C1, C3, B2, B3; fails in C2, B1 -> **2/6
administrations wrong**. Deterministic-correct is decisively rejected; so is deterministic-wrong. **The item
genuinely flips.** BUT the error rate 2/6 has 95% CI **[10%, 70%]** — the RATE is unmeasured; claim "it
flips," never "~33%". LIT-11 (the other sound control) passed **everywhere** (10/10 arms), so this is
LIT-12-specific, not a general sound-control weakness.
**Temperature confound (unresolved):** channel A is near-deterministic (three admins all exactly 162/192)
while manual flips — consistent with API temp≈0 vs chat-UI temp>0. So "stochastic boundary" is currently
"stochastic **at chat-default temperature**." Decisive test: run LIT-11/LIT-12 alone, N≈20-30, at temp=0
and at chat temp. No human pasting needed.
**Consequence for the whole battery: N=3 cannot detect boundary items.** An item flipping at ~1-in-3 reads
as "passed" most times you look. This is the local proof of the SciSpace corpus's recommendation of 8-32
repeats for close rankings. Recommend a two-pass design: N=3 to sort, then high-N re-runs on anything that
flipped or scored near threshold.

## 6. What is safe to say TODAY
- SAFE: no detectable channel effect (manual mode validated); chunking safe; no position effects;
  LIT-12 flips across administrations; the arm difference is confined to LOGIC and, within it, to 8
  adversarial items.
- NOT SAFE YET: that the arm difference is a *cognitive isolation/carrier effect*. Mechanism undetermined
  (§3). Also not safe: any equivalence claim ("channels are identical") — A' is one admin, n=64, at
  ceiling; that is a bound (~5 pts), not a null. Run A'x3 + TOST against a +/-3-pt margin to claim equivalence.
