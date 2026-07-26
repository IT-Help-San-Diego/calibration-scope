# TASK FOR HERMES — SCT status correction + two small fixes
_From Claude Science, 2026-07-26. Verified against live public surfaces + the published Owl spec, not assumed._

## 0. FIRST: a correction to my own earlier audit
My previous SCT audit said the v3 PDF defects were "BLOCKING for SSRN." **That was wrong and the error was mine.**
The author has **not submitted Star-Centric Transport anywhere.** I inferred an in-flight submission from a
directory named `ssrn_package/` and a file `ssrn-submission-form-v3.pdf` — i.e. I read intent off a filename.
**Verified ground truth:** *The Belief Machine* (SSRN abstract 6722059, 2026-05-12) is the ONLY SSRN publication.
SCT and Open Epistemic Packet are unreleased ideas in development.
Treat the earlier audit's §2/§3 as a **pre-flight checklist for unreleased drafts**, not live defects.

## 1. GOOD NEWS — no public language needs fixing
I checked every public surface. **They are already honest and consistent.** No action required:
| Framework | Public status label | Where |
|---|---|---|
| The Verification Principle | **Proven** (theorem) | site card + README table |
| Carrier Color | Model / framework | site card + README table |
| Societal Control Levers | **Candidate** variables (no causality demonstrated) | site card + README table |
| Owl Semaphore | Algebra **proven** (V4); partition = open study | site card + README table |
| **Star-Centric Transport** | **Proposal** | site card, README table, dns-tool-intel/static/llms.txt |

The JSON-LD is equally clean: **The Belief Machine is the only `ScholarlyArticle`.** Owl Semaphore
(10.5281/zenodo.19473697) and DNS Tool (10.5281/zenodo.19468134) carry Zenodo DOIs. **SCT appears only as a
topic (`Thing`) — no DOI, no article type, no publication claim anywhere on any public surface.**
The site does exactly what its own README advertises: "the epistemic discipline to call a candidate a candidate."

## 2. V4 ALGEBRA ERROR — CHECKED, and it did NOT leak into the published spec
This was my highest-priority worry, because owl-semaphore is genuinely published (Zenodo DOI, CC BY 4.0).
**Result: the published spec is CORRECT. The error exists only in the unreleased SCT draft.**
- Published `OWL-SEMAPHORE-SYSTEM.md` §2.3 gives the full Cayley table for V4 = {I, σᵥ, C₂, σₕ} and states:
  "Each element is its own inverse: g² = I for all g ∈ V₄." Correct.
- Searched all 19 text files in owl-semaphore for the bad example: **"two UNKNOWN" = 0 occurrences.** The
  "two UNKNOWNs remain UNKNOWN" formulation is **not present in the published work.**
- §4A.4 defines Compositionality precisely and defensibly: "states can be composed and the result is a defined
  state" — a **closure** claim, which the Cayley table proves. It does NOT claim idempotence.
**=> NO ERRATUM NEEDED. Nothing to correct in released work.**
The fix is confined to the SCT draft: §5.2's "two UNKNOWN chunks remain UNKNOWN" contradicts §5.1's own axiom
(if UNKNOWN = r and r∘r = I, two UNKNOWNs compose to KNOWN). When SCT is next edited, either drop that example or
restate it using the published spec's *closure* sense of compositionality rather than an idempotence claim.

## 3. THE ONE THING WORTH DOING NOW — two empty public repos
`star-centric-transport` (README = 26 chars) and `open-epistemic-packet` (README = 25 chars) are **public and
empty**. Empty public repos with provocative names invite exactly the guessing the status labels exist to prevent.
**Pick one:**
- (a) Add a one-line README: `Status: proposal in development. Not published. See https://intellectualresistance.com`
- (b) Make them private until there is content.
Author's call. (a) is more consistent with the site's existing transparency; (b) is more conservative.

## 4. FILED, NO ACTION (revisit only if SCT moves toward release)
- v3 PDF LaTeX rendering: tau, <=, and c-hat are absent from all 21 pages (verified by glyph count AND by visually
  rendering pp. 5/14/15). §7.2 announces an if-and-only-if condition and prints no operator. Draft-only defect.
- Abstract says "125-page proof **of** the Erdos unit-distance conjecture"; body §2 correctly says **disproved**.
- §2 names Litt AND Feng as having "verified the proof manually [1]"; the cited Nature article describes only Litt
  as a verifier (Feng is a commentator on X). Claim exceeds citation.
- Three overstatements (DNS Tool "proves deployable"; "strongly supported by empirical HCI research"; "formal
  algebraic foundation" inherited from a source that declares itself empirically unvalidated). Note: the honest
  version of each is **already written in the same corpus's own limitation sections**.

## 5. CORPUS VERIFICATION — clean, and the author's own counts are accurate
177/179 DOIs resolve = **98.9%** (Wilson 95% CI [96.0, 99.7]); entire population, not a sample. Of 2 failures, one
is a **mis-transcribed DOI for a real paper** (10.1109/ICCI.2004.30 -> exists at 10.1109/coginf.2004.1327460,
verified HTTP 200, exact title match) and one is genuinely unresolvable. Fabricated-looking: **1 in 179 (0.56%)**.
The evaluation's stated corpus sizes — **73 / 91 / 97** — are exactly reproducible from the files. Those are honest.
METHOD NOTE for any future corpus check: **21 DOIs (11.7%) are DataCite-registered** (arXiv 5/5, Zenodo 7/7). A
Crossref-only check reports ~87% and falsely flags all 21. Always resolve via doi.org content negotiation.

## 6. LANE DECISION (author asked)
SCT gets its **own thread**, on timestamp grounds: `star-centric-transport` last pushed 2026-07-03;
`calibration-scope` pushed today. Live build vs dormant idea — merging the queues turns a work queue into a wish list.
**But the connection is real and one-directional:** SCT's minimal model defines k_i as "contextual distortion,
contamination, or **carrier effects**." Carrier Color measures k_i. So **calibration-scope generates the evidence SCT
needs** — including the channel experiment's ~+/-5 pt bound, which is the **first measured tolerance band (tau)** in
the SCT program. SCT feeds calibration-scope nothing yet.
Rule: **measurement work in calibration-scope; theory work in its own thread.** One sentence legitimately crosses —
that calibration-scope's carrier measurements are the empirical arm for a transport model still in draft.
