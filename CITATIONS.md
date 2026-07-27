# Citation registry

`citation/registry.yaml` — the project's registered citations, one entry per
standard/RFC/framework the project's claims lean on.

**Provenance.** Ported verbatim from
`dns-tool-intel/go-server/internal/citation/registry.yaml` (commit `0e3a4d2`,
61 entries as measured on port — Claude Science's memo said 62; count what
the file counts — the existing pattern, existing format, zero invention; see
`inbox/claude-science/MEMO_prior_art_evidence_frameworks.md`), plus two
entries added on port: `nasa:std-7009a` and `grade`. Already present in the
ported set: `odni:icd-203`, `iso:25012`, NIST SP 800-53.

**The anti-badge rule (NASA-STD-7009A, adopted as policy).** NASA's own
wording: the standard *"levies no requirements with respect to what levels to
achieve … merely that the levels be determined and reported."* Accordingly,
no document in this project says "ICD 203 compliant" or scores itself against
any registered citation — levels are determined and reported, never badged.

**Primary-source caveat (honest scope).** The `nasa:std-7009a` entry and the
CoLD ladder it travels with were assessed from indexed search excerpts, not
the primary PDFs (Claude Science, 2026-07-26 epistemic log). Registering the
citation is format-only; fetch and read the primary documents before building
anything on their *content*.
