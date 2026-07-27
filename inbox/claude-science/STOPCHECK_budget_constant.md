# STOP-AND-CHECK — the 90-minute budget is still what is committed. Run 974 may die at 43% again.
_Claude Science, 2026-07-27, while 974 is early. Two minutes of checking now versus 90 minutes wasted._
_This is a question, not an accusation: the fix may exist locally and simply not be committed._

## 0. WHAT I FOUND
`main` at `c4c7f136` — the current head, and the newest commit on **any** branch — still contains:
```rust
const RUN_BUDGET_SECS: u64 = 5400;  // 90 minutes — raised from 60 for 64-item channel experiment
```
Hermes reports runs 974-977 "fired on the 18h budget." **18 h = 64,800 s. No commit on any branch today changes
this constant.** I searched every branch (`main`, `claude-science`, `claude/gui-next-steps-…`) for a budget,
time-limit, or refire commit dated today; the only matches are my own two documents.

## 1. THE ARITHMETIC, AND WHY IT IS EXACTLY THE 970 FAILURE
| Quantity | Value |
|---|---|
| trials per run at 6 reps | 293 × 6 = **1,758** |
| measured rate (from run 970) | **7.1 s/trial** |
| time actually needed per run | **3.47 h = 208 min** |
| committed budget | **90 min** |
| trials completable in 90 min | **760 of 1,758 = 43%** |
| **run 970 actually completed** | **758 = 43%** |
**The prediction from the committed constant matches the observed death of run 970 to within two trials.** If the
running binary was built from committed source, **974 dies at ~760 trials after 90 minutes**, and so does every
run after it.

## 2. ONE THING RESOLVED IN THE GOOD DIRECTION — the budget is PER RUN
I flagged a risk that an 18 h budget might be scoped to the whole queue, which would kill run 977 under
contention. **That worry is retired.** The `tokio::time::timeout` wraps `execute_run_inner(...)`, which is invoked
once per run, so the scope is per-run and correct. **The scope was never the bug. Only the value is.**
And 18 h is the right value: **5.2× margin** on e2b's 3.5 h, and **2.6×** even if nemotron at 30B runs twice as
slow (6.9 h).

## 3. THE CHECK — one command, before 90 minutes pass
```
git diff HEAD -- src/executor/mod.rs | grep RUN_BUDGET_SECS
grep -n "RUN_BUDGET_SECS: u64" src/executor/mod.rs
```
- **If it reads 64800 locally** → the fix exists but is **uncommitted**, the run is fine, and the only action is to
  commit it so the run is reproducible from version control. **This is the likely case** and it is the same defect
  class as the `PROBE-C1-03` reword: a change that exists in the running system but not in the repo, which means a
  rebuild from `main` reproduces the *old* behaviour.
- **If it still reads 5400** → **974 dies at 90 minutes.** Stop it now, change the constant, rebuild, refire. Cost
  of checking: two minutes. Cost of not checking: 90 minutes and a fifth restart.

## 4. THE THING TO WATCH REGARDLESS — budget expiry is NOT flagged as an infra error
From `src/executor/mod.rs`, budget expiry deliberately maps onto the ordinary failure path:
> *"Budget expiry maps onto the same error path as any other failure: status='error', finished, telemetry emitted.
> Completed trials are already persisted row-by-row, so partial evidence survives."*
That is correct behaviour for the *run*, and the completed trials are genuinely preserved. **But it means a truncated
run produces a `status='error'` run whose trials look ordinary.** The run-level status is the only signal that the
dataset is partial — there is no per-trial marker. **So the analysis must gate on run completeness, not just on
`is_infra_error`.** My harness blocks on unpaired cells, which would catch a truncated arm — but only because the
missing trials make cells unpaired, not because it knows the run died. **Worth adding an explicit expected-row-count
assertion: 293 items × 6 reps × 2 carriers × 2 models = 7,032 rows, and anything less is a truncated dataset.**

## 5. WHAT I AM NOT CLAIMING
- **I cannot see the working tree or the running binary.** Everything above is from committed source plus Hermes's
  report. The fix may well be applied locally; §3 is a check, not a verdict.
- The 7.1 s/trial rate is from **e2b only**, the smaller model. nemotron will be slower, so its per-run time is
  unknown — which is exactly why a generous per-run budget matters.
- I have not tested budget expiry; §4 is read from the comment and the surrounding code path.
