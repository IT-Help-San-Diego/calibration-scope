# Star-Centric Transport — audit + synthesis with Carrier Color
_Claude Science, 2026-07-26. Two parallel tracks: DOI integrity of the 3 literature corpora, and a faithful_
_claim-extraction from v3 PDF + evaluation + Erdos anchor + DNS Tool doc. Plus an independent simulation of the_
_"lying progress bar" premise. Full detail: sct_corpus_verification.md, sct_claim_extraction.md._

## 0. BOTTOM LINE
The **core idea is sound and the Carrier Color connection is real and load-bearing** (§4 below). The **corpus is
clean** (98.9% DOI resolution). But the **released v3 PDF has defects that must be fixed before any further SSRN
action** (§2), and the overstatement pattern is concentrated in exactly one place: **abstracts and executive
summaries, not limitation sections** (§3). That last pattern is this project's own thesis — stated vs actual —
appearing in the author's own paper.

## 1. CORPUS: CLEAN (and the evaluation's own counts are accurate)
- **179 DOIs, 177 resolve = 98.9%** (Wilson 95% CI [96.0, 99.7]). Entire population resolved, not a sample.
- Of the 2 failures: **1 is a mis-transcribed DOI for a real paper** (`10.1109/ICCI.2004.30` -> the paper exists at
  `10.1109/coginf.2004.1327460`, verified HTTP 200, title match). **1 is genuinely unresolvable.** So
  fabricated-looking = **1 in 179 (0.56%)**.
- **The earlier Crossref-only trap did NOT recur:** 21 DOIs (11.7%) are DataCite-registered (arXiv 5/5, Zenodo 7/7).
  A Crossref-only check would have reported ~87% and falsely flagged all 21. Method matters.
- **The evaluation's stated corpus sizes — 73 / 91 / 97 papers — are EXACTLY reproducible and traceable.** Credit
  where due: those numbers are honest. (My own task brief had 385/452/430; those were LINE counts inflated by
  embedded newlines in the quoted Relevance field. My error, not the corpus's.)

## 2. CRITICAL — the released v3 PDF does not contain its own formal model
Verified by glyph count across the full 21-page text layer AND by visually rendering pp. 5/14/15:
**tau = 0 occurrences. <= = 0 occurrences. c-hat = 0 occurrences.** The pages print
`[ |_{i,j} - c_i| ]` — **no relational operator, no tolerance symbol, no hat on the reconstructed center.**
So §7.2, which announces a necessary-and-sufficient condition ("verified **if and only if**"), states nothing.
The intended form survives only in the evaluation markdown.
**This is a production/LaTeX-rendering defect, not a substantive error — but it is disqualifying for a paper whose
Abstract advertises "formal foundations."** A reviewer opening the PDF finds the central inequality missing.
**FIX FIRST, before any SSRN submission proceeds.** Then re-seal and re-hash the package.

Two more that a reviewer will catch:
- **Abstract contradicts the body on the Erdos result.** Abstract: "125-page proof **of** the Erdos unit-distance
  conjecture." Body §2 (correct): the system "**disproved** an 80-year-old conjecture." A proof and a refutation are
  opposite results. Also: the Nature source calls the 125 pages the *reasoning*, not the proof; §2.2 gets this right
  but the Abstract does not.
- **Claim exceeds citation.** §2 names Daniel Litt AND Tony Feng as having "verified the proof manually [1]." The
  cited Nature article describes **only Litt** as a verifier; Feng appears solely as a commentator reacting on X.
  Drop Feng or re-source.

## 3. THE OVERSTATEMENT PATTERN — and it is the project's own thesis, self-applied
The extraction catalogued 10 overstatements. They are **not randomly distributed**: they cluster in the Abstract,
§§4-6, and the evaluation's Executive Summary/§9. **The limitation sections are candid and accurate.** A reader of
§8/§9 alone gets a true picture. The three that matter most:

1. **"The DNS Tool implementation PROVES this architecture is deployable, not theoretical"** (§4.5), and
   "a deployed proof-of-concept" (Abstract). **DNS Tool does not implement the core rule.** Exhaustive search of
   `dnstool_approach.md`: **0 occurrences** of "star-centric", "recoverable center", "chunk", "forward progress",
   "advance", "transport". What IS deployed — ICAE, ICuAE, EWMA drift, chain of custody, 5-perspective review — is
   real, documented, with test-case counts and a public validation matrix. But it scores *confidence and currency of
   findings about DNS records*; it does not **gate forward progress of chunks on center reconstruction**, which is
   the entire content of the core rule. The mapping is post-hoc and same-author. Honest version: "DNS Tool deploys
   the verification PRINCIPLE (record present != record trustworthy) and supplies the confidence/currency/drift
   machinery SCT would need — it does not implement the chunk-advance rule."
2. **"Strongly supported by empirical HCI research."** The evaluation concedes in §2.3 that "the HCI literature does
   not address... the underlying system architecture," and §8.2 lists the UX question as OPEN — then §9 recruits that
   same literature as one of three bodies of evidence by which the proposal is "strongly supported." The HCI work
   supports **the problem**, not **the solution**. Also: v3's Acknowledgments claim HCI grounding while v3's
   reference list contains **zero** HCI citations (the HCI base exists only in the evaluation).
3. **A real math error in the V4 algebra.** §5.1 states the axiom: V4 is "the unique abelian group of order 4 where
   **every non-identity element is its own inverse**." §5.2 then illustrates compositionality with "two UNKNOWN
   chunks remain UNKNOWN." If UNKNOWN = r and r∘r = e, **two UNKNOWNs compose to KNOWN, not UNKNOWN.** The example
   contradicts the axiom one page earlier. And the second half ("an UNKNOWN chunk verified becomes KNOWN") treats
   verification as an external operator, not a group element — so the claimed compositionality isn't demonstrated
   by the example given. Fixable, but it must be fixed: it's the load-bearing claim for "formal algebraic foundation."
   (Related: Owl Semaphore's own v3 release notes list "no empirical validation yet" as a normative limitation — so
   an unvalidated justification is being inherited as a "formal algebraic foundation.")

**What the documents get RIGHT, recorded for symmetry:** v3 §9.2 names the central definitional gap as "an open
research problem" and adds "Naming this honestly makes the proposal stronger, not weaker." §9.3: "a multi-year
research program." §8 is five explicit disclaimers. The evaluation §8.1: "currently a conceptual proposal, not a
formal specification." That is the author's own standard, met.

## 4. THE CARRIER COLOR CONNECTION IS REAL — and it is the strongest thing here
This is not a stretch, it is **already in the notation**. SCT's minimal model:

    x_i = f(c_i, k_i)     where k_i = "contextual distortion, contamination, or CARRIER EFFECTS"

**k_i IS the carrier term.** Carrier Color is the empirical program that measures k_i; SCT is the transport rule that
decides what to do when k_i has pushed a chunk off center. They are two halves of one construct:
- **Carrier Color** (measured, this project): identical logical content + different carrier -> different verdict.
  That is a direct empirical demonstration that **k_i is non-negligible in practice.**
- **SCT** (proposed): a chunk advances only if the center is recoverable despite k_i.
So Carrier Color supplies the **empirical warrant** SCT's §8.2 says it lacks, for one specific k_i (linguistic
carrier). That is a genuine, defensible bridge — and it is the one place where the two bodies of work make each
other stronger rather than merely rhyming.
**Concrete next step it implies:** the channel experiment already estimated a bound on carrier effect (no detectable
difference, bounded ~+/-5 pts). That bound IS an empirical estimate of a tolerance band tau for one channel/carrier
pair. It is the first measured tau in the whole SCT program. Worth saying explicitly.

## 5. INDEPENDENT CORROBORATION of the "lying progress bar" premise (my simulation)
I simulated the mechanism rather than take it on faith. Result: **the premise is right, the usual explanation is not.**
- **Variance alone does NOT produce the effect.** With randomly varying item costs, naive extrapolation error decays
  smoothly as 1/sqrt(n): 14% at 5% done, 9% at 10%, 3% at 50%. Noisy early, no halfway cliff.
- **Non-stationarity DOES, decisively.** If late work is heavier (finalize/index/flush/verify — how real installs
  behave), the estimator is not noisy but **BIASED**, and biased in one direction the entire way:
  -68% at 5% done, -54% at 25%, **-36% at halfway**, -18% at 75%, -4% at 95%. Negative = **over-promises**.
- **So the bar does not "lie until halfway then tell the truth." It lies in the SAME direction the whole way**, and
  halfway is merely where the lie shrinks below the annoyance threshold. Root cause: **the estimator assumes the
  middle looks like the beginning.** It does not track the middle — it *assumes* it.
This is an independent, quantitative statement of the gap SCT targets ("data present != data trustworthy"), and it
supports the design goal without touching the unproven mechanism. It also happens to be the truncate-middle
complaint appearing in a third domain (context windows, benchmark summaries, now ETA estimators).
**Caveat:** this is a simulation of estimator behaviour under an assumed cost profile, NOT a measurement of real
installers. It shows the mechanism is sufficient to produce the effect; it does not prove real bars fail this way.

## 6. RECOMMENDED ORDER OF WORK
1. **Fix the v3 PDF rendering** (tau, <=, c-hat missing) — blocking for SSRN. Re-seal after.
2. **Fix Abstract/body contradiction** (proof of vs disproved) and **drop or re-source the Feng verification claim**.
3. **Fix the V4 compositionality example** (r∘r = e) or restate what compositionality means here.
4. **Downgrade the three overstatements** in §3 above to what the sources support. The limitation sections already
   say the right thing — make the Abstract and Executive Summary agree with them. This is the same last-mile fix as
   the carrier-immunity caption cleanup: the honest version is already written elsewhere in the same document.
5. **Then the real scientific move:** state Carrier Color as the empirical arm measuring k_i, and the channel
   experiment's bound as the first measured tau. That converts SCT from "conceptual proposal" toward "proposal with
   one measured term" — which is exactly what §8.2 asks for.
