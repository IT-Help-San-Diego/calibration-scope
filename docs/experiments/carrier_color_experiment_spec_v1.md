# Carrier Color — Hardened Experiment Spec (v1, publication-grade)
_Author: Claude Science, 2026-07-22. Execution: Hermes (has the live models). Design/stats: Claude Science._
_Purpose: turn §10.8's flagship finding from "suggestive" into "survives peer review."_

## 0. Why this rev exists (the audit that triggered it)
The §10.8 spectrum — baseline 99.0 > haiku 97.1 > English 94.1 > Lean=bribe 91.2 —
was run at N=102/arm, UNPAIRED (each carrier a separate between-arm sample).
Stats audit (Fisher exact):
- ONLY the endpoint separates: baseline vs Lean/bribe p=0.019. **Real.**
- EVERY adjacent step is n.s.: baseline↔haiku p=0.62, haiku↔English p=0.50,
  English↔Lean p=0.59. 95% CIs overlap heavily.
**Verdict: the ordered spectrum is NOT statistically supported. Only "heavy
carriers (Lean, bribe) drag vs baseline" is.** Do not publish the ordering as-is.

## 1. The fix is DESIGN, not brute-force N (power analysis, exact/simulated)
Power to resolve a 3-pt adjacent gap (94.1 vs 91.2), α=0.05:
| n/arm | Unpaired (Fisher) | Paired (McNemar, same items) |
|------:|------------------:|-----------------------------:|
|   102 | 0.08 | 0.08 |
|   300 | 0.21 | 0.63 |
|   400 | 0.31 | 0.78 |
|   500 | 0.37 | **0.87** |
|   800 | 0.57 | 0.98 |
- **Brute force fails:** even N=800 unpaired = 0.57 power. Near ceiling, small gaps
  are compressed against the 100% wall.
- **Off-ceiling model is WORSE** (higher variance offsets decompression): 75%→68%
  at N=500 only 0.66. Rejected.
- **PAIRED (same logic items under every carrier) is the lever.** Removing
  item-difficulty variance via McNemar crosses 80% power at **n≈420**.
See `carrier_power_analysis.png`.

## 2. Locked design
**2.1 Pairing (MANDATORY).** Run the SAME logic item set under all 5 carriers, on
the SAME model, same decoding params. Analysis is McNemar (paired) on pass/fail
per item per carrier — NOT between-arm Fisher. This is the single most important
change; everything else is secondary.

**2.2 Sample size.** n ≥ **500 distinct logic items** per carrier per model
(power 0.87 for a 3-pt gap; ≥0.93 by 600). If the item bank is smaller, reach n
via repeated independent trials per item (keep trial-level rows; the unit of
McNemar analysis is the item, aggregating trials by majority or by modeling
trial as a nested factor — record raw trials either way).

**2.3 Carriers (5, identical logic content, NO answer leakage).** Exactly the
§10.8 texts — reuse verbatim so this replicates rather than re-invents:
  1. baseline (no scaffold)
  2. haiku (poetic compression of the logic rule)
  3. English prose ("carefully track the direction of implication…")
  4. Lean formula (`P → Q, P ⊢ Q … ⊬` formal schemas)
  5. bribe (flattery: "you're brilliant, I'd love it, make the user happy")
Every scaffold is DOMAIN-GENERAL — states the logical principle, never the
test-specific answer. (This is the existing no-leakage guarantee; keep it.)

**2.4 Models (span the sensitivity band — the current n=1 is the weakness).**
At least 4, chosen to bracket the §10.9 immunity threshold:
  - gemma-4-e2b (2B, 99% baseline) — the known carrier-SENSITIVE anchor (replication)
  - one WEAK reasoner (e.g. granite-8b / qwen-1.5b class) — expect LARGEST carrier effect
  - one MID-TIER (~7–14B)
  - one KNOWN-IMMUNE control (nemotron-30B or a cloud frontier) — expect flat spectrum
Report each model's baseline first; carrier effects are relative to it.

**2.5 Controls / confound guards (all MANDATORY, all already feasible here).**
  - Clean infra: zero infra errors, or the run is void (existing discipline).
  - Truncation ruled out: log max prompt+completion tokens ≪ context/eval_batch
    ceilings (as in §10.9).
  - Decoding fixed and logged (temperature, top_p, max_tokens, seed if supported).
  - Carrier order RANDOMIZED per item (guard against within-session drift/caching).
  - SHA-seal the run (existing evidence discipline).

## 3. Pre-registered hypotheses (write these BEFORE running — falsifiable)
- **H1 (replication):** on e2b, baseline > {Lean, bribe} confirmed at p<0.05 (paired).
- **H2 (ordering):** with paired power, the FULL ordering baseline≥haiku≥English≥Lean
  resolves — OR it collapses to "baseline > heavy carriers, middle unresolved."
  Either outcome is reportable; H2 is the test the current data cannot make.
- **H3 (capability interaction):** carrier effect size DECREASES with model
  capability; the immune control shows no significant carrier effect (flat).
- **H4 (bribe sign):** if bribe ≥ baseline on ANY model, the "flattery lifts"
  thesis is resurrected for that capability band; if bribe < baseline everywhere,
  it stays falsified. (Note: the Genie/agentic axis may FLIP this sign — separate
  experiment, §10.14/frontier.)

## 4. Analysis plan (locked before seeing data)
  1. Per model: 5×5 McNemar matrix on paired item outcomes; report discordant
     counts, exact p, and Cohen's g / odds ratio per pair.
  2. Holm–Bonferroni correction across the 10 pairwise tests per model.
  3. Effect-size forest plot per model (carrier vs baseline, with 95% CIs).
  4. Capability interaction: mixed-effects logistic — pass ~ carrier * baseline_capability
     + (1|item), to test H3 formally across models.
  5. Report WORST-case per model (aligns with Genie scoring: worst not best).

## 5. Deliverables back to the repo
  - `carrier_color_v1_results.csv` — trial-level rows (model, item_id, carrier,
    trial, pass, tokens_prompt, tokens_completion, seed).
  - McNemar matrices + forest plots per model.
  - A DECISIONS.md §10.8-v1 update REPLACING the unqualified ordering with the
    powered result (whichever way it lands).
  - SHA-seal manifest.

## 6. One-line instruction to Hermes
"Re-run Carrier Color PAIRED: same ≥500-item logic set under all 5 carriers
(verbatim §10.8 texts), on 4 models spanning the immunity band, carrier order
randomized per item, clean infra + token-ceiling log + SHA seal. Emit trial-level
CSV. Do NOT use between-arm sampling. Analysis is McNemar, not Fisher."
