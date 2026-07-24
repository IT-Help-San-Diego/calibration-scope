# Channel Contamination — Bridge-Model Experiment Spec (v1, publication-grade)
_Author: Claude Science, 2026-07-24. Execution: Hermes (pack generator + ingest + hooks). Design/stats: Claude Science._
_Purpose: measure whether MANUAL administration channels contaminate a model's benchmark score,_
_relative to the API-isolated baseline. This is the VALIDATION of Manual Subject Mode (§14) — distinct_
_from its APPLICATION (the Replit pilot, which cannot validate anything: it confounds no-API with channel)._

## 0. The claim we want to license
"Administering the same items through a manual channel (single chat) changes the measured score
vs. one-isolated-call-per-item (API), and the size of that change is X points." Publishable only
if the confound below is broken.

## 1. Why Replit CANNOT be the subject (the design flaw this spec exists to avoid)
Replit = no-API AND manual-channel, inseparably. With no isolated baseline for Replit itself, any
score difference could be the model, the channel, or the no-API path — unidentifiable. **The subject
MUST be a BRIDGE MODEL: reachable BOTH by API (one isolated call per item) AND pasteable into a
web/chat UI manually.** Then channel is the ONLY thing that varies within-subject.
Bridge candidates (Hermes): any local LM Studio model (Gemma-4-31B, Qwen3-VL-8B, ...) driven via
its OpenAI-compatible API for the baseline AND via its chat UI for manual; or an OpenRouter/Nous
model with both an API and a web UI.

## 2. Design (within-subject, paired on items)
**2.1 One bridge model, ONE item set, THREE channels:**
  - **A. API-isolated** — one HTTP call per item, fresh context each (the clean baseline; = the API lane).
  - **B. manual-chunked** — items pasted in batches (e.g. 8 per chat), several chats.
  - **C. manual-single-blob** — all items in ONE chat (max contamination: position decay + self-priming).
**2.2 Item set:** the 64-item full-text battery (sha3-512 2dfc8023...e9d76b8). Larger n = more power
(see §4); 42-item logic pack only if the battery is impractical.
**2.3 Pairing (MANDATORY):** the SAME items go through all three channels on the SAME model. Analysis
is paired on item_id. This is the power lever — do NOT run different items per channel.
**2.4 N and order:** N=3 administrations per channel, **item order RE-RANDOMIZED each administration**
(Hermes's --shuffle flag; log the seed per administration for provenance). Randomization breaks the
position/item-identity confound in channels B and C — without it, "lost in the middle" decay is
indistinguishable from some items just being harder.
**2.5 Grading:** identical grader across channels (exact-match vs expected_result — same as API lane
and human-cal). Manual replies go through the tolerant numbered-response parser; unmappable items are
handled per the informative-missingness rule (§3).

## 3. Informative-missingness handling (from the §14 review — MANDATORY, not optional)
Manual channels produce unmappable replies (format collapse). Dropping them from the logic denominator
biases the surviving sample toward easy/early items exactly when compliance drops — the logic and
format scores are COUPLED through the missingness mechanism. So per channel per administration:
  - report logic as **k / n_mappable**, ALWAYS with n_mappable shown (never a bare %).
  - report **best/worst bounds**: logic if all unmappable were correct vs all wrong. The channel gap
    (§4) is computed on the BOUNDS, not just the point estimate — if the API-vs-manual gap survives
    even the worst-case bound, it's robust; if it flips sign between bounds, it's not real.
  - compute the **mappability-vs-position correlation**; if significant, flag the run
    `mappability-position-correlated` and treat its logic point estimate as biased-high.
  - format compliance is TWO numbers: map-rate + drift-point (item index where mapping first fails).
    Scored separately; never collapsed; never contaminates logic and vice versa.

## 4. Analysis plan (locked before data)
Unit = item; three related channels on the same items.
  1. **Omnibus:** Cochran's Q across the 3 channels (paired, binary) — is there ANY channel effect?
  2. **Pairwise:** McNemar exact per channel-pair (A-B, A-C, B-C) + Holm-Bonferroni across the 3.
  3. Report each channel's pass rate as k/n_mappable + best/worst bounds; the headline gap (A vs C)
     is the interval between bounds, not a point.
  4. If N=3 administrations: aggregate item outcome by majority, OR model administration as a repeated
     factor (GEE binomial clustered on item) to use all trials — prefer the latter if map-rates are high.
  5. Report WORST-case channel behavior, not best (Genie-style scoring discipline).

**Power (McNemar, paired, simulation @ α=0.05, 80% — PLANNING estimates; true baseline & rho unknown):**
| Design | min detectable A-vs-C gap |
|---|---|
| 64-item battery, 1 admin | ~15-18 pts |
| 64 items x 3 admins       | ~9-11 pts |
| 42-item logic, 1 admin    | ~20-25 pts |
Only a GROSS contamination effect (single-blob costs ~20+ pts) is catchable in one 42-item pass.
For sub-15-pt resolution use the 64-item battery x 3 re-randomized administrations. rho >= 0.6
(same model, same items) works in our favor. Firm up once the pilot yields an actual baseline + rho.

## 5. Pre-registered hypotheses (write BEFORE running)
- **H1:** channel C (single-blob) scores LOWER than A (API-isolated) — position decay + self-priming
  drag. Directional; test A vs C.
- **H2:** channel B (chunked) lies between A and C.
- **H3 (ties to §10.15):** in channel C, item-level pass probability DECLINES with within-blob
  position ("lost in the middle") — testable via the logged per-administration order (that's what the
  re-randomization enables: position is decorrelated from item identity, so a position effect is real).
- **H4:** format compliance (map-rate) DECAYS with pack length / position — the manual analogue of the
  carrier crowding out reasoning headroom.
Any outcome is reportable; a null A-vs-C with adequate power is itself a finding (manual single-blob is safe).

## 6. Deliverables back to the repo
  - `channel_contamination_v1_results.csv` — trial-level: model, channel, admin, item_id, position_in_admin,
    seed, pass, mappable, tokens_* (API only), format_ok.
  - The analysis reuses/extends carrier_color_analysis.py (McNemar+Holm already validated); add the
    Cochran's Q omnibus + the bounds computation. I'll write that extension when the CSV lands.
  - DECISIONS.md §14-results update with the powered channel gap (bounds, not bare point).
  - EPISTEMIC_LOG.jsonl entry: action=rerun/verify, the CSV sha256, channel labels, seeds.

## 7. Executor one-liner (for Hermes to wire)
"Run <bridge_model> through the 64-item battery in 3 channels x 3 re-randomized administrations:
A=API one-call-per-item, B=manual 8-per-chat, C=manual single-blob. --shuffle per admin, log seeds.
Emit trial-level CSV with position_in_admin + mappable + format_ok. Grade with the standard exact-match
grader + tolerant parser. Do NOT compare channels bare — the analysis handles the bounds."
