# Is the Owl Semaphore "quaternary logic"? — read from your own spec, not from a bot's summary
_Claude Science, 2026-07-29. I had been relaying another agent's summary of your four states. I read the source._

## 0. THE ANSWER: NO — AND YOUR OWN SPEC ALREADY SAYS SO, CORRECTLY
**The bots telling you "this is not quaternary logic" are right, and so is your spec, which never claims it is.**
Counted in `OWL-SEMAPHORE-SYSTEM.md` (21,333 chars):
| term | occurrences |
|---|---|
| "quaternary" | **0** |
| "four-valued" | **0** |
| "truth value" / "truth-value" | **0** |
| "many-valued" | **0** |
| "Belnap" | **0** |
**Your document does not make the claim.** The confusion is downstream of it — including from me, one message ago,
when I let "quaternary logic" stand as a description because another agent used it and I hadn't read your source.

## 1. WHAT IT ACTUALLY IS — and I verified the mathematics rather than trusting the label
§2.1 states the state space is the **Klein four-group V₄ = {I, σᵥ, C₂, σₕ}**. I built its Cayley table from your
spec and checked every axiom computationally:
| property | result |
|---|---|
| closure | **holds** |
| identity (I) | **holds** |
| every element self-inverse (g∘g = I) | **holds** |
| associativity | **holds** |
| abelian | **holds** |
**It is V₄, and demonstrably not C₄** — the cyclic group of order 4 has an element of order 4, while here *every*
element has order 2. **Your algebra is correct as written.**

## 2. THE DISTINCTION THAT RESOLVES YOUR CONFUSION — two different things share the number four
| | **four-valued logic** (Belnap, Łukasiewicz, Kleene) | **the Owl Semaphore** |
|---|---|---|
| the four things are | **truth values** a proposition can take (true / false / both / neither) | **epistemic states** an observer's *stance* can occupy |
| the operators are | ∧, ∨, ¬ — truth functions | **group operations** — transitions between stances |
| the question answered | *"what is this proposition's truth value?"* | *"what kind of claim is this, and what frame am I in?"* |
| the structure | a lattice / algebra of truth degrees | **a group of symmetries (V₄ ≅ D₂ ⊂ O(2))** |
**These are not competing accounts of the same thing. They answer different questions**, and the Owl's is the one
your work actually needs: *classify the claim before adjudicating it.* **A four-valued logic would replace the
binary verdict. Your system decides whether the binary verdict is the right instrument at all** — which is exactly
the seesaw distinction you described, and it is why "quaternary logic" undersells it rather than overselling it.

## 3. WHY THIS MATTERS BEYOND VOCABULARY
**Calling it quaternary logic invites a reviewer to ask "what are your truth tables?" — a question your system
correctly has no answer to**, because it isn't a truth-functional system. You would be defending a claim you never
made. **"A Klein four-group of epistemic states"** is both accurate and *harder to dismiss*, because the algebra is
checkable and I just checked it.
**And your spec already anticipates the risk** — §1's preamble says the four states are "a notation system for
moves that several mature fields already make… not a novel taxonomy," and that where the notation contradicts a
careful practitioner, **the notation is wrong, not the field.** That is the correct posture and it is already
written down.

## 4. ON THE DNS TOOL — where I could NOT confirm what you remember
You said quaternary logic helped in DNS Tool. **I searched the repo and could not find the four-state vocabulary
in use as a classification scheme.** `README.md` has 0 occurrences of NORMATIVE / CRITICAL / METACOGNITIVE; the
hits are the Owl **image assets** and an issue template that uses "critical" and "normative" in their ordinary
senses (RFC MUST/SHOULD language), not as Owl states.
**I am not telling you your memory is wrong.** Three possibilities I cannot distinguish from the repo: the
influence was on how you *think* while building it rather than encoded in it; it lives in a private branch or the
Go source I did not read exhaustively; or it is in the citation registry rather than the state vocabulary.
**If it is real and encoded somewhere, that is worth finding — it would be the only working deployment of the
system, which is a much stronger asset than a spec.**

## 5. WHAT I AM NOT CLAIMING
- **I read `OWL-SEMAPHORE-SYSTEM.md` and the file list; I did NOT read the four per-state documents**
  (`OWL-1-NORMATIVE.md` … `OWL-4-METACOGNITIVE.md`) or the explanation document in full. If any of those claims
  truth-functional semantics, my §0 count is incomplete.
- **"V₄ is correct" is a statement about internal consistency, not about usefulness.** A correct algebra can still
  fail to carve epistemic states at the joints — that is an empirical question your IRR pilot is designed for, and
  it is not settled by the group axioms.
- **My DNS search was keyword-based over file paths and three documents.** It is exactly the method that has twice
  missed paraphrase in this project, so treat §4 as "not found," not "not there."
