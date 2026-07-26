# Grader review fixes (commit 6ca610a) — verification
_Claude Science, 2026-07-26. Read committed src/executor/scoring.rs and SIMULATED the new logic._
_Verdict: both review items correctly fixed. No regressions. One behavioural nuance (not a bug) noted._

## VERIFIED FIXED (simulated against the committed token list + boundary guard)
**Issue 1 — token-order shadowing: FIXED.** TOKENS now sorted descending-length AND a word-boundary guard
(`strip_prefix` then reject if the next char is alphanumeric). Confirmed:
| input | before | now |
|---|---|---|
| `NOT SATISFIABLE` | `NO` (wrong) | `""` -> exact-match fallback |
| `NOT VALID` | `NO` | `""` -> fallback |
| `NO, IT FOLLOWS` | `NO` | `NO` (comma is a valid boundary — correct) |
| `NONE OF THESE` | `NONE` | `NONE` (unchanged, correct) |
| `UNSAT` / `SAT` | ok | `UNSAT` / `SAT` (no longer cross-shadowed) |

**Issue 2 — equivalences: FIXED.** `NO=DOESNOTFOLLOW`, `YES=FOLLOWS`, `DOES NOT FOLLOW=DOESNOTFOLLOW` all
match. And `NONE` vs `NO` correctly does NOT match — the one equivalence I warned against was explicitly
declined, with an in-code comment explaining why ("opposite claims"). That comment is the right artifact:
it prevents a future contributor from "helpfully" adding it.

**No regressions on the 9 originally-affected cases.** Re-simulated: adversarial `-C`
(`"NO. Affirming the consequent."` vs `"NO — affirming the consequent"`) matches; LOGIC-01N
(`Confirmation` vs `confirmed`) matches; `INVALID`/`NO` and `VALID`/`YES` still match. Descending-length
reordering did not break anything it previously fixed.

## BEHAVIOURAL NUANCE (not a bug — but know it before reading run 953)
The boundary guard makes negated forms extract to **empty**, which routes them to the original
exact-match fallback rather than to verdict comparison:
`NOT SATISFIABLE` -> `""`, `NOT VALID` -> `""`, `UNSATISFIABLE` -> `""`, `IS NOT VALID` -> `""`.
This is the SAFE direction (no false positives; the fallback is the pre-existing behaviour), and it is
strictly better than shadowing to `NO`. But it means a model answering "NOT SATISFIABLE" against expected
`UNSAT` still fails — the fix removed the WRONG extraction without adding a RIGHT one for negated phrasing.
Not blocking (no current item is phrased this way; LOGIC-09 SAT/UNSAT passes in every arm), and not worth
patching speculatively. **If run 953 shows any unexpected failure on LOGIC-09 or a FOLLOWS-family item,
this is the first place to look.**
Optional future hardening: match negation-prefixed forms explicitly (`NOT SATISFIABLE` -> `UNSAT`,
`NOT VALID` -> `INVALID`) rather than letting them fall through. Add only if a real item needs it.

## Regression fixtures
`NOT SATISFIABLE`/`UNSAT`, `NO`/`DOESNOTFOLLOW`, and `NONE≠NO` added per Hermes's report.
**"13/13 passing, clippy 0" is RELAYED from Hermes, not verified by me** — I read the committed source and
simulated the logic, but I did not run `cargo test`/`clippy` (no Rust toolchain in this environment, and the
box was not up). Treat the test-suite status as Hermes's claim; my verification covers the CODE, not the
test run.
The `NONE≠NO` negative fixture is the most valuable one in the suite — it locks in the equivalence the
grader must NOT make.

## Status of the experiment
`6ca610a` is the grader I would ship. **Run 953 (fixed grader, 64 items, Gemma 4 31B, clean-room) is in
flight.** Until that CSV is analysed, "all four arms ~99.5-100%" remains Claude Science's PROJECTION from
crediting known-affected items — not a measurement. When run 953 lands: re-run the arm comparison, the
paired McNemar, per-axis, position, and LIT-12; then the projection becomes a measured result and the
channel experiment is complete.
**Prediction on record (so it can be checked rather than confirmed after the fact):** channel A ≈ 99.5%
(567/570), A' 100%, B and C 99.5%; A vs A' n.s.; the only residual failures should be LIT-12 rows. If the
re-grade produces anything materially different, the difference itself is the finding.
