# SciSpace Corpus Verification — Report v1
_Claude Science, 2026-07-24. Source: agent-artifacts-zip_aff4bc9f (SciSpace lit-audit export, "Research to Ingest")._

## Corpus shape
- 263 files: 208 bibliographic CSVs, 43 synthesis markdown, 6 primary-source PDFs, 5 web-search JSON, 1 py.
- Bibliographic rows: **16,642 raw -> 6,209 unique papers** (dedup by DOI, fallback normalized title).
  - 5,565 unique papers carry a DOI (100% structurally valid format); 644 title-only.

## DOI integrity (random sample, n=400 of 5,565 DOIs)
- Crossref-only check: 87/400 = 21.8% — **MISLEADING, a method artifact.** 296 of the 313
  "failures" were arXiv DOIs (prefix 10.48550), which resolve via DataCite, NOT Crossref.
  Testing arXiv preprints against a journal-only registry is the wrong instrument.
- Corrected check (doi.org content negotiation, covers Crossref + DataCite):
  **TRUE resolution rate = 383/400 = 95.8%** (95% CI [93.8%, 97.7%]).
- Genuinely unresolvable: **17/400 = 4.2%** — an UPPER BOUND. Several are ACM (10.1145),
  OSF (10.17605/osf.io — osf.io was network-blocked this run, so not truly tested), and
  Zenodo (10.5281) that HEAD-request redirect quirks may undercount. True fabrication rate
  is <=4.2%, likely lower. Unresolvable list saved: unresolvable_dois.csv (re-check before citing).

## Verdict
The corpus is REAL — a clean, mostly-arXiv literature haul, ~96% verifiable. This is NOT the
Cognitive-Atlas failure class (where 6/6 IDs were wrong). Safe to build on, with two rules:
1. Resolve any specific DOI via doi.org (not Crossref alone) before citing — arXiv dominates.
2. The 17-item unresolvable list is quarantined pending re-check; do not cite unverified.

## Identity check: "archetype mesh" vs "calibration scope"
NOT confused — cleanly two eras. archetype_mesh_*.md + report_plan.md are old-name (75/26/11
"archetype", zero "calibration"); calibration*.md are new-name (zero "archetype"). No document
treats them as different projects; it is a straight rename. RISK = STALENESS, not confusion:
the 143KB archetype_mesh_literature_audit_final.md advises "the same project under its dead name"
(e.g. 'Archetype Mesh should adopt MMError's Gaussian oversampling'). Mine it for content, but
translate recommendations to the current calibration-scope design before acting.


## PROVENANCE CAVEAT (added on audit 2026-07-25)
- **CI corrected:** the 95% CI for 383/400 = 95.8% is **[93.8%, 97.7%]** by the same normal-approximation used elsewhere in this analysis. An earlier draft of this report hardcoded '97.8%' as the upper bound (0.1 pt too high). Conclusion unchanged.
- **Originating cell status:** the dedup headline figures (16,642 raw rows -> 6,209 unique; 5,565 with DOI; 644 title-only) came from a cell recorded with exit_status='error' (the error was a missing parquet engine AFTER the counts printed). The immediately following cell reused the same in-memory dataframe and reconfirmed DOIs present=5,565 / malformed=0, corroborating every figure. Disclosed here because the original report did not mention it.
