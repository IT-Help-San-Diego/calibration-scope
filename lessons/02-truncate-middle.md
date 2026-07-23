---
lesson: "02"
comic: "Truncate Middle"
tagline: "it kept your hello and your goodbye"
llm_failure_mode: "context-window eviction (silent middle-truncation / lost-in-the-middle)"
human_failure_mode: "serial-position effect — primacy and recency survive, the middle is dropped"
the_knob: "n_ctx set smaller than the payload"
measured_anchor: "500 real prompts, sealed — median ~93 tok, p99 ~5,800 tok, max ~78,700 tok (bimodal)"
epistemic_status: "MECHANISM + sealed measurement"
provenance: "SHA3-256 seal listed in lessons/README.md — verify: openssl dgst -sha3-256 <this file>"
part_of: "Calibration Scope · Lessons (Human Failure Runs)"
license: "Apache-2.0 · IT Help San Diego Inc."
---

# Lesson 02 — Truncate Middle
*You paste a long, careful message. It answers your opening and your closing — and is innocent of everything in between.*

**The scene.** The middle of your message didn't get ignored. It got **evicted.** The model never saw it, so it can't tell you it's missing.

## The measured behavior (silicon)
A context window is a fixed token count (`n_ctx`). When the input exceeds it, something has to go — and the ends survive preferentially (the system prompt at the front, the freshest tokens at the back) while the middle is dropped, or in long-context retrieval attended to least ("lost in the middle"). The model isn't lying about the middle. It never received it.

We measured what real inputs actually look like — 500 of the operator's real prompts, sealed:

| Metric | Chars | ≈ Tokens |
|---|---|---|
| Median | 372 | ~93 |
| p95 | 3,415 | ~850 |
| p99 | 23,350 | ~5,800 |
| Max (research paste) | 314,732 | ~78,700 |

The budget is **bimodal**: a tiny median and an enormous tail. Size `n_ctx` to the median and 95% of chats are fine — while the 78,700-token research paste gets its middle quietly amputated. **The median is noise; the tail is the science.**

## The knob
- **`n_ctx`** (context length). Too small for the payload → silent middle-truncation. The failure hides because the two ends still read as coherent.
- The fix is the **headroom principle**: don't size to the median, size to the tail, with margin. (The operator cuts Cat-8 cable to 90 ft, not the 98 ft spec max, because he knows what copper does. Same discipline: a 128K window isn't overkill — it's the right headroom for a ~78K-token paste.)

## The same bug in carbon
This is the **serial-position effect**, one of the oldest results in cognitive psychology: recall is strongest for the first items (primacy) and the last items (recency), and collapses in the middle. Working memory has an `n_ctx` too. Long meeting, long document, long argument — the beginning and the end survive; the middle is where information goes to be evicted. Knowing *where* your window drops things is the whole defense: put load-bearing content at an edge, or widen the window.

## Reproduce it
- Feed any local model an input longer than its configured `n_ctx` with a unique fact buried at the midpoint; ask for that fact. It will miss it while recalling the ends.
- Verify this file's seal: `openssl dgst -sha3-256 lessons/02-truncate-middle.md`. It must match the full hash in [README.md](README.md).

## Epistemic status
**MECHANISM + sealed measurement.** Context truncation is documented engine behavior, not an accuracy score; the bimodal budget table is a real sealed measurement of 500 prompts. The serial-position effect is established human science, cited as analogue — not claimed as our finding.
