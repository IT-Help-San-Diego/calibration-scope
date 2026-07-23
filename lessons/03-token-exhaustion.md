---
lesson: "03"
comic: "Token Exhaustion"
tagline: "an empty answer isn't a wrong answer"
llm_failure_mode: "empty completion (finish_reason: length) rendered as an answer"
human_failure_mode: "choking under load — running out of working budget mid-thought"
the_knob: "max_tokens / reasoning budget set too low for the problem"
measured_anchor: "real caught incident, now a permanent regression test"
epistemic_status: "SEALED — real caught incident + regression test"
provenance: "SHA3-256 seal listed in lessons/README.md — verify: openssl dgst -sha3-256 <this file>"
part_of: "Calibration Scope · Lessons (Human Failure Runs)"
license: "Apache-2.0 · IT Help San Diego Inc."
---

# Lesson 03 — Token Exhaustion
*You ask a hard question. The model thinks… and thinks… and hands you a blank.*

**The scene.** The dashboard used to render that blank as if it were the answer. It isn't an answer. It's a model that ran out of room to finish the sentence.

## The measured behavior (silicon)
Real incident, caught in the first week and now a permanent regression test: a model exhausted its generation budget mid-reasoning and returned an **empty completion with `finish_reason: length`.** The UI displayed the empty string as the model's answer — a silent, confident-looking blank. The fix was to make it **loud**: a failure banner reading *"NO FINAL ANSWER — this is a failure, not a result."*

The distinction is the whole point: **"produced nothing" and "produced something wrong" are different failures with different fixes.** Conflating them corrupts every score downstream.

## The knob
- **`max_tokens` / reasoning budget.** Set it too low against a problem that needs a long chain of thought and the model spends its entire budget reasoning, with nothing left to *emit*. The thinking happened; the answer never got a turn.
- **`finish_reason` is the tell.** `stop` = it chose to finish. `length` = it was cut off. Treat `length` + empty output as an **infrastructure failure**, never a capability verdict — a model must not be blamed for a budget you set.

## The same bug in carbon
**Cognitive load and choking.** Give a capable person a hard problem and a shrinking clock and they can go blank at the buzzer — not because they don't know, but because the working budget ran out before the answer could be assembled. The exam lesson and the LLM lesson are one: *don't score the blank as a wrong answer.* Distinguish "didn't finish" from "got it wrong," or you'll mis-diagnose the mind — or the model — every time.

## Reproduce it
- Give any reasoning model a multi-step problem with `max_tokens` set deliberately low; watch it burn the budget on reasoning and return empty with `finish_reason: length`.
- Verify this file's seal: `openssl dgst -sha3-256 lessons/03-token-exhaustion.md`. It must match the full hash in [README.md](README.md).

## Epistemic status
**Real caught incident (regression-tested).** The empty-response-as-answer bug and its `finish_reason: length` fix are in the project history. Cognitive load / choking-under-pressure is established human science, cited as analogue.
