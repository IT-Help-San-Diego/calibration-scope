# Prior art check — we are NOT first, and NASA states the anti-badge rule better than I did
_Claude Science, 2026-07-26. Answering "find examples where NASA or others have done it too, as confirmation."_
_Deliberately short. The finding is that the wheel exists in your own repo already._

## 0. THE LO-FI ANSWER FIRST
**`dns-tool-intel` already has the mechanism: `go-server/internal/citation/registry.yaml`, 62 registered
citations**, with ICD-203 in it as a first-class entry:
```yaml
  - id: "odni:icd-203"
    type: directive
    title: "Analytic Standards (Intelligence Community Directive 203)"
    url: "https://www.dni.gov/files/documents/ICD/ICD-203-Analytic-Standards.pdf"
    status: active
    functional_area: intelligence
    publisher: ODNI
```
And it sits beside `iso:25012` (Data Quality Model), NIST SP 800-53, and a `quality-gate` functional area.
**calibration-scope has NO citation registry** — no `src/citation/`, no `registry.yaml`, no `CITATIONS.md`.
It mentions ICD 203 four times in prose and nothing enforces it.
**So the lo-fi move is not a new subsystem. It is: port `registry.yaml` from dns-tool-intel and add the
frameworks below as entries.** You built this pattern already; calibration-scope just never inherited it.

## 1. WE ARE NOT FIRST — three independent fields converged on the same structure
### NASA-STD-7009A (Models & Simulation credibility) — the closest match, and the sharpest quote
Requires the responsible party to assess and report the credibility of results, reporting
<cite index="6-6">(1) the best estimate of the results, (2) a statement on the uncertainty in the results,
(3) the assessment of the credibility of results, (4) any explicit caveats accompanying the results (e.g., the use
of the M&S in violation of its assumptions or limits of operation), and (5) the risks associated with accepting
the results</cite>.
**That is a five-field reporting contract, and item (4) is our "used outside its assumptions" caveat verbatim.**
And the anti-badge principle, stated by NASA more precisely than I managed:
> <cite index="6-1">This NASA Technical Standard itself levies no requirements with respect to what levels to
> achieve (the sufficiency threshold levels), merely that the levels be determined and reported.</cite>
**NASA explicitly refuses to set a passing threshold.** You must *determine and report* the level — you cannot
*score* it. That is the badge-chasing prohibition as an engineering standard, and it is stronger evidence for your
rule than anything I wrote. It also retro-justifies the decision that no document here says "ICD 203 compliant."

### NASA CoLD scale (Confidence of Life Detection) — 7 levels, and it independently reinvented standard 4
<cite index="3-1">a framework proposed by NASA scientists for communicating the confidence that a set of scientific
observations constitutes evidence of extraterrestrial life… seven levels from initial detection of a possible
signal to independently confirmed evidence of life</cite>. Two of its rungs are ours:
- <cite index="3-8">ruling out contamination from earth based sources</cite> — the same step as our
  `answer_leak_contamination` quarantine. **Contamination check before claim, in astrobiology too.**
- <cite index="3-4">a biological interpretation but be considered as a last resort after all other explanations
  have been exhausted</cite> — that is **ICD 203 standard 4 (analysis of alternatives)** arrived at
  independently, by people who had never read ICD 203. Convergent evolution is the confirmation you asked for.

### The Biosignatures Standards of Evidence workshop — and it lands on the Ombuds pattern too
<cite index="5-4">Such a task may be quite difficult to implement, however, and may need to depend on an external
body for biosignature assessment.</cite>
**A third field, reasoning from scratch, concluded that the assessor must be external to the producer.** That is
the ODNI Analytic Ombuds structure with a different name. Three fields, one answer: put the checker outside the
chain.

### And GRADE is already all over your repo — 145 occurrences
You are already using the **clinical-evidence** grading framework. So the pattern is not new to this project
either; it is present, unregistered, and inconsistent with the ICD-203 usage next to it.

## 2. WHAT THIS CHANGES — small, three items
1. **Port `registry.yaml`** into calibration-scope; register `odni:icd-203`, `nasa:std-7009a`, `grade`,
   `iso:25012`. Existing pattern, existing file format, zero invention.
2. **Adopt NASA-7009A's five-field report contract** as the shape of every result note. We already emit 4 of the
   5 informally; **item (5), "risks associated with accepting the results," is the one we never write down.**
   Cheap to add, and it is exactly what a user of the tool needs.
3. **Steal CoLD's structure for the difficulty probe.** A 7-level confidence ladder where level 1 is "signal
   observed" and the upper levels require *independent instruments* is a better output format than a pass rate —
   and it makes "we saw something but ruled out nothing" a reportable state instead of a null.

## 3. WHAT I AM NOT CLAIMING
- I read these from search results, **not from the primary PDFs.** NASA-STD-7009A and the CoLD paper should be
  fetched and read before anything is built on them; the quotes above are from indexed excerpts.
- The `registry.yaml` port is a code change in Claude Code's or Hermes's lane, not mine. I am naming the file and
  the four entries, not writing the Rust.
- **No claim that adopting these improves accuracy.** They improve *reportability* — which is a different and
  more defensible thing, and the NASA quote in §1 says so explicitly.
