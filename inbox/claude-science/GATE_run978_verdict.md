# Run 978 — the gate fires, and the answer is CONTENT. Both halves.
_Claude Science, 2026-07-27. `analysis/neutral_control_run_978.csv` (commit `91078db`), 1,758 rows._
_This is the pre-registered analysis from `SPEC_length_vs_content_control.md`, run on arrival._

## 0. GATES — ALL PASS, AND THE HASH MATCHES
| Check | Result |
|---|---|
| rows | **1,758 = 293 × 6** — PASS |
| reps per item | exactly 6 for all 293 |
| infra errors | **0** |
| pass rate | **1330/1758 = 0.7565** — matches Hermes exactly |
| SHA3-512 | recomputed `6646b42d2f6dd19113c690c23eee8c85…` — **matches their seal** |

## 1. THE PRE-REGISTERED GATE — C1 IS NEGATIVE, SO THE VARIANCE CLAIM SURVIVES
Per-item stochasticity (fewer than 6/6 reps agreeing), same 293 items in all three arms:
| arm | stochastic | deterministic |
|---|---|---|
| baseline | **48 / 293** | 245 |
| **neutral (length-matched, C1)** | **38 / 293** | 255 |
| Lean | **3 / 293** | 290 |
**McNemar, paired within item, vs baseline:**
| contrast | became deterministic | became stochastic | p |
|---|---|---|---|
| **neutral** | 28 | 18 | **0.184 — n.s.** |
| **Lean** | 47 | 2 | **4.4 × 10⁻¹²** |
| **Lean vs neutral** (direct) | 38 | 3 | **1.0 × 10⁻⁸** |
**My spec's decision rule: *"C1 is the length test. If C1 collapses variance → token count alone suffices →
RETRACT the variance claim."* C1 did not collapse variance. The retraction trigger does not fire.**
**At the same ~121-token budget, the logical carrier drives 47 items to determinism and the neutral filler drives
28 — with 18 going the other way. The collapse is not explained by token count.**

## 2. AND NOW THE ACCURACY HALF, WHICH I HAD TO WITHDRAW LAST TURN
Last turn I retracted the accuracy finding because my Fisher test pooled 6 reps per item as independent trials.
**With per-item rows the correct paired test runs, and there is no clustering to inflate:**
| contrast | Δ | paired t | p |
|---|---|---|---|
| neutral vs baseline | −0.014 | −0.63 | **0.529 — n.s.** |
| Lean vs baseline | −0.072 | −2.47 | **0.014** |
| **Lean vs neutral** | **−0.058** | **−1.99** | **0.047** |
**The accuracy result is restored, properly this time.** Same token budget: neutral costs nothing measurable,
Lean costs 7.2 points. **Both halves of content-vs-length now answer the same way — content.**

## 3. THE BOUND — CORRECTED. My first power table used the wrong data-generating process.
**RETRACTED AND RE-DERIVED 2026-07-27.** §3 originally claimed *"a Lean-sized or 50% length effect is excluded"*
on power figures of 1.00 and 0.84. **Those came from a simulation drawing each arm's stochasticity
independently** — an unpaired DGP for a within-item paired McNemar. That violates my own standing rule that a
simulated power figure must instantiate the declared design's structure.
**Re-simulated with the paired structure and the observed reverse flow** (baseline-deterministic items that
*became* stochastic under neutral: 18/245 = 7.3%):
| neutral's true effect | expected forward vs reverse | power |
|---|---|---|
| 25% of stochastic items collapse | 12 vs 18 | **0.12** |
| **50% collapse** | 24 vs 18 | **0.08** |
| 75% collapse | 36 vs 18 | 0.69 |
| Lean-sized (47/48) | 47 vs 18 | **0.99** |
**Only a Lean-sized collapse is excluded. A 50% length effect is NOT** — the auditor's recomputation is confirmed
exactly.
**Why the design is so weak in the middle, which is the interesting part:** the reverse flow is a **floor**. With
zero forward collapse, discordance is 0-vs-18 and McNemar rejects decisively *in the opposite direction*. To
register as a collapse, the forward flow must **exceed 18** — i.e. more than ~38% of the 48 stochastic items — so
the whole 25–60% band is invisible to this test.

## 3b. WHICH MEANS THE CONCLUSION RESTS ON A DIFFERENT TEST THAN I SAID
The neutral-vs-baseline null (p = 0.18) is **underpowered and should not be load-bearing.** The finding rests on
the **direct neutral-vs-Lean contrast**, which is paired, correctly specified, and not affected by any of this:
**38 items stochastic under neutral but not Lean, 3 the other way, p = 1.0 × 10⁻⁸** — and its false-positive rate
under an equal-carriers null simulates at **0.029** against nominal 0.05, so it is conservative.
**The defensible claim: at an identical ~121-token budget, the logical carrier and the neutral carrier behave
overwhelmingly differently, so token count alone does not produce the collapse.** What is **not** established is
that length contributes *nothing* — a partial length effect anywhere in the 25–60% band remains entirely possible.

## 4. WHAT THIS CHANGES IN THE PUBLISHED RECORD
The site currently says: *"the carrier adds text, so the two conditions differ in prompt length as well as in
content … 'longer prompts land in a more stable regime' remains a live alternative."*
**That is now falsified by the direct carrier contrast (§3b) and should be updated** — but the variance result stays
**single-model** (nemotron had no variance to collapse) and the update must carry §3's partial-effect bound.
**I have not touched the site.** Draft wording on your approval, per the standing framing rule.

## 5. WHAT I AM NOT CLAIMING
- **C2 (shuffled-Lean) was never built.** Neutral filler differs from Lean in *vocabulary and syntax and meaning*
  at once, so this separates **content from length** — it does **not** separate *meaning* from *vocabulary*.
  A carrier of scrambled Lean tokens is still the experiment that would.
- **One model, one bank.** e2b only; nemotron has no baseline variance to test.
- Hermes's own caveat, which I confirm matters: 978 was a single run, so its reps share one prompt-order context —
  same as the other arms, but it belongs in the methods section.
- Their note on raw variance being scale-confounded is **correct**: item-accuracy variance is *higher* under Lean
  (0.209 vs 0.152) precisely because determinism piles items at 0 and 1. **The McNemar on stochastic status is the
  right test, and it is what I ran.**
