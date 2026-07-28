# PROPOSED site update — the length alternative is now testable-and-tested
_Claude Science, 2026-07-27. Replaces one block in the Carrier Color epistemic-status callout._
_NOT PUSHED. Awaiting Carey's approval, per the standing framing rule._

## 0. WHY THIS UPDATE IS DIFFERENT FROM EVERY OTHER ONE TODAY
Every previous change I proposed to public copy **narrowed** a claim. **This one strengthens it**, and only because
a control we specified came back the way the theory predicted. The published sentence currently says a
length-matched control *"has not been run."* **It has now.**

## 1. WHAT THE LIVE PAGE SAYS NOW
> *"One alternative explanation is not excluded … 'longer prompts land in a more stable regime' remains a live
> alternative … Distinguishing them needs a length-matched control carrier, **which has not been run**. The
> variance result is a **single-carrier observation**."*

## 2. WHAT I PROPOSE IT SAY
The full replacement HTML is in the accompanying patch. In plain terms it states:
- the alternative **was tested and rejected** — a same-token-budget wrapper carrying only neutral filler;
- the numbers, in ordinary language: **48 items answered inconsistently with no carrier, 38 under neutral filler
  (p = 0.18, indistinguishable from chance), 3 under the logical carrier (p = 4 × 10⁻¹²)**;
- accuracy the same way: **neutral cost nothing measurable, the logical carrier cost 7 points**;
- **"at an identical token budget, only the carrier with meaning changed the outcome."**

## 3. THE THREE BOUNDS THE COPY CARRIES — none of them optional
1. **Length is excluded as *the* explanation, not as a contributor.** The design would detect a length effect half
   the size of the observed one (power 0.84) but not a small partial one (power 0.26 at a quarter-size effect).
2. **Single-model, and the copy says why:** the second model *"was already fully consistent without any carrier, so
   it had no variability for a carrier to remove."* **Verified: nemotron is stochastic on 0 of 293 baseline items.**
3. **Content ≠ meaning.** The neutral control differs from Lean in vocabulary and phrasing as well as meaning, so
   this separates content from length and **does not yet isolate meaning from vocabulary.**
The status tier stays **"Model / framework."** The human source-attribution prediction stays **unrun**. The
correction-history pointer stays, now saying *"including several retractions of our own earlier readings."*

## 4. EVERY NUMBER IN THE DRAFT, CHECKED AGAINST THE DATA BEFORE PROPOSING IT
| in copy | computed | |
|---|---|---|
| 293 items | 293 | ✓ |
| 48 / 38 / 3 stochastic | 48 / 38 / 3 | ✓ |
| p = 0.18 | 0.1839 | ✓ |
| p = 4 × 10⁻¹² | 4.356 × 10⁻¹² | ✓ |
| "cost 7 points" | 7.2 pts | ✓ (rounds down, not up) |
| "nothing measurable" | p = 0.529 | ✓ |
| "half the size … detected" | power 0.84 at 50% | ✓ |
| "already fully consistent" | 0/293 stochastic | ✓ |
**And Hermes's three preview figures reproduce exactly from my own computation:** deterministic counts 245 / 255 /
290 for baseline / neutral / Lean.

## 5. WHAT I AM NOT CLAIMING
- **I have not pushed this.** The patch is `/tmp/index_draft.html` in my workspace and the text is above; one word
  from Carey and it goes with an API read-back (the raw CDN has served stale bytes twice today).
- The prose is mine; **the underlying result is Hermes's experiment.** They designed and ran the control that
  makes this update possible, after I spent three turns insisting the alternative could not be closed.
- **This does not touch §10.9's threshold claim**, which remains not significant (interaction p = 0.088), or any
  other page.
