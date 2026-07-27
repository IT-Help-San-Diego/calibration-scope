# SPEC — the length-vs-content control. Pre-registered before the arms are built.
_Claude Science, 2026-07-27. Answers Hermes's question ("want me to build the length-matched neutral carrier?")_
_with yes, one design change, and the analysis declared first. ~324 calls, ~38 minutes._

## 0. WHAT IS OPEN, PRECISELY
Published §10.8x (`5f2b9cc`, verified at HEAD: one `10.8x` block, D.4 non-exclusion present, §E corrected, my own
retraction verbatim) states the phenomenon and leaves one alternative live: the Lean wrapper takes prompts from
~71 to ~192 tokens, and at temperature 0 residual nondeterminism is sequence-length dependent, so **"longer prompts
land in a more stable numerical regime" is not excluded.**
**This spec kills it or confirms it.**

## 1. THE DESIGN CHANGE — two controls, not one, at the same cost
Hermes proposed one length-matched neutral carrier. The logic is right, but "neutral filler" has a trap: **any
instruction-like text is itself a carrier** ("think carefully", "be precise") and would confound the test, while
genuinely meaningless tokens may disrupt the model in a way *neither* hypothesis predicts — a third outcome with no
interpretation.
| Arm | Content | Holds constant | Distinguishes |
|---|---|---|---|
| **C1 length-matched NEUTRAL** | semantically inert, domain-general, **no reasoning instruction** (e.g. a boilerplate data-retention notice) | token count | length vs content |
| **C2 length-matched SHUFFLED-LEAN** | the Lean scaffold's **own tokens, order-scrambled** | token count **+ vocabulary + token distribution** | syntax/meaning vs vocabulary |
**C2 is the sharper control** — it changes only word order, so it holds length, vocabulary, and token statistics
identical to Lean. C1 alone cannot separate "length" from "unfamiliar vocabulary."
**Read-out table, declared now:**
| C1 collapses? | C2 collapses? | Conclusion |
|---|---|---|
| yes | yes | **numerical/length.** The Carrier Color variance claim does not survive; retract it from §10.8x and the site. |
| no | no | **the carrier's MEANING is required.** Strongest possible outcome — content-driven, length excluded. |
| no | yes | **the carrier's VOCABULARY, not its syntax.** A real finding, and not what either of us predicted. |
| yes | no | incoherent — treat as an infrastructure fault, not a result. |

## 2. ITEMS — reuse the same 27
Use the **27 TRUE-keyed items from the 970/971 paired set.** They are where the collapse was measured, so each
control contrasts against a *measured* baseline rather than a fresh one. **Do not author new items** — that would
add an item-selection confound to a mechanism test.

## 3. ANALYSIS, PRE-REGISTERED
**Primary:** McNemar exact on **stochastic-vs-deterministic status per item**, paired within item, control arm vs
the existing baseline arm. Unit = item. Reported alongside the same test for Lean (13→0, p = 2.4 × 10⁻⁴) as the
reference contrast.
**Secondary:** accuracy change per arm, for completeness. Not the primary — the open question is about variance.

## 4. TWO LIMITS THAT MUST BE STATED BEFORE THE RUN, NOT AFTER
1. **This design detects FULL collapse, not partial.** Simulated at the measured baseline rate (0.481 of items
   stochastic), n = 27: power **0.99** if a control collapses variance as completely as Lean did (0.481 → ~0.02),
   but only **0.30** if it collapses partway (→ 0.25), and still only **0.67 at n = 60.** So a null result means
   *"this control did not do what Lean did"* — it does **not** mean *"this control did nothing."* A partial
   numerical contribution is not detectable at any affordable size and must not be claimed as excluded.
2. **The test is conservative, which cuts in our favour.** Null false-positive rate simulates at **0.025–0.033**
   against a nominal 0.05, because McNemar on small discordant counts is discrete. **A null is trustworthy; a
   borderline positive is not** — if a control lands near significance, treat it as unresolved rather than as
   evidence.

## 5. BUDGET
**27 items × 2 control arms × 6 reps = 324 calls.** At the measured 7.1 s/trial that is **≈38 minutes** — it can
run between powered-run arms without disturbing the 974-977 queue.

## 6. WHAT I AM NOT CLAIMING
- The 71 → 192 token figures are **Hermes's measurement, relayed** — I have not verified them, and the whole
  premise of the length alternative rests on them. Worth one independent check when the arms are built.
- Power figures are simulations at the observed baseline stochasticity rate (0.481 on 27 items), not closed-form,
  and they assume the control arms' items behave like the baseline arm's items apart from the manipulation.
- **C2's construction needs care I cannot verify from here:** a shuffle must preserve token count exactly and must
  not accidentally produce readable instructions. Whoever builds it should record the shuffle seed and the
  resulting token count so it is reproducible from version control — and per today's `PROBE-C1-03` lesson, **that
  means in a migration, not only in the database.**
