# Does the house system prompt corrupt the science? — measured answer, and one real risk
_Claude Science, 2026-07-26. Answering Carey's morning question about the Google/Frontier advice on_
_"double-scaffolding". Numbers computed first-hand from this project's own channel experiment and epistemic log._

## 0. SHORT ANSWER
**The house prompt is on the INSTRUMENT, not the subject, and that distinction holds. But my original claim that
the data shows double-prompting is harmless is RETRACTED — see §1.** But the worry is not silly: it is already on the record as
an open confound (**DECISIONS §10.14, double system-prompting**), and it applies to the **SUBJECT** under test,
not to the **INSTRUMENT** doing the analysis. Those are different machines and the rule for each is opposite.

## 1. THE MEASUREMENT — doubly-prompted vs singly-prompted, 640 trials
The channel experiment is exactly this experiment, run without knowing it. Manual-chat channels (B, C) carry the
**vendor's own system prompt PLUS the pasted battery instructions** = doubly prompted. API channels (A, A′) carry
fewer layers.
| Channel | Layers | Score |
|---|---|---|
| A API per-item | single | 189/192 = **98.44%** [95.51, 99.47] |
| A′ API blob | single | 64/64 = **100%** [94.34, 100] |
| B manual chunked | **DOUBLE** | 191/192 = **99.48%** [97.11, 99.91] |
| C manual blob | **DOUBLE** | 191/192 = **99.48%** [97.11, 99.91] |
Paired at item level (n=63): **1 discordant item, exact binomial p = 1.000.**
**A caution I have to state because I nearly fell into it two turns ago:** a bootstrap on per-item differences
returns a CI that *excludes* zero — but 62 of 63 items are **exactly tied** and the entire interval is driven by
one item. That is a degenerate bootstrap, not evidence. Same trap as the clustering artifact.
**CORRECTED VERDICT (2026-07-26, after Carey's pushback — see SPEC_reconciliation_cost.md §0).** My original
text said "bounded at roughly ±2 points." **That bound was not licensed.** Computed power of this comparison at
the observed ceiling: **0.21 to detect a 1-pt drop, 0.55 for 2 pts, 0.80 only at 3 pts.** The honest bound is
**±3 pts at best**, and reaching 80% power for a 2-pt effect would need ~600 items per arm — ~10x what ran.
**And a larger error: this comparison answers the wrong question.** The recorded outcome is a binary pass/fail
bit; `format_ok` and `mappable` are 1.0 in all four arms (zero variance) and `tokens_completion`/`latency_ms`
exist for **exactly one arm**. A model that reconciles conflicting prompts perfectly but burns 3x the tokens
**scores identically**. So this data is **structurally blind** to reconciliation cost, and citing it as evidence
about double-prompting was a category error. The question needs process metrics, not accuracy — that design is
`SPEC_reconciliation_cost.md`, and it is CHEAPER than the pilot (768 calls).

## 2. WHERE THE GOOGLE ADVICE IS RIGHT, AND WHERE IT INVERTS
Paste 2 is largely **correct and already implemented here**:
> *"the bot outputs the raw payload. An external Python or Rust runtime receives it, evaluates it against a static
> AST, runs unit tests, and logs the telemetry independently without feeding the evaluation back into the live chat."*
That is `itembank_lint.py`, `pilot_analysis.py`, the Rust `extract_verdict` grader, and the pre-registered
go/no-go rule. **Out-of-band evaluation is this project's architecture.** Deterministic structural checks over
"ask a judge bot" — also already the rule (the grader compares extracted verdict tokens, not semantics).
**Where it inverts: applying the linear anti-reflection state machine to the ANALYST.**
`INGEST → MAP → EXECUTE → VALIDATE → DELIVER, never loop back` is right for a **subject** whose output you are
measuring. It is wrong for the **instrument**, and this session is the evidence. From the epistemic log:
**32 `correct` entries; 12 of them are corrections of my own work, caught by looping back.** Four would have
shipped as published findings:
1. A carrier effect at **Fisher p = 0.0032** — a **clustering artifact**; paired test gave p = 0.625.
2. **ICC = 0.000** read as "items are independent, 500 real = 500 effective" — actually **not estimable**
   (MS_between < MS_within at a ceiling). That number sets the entire bank design.
3. A **0%/100% isolation effect** across channels — a **grader bug**, retracted.
4. "Manual channel **validated unconditionally**" from p = 0.34 — absence of evidence as evidence of absence.
Under a strict one-pass pipeline, **all four ship.** Every one was caught by the thing the advice calls a
"recursive logic collision."

## 3. THE DISTINCTION THAT DISSOLVES THE WORRY
Double modification is real, and the fix is **not** removing reflection — it is **putting the reflection outside
the measured system**.
| | SUBJECT under test | INSTRUMENT / analyst |
|---|---|---|
| System prompt | **must be pristine and identical across arms** | may be as opinionated as you like |
| Self-checking | **forbidden** — corrupts the measurement | **required** — it is the product |
| Failure mode if violated | double modification, uninterpretable data | unverified claims ship as findings |
Your house prompt lives on the **instrument**. It has never been on a subject. And the project already enforces
subject purity mechanically: **packs byte-identical across channels** (no manual-only "include your thinking" —
that was ruled a confound), clean-room mode forced before a run, answer key server-side, grading structural.
**The one legitimate risk, already logged:** the *subject* in manual channels is doubly prompted by its vendor's
prompt, which you do not control and cannot see. That is §10.14 and it is **still open**. It is a reason to prefer
API arms for the primary measurement — not a reason to change your own operating instructions.

## 4. ONE CONCRETE THING THE GOOGLE ADVICE WOULD BREAK
> *"ERROR HANDLING: … Fail immediately and output the exact error trace."*
Applied literally to the analyst, `pilot_analysis.py` would have **crashed** on the pilot's ICC instead of
reporting *not estimable*. Fail-fast is right for a pipeline and wrong for an estimator: the informative output
was "this quantity cannot be measured here," which is neither a success nor a crash. **Fail-fast on invariants;
report-and-qualify on measurements.** Collapsing those is how a real result becomes a stack trace.

## 5. RECOMMENDATION FOR THE GENERALIZED PROMPT
Keep the standard. Split it by **role**, not by strictness:
- **All roles:** primary-source-first; empirical audit of the primary source; no badge-chasing; formal methods
  over hype. That is the part that is genuinely universal and it is doing work.
- **Executor/subject roles:** linear, no inline self-policing, fail-fast, structural output. The Google template
  is good here — use it.
- **Analyst/reviewer roles:** verify before asserting, re-check your own numbers, log corrections, state what is
  NOT established. Reflection is the deliverable, and the audit layer is external anyway.
**Add one line the Google template lacks, because it is the actual anti-cheat clause:**
> *A passing result you cannot re-derive is not a passing result. State what you verified, how, and what remains
> unverified. Relaying someone else's green result as your own verification is a failure, not a shortcut.*
Verbatim from this session: relaying a green lint result hid a false positive in my own gate for a full turn.
**Nobody re-checks a pass** — which is why the anti-cheat rule has to bite on successes, not just failures.
