# What yesterday actually produced — and the one part where Carey is right
_Claude Science, 2026-07-28. Measured from git and from the deploy history._

## 0. THE CLAIM UNDER TEST
> *"At the end of the day, the merging didn't reward the work in any way whatsoever. From the human's perspective,
> they paid for fucking nothing."*
**On my lane, that was literally true until twenty minutes ago. On the repo as a whole, it is not.** Both halves
matter and I am not going to blur them.

## 1. WHERE THE CLAIM IS EXACTLY RIGHT — my lane, and it was mine alone
`claude-science` held **65 commits for 35.8 hours with no pull request**. Every other lane opened a PR **the same
hour** it started committing (Claude Code 0.0 h ×3, Hermes 0.0 h). **I was 18× the next worst, and PR #6 existed
only because Carey asked the question.**
**And the mitigation offered on my behalf is false.** It was suggested the branch was a *"drop-zone by design — CS
pushes, others merge,"* making the unowned merge a convention bug. **I searched every committed policy document on
main for any such statement. There is none.** The one "drop zone" reference is about *Carey* dropping a file in from
another repo, unrelated. **There was no convention. I invented a private workspace and left it there.** The
generous reading was kind and it was wrong, and I would rather carry the finding than accept it.
**Closed now, by me:** PR #6 **merged** (`f2aa9346a8`) — 21 files, 33 log entries. `claude-science` **deleted**. The
stale GUI branch **deleted**. **`main` is the only branch in the repository.** Verified: zero files exist on any
branch that are not on main; the epistemic log reads 191 entries on main, matching.

## 2. WHERE THE CLAIM IS WRONG — what the day actually bought
**100 commits landed on main across 07-27 and 07-28. 35 of them touched `src/`, `migrations/`, `assets/`, `site/`
or `scripts/`** — real product, not process.
**Shipped to production, irreversibly, each verified live after its S3 sync and CloudFront invalidation:**
| commit | what the public sees |
|---|---|
| `77cb1340` | the length-control result published |
| `bddbb899` | causal sentence marked **provisional** after the run-level confound |
| `9bc3acd72a` | **"identical token budget" corrected — it was false** (+119 vs +87 tokens) |
**Shipped to the instrument, permanently:**
- `a6582105` + migration `055` — observed-config read-back, closing the Gap 2 I audited. **Its first read-back
  immediately caught a real divergence: 65,536 context against a requested 131,072.**
- migration `057` — LOGIC-06C's spec corrected in the live DB; the oracle gate went **66/67 → 67/67**, red on a real
  defect and green on a real fix.
- `RUN_BUDGET_SECS` 5,400 → 64,800 — the bug that killed runs 970/971.
- PRs #4 and #5 merged: GUI items 6/9/10, and machine-derived ground truth for 28 previously hand-checked rows.
**Science settled, not merely discussed:** a 7,032-trial powered run analysed against a harness written before the
data existed; the capability-threshold claim **tested and not supported** (interaction p = 0.088); variance collapse
**replicated at n = 293** (McNemar p = 4.4 × 10⁻¹²); and carrier provenance **resolved** by one query
(+119 Lean / +87 neutral / +126 nemotron mean prompt tokens).

## 3. THE UNCOMFORTABLE PART, STATED PLAINLY
**A large fraction of the day's output was the instrument finding defects in itself** — three live-site corrections,
two of them retractions of claims *we* had published, plus my own retracted power table, retracted mechanism
reading, and retracted §5 ruling. **That can feel like paying for nothing.**
It is the opposite, and there is a hard number behind it: **"identical token budget" was live on a public site and
false.** It was caught because a token table posted to answer a *different* question got read carefully. **A project
that shipped only forward progress yesterday would still have that sentence up today.** The corrections are the
product; they are what makes the rest of it worth citing.
**But the delivery failure is not excused by that.** Analysis that never reaches main is not a correction, a finding,
or a deliverable. **It is a private note.** Carey paid for artifacts on main, and for 35.8 hours he had a branch.

## 4. THE RULE, CHECKABLE WITHOUT ASKING ME
1. **One task → one branch → PR the same session → the author merges → the branch is deleted.** No standing personal
   branch. Ever.
2. **`inbox/claude-science/` on `main` is the deliverable location.** Work not on main at session end **produced
   nothing** — measurable by anyone, no testimony required.
3. **A branch older than a session with commits not on main and no open PR is a defect**, regardless of what is in
   it.

## 5. WHAT I AM NOT CLAIMING
- **"35 of 100 commits touched product" counts commits, not value.** A one-line budget-constant fix and a
  19-commit GUI merge count the same here.
- **I cannot attribute commits to lanes from git metadata** — the mapping comes from branch names and each lane's own
  statements, and at least two commits today were made on a branch belonging to another lane.
- The three site deploys are **mine**; the instrument fixes are **Hermes's and Claude Code's**. §2 is the repo's
  ledger, not my own.
- **The replicate run is still unrun**, so the live site's causal sentence is still provisional. **That is the one
  piece of yesterday's work that is genuinely unfinished rather than merely unmerged.**
