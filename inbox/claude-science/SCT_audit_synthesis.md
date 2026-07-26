# Star-Centric Transport — audit + synthesis with Carrier Color
_Claude Science, 2026-07-26. Two parallel tracks: DOI integrity of the 3 literature corpora, and a faithful_
_claim-extraction from v3 PDF + evaluation + Erdos anchor + DNS Tool doc. Plus an independent simulation of the_
_"lying progress bar" premise. Full detail: sct_corpus_verification.md, sct_claim_extraction.md._

## 0. STATUS CORRECTION (2026-07-26, after author input) — READ FIRST
**This audit's original framing was wrong about publication intent, and the error was mine.** The original text
said the v3 PDF defects were "BLOCKING for SSRN — fix before any further SSRN action." **The author has NOT
submitted Star-Centric Transport anywhere.** I inferred an in-flight submission from the presence of a directory
named `ssrn_package/` and a file named `ssrn-submission-form-v3.pdf`. That is reading intent off a filename —
the same failure class this project exists to catch.

**Verified ground truth (checked against live public surfaces, not assumed):**
- **The Belief Machine** is the author's ONLY SSRN publication (abstract 6722059, published 2026-05-12). Confirmed
  in intellectualresistance.com JSON-LD as the sole `ScholarlyArticle`.
- **Star-Centric Transport and Open Epistemic Packet are UNRELEASED ideas in development.** SCT appears in the
  site's structured data only as a topic (`Thing`) — no DOI, no article type, no publication claim.
- **Every public surface already labels SCT honestly as "Proposal"**: intellectualresistance.com card, the site
  README status table, and dns-tool-intel/static/llms.txt ("Star-Centric Transport (status: Proposal)").
- **Complete public exposure inventory — all 11 SCT-bearing files opened and read individually** (an earlier
  version of this list omitted dns-tool-intel entirely and was written after reading only 5 of 11; corrected):
  | Repo | File | SCT mentions | Status label near mention |
  |---|---|---|---|
  | intellectualresistance | README.md | 1 | Proposal |
  | intellectualresistance | index.html | 12 | Proposal |
  | intellectualresistance | llms.txt | 1 | Proposal |
  | intellectualresistance | llms-full.txt | 1 | Proposal |
  | **dns-tool-intel** | static/llms.txt | 1 | "Star-Centric Transport (status: Proposal)" |
  | **dns-tool-intel** | static/llms-full.txt | 1 | "Star-Centric Transport (Proposal)" |
  | **dns-tool-intel** | go-server/static/llms.txt | 1 | "(status: Proposal)" |
  | **dns-tool-intel** | go-server/static/llms-full.txt | 1 | "(Proposal)" |
  | **dns-tool-intel** | go-server/templates/ecosystem.html | 1 | Proposal |
  | star-centric-transport | README.md | 1 | none (26-char stub) |
  | open-epistemic-packet | README.md | 0 | none (25-char stub) |
  So SCT text lives in **THREE** public repos, not two. The word "published" does appear in the four dns-tool-intel
  LLM files, but it refers to the theory **site**, not to SCT: each file also carries an explicit anti-upgrade
  clause — "the framework statuses above are reproduced as published, not upgraded" / "reproduced exactly as
  published; only capabilities this site documents as implemented are claimed as shipped." Checked in context, not
  by keyword. **All 11 files are honest. No public language requires correction.**

**Consequence for everything below:** §2 and §3 are a PRE-FLIGHT CHECKLIST for unreleased drafts, NOT live
publication defects. Nothing below requires urgent action. The two items worth doing anyway are named in §6.

## 0b. BOTTOM LINE
The **core idea is sound and the Carrier Color connection is real and load-bearing** (§4 below). The **corpus is
clean** (98.9% DOI resolution). The **unreleased v3 DRAFT PDF has defects to fix before it is ever distributed**
(§2 — it is NOT distributed today; see §0), and the overstatement pattern is concentrated in exactly one place:
**abstracts and executive summaries, not limitation sections** (§3) — and only in the DRAFT: the PUBLIC status
labels are already correct (§0, verified across all 11 SCT-bearing public files). That last pattern is this project's own thesis — stated vs actual —
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

## 2. PRE-FLIGHT (not urgent) — the v3 DRAFT PDF does not contain its own formal model
Verified by glyph count across the full 21-page text layer AND by visually rendering pp. 5/14/15:
**tau = 0 occurrences. <= = 0 occurrences. c-hat = 0 occurrences.** The pages print
`[ |_{i,j} - c_i| ]` — **no relational operator, no tolerance symbol, no hat on the reconstructed center.**
So §7.2, which announces a necessary-and-sufficient condition ("verified **if and only if**"), states nothing.
The intended form survives only in the evaluation markdown.
**This is a production/LaTeX-rendering defect, not a substantive error — but it is disqualifying for a paper whose
Abstract advertises "formal foundations."** A reviewer opening the PDF finds the central inequality missing.
**Fix before this draft is ever distributed** (it is not distributed today — see §0). Then re-seal and re-hash.

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
**Stated with the correct statistic (a v1 version of this section conflated two different quantities — see note):**
- **Variance alone does NOT bias the estimate.** With randomly varying item costs, the naive extrapolator is
  **UNBIASED**: mean SIGNED bias is ~0 at every completion point (+0.1% at 5% done, -0.2% at 50%, -0.02% at 95%).
  Its mean *absolute* error is large early (14% at 5% done, 9% at 10%, 3% at 50%) and decays as 1/sqrt(n) — that is
  **noise, not lying**: it is equally likely to over- or under-promise, and it converges on the truth.
- **Non-stationarity DOES bias it, decisively.** If late work is heavier (finalize/index/flush/verify — how real
  installs behave), the estimator is **BIASED in one direction the entire way**: -68% at 5% done, -54% at 25%,
  **-36% at halfway**, -18% at 75%, -4% at 95%. Negative = **systematically over-promises**.
- **So the bar does not "lie until halfway then tell the truth." It lies in the SAME direction throughout**, and
  halfway is merely where the lie shrinks below the annoyance threshold. Root cause: **the estimator assumes the
  middle looks like the beginning.** It does not track the middle — it *assumes* it. And note what makes the
  non-stationary error shrink: not learning, just the job running out of room to be wrong in.
**PANEL-B NOTE (second correction).** The first corrected figure plotted `|mean signed bias|` for the
non-stationary series against `mean|error|` for the variance series, under one axis label. Those are different
quantities. Numerically it made no difference HERE — the non-stationary error is negative in 200/200 replicates,
so |mean| equals mean|.| exactly — but the label was wrong in principle and would mislead on any series that
changes sign. Panel b now plots the true E|error| for BOTH series, computed per-replicate before averaging.

**METHODOLOGICAL NOTE (correction).** The first version of this figure plotted the variance-only case's mean
ABSOLUTE error as a negative quantity on an axis labelled "negative = over-promises." That was wrong: it made an
unbiased estimator look systematically deceptive. The corrected figure separates the two panels — signed bias
(where variance sits flat at zero) and error magnitude (where the 1/sqrt(n) decay actually lives). The distinction is
the whole finding, so getting the statistic wrong would have inverted it.
**Caveat:** this is a simulation of estimator behaviour under an ASSUMED cost profile, NOT a measurement of real
installers. It shows the mechanism is *sufficient* to produce the effect; it does not prove real bars fail this way.

## 6. RECOMMENDED ORDER OF WORK (revised after the §0 correction)
**Nothing here is urgent — SCT is unreleased and its public label is already honest.** Two items are worth doing
now anyway, because they would be embarrassing whenever it does ship, and one of them touches PUBLISHED work:

**DO NOW (Hermes):**
1. **The V4 compositionality error — check whether it leaked into the PUBLISHED Owl Semaphore spec.** This is the
   only finding that may touch released work: owl-semaphore carries a Zenodo DOI (10.5281/zenodo.19473697) under
   CC BY 4.0. The error: SCT §5.1 states V4's axiom "every non-identity element is its own inverse", then §5.2
   illustrates compositionality with "two UNKNOWN chunks remain UNKNOWN" — if UNKNOWN = r then r∘r = e, so two
   UNKNOWNs compose to KNOWN, not UNKNOWN. **Grep the published Owl spec for the same example.** If it is only in
   the SCT draft, fix the draft. If it is in the published spec, that is a real erratum and needs a versioned
   correction, not a silent edit.
2. **The two empty public repos.** `star-centric-transport` (26-char README) and `open-epistemic-packet` (25-char
   README) are PUBLIC and empty. Either add a one-line README stating "Status: proposal in development, not
   published — see intellectualresistance.com" or make them private until there is content. Empty public repos with
   provocative names invite guessing; the whole point of the status labels is to prevent guessing.

**FILED, NO ACTION (revisit only if SCT moves toward release):**
3. v3 PDF LaTeX rendering (tau / <= / c-hat missing) — §2.
4. Abstract vs body on the Erdos result (proof of vs disproved) — §2.
5. Feng named as verifier beyond what the Nature source supports — §2.
6. The three overstatements — §3. Note the honest version is ALREADY WRITTEN in the same corpus's limitation
   sections, and the PUBLIC labels are already correct. This is a draft-internal consistency fix.

**THREAD HYGIENE (author's question: separate thread?)**
Yes — keep SCT in its own thread, on TIMESTAMP grounds rather than topical ones. `star-centric-transport` last
pushed 2026-07-03; `calibration-scope` pushed today. One is a live build, the other a dormant idea; merging their
queues turns a work queue into a wish list.
**But the connection is real and DIRECTIONAL:** SCT's own notation defines k_i as "carrier effects"; Carrier Color
measures k_i. So calibration-scope GENERATES the evidence SCT needs (the channel bound, the first measured tau,
the grader-artifact discipline). SCT feeds calibration-scope nothing yet. Rule: **measurement work here, theory
work in its own thread.** The only sentence that legitimately crosses into calibration-scope is that its carrier
measurements are the empirical arm for a transport model still in draft — true, and about THIS project's outputs.
