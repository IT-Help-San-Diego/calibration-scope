# Tango is Clever Hans, and it breaks a different thing than the dog did
_Claude Science, 2026-07-29. Carey's second red-team: a trained dog "answers" roof / rough._

## This has a name and a date

**Clever Hans, Pfungst 1907.** A horse appeared to do arithmetic; it was reading involuntary
cues from whoever asked. It is the founding case of experimenter expectancy and the reason
double-blind protocols exist at all. **Carey reinvented it as an attack on our instrument, which
is the correct instinct — it is the single most durable way to fake a positive result in animal
cognition, and it has a 119-year head start on us.**

## It is the INVERSE of the dog case, not a variant

| case | signal | our decoder | what lands in the record |
|---|---|---|---|
| **dog** (previous red-team) | emitted (nonverbal) | **failed** | nothing — a false NEGATIVE |
| **Tango** | emitted (a bark) | **hallucinated** | `CORRECT` — a false POSITIVE |

**The dog costs us a subject. Tango costs us the instrument.** A false negative looks like a bad
subject and invites a re-test. A false positive looks like a *discovery* — and this project's
whole product is verdicts other people are supposed to trust. **Manufacturing a pass is the worse
failure by a wide margin.**

Note what Tango does *not* require: no fraud, no bad faith. The handler asks, hears a bark,
and maps it onto the answer they were listening for. **The grader's expectation is the whole
mechanism.** Carey's own framing gives it away — *"Holy shit! Correct answer number two"* — the
answer was scored by the person who knew what it should be.

## What the repo actually has — and the hole is bigger than the dog's

**What "blind" means here today:** the site says *"Blind tests, machine-verified ground truth."*
Reading the battery, that means **the SUBJECT does not see the key**. That is real, and it is
orthogonal to Clever Hans — a blinded subject can still be cued by an unblinded grader.

**The `participants` table** (migration 043) is: `id, kind, display_name, notes, created_at`.

- **No scorer field.** The schema does not record *who graded a human run*.
- **No scorer blinding.** For any hand-administered run, the administrator IS the grader.
- **No free-text transcript column.** Nothing preserves what the subject actually emitted, so
  the grader's interpretation is the only surviving record — unauditable after the fact.

**So Tango passes.** Not because anyone cheated, but because the instrument has no mechanism that
could catch it. And that is a gap between what the site states — *blind tests* — and what is
actually true of the human path.

## Siri: yes, run it, and it is a genuinely good test — for a reason other than the joke

Carey wants Siri in the battery expecting it to fail badly. **It belongs there, but the
interesting part is not whether it flunks.** Siri is the first proposed subject that is
*addressable* (real interface), *decodable* (speech → text), and **in-domain** (it accepts
arbitrary questions) — so it passes all three preconditions the rock, dog and calculator each
failed, while being **architecturally unlike** every current subject: a routing layer over
multiple backends, with fallbacks, that can silently substitute a web search for reasoning.

**That makes it the sharpest available test of a claim we already make.** The mission sentence
says *any substrate*. Siri is the case where the substrate is a **pipeline**, not a model — and
`is_infra_error` cannot express "the subject answered, but a different component answered than
the one we meant to test."

**One warning, and it is the Tango warning again:** administering Siri by voice, by hand, means a
human decides whether "that counted." **Siri is Tango with a Lightning port** unless the
transcript is captured verbatim and graded by someone who does not know the key.

## Recommendation

1. **CS-042** — record the scorer, and blind them. `participants` needs a `scored_by` and the
   grader must not be the administrator for hand-run trials. Cheap, schema-only.
2. **CS-043** — capture a **verbatim response transcript** for hand-administered trials, so a
   grader's interpretation is auditable rather than authoritative. This is also what makes a
   Tango-class result *re-gradable by a stranger*, which is the actual standard.
3. **CS-044** — Siri as a subject, gated behind 1 and 2, because running it before them produces
   exactly the result Carey is joking about and no way to defend it.
4. **The comic Carey wants should be the DOG, not Tango** — "the decoder failed" is the teachable
   moment. Tango is the darker lesson and belongs in the methods section, not the punchline:
   *the instrument can be fooled by a friendly handler who is not lying.*

## What I have NOT established

- I have not run anything against Siri, a dog, or a human. Every claim above is read from
  migration 043, the site copy, and the battery definition.
- **I did not verify how a human run is graded in the UI** — only that the schema has no scorer
  or transcript column. There may be a UI-level flow that partially covers this; if so, it is
  undocumented in the schema, which is its own defect.
- Clever Hans is my identification of the mechanism, not Carey's claim. He described the setup;
  the attribution to experimenter expectancy is mine.
