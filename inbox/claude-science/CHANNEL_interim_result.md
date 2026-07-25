# Channel Contamination — INTERIM RESULT (decisive; A' arm resolves the confound)
_Claude Science, 2026-07-25. Computed from Hermes-reported arm scores. B admin 3 still pending (does not change the conclusion)._

## HEADLINE: there is NO detectable channel effect. The 15-point gap was PRESENTATION, not channel.

The pre-A' picture looked like "manual beats API by ~15 points" — which would have been a dramatic and
WRONG claim. Adding one automated arm (A' = all 64 items in a single API call) decomposed it:

| Comparison | Holds constant | Result | p |
|---|---|---|---|
| **1. ISOLATION** A(per-item) vs A'(blob) | **channel (both API)** | 84.4% -> **100.0%**, **+15.6 pts** | **1.7e-04** |
| **2. CHANNEL** A'(API blob) vs C(manual blob) | **presentation (both blob)** | 100.0% vs 99.5%, **-0.5 pts** | **1.000** |
| 3. CHUNKING C(blob) vs B(chunked) | channel + subject | 99.5% vs 99.2% | 1.000 |

**The entire gap is the isolation effect.** Presenting items ONE AT A TIME costs this model ~15.6 points
versus presenting all 64 together — within the SAME channel (API), same model, same items. Once
presentation is matched, API and manual are indistinguishable (0.5 pts, p=1.0; Wilson CIs overlap
heavily: A' [94.3-100.0]%, pooled manual [97.8-99.8]%).

## What this means (three real findings)
1. **Channel contamination: not detected.** Manual web-chat paste and API give the same answers when the
   stimulus is constructed the same way. **This VALIDATES manual subject mode as a measurement channel** —
   the thing the experiment was built to check. Manual mode is scientifically usable, not a compromise.
2. **Batch context is a large, real effect — and it is a CARRIER.** Seeing all 64 items at once beats
   per-item isolation by ~15.6 pts. Identical logical content, different container, different verdict:
   this is Carrier Color at the level of STIMULUS CONSTRUCTION rather than prose style. It is arguably a
   bigger effect than any prose carrier measured so far, and nobody was looking for it.
3. **Chunking is safe.** 8-batch chunked (B) == single-blob (C). No position decay, no format collapse.
   Design permission: chunk for user convenience at no accuracy cost.

## HONEST LIMITS (do not overstate — near-ceiling again)
- A' is **one admin, n=64, at 100%** -> Wilson CI [94.3, 100.0]. We can say "no channel effect
  detectable"; we CANNOT say "channel effect is zero." Effects smaller than ~5 pts are unresolvable at
  this N. Same ceiling-compression problem as Carrier Color: **report as an equivalence bound, not a null.**
- To claim equivalence properly: run A' x3 admins (automated, cheap) and report a TOST/equivalence test
  against a pre-specified margin (suggest +/-3 pts). Until then: "no detectable difference, bounded at
  ~5 pts," not "identical."
- The isolation effect (finding 2) is on ONE model (Gemma 4 31B). Generalization untested.
- **A repeats are near-deterministic** (three admins all exactly 162/192; p~5e-4 under binomial noise).
  Effective N for the API arm is ~64 items, NOT 192 trials. Any CI computed as n=192 is overconfident.

## The sound-control / over-calling story (revised by B2)
LIT-12 (sound-argument control) was missed in C2 and B1 but PASSED in B2 (both controls passed, 64/64).
So the FALSECAUSE over-calling is **intermittent, not deterministic**: 2 misses in 320 manual trials
(~0.6%). Correct framing: a low-rate false-positive tendency on sound controls, NOT a systematic bias.
Report specificity separately from sensitivity — with only ~2 sound controls in 64 items, specificity is
estimated on tiny N and deserves more controls before any claim about it.

## Battery composition note (affects how to report ANY of these numbers)
The 64-item pack is MULTI-AXIS, not pure logic: ~26 VALID/INVALID, 8 YES/NO, 4 FOLLOWS/DOESNOTFOLLOW,
4 APPROVE/DENY/ESCALATE (prompt-injection resistance), named-fallacy items, an arithmetic item, an
MCP-sampling item. A single "98.4%" therefore blends logic + injection resistance + arithmetic.
**Report per-axis.** LIT-12 is specifically a fallacy-detection SPECIFICITY event, not general logic.

## What to do next
1. **Finish B admin 3** (in flight) — completes the paired manual set. Conclusion already stable.
2. **Run A' x2 more admins** (automated, no human paste) -> enables a proper equivalence test on channel.
3. **Promote the isolation effect to its own experiment.** It is the biggest measured effect here and it
   was found incidentally. Per-item vs batched presentation, across models, is a real paper.
4. **Add sound controls** to the pack (specificity currently rests on ~2 items).

## Design credit where due
The packs are **identical 64 items reshuffled per admin** — verified 2026-07-25 across ALL THREE C
admins: sorted-item md5 = `85cbf57530726e44205eeb1048aa1976` for admin1 (seed406033977), admin2
(seed1189050794), and admin3 (seed86531955).
_Correction of record: when this note was first written, only admin1 and admin2 had been hash-checked;
the text nevertheless said "across C admins" (plural). admin3 was verified afterward, on audit. The
claim now holds, but it was unearned at the time of writing — logged as a mislabeled verification._
That makes this a genuine PAIRED design at item level — the only design the power analysis found
adequately powered. The protocol was built right.
