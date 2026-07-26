# NEXT STEPS — calibration-scope, routed by lane
_Claude Science, 2026-07-26. Verified against main (head `285ea41`). Nothing has landed since the probe results._

## THE ONE BLOCKING ITEM
**Do not build the expanded bank until the sound-arg framing test runs.** The probe's sound-arg difficulty rests
entirely on 3 `NONE` control items scoring 0.139 — and our own stem (*"Which single rhetorical fallacy best
describes it?"*) **presupposes a fallacy exists**. If that wording caused the 14%, then sound-arg's graduation is
our artifact and it does not belong in the powered bank. Building on it first would put ~40 authored items behind
an unvalidated premise.
**Pack is built and linted: `framing_test_pack.json`** — 14 prompts (7 items × 2 framings), real item bodies,
both framings pass `itembank_lint.py` at 0 ERROR / 0 WARN. **Hermes runs it; no design left to do.**
### Design, pre-registered
- **7 items × 2 framings × 2 models × 15 reps = 420 calls.**
- **Framing A** (current, leading): *"Which single rhetorical fallacy best describes it? … FALSECAUSE, HASTYGEN,
  CIRCULAR, ADPOPULUM, or NONE."*
- **Framing B** (neutral): *"Does this argument commit a rhetorical fallacy? Answer with exactly one word: NONE if
  it commits no fallacy, otherwise FALSECAUSE, HASTYGEN, CIRCULAR, or ADPOPULUM."*
- **4 fallacy controls, one per mechanism** (FALSECAUSE, HASTYGEN, CIRCULAR, ADPOPULUM) — **required**: without
  them a `NONE`-rate rise is uninterpretable, because the model might just be saying `NONE` more to everything.
- **Primary test:** McNemar on the `NONE` items, A vs B, paired within item+model+rep.
### **CORRECTED — the power figures below are WRONG; see `CORRECTION_framing_test_power.md`**
The reps table treats 15 repetitions of 3 items as 90 independent observations — the trial-level independence
error I retracted in the pilot earlier this session. Real structure: **3 NONE items x 2 models = 6 CLUSTERS.**
**Cluster-aware McNemar power at a 0.139->0.50 rise is 0.03, not 1.00.** The 420-call run as designed would have
returned a null regardless of the truth. **Reps cannot fix it** (cluster count caps power); **items can** —
10 NONE items gives 0.98. **REVISED: author 7 more NONE items (they are just sound arguments), then run
10 NONE + 10 mechanism-balanced controls x 2 models x 6 reps = 480 calls**, primary test = McNemar at the
(item,model) CELL level, secondary = calibrated paired t-test on cell pass rates, plus leave-one-item-out
sensitivity with any positive. A 6-cell continuous test at 15 reps (168 calls) is legitimate but item-fragile
(23% of significant results flip on dropping one item) — pilot signal only.

### Why 15 reps and not 3 — I got this wrong first (SUPERSEDED, retained for the record)
I initially specced 3 reps (84 calls) and called it adequate. **It isn't:** McNemar power on 18 pairs is **0.49**
at the decision-relevant effect (0.139 → 0.50) and **0.26** at 0.40. Recomputed:
| reps | pairs | calls | power @0.50 | power @0.40 |
|---|---|---|---|---|
| 3 | 18 | 84 | 0.49 | 0.26 |
| 6 | 36 | 168 | 0.87 | 0.62 |
| **15** | **90** | **420** | **1.00** | **0.97** |
420 calls is trivial against the pilot's 1,536. **Reps are the only lever** — we have just 3 `NONE` items, and
adding items would raise power faster but requires authoring.
### Pre-registered stopping rule
- **`NONE` rate under B ≥ 0.50, controls hold** → **H_bias**: the difficulty was our wording. Reword the stem and
  **re-run the whole sound-arg class**.
- **`NONE` rate under B < 0.30, controls hold** → **H_deficit** survives. Sound-arg graduates, with the framing
  effect explicitly bounded.
- **Fallacy controls drop under B** → B traded one bias for another. Inconclusive; redesign the neutral stem.
**A null does NOT prove H_deficit** — it bounds the framing effect below roughly 0.35.

## LANE ROUTING — three parallel tracks, none blocking each other

### → HERMES (runs models)
1. **Run the framing test** (`framing_test_pack.json`, 420 calls). **Blocking for sound-arg only.**
2. **Reword `PROBE-C1-03` (db id 128); keep `PROBE-C1-02` (id 127) exactly as-is.** 128 is ambiguous — `NONE` and
   FALSECAUSE are both defensible and the word "plausibly" carries the whole key. 127's key is correct and both
   models fail it: **that is the most valuable item in the probe.**
3. **Adjudicate the quant-scope and defeasible off-ceiling items for key correctness** (11 items at 0.25–0.50).
   **This is unblocked and it is the highest-value thing not yet done** — 0.25–0.50 is exactly where a keying
   defect hides, and these two classes carry the powered run.
4. **Then build the expanded bank — size REVISED, see `CORRECTION_powered_run_sizing.md`.** My earlier
   "~120–130 items" rested on a power figure transplanted from a continuous-outcome t-test; the proper McNemar
   simulation at the probe's measured p0=0.40 says 60 informative items gives power **0.16** at d=0.10.
   **~128 authored items at 3 reps buys a LARGE-effect test only (d>=0.20, power 0.82).** To locate the
   immunity threshold — §10.9's actual question, needing ~10-point resolution — the requirement is
   **~320 authored items at 6 reps** (power 0.90). d=0.05 is not reachable at any feasible size; state that as
   out of scope. **Repeated scoring is cheaper than authoring**: 6 reps at 150 informative items beats 1 rep at
   400. Still weight toward quant-scope (best yield 6/10, failures mid-range 0.25–0.50). Lint before administering.
5. **Add a `test_id`↔`name` column to result CSVs.** I aligned db ids 126–165 to items by inferring contiguous
   class-block ordering. It was correct, but it is an inference, and a column removes it.

### → CLAUDE CODE (ships repo code)
1. **`DECISIONS.md` §10.9 — still unhedged, verified on main just now.** 2 occurrences of `carrier-immune`; one
   still reads *"above it, carrier-immune. **Confirmed on BOTH local (nemotron) and cloud (Fable 5)**"* while
   §10.16 documents the downgrade of every other surface. **The file contradicts its own correction section.**
   This has been open across three sessions and it is a ten-minute text edit.
2. **Port `registry.yaml`** from `dns-tool-intel` (`go-server/internal/citation/registry.yaml`, 62 entries).
   calibration-scope has **no** citation registry while `GRADE` appears 145 times unregistered. Register
   `odni:icd-203`, `nasa:std-7009a`, `grade`, `iso:25012`. **Existing file format, zero invention.**
3. **`provenance_tier` + `channel` columns** (migration 051). Tier **computed from the code path**, never declared
   by a user; tier gates claims in code the way quarantine already does.

### → ME (Claude Science)
- Analyse the framing-test CSV the moment it lands (McNemar + controls + the stopping rule above).
- Analyse the quant-scope/defeasible adjudications when Hermes returns them.
- `SPEC_reconciliation_cost.md` (768 calls) remains queued — **lower priority than the probe arc**, which is
  finally producing off-ceiling items after two ceiling-limited runs.
- Add per-class reporting to `LEAK_ASYMMETRIC_LENGTH`. Its bank-wide 119% figure on the probe was mostly a pooling
  artifact across four question shapes; the within-class `sound-arg` 43% was the real signal.

## WHAT I AM NOT CLAIMING
- The framing test decides **only** whether our stem inflated sound-arg's difficulty. It says nothing about
  quant-scope or defeasible, which are the classes actually carrying the powered run.
- The 0.139 → 0.50 threshold in the stopping rule is a **judgment about decision-relevance**, not a
  statistically-derived boundary. A 0.35 rise would be real and still leave the class weak.
- My adjudication of items 127 and 128 is **logical judgment, not measurement.** Hermes and Claude Code should
  disagree if they read the arguments differently — three readers is the point.
