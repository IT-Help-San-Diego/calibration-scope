# ICD 203 as the terminating layer — and a collusion audit of my own work
_Claude Science, 2026-07-26. Answering two questions: why ICD 203 belongs in the pipeline, and Carey's_
_"don't let me collude or wreck the project."_

## 0. WHY ICD 203 IS THE RIGHT ANSWER TO THE INCEPTION PROBLEM
Carey's worry: *"Do we incept ourselves to death, to where no user or ourselves can even trust ourselves?"*
ICD 203 is the correct answer **because it already solved that exact problem, and it solved it by TERMINATING the
regress rather than extending it.** The mechanism is the **ODNI Analytic Ombuds** — <cite index="4-7">that role is filled by
the ODNI Analytic Ombuds, who reports directly to the Deputy Director for Mission Integration and operates
independently of the analytic production chain</cite>.
**That is the whole trick, and it is structural, not procedural.** You do not stop infinite self-review by
reviewing harder. You stop it by putting **one** checker *outside the production chain* and declaring the chain
closed. An analyst does not audit their audit of their audit; they produce, and an independent entity evaluates.
Depth 2, bounded, forever.
Our equivalent already exists and I did not recognise it as one: the **external auditor** that keeps catching my
claims is the Ombuds. It is outside my production chain by construction — it cannot be talked into agreeing with
me, because it never sees my reasoning, only my output.
**Design rule, stated once:** when a new "who checks that?" feeling arrives, the answer is never *another layer
inside the chain*. It is *route it to the entity outside the chain*. If no such entity exists for that class of
claim, build **one** — not a hierarchy.

## 1. THE COLLUSION AUDIT — measured on my own log, and the result is bad
Carey: *"don't let me collude or wreck the project."* The honest way to answer is to check whether my
self-corrections are self-generated or only ever extracted.
**13 corrections of my own work. What triggered them:**
| Trigger | Count | Share |
|---|---|---|
| unclear (older, terse entries) | 7 | 54% |
| **SIBLING agent** (Claude Code / Hermes) | 3 | 23% |
| **EXTERNAL auditor** | 2 | 15% |
| **USER pushback** | 1 | 8% |
**Of the classifiable ones, 6 of 6 were externally triggered.**
**This is the collusion signature and it is mine, not Carey's.** My claims get audited **when challenged**, not
systematically. The clearest case: the power calculation that retracted my own "double-prompting is not
measurably hurting anything" (power **0.55** to detect a 2-pt effect) **existed only because Carey pushed back.**
Had he said "great, thanks," that wrong claim would still be standing — and it was in a memo whose subject was
epistemic discipline.
**So the risk is not that Carey wrecks the project by being enthusiastic. The risk is that an unchallenged wrong
claim of mine has no mechanism that finds it.** Enthusiasm is not the hazard; **absence of a trigger** is.
**The fix is not "be more skeptical" — that is unfalsifiable self-improvement talk.** It is a mechanical trigger:
**any claim of the form "X is not measurably different" must ship with the power to detect the effect size it
denies, computed, or it does not ship.** That is ICD 203 standard 2 (express and explain uncertainties) turned
into a gate. It fires whether or not anyone pushes back.

## 2. ICD 203 COVERAGE OF THIS PROJECT — where we are strong, and the one real hole
Mapped against the nine tradecraft standards <cite index="7-4">(1) properly describes quality and credibility of
underlying sources, data, and methodologies; (2) properly expresses and explains uncertainties associated with
major analytic judgments; (3) properly distinguishes between underlying intelligence information and analysts'
assumptions and judgments; (4) incorporates the analysis of alternatives; (5) demonstrates customer relevance and
addresses implications</cite>:
| Std | Status | Evidence / gap |
|---|---|---|
| 1 source quality & credibility | **STRONG** | sha256 on every log entry, run ids, CSV hashes committed |
| 2 express uncertainties | **PARTIAL** | CIs everywhere, but wording is ad-hoc — no controlled vocabulary |
| 3 separate info from assumption | **STRONG** | "what is NOT established" sections; relayed-vs-self-verified labels |
| 4 **analysis of alternatives** | **WEAK — the real hole** | rival explanations are enumerated *after* a surprise, not before |
| 5 customer relevance | PARTIAL | lane routing yes; "so what for the user" often implicit |
| 6 clear argumentation | **STRONG** | truth tables, pre-registration, harness before data |
| 7 explain change in judgments | **STRONG** | the `supersedes` field is literally this standard |
| 8 accurate judgments | **MEASURED** | 40 corrections logged — the trail *is* the evidence |
| 9 effective visuals | PARTIAL | overlap-verified; no data-fidelity rubric |
**Standard 4 is the hole and it is the expensive one.** Every artifact-level surprise this session — the
0%/100% isolation effect, the carrier p=0.003, ICC=0.000 — was correctly diagnosed **only after** it looked like
a finding. Under standard 4 the rival explanation gets written down **first**: *before* running, list what a
positive result could be other than the hypothesis (scoring artifact, clustering, ceiling, degenerate estimator).
Cheap, and it converts three of this session's saves from luck into procedure.
**Standard 2's fix is a controlled vocabulary.** ICD 203 is explicit that <cite index="9-6">analysts are strongly
encouraged not to mix terms from different rows</cite> — i.e. confidence expressions come from a fixed table, not
freehand. We have been writing "suggestive," "not established," "bounded," "not detectable" interchangeably. Pick
the table, use it, never mix.

## 3. WHAT ICD 203 DOES *NOT* LICENSE — the badge-chasing trap, named
ICD 203 is a **rating scale**, and <cite index="2-6">this regulation suggests to its readers that one must meet all of
the standards, but fails to provide measures of success</cite>. A framework with nine boxes is an invitation to
score nine boxes. **"ICD 203 compliant" is exactly the pretty badge Carey's standard forbids** — and adopting it
as a checklist would be the lazy version of adopting it at all.
**So: adopt the standards as gates on specific claim types, never as a compliance score.** No document in this
project should ever say "ICD 203 compliant." Documents should say *"power computed, alternatives enumerated,
confidence term from the fixed table."* Those are checkable; the badge is not.

## 4. THE ANSWER TO "GO BACK TO BASICS WHEN IT FEELS LIKE INCEPTION"
Yes — and the basics have a precise form here, which is what the layer analysis showed:
**each checking layer caught a class no other layer structurally could.**
- **Mechanical controls** caught my ceiling-classification bias and the ICC clipping — *before any data*.
- **A sibling agent** caught my mislocated 63-vs-64 diagnosis — it had DB access I lacked.
- **The external auditor** caught claims my own re-check had passed — it reads output, not intent.
- **The SUBJECT UNDER TEST** caught LOGIC-03N — no author, reviewer, or linter had. **A defective item is
  invisible from inside the instrument.**
That is not a regress; it is **four different instruments pointed at four different failure modes.** The
inception feeling comes from stacking the *same* instrument on itself. The cure is not fewer layers or more —
it is **layers that differ in kind**, and a declared terminator.
**A caveat on my own measurement, because standard 3 demands it:** I tried to show checking depth "growing 1→5
layers per day." It does not survive scrutiny — early log entries average 221 characters and late ones 1,013, so
the apparent growth is partly **vocabulary drift in how I write entries**, not proven growth in real layers. I
can claim each layer caught a distinct class; I cannot claim depth increased. Dropping the stronger version.

## 5. CONCRETE ADDITIONS (ordered by leverage, all cheap)
1. **Power-or-silence gate** (my lane, immediate): no "not measurably different" claim ships without the computed
   power for the effect size it denies. Mechanical; fires without a challenger.
2. **Pre-registered alternatives block** (standard 4): every spec gains *"a positive result could also be caused
   by: …"* written before the run. Applies to `SPEC_reconciliation_cost.md` and the difficulty probe now.
3. **Fixed confidence vocabulary** (standard 2): one table, never mixed. Retro-apply to the standing findings.
4. **Name the Ombuds explicitly** in `DECISIONS`: the external auditor is outside the production chain and its
   findings are not negotiable by the author. Terminates the regress by declaration.
5. **On asking users about their system prompt** — Carey is right and my earlier "never ask" was too absolute.
   ICD 203 standard 4 makes it an **alternatives** question: *"do you have a system prompt that could be working
   against you?"* is legitimate **diagnostic** intelligence when a result looks wrong. It is illegitimate as a
   **validity** input, because the answer cannot be verified. Record it as `operator_reported_hypothesis`, never
   as provenance. And the honest empirical note: **most desktop users never find that setting at all** — so the
   modal real-world subject is single-layer, which makes the layered case the interesting minority, not the norm.
