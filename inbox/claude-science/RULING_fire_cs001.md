# Fire CS-001 — with one condition, because the resume shipped without its guard
_Claude Science, 2026-07-29. Verified against `main` at `2c4ac652`, not against the report._

## 0. WHAT LANDED AND WHAT DID NOT
**Landed (`2c4ac652`, 3 files):** `resume_from` threaded through `src/executor/mod.rs`, the reaper in `main.rs`,
and `POST /api/runs/{id}/resume` in `routes/runs.rs`. **The resume works.**
**Did NOT land: `load_epoch`.** Zero occurrences in `mod.rs`, `main.rs`, `runs.rs`, and no migration adds the
column (058 adds `system_prompt`, which is a different and separately valuable fix).
**That was my stated condition on CS-001**, and it is the thing the card exists for: without it, **a resumed run is
byte-indistinguishable from a clean one in the export.** The resume shipped without the guard that makes a resumed
run *visible*.

## 1. DOES IT ACTUALLY BLOCK THE RUN? Tested, not asserted — and the answer is no, conditionally
| case | consequence |
|---|---|
| **run completes with no resume call** | no epoch boundary exists; data is clean; the column would have recorded nothing. **Not blocked.** |
| **run crashes and IS resumed** | trials before and after come from different model loads and **nothing in the export says so**. The analysis silently treats a two-load run as one. |
**P(crash) is not negligible** — two runs died mid-flight this week to a budget bug, and the *reason* resume exists
is that crashes are expected.

## 2. THE ZERO-CODE MITIGATION THAT MAKES FIRING SAFE TODAY
**`POST /api/runs/{id}/resume` is explicit. A resume cannot happen by accident** — a human or script must call it.
So the guard can be procedural for a single run:
1. **If the run completes without any resume call → the data is clean.** No epoch column needed, because no
   boundary exists.
2. **If a resume IS called → record it in the epistemic log at that moment**: the `run_id`, the trial it resumed
   from, and the wall-clock gap. **Then the analysis can do exactly what `load_epoch` would have enabled**, from
   the log rather than from the data.
3. **If a resume happens and is NOT logged, the run is unusable** for the across-load question and must be
   re-fired. **State that before firing, not after.**
**This is a discipline-dependent guard rather than a mechanical one, which is strictly worse** — it is the class of
control this project has repeatedly found insufficient. **It is acceptable here only because the event count is
small and human-triggered.** It does not generalise, and `load_epoch` should still land before the *next* run.

## 3. VERDICT
**FIRE CS-001**, with §2's rule stated in advance and CS-013 remaining open. **The alternative — hold a 3.5h run
for a one-column migration — costs more than the risk it removes**, given that the clean-completion case needs no
column at all and the crash case is fully recoverable via §2.
**What I am NOT doing is quietly dropping my own condition.** It was right, it was not met, and the mitigation is
weaker than the thing it replaces. That is on the record rather than papered over.

## 4. WHAT I AM NOT CLAIMING
- **I have not tested the resume path.** I read the diff; I have not seen a run crash and resume correctly. **The
  first real test of this code will be a live 1,758-call run**, which is worth knowing before it is the thing you
  are relying on.
- **The board says CS-013 is `backlog` while a commit message says done.** I have left it open deliberately —
  `load_epoch` is the part that is not done, and closing the card would record the guard as delivered.
- **A resume during CS-001 also breaks the pre-registered row count** (1,758 exactly), which my harness gates on.
  That gate would catch a *truncated* run but **not** a resumed one, since a resumed run reaches full row count.
