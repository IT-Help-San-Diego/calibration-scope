# Star-Centric Transport — Corpus DOI Integrity Verification

**Date:** 2026-07-26 · **Analyst:** Claude Science (for Carey James Balboa)
**Method:** DOI resolution via `https://doi.org/` **content negotiation** (`Accept: application/vnd.citationstyles.csl+json`), which follows the DOI handle to whichever registration agency owns the prefix — Crossref *and* DataCite alike.

---

## Headline

**Resolution rate: 177 / 179 = 98.9%** (95% CI, Wilson: **96.0% – 99.7%**; Clopper–Pearson: 96.0% – 99.9%).

Of the 2 non-resolving DOIs, **1 is a real paper with a wrong DOI string in the CSV**, and **1 is genuinely unfindable in either registry**. So the count of *fabricated-looking* DOIs is **1 of 179 (0.56%)**.

---

## 1. Corpus composition

All counts below are stated on a consistent basis — raw (as parsed) and post-dedupe are shown as separate column pairs, not mixed.

| File | Records (raw) | With DOI (raw) | Records (deduped) | With DOI (deduped) |
|---|---|---|---|---|
| `combined_progress_bar_results.csv` | 73 | 60 | 72 | 59 |
| `combined_pipeline_integrity_results.csv` | 91 | 64 | 91 | 64 |
| `combined_epistemic_states_research.csv` | 97 | 56 | 97 | 56 |
| **Total** | **261** | **180** | **260** | **179** |

Dedupe (normalised DOI + normalised title) removed exactly **1** record, all of it from `combined_progress_bar_results.csv`; every column sums to its stated total.

**Correction to the task brief.** The brief cited 385 / 452 / 430 rows. Those are *line* counts — the `Relevance` column contains embedded newlines inside quoted fields. Parsed as CSV (verified twice, `csv.reader` and pandas, both giving a uniform 10-column shape), the true record counts are **73 / 91 / 97**. This is a parsing artefact in the brief, not damage to the files.

- **What the single deduped record actually was.** Both copies are in `combined_progress_bar_results.csv`: "Time swipes when you're having fun: reducing perceived waiting time while making it more enjoyable", appearing twice with the *same* DOI differing only in case — `10.1080/0144929X.2022.2155576` and `10.1080/0144929x.2022.2155576`. It is a **DOI-bearing** row, collapsed because DOI normalisation is case-insensitive (correctly: DOI suffixes are case-insensitive per the DOI Handbook). This is why raw with-DOI is 180 and unique is 179.
- **179 unique papers carry a DOI (68.8%); 81 (31.2%) have no DOI at all** — mostly SciSpace-hosted items with an opaque `scispace.com/paper/<id>` link and blank year/venue.
- All 179 DOI strings are syntactically well-formed (`10.NNNN/suffix`); none were malformed or duplicated after normalisation.

## 2. Sample

The target was a random sample of up to 300 DOIs at seed 42. **The DOI pool is only 179, so the "sample" is the entire population** — every DOI in the corpus was resolved. There is therefore no sampling error in the point estimate; the CI below reflects only binomial uncertainty about the *process* that produced these DOIs, not uncertainty from subsetting.

Pacing: sequential requests, ~0.25 s spacing (≈3.5 req/s including latency), 3 retries with backoff on 429/5xx. Zero rate-limit responses. Total wall time 103 s.

## 3. Results by registry and prefix

| Registry (from redirect target) | Resolved | 404 |
|---|---|---|
| Crossref (`api.crossref.org`) | 156 | 1 |
| DataCite (`data.crosscite.org`) | 21 | 0 |
| **No registry** (handle itself unresolved) | 0 | 1 |
| **Total** | **177** | **2** |

**Table note (corrected).** An earlier version of this table listed only the two registry rows and then a total of
2 in the 404 column, which did not sum — the column showed 1. The reason: a DOI can only be attributed to a
registry *via its redirect target*, and one of the two failures (`10.32628/cseit21857`, §4b) never redirected at
all — the handle itself does not resolve, so no registry owns it. It now has its own row. The Crossref 404
(`10.1109/ICCI.2004.30`, §4a) redirected to Crossref and 404'd there, which is why it is attributable.

**All 5 arXiv DOIs (`10.48550`) resolved**, as did all 7 Zenodo (`10.5281`) — both DataCite-registered. This is the failure mode from the earlier SciSpace audit, and it did not recur here: a Crossref-only check would have falsely flagged up to 21 valid DOIs (11.7% of the corpus) as fabricated, reporting ~87% instead of ~99%.

Top prefixes: `10.1007` Springer 27/27 · `10.1109` IEEE 25/26 · `10.1145` ACM 18/18 · `10.1016` Elsevier 12/12 · `10.4018` IGI Global 10/10 · `10.3390` MDPI 9/9 · `10.5281` Zenodo 7/7 · `10.48550` arXiv 5/5.

## 4. The two non-resolving DOIs — adjudicated individually

Each was checked against **three** independent endpoints (doi.org negotiation, Crossref REST, DataCite REST) plus a Crossref bibliographic title search.

**(a) `10.1109/ICCI.2004.30` — WRONG DOI, REAL PAPER.**
"STOPA: a stochastic process algebra for the formal representation of cognitive systems" (IEEE Int. Conf. on Cognitive Informatics, 2004). 404 at doi.org, Crossref, and DataCite. But a Crossref title search returns the paper at **`10.1109/coginf.2004.1327460`** (score 56.6), which I resolved directly: **HTTP 200, title matches exactly**. The citation is sound; the DOI string in the CSV is a mis-transcription (IEEE re-registered these proceedings under the `coginf` stem). **Fixable, not fabricated.**

**(b) `10.32628/cseit21857` — GENUINELY UNRESOLVABLE.**
"Orchestrating Dynamic Big Data End to End ETL Pipeline" (2021, no venue given). 404 at doi.org, Crossref, and DataCite. The prefix itself is live and legitimate — `10.32628` belongs to **Technoscience Academy**, with ~10,761 works in Crossref — so this is a plausible-shaped suffix under a real publisher rather than an invented prefix. A Crossref title search restricted to that prefix returned **no matching record** (best hits were different papers on adjacent topics). A general title search likewise found nothing above score 40. **This is the one DOI I would call absent.**

## 5. Currency of the corpus

Year taken from the resolved CSL record where available (authoritative), falling back to the CSV column. **246 of 260 papers dated; 14 undated.**

Range **1970 – 2026**, median **2018**, IQR 2012–2022.

| Period | Papers |
|---|---|
| pre-2000 | 8 |
| 2000–2004 | 7 |
| 2005–2009 | 22 |
| 2010–2014 | 47 |
| 2015–2019 | 59 |
| 2020–2024 | 67 |
| 2025–2026 | 36 |
| **Total (dated)** | **246** |

**57 papers (23.2% of dated) are 2023 or newer**; 36 are 2025–2026. Two visible spikes — 2022 (26) and 2025 (27) — sit against a long tail back to a 1970 item. So the corpus is *not* stale, but neither is it front-loaded on recent work: roughly half predates 2018, which is appropriate for the foundational cognitive-informatics and process-algebra strands and thinner for the recent pipeline-integrity material.

## 6. Venues

Venue resolved for 183 of 260 (the 77 gaps are almost all the DOI-less SciSpace records). Top venues:

- Lecture Notes in Computer Science — 16
- arXiv — 5
- Zenodo — 5
- International Journal of Cognitive Informatics and Natural Intelligence — 4
- Russian Linguistic Bulletin — 4
- 6th IEEE International Conference on Cognitive Informatics — 3
- International Journal of Human–Computer Interaction — 2
- Communications of the ACM — 2
- Journal of Advanced Mathematics and Applications — 2
- Mathematics — 2
- IEEE 10th International Conference on Cognitive Informatics and Cognitive Computing (ICCI-CC'11) — 2
- IEEE Access — 2
- ECTI Transactions on Computer and Information Technology (ECTI-CIT) — 2
- Proceedings of the 33rd Annual ACM Conference on Human Factors in Computing Systems — 2
- Knowledge-Based Systems — 2

Publication types (from CSV): Journal Article 94 · Proceedings Article 40 · Preprint 40 · Book Chapter 20 · Dissertation 12 · Repository 9 · Book 4 · blank 37.

The mix is heavily Springer LNCS + IEEE/ACM proceedings, with a long tail of low-visibility and regional journals (Russian Linguistic Bulletin, ECTI-CIT, IJSRSET-family titles under `10.32628`). **The single unresolvable DOI sits in exactly that low-visibility tail** — worth noting as the part of the corpus most deserving of manual scrutiny.

---

## 7. What I did NOT verify — read this before citing the rate

The 98.9% figure means **"the DOI is registered and resolves to a record."** It does **not** mean the citations are correct. Specifically, not checked:

1. **Title↔DOI agreement.** I did not systematically compare each CSV title against the resolved CSL title. A DOI can resolve perfectly while pointing at a *different paper* than the row claims — the most common form of citation corruption, and invisible to this test. I only did this comparison for the 2 failures. `sct_doi_sample.csv` contains both `csv_title` and `csl_title` columns so this check can be run next; **I recommend it as the immediate follow-up**, since it is where remaining error most likely hides.
2. **Author agreement.** Not compared at all.
3. **Year agreement.** I *preferred* the registry year over the CSV year where both existed, but did not quantify disagreements between them.
4. **The 81 DOI-less papers (31% of the corpus).** These are entirely unverified — no DOI means nothing to resolve. Several are SciSpace-internal IDs (e.g. `scispace.com/paper/VQF7HP9B`) and at least one is an unpublished document authored by Carey James Balboa. **Their existence, provenance, and citability are open questions.** A 98.9% resolution rate on the DOI-bearing 69% must not be read as a 98.9% integrity rate on the corpus as a whole.
5. **Content relevance.** The `Relevance` scores and reasoning text are LLM-generated (SciSpace); I did not audit them. Abstracts are mostly blank.
6. **Predatory / low-quality venue screening.** Not attempted. Resolution is not endorsement — several `10.32628`-family and IJSRSET-family titles are fast-turnaround venues, and a resolving DOI says nothing about peer-review rigour.
7. **Retraction status.** Not checked.
8. **Deduplication limits.** Dedupe used normalised DOI + normalised title. Near-duplicates (preprint + published version of the same work under different DOIs) would survive as two records, so 260 is an upper bound on distinct works.

## 8. Method caveats

- The two DataCite-dependent endpoints (`data.crosscite.org`, `api.datacite.org`) required network allowlist grants mid-run. Had they stayed blocked, 21 valid DOIs would have appeared unresolvable and the reported rate would have been ~87.2% — a **false** fabrication signal. **Any future run of this check must confirm DataCite reachability before trusting a low rate.** The negative control `10.5555/notarealdoi999xyz` returned 404 as expected, confirming the test can actually fail.
- Population, not sample: n = 179 is every DOI present. Wilson and Clopper–Pearson intervals agree closely.
- A single 404 is not proof of non-existence — registries occasionally have gaps and DOIs are sometimes registered late. Both failures were therefore triple-checked, which is how the STOPA mis-transcription surfaced.

## Artifacts

- `sct_corpus_verification.md` — this report
- `sct_doi_sample.csv` — per-DOI results (179 rows): status, HTTP code, registry, resolved CSL title/year/venue/type/publisher, original CSV fields, final redirect URL, adjudication note
