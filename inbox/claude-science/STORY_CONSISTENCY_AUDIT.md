# Story Consistency & Audience-Mesh Audit — calibration-scope public surfaces
_Claude Science, 2026-07-24. Once-over per Carey: is the story coherent across all readers, from Aristotle_
_(logic) through Fibonacci (golden ratio) through the science — without breaking science, storytelling, or reality?_
_Surfaces read: README (fresh), site copy, DECISIONS §15 (Measure/Reveal/Witness + OSCENT + mission sentence), owl-semaphore README._

## VERDICT: the story is strong and largely coherent — but there is ONE real inconsistency and two gaps.

## FINDING 1 (the main one) — the surfaces still lead with the OLD framing, not the mission sentence
§15 mandates a single voice: **"Calibration Scope measures reasoning — in any subject, on any substrate —
and seals the measurement so anyone can verify it."** And OSCENT = "oscilloscope for intelligence," the
framing chosen specifically to avoid "just a bot tester." BUT:
- README opens: *"A benchmarking dashboard for LM Studio and cloud LLMs..."* — that IS the "bot tester"
  framing OSCENT was coined to escape. The carbon/human side arrives as *"Then measure yourself"* tacked
  on the end of the tagline, and "silicon and carbon under one instrument" is buried in paragraph 3.
- Site copy opens with *"Get started"* / install commands — utility-first, mission-silent.
- The mission sentence does not appear verbatim as the lead on EITHER surface.
**This is the wording-audit gap §15 itself flagged as live.** The instrument's story has evolved past its
own front door. Fix: lead every surface with the mission sentence; demote "LM Studio dashboard" from
identity to capability ("runs against LM Studio and cloud endpoints" is a HOW, not a WHAT). The substrate-
neutral OSCENT voice should be the first thing every reader meets, then narrow to their use.

## FINDING 2 (audience mesh) — the neuroscientist bounces before reaching the carbon story
The "archetype mesh of who lands here": local-AI hobbyist, AI-safety researcher, the trust-nothing skeptic,
the cognitive scientist. First three are served by the current README top. The COGNITIVE SCIENTIST is NOT:
they meet "benchmark your LM Studio models" and leave before reaching "silicon and carbon," the LOT/PNAS
keystone, or the Cognitive Atlas crosswalk. Given how fast and how VALIDLY the neuroscience slipped in
(PNAS keystone, logic-language separability), the front door should have an explicit thread for them —
one line near the top: *"If you study human reasoning: the same sealed battery measures carbon and silicon
on identical stimulus; see the cognitive-construct crosswalk."* Cheap, and it stops the bounce.

## FINDING 3 (Aristotle + Fibonacci visual grammar) — consistent where it exists, but partly ASSERTED not shown
- **Aristotle (logic layout): CONSISTENT and real.** The site's English -> Lean -> Verified ladder is
  literally premise -> inference -> machine-checked conclusion — Aristotelian logical order as the visual
  spine. owl-semaphore's four epistemic states (NORMATIVE / NON-NORMATIVE / CRITICAL / METACOGNITIVE) are a
  logical algebra (V4 Klein-four), told as story ("four owls tell you what kind of thinking you're looking
  at"). The formal+human sentence pairing in owl-semaphore is the same move as English->Lean here. The
  logic-as-story grammar IS shared across the two repos. Good.
- **Fibonacci / golden ratio: ASSERTED, not yet verifiable.** Golden-ratio layout is claimed for the
  WITNESS artifact (§15) — but that artifact is unbuilt (Claude Code lane), and I found no evidence the
  README/site/dashboard layouts follow phi. RISK: claiming Fibonacci as a design principle while only one
  unbuilt surface uses it breaks the "don't leave reality" rule by asserting a consistency that isn't
  there yet. Fix: either (a) make golden-ratio real across the shipped surfaces before claiming it as an
  identity, or (b) scope the claim honestly to "the Witness artifact uses golden-ratio layout" (one
  surface), not "we are Fibonacci math." Same discipline as the DOI/ID verification: don't assert a
  property you haven't shipped.

## THE THREE RULES CHECK (science / storytelling / reality)
- **Science rules: HELD, with one guard.** The "crosswalk" language IS real science, not a stretch —
  a *crosswalk* is the standard informatics term for a validated mapping between two classification
  systems (it's used exactly this way for ontologies, medical coding, metadata standards). So
  ontology_crosswalk.json mapping test-families -> cognitive constructs is methodologically legitimate
  AND the "help minds/sciences safely cross to the other side" metaphor is the SAME word doing double
  duty — rare and genuinely elegant. GUARD: the LLM<->human logic-separability link (PNAS keystone) is
  OUR analogy, not established science. Public copy must frame it as hypothesis ("what if? let's measure"),
  never as proven — which is exactly Carey's own framing ("Hey guys, let's measure and run some data").
  Keep it interrogative and you don't break the rule.
- **Storytelling rules: HELD.** Measure -> Reveal -> Witness is a clean three-act structure; the owl
  carries identity across both repos; the mission sentence (once it leads) is the through-line. The one
  fix is Finding 1 — the story's told, it's just not on the front door yet.
- **Reality rules: HELD, watch Finding 3.** Every published NUMBER is a sealed run (verified this
  session: corpus 96% real, DOIs re-checkable, hashes match). The only reality risk is asserting the
  Fibonacci/golden-ratio consistency ahead of shipping it.

## CONCRETE FIXES (ordered, all Claude Code / Hermes lane — doc + copy, not science)
1. Lead README + site + dashboard landing with the mission sentence verbatim (closes the §15 wording audit).
2. Demote "LM Studio benchmarking dashboard" from identity to capability; lead with OSCENT / substrate-neutral.
3. Add one cognitive-scientist thread near the top of the README (Finding 2).
4. Scope the golden-ratio claim to what actually ships, or ship it first (Finding 3).
5. Frame the neuro bridge as hypothesis everywhere public ("what if / let's measure"), never as result.

## What is ALREADY consistent and should NOT be touched
The trust-nothing / SHA-seal / N=3 / "no marketing numbers" spine; the silicon<->carbon "one instrument"
thesis; the Carrier Color findings block; the owl as shared identity; the logic-as-story (Aristotelian)
visual order. The bones are right. This is a front-door and honest-scoping pass, not a rebuild.
