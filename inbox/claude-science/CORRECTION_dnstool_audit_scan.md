# CORRECTION to AUDIT_dnstool_icd203_usage.md — the "whole repo" scan never ran, plus one NEW real finding
_Claude Science, 2026-07-26. Two audit findings against my own audit, both correct. Re-run properly via the_
_GitHub API after diagnosing why the shell scan kept failing._

## 0. WHAT WAS WRONG WITH MY AUDIT
Two claims in v1 were unearned:
- **§1 "Audited every user-facing string in the repo (Go string literals + HTML templates)"** and **§4 "I audited
  two surfaces properly — Go string literals across the repo, and the HTML templates."**
- **§2 "Grepped every template and doc... zero hits."**
**Both scans read my own workspace, not the repository.** `git clone` into `/tmp` failed silently
(`&&`-chain aborted, no "cloned" line in the output) and the following `grep -r .` therefore walked the cwd —
which is why the hit paths were `./pg_confidence.html`, `./scispace_corpus/*.md`, `./zenodo-repro/extracted/...`
and **no live `go-server/...` path appeared at all.** I diagnosed this for the badge grep and then **failed to
apply the same diagnosis to the vocabulary grep in the cell before it.** The badge "zero hits" figure additionally
traced to a **one-file** count on `confidence.html`, not a repo-wide scan.
**Root cause of the silent failure, now known:** `git clone` is not permitted in this sandbox —
`/private/tmp/dti/.git: Operation not permitted`. It failed the same way twice. **Standing fix: never scan behind
a clone without asserting the clone succeeded first** (`[ -d .git ] || exit 1`), and prefer the GitHub API, which
worked all session.

## 1. THE RE-RUN — real numbers this time
Via the GitHub API: **tree of 1,476 blobs, `truncated: false`** (asserted, not assumed). In-scope
`.go`/`.html`/`.md` excluding `gomod/`, `zenodo-repro/`, `scispace_corpus/`: **753 files, all 753 fetched, 0
failures.**
| Check | v1 claim | Actual |
|---|---|---|
| Badge / compliance claim | "zero hits" (1 file) | **0 hits across 753 files** — claim survives, now earned |
| Row-2 likelihood terms | "none" (never scanned) | **8 raw hits; 1 in a user-facing analytic judgment** |
`remote` appears in 27 files but every instance is **network-remote** ("Remote Probe Failover", "remote
infrastructure", "CISA Remote Penetration Test") — not the ICD-203 likelihood term. Correctly excluded.

## 2. THE NEW FINDING MY FAILED SCAN MISSED — a genuine row mix
**`go-server/internal/analyzer/remediation.go`**, verbatim:
```go
label: "Probable No-Mail Domain — Needs Formal Declaration"
```
Every other user-facing analytic judgment in the tool uses **row 1**:
```go
"Unlikely — SPF and DMARC quarantine policy enforced"
"Likely — SPF alone cannot prevent spoofing"
```
**`Probable` is a row-2 term.** So the product does mix rows, and ICD-203 is explicit about the consequence:
> *"Analysts are strongly encouraged not to mix terms from different rows. Products that do mix terms **must**
> include a disclaimer clearly noting the terms indicate the same assessment of probability."*
So v1's "**No row mixing. No disclaimer needed.**" was wrong on both halves — and it was wrong because the scan
never ran.
**Severity: LOW.** One occurrence, one file, no other in-scope file contains the phrase, and no template
references `No-Mail` — so it may not currently render to users at all (the label is defined in Go; I did not trace
the render path, so I am not claiming it is unreachable either).
**Fix, one word, cheaper than a disclaimer:** `"Probable No-Mail Domain"` → **`"Likely No-Mail Domain"`**. That
puts every judgment in the tool on row 1 and removes the disclaimer obligation entirely.

## 3. WHAT SURVIVES FROM v1 UNCHANGED
- **The legitimacy verdict.** Based on the directive's own POLICY text ("applied... in a manner appropriate to its
  purpose"; "IC elements may create supplemental analytic standards"), read from the primary PDF. Untouched by
  the scan failure.
- **The `confidence.html` defect** — read from the live file, not the failed scan. **And Carey has since fixed
  it: verified first-hand on `main` just now.** `"maps analytic confidence to five levels"` and
  `"almost no confidence"` are both **absent**; the live sentence reads *"paralleling ICD 203's practice of
  expressing judgments as defined verbal bands rather than raw numbers"* — true, no invented band count, no
  likelihood vocabulary, no axis mixing. Correct fix.
- **`posture.go`'s two-axis separation** — read from that single file directly (which was always the only
  genuinely repo-sourced vocabulary evidence in v1).
- **Leaving `scripts/gptzero-results.json` untouched** was right: it is a historical record of text as analyzed,
  and editing it would falsify the record. Same principle as quarantine-don't-delete.

## 4. FAILURE CLASS, FOR THE LOG
This is my recurring one — **certifying a set after verifying a subset** — with a new and worse variant: the
subset was **empty**. I had *evidence* the scan failed (the missing "cloned" line, then the explicit `cd:` error)
and applied it to only one of two dependent claims. **New standing rule: when a tool invocation is discovered to
have failed, re-check every claim in the same turn that depended on it, not just the one that threw.**
