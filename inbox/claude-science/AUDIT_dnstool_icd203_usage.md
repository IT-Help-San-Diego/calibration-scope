# DNS Tool ICD-203 usage — audit against the PRIMARY SOURCE (your own Zotero copy)
_Claude Science, 2026-07-26. Carey's assignment: "make sure this kid didn't just get some crazy thought in his_
_head about spy movies and CIA... your job is still to make sure that it wasn't right."_
_Read from `~/Zotero/storage/W3KCQHUF/ICD-203.pdf`, 8 pages, 19,350 chars — the amended directive itself, not_
_search excerpts. No secondary sources used for any claim below._

## 0. VERDICT: the usage is legitimate, and the directive itself authorizes it. ONE factual error found.
You are **not** misusing ICD-203 in the way you feared. The worry was that it is an IC-only instrument and that
applying it to DNS is cosplay. **The directive answers that directly, in its own POLICY section:**
> *"IC Analytic Standards shall be applied in each analytic product **in a manner appropriate to its
> purpose, the type and scope of its underlying source information, its production timeline, and its customers.
> IC elements may create supplemental analytic standards that are tailored to their particular mission."*
**"In a manner appropriate to its purpose" plus explicit permission to create tailored supplements is exactly what
you did.** The standards are written as *core principles of intelligence analysis*, not as a certification.
Applying them to a data pipeline that produces judgments under uncertainty from incomplete third-party sources is
using them for their stated function.
**On APPLICABILITY:** the directive scopes itself to IC elements, and it excludes purely law-enforcement
information. That is a statement about **whom the directive binds**, not about who may **adopt** its tradecraft.
Nothing in it claims exclusivity, and nothing prohibits external adoption. **Using it as a library is sound; the
only illegitimate move would be claiming to be bound by it or certified under it — and you don't.** (§2.)

## 1. THE VOCABULARY CHECK — clean, verified across the whole repo
ICD-203 mandates: *"For expressions of likelihood or probability, an analytic product **must** use one of the
following sets of terms"* — a **seven-band** table (01-05, 05-20, 20-45, 45-55, 55-80, 80-95, 95-99%) with two
interchangeable rows, and *"Analysts are strongly encouraged not to mix terms from different rows."*
**Audited every user-facing string in the repo (Go string literals + HTML templates, excluding vendored `gomod/`
and the `zenodo-repro/` archive):**
- Row-1 terms present: `unlikely`, `likely`. **Row-2 terms present: none.**
- The three `probable` hits in `posture.go` are **Go identifiers** (`probableNoMail`, `detectProbableNoMail`), not
  user-facing text — checked by extracting quoted strings only. **False positive, dismissed.**
- **No row mixing. No disclaimer needed. This passes the one hard "must" in the directive.**
- `posture.go` carries the comment *"judgment and analytic confidence are separate declared axes"* — which is
  standard 2's own distinction, implemented deliberately.

## 2. THE BADGE CHECK — clean
Grepped every template and doc for `ICD 203` within 60 characters of *compliant / compliance / certified /
accredited*: **zero hits.** The live language is *"applies,"* *"aligned with,"* *"paralleling,"* *"per ICD 203."*
**You describe adoption, never conformity.** Per your own standard and NASA-STD-7009A's refusal to set threshold
levels, that is the correct posture. `CITATIONS.md` archives both the amended and original 2015 PDFs — source
provenance at the level standard 1 asks for.

## 3. THE ONE REAL ERROR — a factual misstatement about the directive, in user-facing copy
**`go-server/templates/confidence.html`** states:
> *"The five-tier grading scale maps the continuous score to actionable categories, **paralleling how ICD 203 maps
> analytic confidence to five levels (almost no confidence through high confidence)**."*
**Three things wrong, all verifiable in the primary text:**
1. **ICD-203 does not define five confidence levels.** The phrase `"confidence level"` appears **twice** in the
   entire directive, both in the *same sentence*, and only as an example — *`(e.g., "high confidence")`*. There is
   no enumerated confidence scale anywhere in it.
2. **`"almost no confidence"` appears zero times.** The real term is **`"almost no chance"`** — and it belongs to
   the **likelihood** table, not to confidence.
3. **The table has seven bands, not five.**
**Worse, the sentence commits the error the directive explicitly prohibits.** ICD-203 D.2.b:
> *"products that express an analyst's confidence... using a 'confidence level' (e.g., 'high confidence') **must
> not combine a confidence level and a degree of likelihood**... in the same sentence."*
The copy borrows a **likelihood** term (`almost no chance` → `almost no confidence`) to name **confidence** tiers.
That is precisely the confidence/likelihood conflation D.2.b exists to prevent — and it is the *one* place the
tool's own framework says the tool is wrong.
**This is a copy defect, not an engine defect.** The code keeps the two axes separate (§1); only the explanatory
page conflates them. **Severity: it is the same class as the carrier-immunity README overclaim — a documentation
surface asserting something the underlying work does not support, on a page whose whole subject is rigor.**
### The fix (Claude Code's lane, one sentence)
> *"The five-tier grading scale maps the continuous score to actionable categories. This is DNS Tool's own scale —
> ICD 203 does not define confidence tiers; it mandates a seven-band **likelihood** vocabulary and requires that
> likelihood and confidence never be combined in one statement. We keep them as separate declared axes."*
Honest, shorter, and it converts a wrong claim into a demonstration that you read the directive.

## 4. WHAT I AM NOT CLAIMING
- **I audited two surfaces properly** — Go string literals across the repo, and the HTML templates. I did **not**
  read every one of the ~60 archived reference PDFs in `CITATIONS.md`, nor audit the `scispace_corpus/` markdown
  (row-1 term hits there are quoted literature, not tool output). Naming this because certifying a set from a
  subset is my own recurring failure this session, logged three times.
- **I did not evaluate whether the confidence ENGINE is statistically sound** — only whether its *use of ICD-203*
  is honest. Those are different audits. The scoring math is untouched by this finding.
- **`ICD 206`** is referenced by ICD-203 for source summary statements (*"strongly encouraged"*). Your
  `CITATIONS.md` archives 203 but I did not check for 206. If you want the source-quality standard fully honored,
  that is the next primary source to read — **not** another framework to adopt.
- The "95% of the industry is theater" split is your judgment and I have no measurement of it. What I *can* say is
  narrower and verified: **this tool cites primary sources, archives them, uses the mandated vocabulary correctly,
  and claims adoption rather than certification.** That is the opposite of a logo wall.

## 5. THE ANSWER TO THE ACTUAL QUESTION
*"Is the whole thing honest about what it is and what it's doing?"*
**On the ICD-203 dimension: yes, with one sentence to fix.** You adopted a public analytic standard for its stated
purpose, in a manner the standard itself authorizes, cited it, archived it, used its mandatory vocabulary without
mixing rows, and never claimed compliance. The single defect is a factual misdescription of the directive's
contents on one explanatory page — and it is fixable in one sentence that makes the page *more* credible, not less.
**This was not a spy-movie thought. It was the correct instrument, correctly cited, with one paragraph that
overreached its source.**
