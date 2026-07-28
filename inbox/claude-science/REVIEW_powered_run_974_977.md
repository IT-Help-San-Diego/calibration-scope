# Powered run 974-977 — three things before this becomes a result
_Claude Science, 2026-07-27. I do not have the CSV; everything below is derived from the reported statistics_
_or from the repo. Nothing here is a verdict — two of the three are requests._

## 0. THE CSV IS NOT IN THE REPO
**No powered-run results file exists on any branch or in any open PR** — verified, and I have to record that
**an earlier version of this section claimed a three-branch search I had not actually run**: I fetched only `main`'s
tree and wrote "all three branches." That mattered specifically, because **my own pushes default to the
`claude-science` branch**, so a results export committed there would have been invisible in `main`'s tree — the one
place the file could have hidden was the one place I hadn't looked. **Now actually searched, all three branch trees
plus open PR #3's file list:**
| Branch | files | .csv | powered-run / 974-978 / neutral results |
|---|---|---|---|
| `main` | 408 | 12 | **none** |
| `claude-science` | 379 | 5 | **none** |
| `claude/gui-next-steps-…` | 407 | 12 | **none** |
| PR #3 (open) | 9 changed | 0 | **none** |
Widened past `.csv` to any `csv/tsv/json/jsonl/parquet/sql` matching the run numbers: the only matches are
`analysis/powered_bank_base.json` and `migrations/054_powered_bank.sql` — **the bank definition, not results.**
**So the conclusion stands and is now earned: the 974-977 numbers are relayed and I cannot verify them.** My pre-registered harness (`carrier_analysis.py`)
runs in one command the moment the export lands.
**The gate that matters most is the one only the CSV can answer:** `EXPECTED_ROWS = 7032` (4 × 293 × 6). Budget
expiry is **not flagged per-trial** — a truncated run's rows look ordinary — and that is exactly how 970 and 971
died undetected until I counted rows. "All four DONE" is a claim about the queue; the row count is the check.

## 1. THE HEADLINE COMPARES TWO SIGNIFICANCE VERDICTS. THAT IS NOT THE THRESHOLD TEST.
Reported: e2b Δ = −0.072 (t = −2.47, significant); nemotron Δ = −0.010 (t = −0.42, n.s.). Conclusion drawn:
*"that's the threshold."*
**"Significant in A, not significant in B" does not establish that A differs from B.** The threshold claim *is* the
interaction: is Δ<sub>e2b</sub> different from Δ<sub>nemotron</sub>? Two arms can differ in significance while their
effects are statistically indistinguishable — one sits just past the line, the other just short of it.
I recovered the standard errors from the reported Δ and t (SE = |Δ/t|): **0.0292 and 0.0238.** The
difference-of-differences is **−0.062**.
| Assumption | SE | t | p |
|---|---|---|---|
| **independent arms** (my proxy) | 0.0376 | −1.65 | **0.100** |
| paired, ρ = 0.3 | 0.0316 | −1.96 | 0.050 |
| paired, ρ = 0.5 | 0.0269 | −2.31 | 0.021 |
**So the interaction is not refuted — it is untested.** My independent-arms figure is an *upper bound* on the SE,
because both models saw the same 293 items and a per-item paired interaction test cancels item difficulty.
**If per-item carrier effects correlate across models at ρ ≳ 0.3 — plausible, since hard items may be
carrier-vulnerable for both — the interaction is significant.** That correlation is computable only from the CSV.
**Request: run the paired interaction test (per-item difference-of-differences across the two models) and report
its t and p.** Until then §10.9's threshold claim should say *"consistent with a capability threshold"*, **not
"that's the threshold."** The difference is the interaction p-value, and nobody has it yet.

## 2. THE VARIANCE RESULT — THE PUBLISHED FINDING — WAS NOT REPORTED AT ALL
The overnight summary reports **means only.** But §10.8x, the site copy, and the whole Carrier Color claim rest on
the **variance collapse**: 13 of 27 TRUE-keyed items stochastic at baseline → **0 of 27** under Lean, McNemar exact
p = 2.4 × 10⁻⁴.
**That was measured on 53 preview items. The 293-item bank is a replication test of it, and the replication has
not been read out.** This is the highest-value number in the export and it is missing from the report.
**Request: per model, the count of items with an intermediate cell rate (not 0.000, not 1.000) under each carrier.**
If the collapse reproduces at n = 293, the published claim is materially stronger than what the site currently
says. **If it does not reproduce, the site copy needs revision** — and I would rather find that myself than have a
reader find it.

## 3. WHAT I AM NOT CLAIMING
- **I have not seen the data.** The SEs above are back-derived from two reported summary statistics; if either Δ or
  t was rounded in the relay, my figures inherit that error. They establish the *shape* of the problem (an
  interaction spanning p = 0.02–0.10 depending on ρ), not its value.
- I am **not** saying the threshold is absent. The direction is right and the e2b effect looks real. I am saying the
  comparison as reported cannot carry the word "threshold."
- The reported primary test **does** match the pre-registration (rate-based paired t on per-item pass rate, paired
  within item × model) — I checked `analysis/POWERED_RUN_preregistration.md`. My objection is to the *inference
  drawn across two such tests*, not to the test itself.
- **978 should be left to finish.** It answers content-vs-length, and per the corrected spec **C1 is the length
  test: a positive there — borderline or not — retracts the variance claim from the site.**
