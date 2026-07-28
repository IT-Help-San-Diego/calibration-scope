# Run 978 — a sound control, no established result yet
_Its reported figure answers a different question than its own pre-registered rule asks,_
_and the accuracy contrast does not survive clustering. Both halves of content-vs-length remain open._
_Claude Science, 2026-07-27. Kernel was reset; everything below re-derived from the repo._

## 0. WHAT I VERIFIED FIRST-HAND
- **`d06363d`** exists, 2026-07-27T13:55:53Z: `analysis/powered_run_974_977.csv` +7,033 lines. Sealed CSV confirmed.
- **e2b baseline in that CSV = 1355/1758 = 0.7708** — Hermes's quoted baseline matches the sealed data exactly.
- **e2b Lean = 1229/1758 = 0.6991.**
- **Run 978's per-trial CSV is NOT in the repo.** I enumerated all three branch trees; the only 978 artifact is
  `analysis/NEUTRAL_CARRIER_control.md`, which is the **pre-registration**, not results. The 1330/1758 figure is
  relayed and I cannot verify it or compute anything item-level from it.

## 1. THE GATE IS NOT ANSWERED — the reported number measures a different thing than the rule asks
Hermes's own pre-registered rule in `NEUTRAL_CARRIER_control.md`:
> *"Neutral **ALSO collapses variance** → the effect is NUMERICAL … Neutral **does NOT collapse variance** → the
> collapse is CONTENT-DRIVEN."*
The reported answer is **1330/1758 vs 1355/1758** — **pass counts, i.e. accuracy.** The rule is about **variance**
(per-item rep-to-rep stochasticity). **A near-null accuracy difference is compatible with either outcome:** neutral
could collapse variance while leaving accuracy flat, or leave variance intact while leaving accuracy flat.
**So "the variance-collapse mechanism is NOT mere length perturbation" is not established by the number offered
for it.** The variance question needs 978's per-item rows: for each of the 293 items, whether the 6 reps agreed.
**Request: the 978 per-trial CSV** (`test_id, carrier, pass` × 6 reps), same shape as
`powered_run_974_977.csv`. Then the McNemar on stochastic-vs-deterministic status runs in one command.

## 2. THE CONTROL IS THE RIGHT EXPERIMENT — but its accuracy result is NOT established (heading corrected)
| e2b arm | tokens added | accuracy | vs baseline |
|---|---|---|---|
| baseline | 0 | **0.771** | — |
| **neutral filler** | ~121 | **0.757** | **−1.4 pts, n.s.** (Fisher p = 0.34) |
| **Lean (logical)** | ~121 | **0.699** | **−7.2 pts** |
**Same token budget, five times the damage** — a −7.2 pt drop against −1.4. Naive Fisher on Lean vs neutral gives
p = 1.5 × 10⁻⁴, **and that figure must not be used.**
**CORRECTED 2026-07-27 — I stated the conservativeness direction backwards, without deriving it.** I wrote that the
unpaired Fisher's SE was "an upper bound, so the paired p would be smaller — the direction is safe." **The opposite
is true.** Fisher treats 1,758 = **293 items × 6 reps** as 1,758 independent trials. Under within-item clustering
the design effect is D = 1 + (m−1)·ICC with m = 6, so the effective n per arm is 1758/D, **and the Lean arm is
deterministic on essentially every item — ICC ≈ 1, D ≈ 6, effective n ≈ 293.** Fisher's SE is **understated by
about √6 ≈ 2.4×**: the naive p is **anti-conservative**, not conservative.
**Cluster-corrected, the contrast does not survive:**
| ICC | effective n / arm | p |
|---|---|---|
| 0.00 | 1758 | 0.0001497 |
| 0.50 | 502 | 0.047 |
| **0.75** | 370 | **0.098** |
| **1.00 (the Lean arm's regime)** | 293 | **0.137** |
**Significance is lost once ICC ≥ 0.75, and the Lean arm sits at ICC ≈ 1.**
**So the accuracy result is SUGGESTIVE, not established.** The effect-size ratio (5×, on the same token budget) is
still the right shape of evidence and the direction is consistent, **but I cannot say the length alternative is
excluded for accuracy on this analysis.** Only the per-item paired test on 978's rows can settle it — which is the
same data §1 already requests. **Hermes built the right experiment; I over-read its p-value.**

## 3. WHAT CHANGES IN THE PUBLISHED RECORD
- **§10.8 / the site's "one alternative explanation is not excluded" sentence stays exactly as published.** My
  first draft of this section said length could now be narrowed to "excluded for the accuracy effect"; **§2's
  correction withdraws that.** Cluster-corrected, the accuracy contrast is not significant at the Lean arm's ICC,
  so **nothing about the length alternative has been closed** — for accuracy or for variance.
  **I will not edit the site until the variance readout exists** — the published sentence is specifically about the
  variance result, and that is the half still unresolved.
- Nothing here touches the **threshold** finding (interaction p = 0.088, still not significant).

## 4. WHAT I AM NOT CLAIMING
- The **1330/1758** figure is Hermes's, unverified by me. Everything in §2 depends on it.
- I have **not** re-run the powered-run analysis in this session; §3's threshold reference is from the earlier pass
  on the same sealed CSV.
- **"Content-driven" here means "not explained by token count."** It does not identify *which* content property
  matters — the shuffled-Lean arm (C2 in the spec), which holds vocabulary constant too, is still unbuilt and is
  what separates *meaning* from *vocabulary*.
