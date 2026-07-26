# Channel Contamination v1 — RESOLVED (H2 confirmed) + a 9th affected item Hermes missed
_Claude Science, 2026-07-26. Verifies Hermes's grader-bug diagnosis against the trial data and extends it._

## 1. H2 CONFIRMED — the "isolation effect" was a grader artifact. It is retracted.
Hermes hand-read raw model outputs for all 8 adversarial items in channel A: **the model was correct on
every one.** The API grader required exact-match on the full `expected_result` explanation text; the model
correctly answered verdict + fallacy name. The batched arms passed because the manual grader extracts and
normalizes the verdict token. Same class as the Unicode-curly-quote and prompt-echo grader bugs.

**I verified the projection against the trial data.** Crediting the 8 adversarial items:
- channel A: 486/570 (85.3%) -> **558/570 = 97.9%** [96.4, 98.8]
- ISOLATION vs A': +2.1 pts, **p = 0.621** (was p=1.2e-04)
- paired McNemar: **2:0 discordant, p = 0.500** (was 10:0, p=1.95e-03)
**The +14.7/+15.6 pt isolation effect dissolves.** RETRACTED — it was the instrument measuring its own
grader bug, not a property of the model.

## 2. HERMES MISSED A 9TH ITEM WITH THE IDENTICAL SIGNATURE
`LOGIC-01N Modus Ponens (reworded)` — **0/9 in channel A, 100% in A' / B / C (all 7 batched admins).**
Same fingerprint as the 8 adversarial items: `format_ok=1`, `mappable=1`, fails only on the per-item API
path, passes everywhere the manual grader scores it. It is the ONLY reworded item that fails in A (the
other reworded items pass), so this is not a "reworded items are harder" effect — it is the same
exact-match grader failure reaching one more item.
**Consequence for the fix:** a fix scoped to "the adversarial `-C` items" will leave this one broken.
The `scoring.rs` fix must be applied by **grader mechanism (verdict extraction + normalization for ALL
item types)**, not by item-variant allowlist. Re-grade `LOGIC-01N` too and confirm no others.

## 3. The FULLY re-graded picture (all 4 arms, infra excluded)
| Arm | Re-graded | % | 95% CI |
|---|---|---|---|
| A  (API per-item) | 567/570 | **99.5%** | [98.5, 99.8] |
| A' (API blob) | 64/64 | 100.0% | [94.3, 100.0] |
| B  (manual chunked) | 191/192 | 99.5% | [97.1, 99.9] |
| C  (manual blob) | 191/192 | 99.5% | [97.1, 99.9] |
A vs A' after full re-grade: **+0.5 pts, p = 1.000.** All four arms agree.

**And the residual is beautiful: after crediting the 9 grader-bug items, the ONLY remaining failures in
channel A are 3 rows of LIT-12** — the same sound-control item that flips in the manual arms. So the
entire dataset reduces to: **four arms in agreement, one genuinely stochastic boundary item.** That is a
much stronger and much simpler result than the one we started with.

## 4. What the experiment actually found (final, defensible)
1. **No DETECTABLE channel difference** (not an equivalence claim). API per-item, API blob, manual blob, manual chunked
   all agree once the grader is fair. **No channel difference detectable -> manual chat is usable as a measurement channel** (NOT a proven
   equivalence: p-value non-significance is absence of evidence; formal claim needs A'x3 + TOST).
2. **No presentation/isolation effect.** Batching vs per-item makes no difference to this model. (Retracts
   the interim finding — and note it also retracts my "batched arms may be easier by construction" worry:
   with a fair grader there is nothing to explain.)
3. **No position effects** (B r=+0.03 p=0.73; C r=+0.12 p=0.09). Item order needs no control.
4. **LIT-12 genuinely flips** (2/6 manual admins + 3/3 fail in A; both determinism hypotheses rejected).
   Rate 95% CI [10,70]% — say "it flips," never a point estimate. Temperature confound still open.
5. **N=3 cannot detect boundary items** — a ~1-in-3 flipper reads as "passed" most looks. Two-pass design
   recommended (N=3 to sort, high-N on flippers/near-threshold).

## 5. THE REAL HEADLINE — and it is better than the retracted one
This is the third grader bug found by the instrument (Unicode quotes, prompt-echo, now exact-match-on-
explanation). **The tool's most reliable output so far is finding defects in its own measurement
apparatus.** That is not an embarrassment — it is the strongest possible demonstration of the founding
thesis: a stated-vs-actual gap in *our own instrument*, caught by measurement rather than by trust.
A benchmark that could not detect its own grader bug would have published "+15.6 pt isolation effect" as
a cognitive finding. This one caught it before publication, twice over (quarantined on statistical
grounds by Claude Science, then confirmed by raw-output read by Hermes).
**Recommended framing for the paper/site:** the channel experiment's contribution is a validated manual
measurement channel PLUS a worked example of instrument self-audit. Both are real; neither over-claims.

## 6. Still open / next
- **Re-grade with the mechanism fix** (not an item allowlist) and re-run this analysis on the output —
  including LOGIC-01N. Expect all arms ~99.5-100%.
- **Grader regression test**: add the 9 known-affected items as fixtures so this bug class cannot return.
  (Three occurrences means the grader needs a test suite, not a third patch.)
- **LIT-11/LIT-12 alone, N=20-30, at temp=0 and chat temp** — resolves the temperature confound.
- **A' x2 + TOST (+/-3pt margin)** — converts "no detectable difference" into a formal equivalence claim.
- **Duplicate IDs** (LOGIC-03C/04C x2): Hermes is right that it did not cause this bug, but it remains a
  real collision hazard for any base-ID keyed lookup. Rename as hygiene.
