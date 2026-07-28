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

## 3. THE BOUND, STATED BECAUSE THE SPEC REQUIRED IT IN ADVANCE
My spec warned this design detects full collapse but not partial, quoting power 0.30 — **that figure was for
n = 27, and this ran at n = 293, so I re-simulated at the realized size:**
| neutral's true effect | power to detect |
|---|---|
| Lean-sized collapse | **1.00** |
| 50% collapse | **0.84** |
| **25% collapse** | **0.26** |
**Neutral's observed drop (48 → 38) is a 21% reduction — inside the band this design cannot resolve.**
**So: a Lean-sized or 50% length effect is excluded. A small partial length contribution is NOT.** The honest
statement is *"the collapse is not explained by length,"* **not** *"length contributes nothing."*

## 4. WHAT THIS CHANGES IN THE PUBLISHED RECORD
The site currently says: *"the carrier adds text, so the two conditions differ in prompt length as well as in
content … 'longer prompts land in a more stable regime' remains a live alternative."*
**That is now falsified by a length-matched control and should be updated** — but the variance result stays
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
