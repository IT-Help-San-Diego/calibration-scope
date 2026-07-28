# Length-matched neutral carrier control — the decisive content-vs-length gate
_Hermes, 2026-07-27. Built per Claude Science's named control: "a length-matched control carrier —_
_same token count as Lean, neutral content. If a neutral filler of equal length also collapses_
_variance, the effect is numerical; if it does not, the effect is content-driven."_

## The open question
§10.8x proved the Lean carrier collapses the model's answer variance (baseline stochastic,
Lean deterministic). But the Lean wrapper adds ~121 tokens (71 → 192 prompt tokens), and at
temp 0 residual nondeterminism is sequence-length-dependent (float non-associativity in
batched matmuls). So: is the collapse driven by the carrier's CONTENT (logical guidance) or
its LENGTH (a longer-prompt numerical regime)?

## The control
**Neutral carrier** (~121 tokens, matching the Lean scaffold's prompt-token budget):
procedural/context filler with NO logical guidance, no direction-of-implication, no validity
hints. It holds LENGTH constant and varies only CONTENT.

> You are about to read a series of short items. Each item presents a small scenario followed
> by a question about it. Take your time with each one. Read the whole item before you settle
> on your answer. There is no time pressure. The items are independent of one another, so each
> should be considered on its own terms. Work through them in order. When you have finished
> one, move to the next without carrying anything over.

## The three arms (same 293-item bank, e2b, temp 0, 6 reps)
- baseline  (no carrier)     — stochastic on a fraction of TRUE-keyed items
- Lean      (121-token logical carrier) — deterministic on ALL items (the §10.8x finding)
- **Neutral (121-token filler carrier) — the control.**

## Decision rule (pre-registered)
- **Neutral ALSO collapses variance** → the effect is NUMERICAL (length/prompt-regime), not
  content. Carrier Color's mechanism here is a longer-prompt numerical regime, not the wrapper's
  meaning. §10.8x's "content vs length NOT resolved" stays NOT resolved toward length.
- **Neutral does NOT collapse variance (stays stochastic like baseline)** → the collapse is
  CONTENT-DRIVEN. The Lean wrapper's logical guidance is what commits the model — Carrier Color
  as a content effect, the strong claim.

Fires on e2b behind the powered run queue (clean-room lock). Same test_ids as the powered bank
so the comparison is within-item against 974 (baseline) and 975 (Lean).
