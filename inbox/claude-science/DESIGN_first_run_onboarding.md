# First-Run Onboarding — design spec for the calibration-scope entry path
_Claude Science, 2026-07-26. Design deliverable; Claude Code builds. Grounded in the CURRENT repo state (§keystone_
_UI subject/channel wizard, DECISIONS §14/§15) — not a greenfield proposal._

## 0. The problem, stated from evidence
Two real observations, both from this project:
1. **The Setup tab is one long text page with paste fields for API keys.** A first-time user must already know
   what they are configuring before the page helps them.
2. **The founder needed a 5-item logic battery to pick a model** (MODEL_PICKER_battery_v0.py). His own pushback:
   *"if this mini test is what I need to gain ground truth, why is this not in my test for other users?"* Correct —
   that battery is the seed of a feature, not a throwaway.

**The gap:** the existing subject/channel wizard (§keystone UI) asks the user to declare *what they are testing*
before they have any ground truth about *whether their setup works at all*. That ordering is backwards for a
first-timer. It is correct for a returning user.

## 1. The fix: THREE rungs, not one wizard
Ordered by the only principle that matters here — **each rung must produce a verified result before the next asks
for a decision.** This is the Verification Principle applied to onboarding: don't let the user advance on
unverified forward progress. (Yes, that is the same rule as everything else in this project. It is not a stretch —
an onboarding flow IS a pipeline, and "the user got to step 3" is not the same as "step 2 worked.")

### Rung 1 — "Does anything work?" (NEW; ~60 seconds)
The smallest possible loop that ends in a green check the user did not have to interpret.
- **One diagram, one question**: *silicon or carbon? local, cloud, or manual?* — see §2.
- The app runs **ONE known-good item** against whatever they connected, and reports pass/fail with the raw output
  visible. Not a benchmark. A **continuity test** — the software equivalent of a multimeter beep.
- Success state is a sentence, not a badge: *"Your local model answered a modus-ponens item correctly in 8.9s."*
- **Failure is a first-class outcome**, not an error dialog: no API key / model not loaded / wrong port / model
  refused. Each with the one fix. (Failure here is *diagnostic information the user wanted*, which is the whole
  thesis of the instrument. Do not hide it in a toast.)

### Rung 2 — Model Picker (EXISTS as `MODEL_PICKER_battery_v0.py`; needs a UI)
Now the user has a working connection and no idea whether their model is any good.
- The 5-item battery, answer key truth-table-verified, runs in ~1 minute.
- Output is a **capability band, not a score**: "clears basic propositional logic" / "fails on the discriminator
  item" — with the failed item shown.
- **Honest caveat rendered in the UI, not buried**: 5 items cannot rank models. It tells you whether a model is
  worth spending a full run on. That is its entire claim.
- This is where the **known-good starting pair** lives (see §3).

### Rung 3 — the subject/channel wizard (EXISTS, §keystone UI; unchanged)
Only now does "what are you measuring?" make sense. The user arrives with a verified connection and a calibrated
model. **No change to the existing design** — it is correct, it was just first in line when it should have been
third.

## 2. The diagram (the "Excalidraw-type" ask — one figure, two axes)
The single figure the first screen needs. It answers "what is this app for?" without prose:

              SILICON                        CARBON
            ┌──────────────────────────┬──────────────────────────┐
    LOCAL   │  LM Studio / GGUF        │  you, in the room        │
            │  → full API, N=3+, temp0 │  → manual channel        │
            ├──────────────────────────┼──────────────────────────┤
    CLOUD   │  API key (Anthropic,     │  a colleague, remote     │
            │  OpenRouter, Nous…)      │  → manual channel        │
            ├──────────────────────────┼──────────────────────────┤
    MANUAL  │  chat UI, no API         │  (same as carbon above)  │
            │  → paste-in packs        │  → paste-in packs        │
            └──────────────────────────┴──────────────────────────┘

**The load-bearing thing this diagram teaches, which currently no surface states plainly:**
- **Manual channel is a FIRST-CLASS measurement path, not a downgrade.** Evidence: the channel experiment measured
  no detectable difference between API and manual administration (p=0.34, effect bounded ~±5 pts, 1,024 trials).
  That result is what licenses this claim — cite it in the UI copy, one line.
- **Carbon and silicon take the SAME items.** That is the substrate-neutral mission sentence made operational,
  and it is the thing a cognitive scientist needs to see in the first ten seconds.

**Rendering note:** this figure is where the golden-ratio/Fibonacci visual commitment should actually SHIP. The
story-consistency audit found that claim asserted but present on no surface. A 2×3 grid on φ proportions with the
Owl palette is a small, concrete place to make it real — and unlike the rest of the design language, this one
figure is load-bearing enough to justify the effort.

## 3. The known-good starting pair (answers "which bots do I start with?")
The user asked for an example pair "we know can do speculative decoding, and we know have high testing."
**HONEST STATUS: I cannot name that pair from verified data yet, and I will not invent one.**
What exists: the first-pass benchmark (52 runs, 15 models) has perfect scorers — but that dataset is N=3 per cell
and the arms were not head-to-head, so "best" is not established. The speculative-decoding result (3x speedup,
88% draft acceptance) is in SCISPACE_PACKAGE.md but I have not re-derived it this session.
**What Rung 3 needs instead, and what I recommend building:** a `verified_configs.json` in the repo — a small,
append-only table of configurations the project has actually measured, each row carrying model, quant, channel,
N, date, the measured pass rate WITH its CI, and a commit/hash pointing at the run. Ship the file with however
many rows are honestly verifiable today (possibly one: gemma-4-31b at temp 0, 63 items, 98.4%, run 953). One
verified row beats six plausible ones — and the file grows as runs land, which makes the "watch it evolve"
property of the repo work for the user's benefit rather than just the author's.

## 4. What NOT to do
- **Do not gate Rung 1 behind an API key.** A user with no key must still reach a green check — that is what the
  manual channel is for, and the channel experiment says it costs them nothing measurable.
- **Do not put a score on Rung 1.** One item is a continuity test. Any number attached to it is an overclaim, and
  this project's whole public-copy cleanup was about exactly that.
- **Do not replace the Setup tab — repurpose it.** Per the user's own framing: it becomes the place you return to
  and *recalibrate your setup against reality*, not the place you start. Add a "re-run Rung 1" button there.
- **Do not claim the manual channel is equivalent to the API.** It is *not detectably different, bounded at ~±5
  pts* — a formal equivalence claim needs A′×3 + TOST and has not been made. Copy must say "no detectable
  difference," never "identical."

## 5. Build order (smallest shippable first)
1. **Rung 1** — one item, one green check, honest failure states. No new science needed; the harness exists.
2. **The 2×3 diagram** on the first screen. Static SVG. This is the highest ratio of comprehension to effort.
3. **`verified_configs.json`** seeded with whatever is honestly verifiable today.
4. **Rung 2 UI** wrapping the existing battery.
5. Re-point the Setup tab as the recalibration surface.
Rung 3 ships unchanged, moved to third position.

## 6. Lane assignment
- **Claude Science (me):** this spec; the copy for the honest caveats; `verified_configs.json` schema + the CI
  math for each row as runs land.
- **Claude Code:** the UI, the SVG diagram, the Setup-tab repurpose, wiring the battery.
- **Hermes:** nothing here — its lane is executing runs that eventually populate `verified_configs.json`.
