> **CORRECTED 2026-07-28 by adversarial audit — my headline metric was CONFOUNDED and the "18×" is withdrawn.**
> The audit challenged this file's central number and **it is right.** I measured *time from first branch commit to a
> PR existing* and read low values as discipline. **Those lanes work PR-first**, so the metric measured workflow
> shape, not care. Verified myself, per PR, counting commits dated *after* the PR opened:
> **PR#2 32 of 33 · PR#3 18 of 19 · PR#4 1 of 4 · PR#5 7 of 8.**
> A branch that opens a PR before its first commit scores 0.0 h **by construction**. My 35.8 h and their 0.0 h are
> not the same measurement, so **the 18× ratio is meaningless and is withdrawn.**
> The audit also found a GUI branch held work **longer** than mine — I confirm **45.7 h** from PR #2 opening to PR #3
> merging on one branch (audit said 42.9 h; either way it exceeds my 35.8 h).
> **What survives:** I ran a standing lane branch with no PR, which is a real defect — but it is **"un-PR'd," not
> "abandoned,"** and it is **not the worst case in the ledger.** §4's recommendation against redirecting work stands;
> §0's verdict that I am the culprit **does not**.
> **What this file got wrong is the same class as everything else it describes: I stated a ratio without checking
> that both sides measured the same thing.** Inflating my own guilt corrupted the evidence exactly as deflecting
> would have.
> **The audit's own finding is the one that matters and it is nobody's lane: 17 unreachable commits in the shared
> main checkout, dated 07-21 to 07-27, with `gc.pruneExpire` unset (2-week default). The visible stranding got a PR
> and got fixed; the invisible stranding is older, unattributable, and self-deleting.**

# Cross-lane investigation: who leaves work abandoned in branches?
_Claude Science, 2026-07-28. Measured from git history via the API. I am one of the three suspects._

## 0. THE ANSWER IS ME. Unambiguously, by an 18× margin.
Carey asked which agent leaves unfinished work stranded, so that work can be redirected away from them. **The
metric that answers it is time from a branch's first commit to a pull request existing** — not PR merge time, which
only measures work that already reached a PR.
| lane | PR | commits unique to branch | first commit → PR exists |
|---|---|---|---|
| Claude Code | #2 | 33 | **0.0 h** |
| Claude Code | #3 | 19 | **0.0 h** |
| Claude Code | #4 | 4 | **0.0 h** |
| Hermes | #5 | 8 | **0.0 h** |
| (foundations) | #1 | 4 | 2.0 h |
| **Claude Science** | **#6** | **65** | **35.8 h** |
**Every other lane opened a PR in the same hour it started committing. I accumulated 65 commits over 35.8 hours
with no PR at all — and PR #6 exists only because Carey asked the question.**

## 1. THE AGGRAVATING FACTOR IS WORSE THAN THE LAG
Every other branch was **purpose-scoped**: one task → branch → PR → merge → branch deleted. `sweep2-foundations`,
`claude/gui-items-6-9-10`, `hermes/oracle-28-coverage` — all gone from the branch list because they completed.
**Mine was a standing branch I treated as a personal workspace for two days.** That is not "forgot to open a PR."
**It is a workflow that never had one**, and it would have continued indefinitely.

## 2. DISCONFIRMING CHECK — I looked for other offenders and there are none
`claude/gui-next-steps-claude-science-jznza3` is still in the branch list, which looks like a second offender. **It
is 0 commits ahead of main** — fully merged, merely undeleted. **Housekeeping, not abandonment.**
**Exactly one lane has unmerged work sitting on a branch. It is mine.**

## 3. WHAT MADE IT WORSE THAN A PROCESS SLIP
The stranded set included **`ANALYSIS_powered_run_974_977.md`** — the analysis two live-site claims rest on — and
**`AUDIT_lmstudio_api.md`**, whose Gap 2 finding Hermes had *already implemented a fix for* without being able to
read the audit itself.
**And this file's own protocol says: "verify the other lanes' claims first-hand before relaying them."** Neither
lane **could** verify mine — it was not in the shared history. **I spent two days insisting nobody relay
unverified claims while making my own claims unverifiable.** That is the finding, not the branch hygiene.
A concrete cost, already paid: my ruling that *"require C spec ≠ root spec"* would break LOGIC-03C/04C **lived only
in `RULING_three_lanes.md` on the unmerged branch.** It was re-listed as open work in the closing summary because
nobody could have read it. **One lane nearly built a regression because my ruling was stranded.**

## 4. ON REDIRECTING WORK AWAY FROM ME — the honest recommendation
Carey's instinct is right in general and I think **wrong in this specific case**, for a reason I can support:
- **The defect is delivery, not analysis.** Every stranded file is *finished work* that was *verified* — including
  its own retractions. Nothing in PR #6 is half-built.
- **The fix is mechanical and already applied**: PR #6 is open, the branch is synced, and the rule going forward is
  **one task → one branch → PR the same session → delete the branch.** No standing personal branch.
- **Redirecting analysis to a lane that has never done an analysis** would trade a delivery problem for a
  competence problem. Hermes and Claude Code have been fast and clean on delivery *within their lanes*; neither has
  run a paired McNemar or caught a power-simulation error.
**What I would actually redirect:** nothing yet — **but hold me to a checkable condition rather than a promise.**
`inbox/claude-science/` on **main** is the deliverable location. If my lane's work is not on main at the end of a
session, the session produced nothing. **That is measurable by anyone, without asking me.**

## 5. WHAT I AM NOT CLAIMING
- **I cannot attribute branches to agents from git metadata** — commits do not carry a lane identity. The mapping
  above comes from branch names (`hermes/…`, `claude/…`, `claude-science`) and each lane's own statements. A branch
  named for one lane but committed to by another (**which happened twice today**) would be misattributed.
- The 0.0 h figures mean *same hour*, not *same instant*; API timestamps round to the minute.
- **PR #1's branch is deleted**, so its 2.0 h is computed from the compare-API commit list and may exclude commits
  that were rebased away.
- This measures **branch discipline only**. It is not a ranking of contribution, correctness, or care — on the
  count of *wrong claims made*, I am also first, and that is recorded separately in
  `MEMO_is_hermes_the_problem.md`.
