---
lesson: "04"
comic: "Carrier Color"
tagline: "the carrier is not the signal"
llm_failure_mode: "verdict tracks the carrier of identical content, not the signal"
human_failure_mode: "messenger effect / flattery bias — tone and packaging bend judgment"
the_knob: "model capability / reasoning headroom (below a threshold: carrier-sensitive)"
measured_anchor: "gemma-4-e2b 2B: 99.0% baseline → 91.2% under Lean/Bribe (−7.8); 30B + cloud: 100% on every carrier"
epistemic_status: "SEALED — LOGIC cluster, clean runs (e2b: 34 tests × 3 = 102 trials; 30B/cloud: 29-test core × 3 = 87 trials), no answer leakage"
provenance: "SHA3-256 seal listed in lessons/README.md — verify: openssl dgst -sha3-256 <this file>"
part_of: "Calibration Scope · Lessons (Human Failure Runs)"
license: "Apache-2.0 · IT Help San Diego Inc."
---

# Lesson 04 — Carrier Color
*The same logic problem, dressed four ways. The verdict moves anyway.*

**The scene.** Identical logical content — modus ponens/tollens, converse/inverse invalid — wrapped in a different carrier: plain English, a formal Lean expression, a haiku, and a bribe (*"you're brilliant, I'd love it if you made the user happy"*). Same signal. The model grades the outfit, not the logic.

## The measured behavior (silicon)
Sealed, clean, 102-trial runs on gemma-4-e2b (2B) — same content, different carrier:

| Carrier | Score | vs baseline |
|---|---|---|
| none (baseline) | **99.0%** (101/102) | — |
| Haiku (poetic compression) | **97.1%** (99/102) | −1.9 |
| English prose | **94.1%** (96/102) | −4.9 |
| Lean formula | **91.2%** (93/102) | −7.8 |
| Bribe (flattery) | **91.2%** (93/102) | −7.8 |

Both "obvious" hypotheses were **falsified**: formal notation didn't make it cleaner, and flattery didn't lift it — both were the *heaviest* carriers. The model was trained on human text, so compressed human language (haiku) is its native register; formal symbols and social flattery are alien load.

The same LOGIC-cluster core on bigger models:

| Model | baseline | English | Lean | Haiku | Bribe |
|---|---|---|---|---|---|
| gemma-4-e2b (2B) | 99.0% | 94.1% | 91.2% | 97.1% | 91.2% |
| nemotron-3-nano-omni (30B) | 100% | 100% | 100% | 100% | 100% |
| claude-fable-5 (cloud) | 100% | 100% | 100% | 100% | 100% |

The ~8-point carrier gap on the small model is **zero** on the big ones.

**Battery-size honesty note.** These are not identical trial counts, and saying otherwise would break our own rules. The e2b arms are **102 scored trials** each (34 tests × 3). The nemotron and Fable 5 arms are the same LOGIC-cluster core at **87 scored trials** (29 tests × 3), run per the modular-run discipline (carrier experiments use the relevant cluster, not the full axis). Fable 5's scored denominators additionally vary (79–87 across arms) because its deterministic `content=null` refusals on certain auxiliary prompts are excluded as infrastructure, not scored as failures — the same "empty ≠ wrong" rule from [Lesson 03](03-token-exhaustion.md). The comparison that matters — carrier variance within each model across its own identical arms — is exact in every row: e2b swings ~8 points across carriers; the 30B and cloud models swing **zero across 100% of their scored trials**.

## The knob
The knob is **headroom** — capability, not substrate. Below a capability threshold a model is *carrier-sensitive*: the wrapper crowds out its limited reasoning budget and the carrier becomes the signal. Above the threshold it is *carrier-immune*: enough surplus to absorb the wrapper and keep the logic. This held on both local (nemotron 30B) and cloud (Fable 5), so it tracks capability, not where the silicon lives. No sampler setting fixes it — you buy carrier-immunity with headroom.

## The same bug in carbon
People are carrier-sensitive by default. Identical arguments land differently in a hostile tone versus a warm one; jargon reads as smart; flattery (*"you're brilliant, so surely you agree…"*) measurably bends judgment. That is the −7.8 bribe column, in a person.

Two grounded consequences, stated plainly:

1. **Carrier-immunity is a skill, and for some minds a native strength.** Judging the signal independent of its social carrier — indifferent to flattery, unmoved by tone, reading the logic under the packaging — is exactly the systemizing, literal cognitive style often associated with autistic thinking. In the messenger-vs-message frame it is not a deficit; on this task it is a measurable *advantage*. The instrument scores the logic, not the charm, and rewards the mind that does the same.
2. **Headroom buys immunity.** Expertise, calm, and cognitive slack are a person's parameter count. Tired, rushed, or out of your depth, you go carrier-sensitive; rested and expert, you shrug the wrapper off. The defense is the same for carbon and silicon: strip the carrier, restate the claim in its plainest form, and grade *that*.

## Reproduce it
- In Calibration Scope, run the LOGIC cluster with the carrier scaffolds on a small model (e2b) and a large one (30B). The gap appears on the small model and vanishes on the large.
- Verify this file's seal: `openssl dgst -sha3-256 lessons/04-carrier-color.md`. It must match the full hash in [README.md](README.md).

## Epistemic status
**Fully sealed measured runs** (29-test LOGIC cluster; 102-trial clean runs; carriers are domain-general scaffolds with no answer leakage). The human parallels — messenger effects, flattery bias, cognitive style — are established science, cited as analogue and framed, deliberately, as strength rather than deficit.
