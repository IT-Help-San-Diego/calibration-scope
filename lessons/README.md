# Lessons — Human Failure Runs

A companion series to [Calibration Scope](../README.md). Each lesson takes one **measured** way an AI model fails, prints the exact knob that produces it, and holds it up next to the **human** cognitive failure it rhymes with. The comic is the hook; this folder is the receipt.

We built an instrument to measure intelligence in silicon and in carbon under one method — pinned stimulus, committed answers, N=3, SHA3-sealed evidence. These are the lessons that fall out when you point it at both. Same bug, two substrates.

## The ground rules (why this is not vibes)
- **Every number is a real, sealed run — or it is labeled as something else.** Each lesson carries an **epistemic status**: `SEALED` (measured clean runs), `MECHANISM` (documented engine behavior), or `PARABLE` (a story calibrated to sealed numbers). The joke never inflates the number.
- **The human science is cited as analogue, not as our discovery.** Serial-position, metacognitive calibration, cognitive load, messenger effects — established results, used to build the bridge, never dressed up as new findings.
- **No magic, no guru, no belief required.** The whole claim is checkable with math you already have and a hash function that has been in the standard library for years.

## The seal is real — verify it
Each comic's footer prints `SHA3-256 <first8>…<last8>` and links back here. That is the actual SHA3-256 of the lesson file below — not decoration. To confirm the joke is reproducible:

```bash
openssl dgst -sha3-256 lessons/04-carrier-color.md
# or
sha3sum lessons/04-carrier-color.md
```

The output must match the full hash in the table (LF line endings, file exactly as committed). If it doesn't match, the seal is broken — and you should trust the file *less*, not more. That is the point.

## The runs
| # | Comic | LLM failure | Human analogue | Status | SHA3-256 |
|---|---|---|---|---|---|
| 01 | [The Calculator Aisle](01-calculator-aisle.md) | overconfidence (confidence ≠ accuracy) | miscalibrated certainty | `PARABLE` | `8601a9163389f596e6e81e5027b7c978d39a2866d53accad72ea2a7a339d483c` |
| 02 | [Truncate Middle](02-truncate-middle.md) | context-window eviction | serial-position effect | `MECHANISM` | `ff28f63b85ac0bfddd790b5c36c2da1d0c582e08beb104216fd91ed8426dc845` |
| 03 | [Token Exhaustion](03-token-exhaustion.md) | empty answer ≠ wrong answer | choking / cognitive load | `SEALED`* | `ca23cb91e8e1415e61f1632fd282e1560e5c7ef101959b561774b9f7fa669eec` |
| 04 | [Carrier Color](04-carrier-color.md) | verdict tracks carrier, not signal | messenger effect / flattery bias | `SEALED` | `f8a9c59669c16bd14dd55c54c9788ee6383fe3ba368b737266fa3675c67dea1a` |

\* real caught incident + regression test.

## Who this is for
- **Neuroscience / cognitive science / autism research.** The bridge is meant to hold weight: each analogue names a real phenomenon, and Lesson 04 argues, from measured data, that *carrier-immunity is a strength, not a deficit.* If a bridge is overbuilt or wrong, the epistemic-status labels are there so you can say exactly where.
- **Infosec / local-model tinkerers.** Every failure here is a knob in your LM Studio sidebar (`temperature`, `n_ctx`, `max_tokens`, model size). Read them as an attacker or a defender: these are the settings that make a model confidently wrong, forgetful, mute, or manipulable by tone.

Same instrument, silicon and carbon. Look in the mouth before you trust the gift horse.

— *IT Help San Diego Inc. · a project of the [Intellectual Resistance](https://intellectualresistance.com/) · Apache-2.0*
