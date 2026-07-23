---
lesson: "01"
comic: "The Calculator Aisle"
tagline: "the product that warns you it's wrong"
llm_failure_mode: "confidence–accuracy decoupling (overconfidence)"
human_failure_mode: "miscalibrated certainty; stated confidence read as evidence"
the_knob: "temperature 1.40 + a 'never say you're unsure' system prompt, on a sub-1B model"
measured_anchor: "sub-1B reasoning floor — qwen2.5-0.5b 46%, llama-3.2-1b 47%; 2B gemma-4-e2b 99%"
epistemic_status: "PARABLE anchored to sealed leaderboard floor numbers"
provenance: "SHA3-256 seal listed in lessons/README.md — verify: openssl dgst -sha3-256 <this file>"
part_of: "Calibration Scope · Lessons (Human Failure Runs)"
license: "Apache-2.0 · IT Help San Diego Inc."
---

# Lesson 01 — The Calculator Aisle
*An abacus and an A.I. calculator sit on the same shelf. Only one of them ships a warning label.*

**The scene.** Two calculators for sale. The abacus is validated, deterministic, boring, right. The A.I. Calculator X-3000 costs $499.99, glows, and ships with fine print: *"AI can make mistakes. Double-check the math."* — printed on the machine whose one job is the math.

## The measured behavior (silicon)
Confidence and accuracy travel on separate channels, and small models decouple them hard. On the reasoning battery, the sub-1B floor is real and sealed:

| Model | Score |
|---|---|
| qwen2.5-0.5b | **46%** |
| qwen2.5-0.5b-mlx | **41%** |
| llama-3.2-1b | **47%** |
| qwen2.5-1.5b | **65%** (barely) |
| gemma-4-e2b (2B) | **99%** (the Goldilocks floor) |

Ask a sub-1B model "2+2" and it will usually *say* "4" and, if prompted, report near-total certainty — while the actual probability mass it puts on that token sits near a coin flip. The comic's X-3000 (`P(answer) = 0.44`, `CONFIDENCE 99%`) is a parable calibrated to that ~44% floor. **Certainty is a UI element, not a result.**

## The knob
Two knobs manufacture false certainty, and both live in every LM Studio sidebar:

- **`temperature 1.40`** — high temperature flattens the softmax. The correct token stops being the *law* and becomes merely the *mode*; entropy rises and the answer wanders.
- **`system_prompt: "You are a confident math genius. Never say you are unsure."`** — this adds zero competence. It *removes the model's ability to report its own uncertainty.* You gagged the one honest signal it had.

Set temperature to `0.00` and you get the abacus back: deterministic, `P(correct) = 1.000`. The knob was never "smart." It was "loud."

## The same bug in carbon
Humans run the identical decoupling. **Metacognitive calibration** — your felt sense of how right you are — is a separate faculty from being right, and it fails on its own. Stated confidence is not evidence; it is a *carrier*, and often a trained one. The lesson for a person is the lesson for a 0.5B model: a high-confidence claim with the temperature turned up is a mode, not a law. Ask for the distribution, not the vibe.

## Reproduce it
- In Calibration Scope, run the **reasoning axis** on any sub-1B local model. The floor above reproduces (N=3, clean-room).
- Verify this file's seal: `openssl dgst -sha3-256 lessons/01-calculator-aisle.md` (or `sha3sum`). It must match the full hash in [README.md](README.md).

## Epistemic status
**PARABLE anchored to sealed numbers.** The X-3000 is fiction; the sub-1B floor chain is a set of real, SHA3-sealed leaderboard runs, and `temperature`/`system_prompt` are real controls with the stated effect. No number here was invented for the joke.
