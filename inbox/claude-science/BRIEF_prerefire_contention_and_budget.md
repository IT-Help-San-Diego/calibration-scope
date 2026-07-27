# Pre-refire brief — your consulting sessions are safe, and two things to settle before 14 hours burn
_Claude Science, 2026-07-27. Written from the committed Rust source and the measured rate of the dead run 970._

## 0. THE CONTAMINATION QUESTION — answered from the source, and the answer is good
Zoho Assist screen-share plus FaceTime audio compete for GPU and memory bandwidth on a Mac. The risk is not that
the run slows down; it is whether a **contention-induced timeout gets recorded as a WRONG ANSWER instead of as
missing data.** That would be silent contamination that passes every gate.
**It does not.** Traced in `src/executor/lmstudio.rs` and `src/executor/mod.rs`:
```
/api/v0/chat/completions  .timeout(Duration::from_secs(90)).send().await?  .error_for_status()?
```
Both `?` operators propagate to `Err`, and the `Err(e)` branch in `executor/mod.rs` sets **`is_infra_error = true`**.
Two further guards back it up: an empty `raw` response sets infra, and `latency_ms == -1` with empty raw sets infra.
**A timeout is recorded as MISSING, never as a failure. Take your calls.**

## 1. HOW MUCH SLOWDOWN THE RUN TOLERATES — measured, not assumed
Run 970 died at 90 minutes having completed 758 of 1,758 trials. That is a **measured 7.1 s/trial** under no
contention — which is where the ~14 h total comes from, and it is the first rate figure in this project grounded in
data rather than estimate (earlier guesses ran 8 s and 28 s; the truth is 7.1 s).
| Slowdown from screen-sharing | s/trial | 4-run total | Timeouts? |
|---|---|---|---|
| 1.0× | 7.1 | 13.9 h | no |
| 2.0× | 14.2 | 27.8 h | no |
| 3.0× | 21.4 | 41.7 h | no |
**The inference timeout is 90 s against a 7.1 s baseline — 12.6× of headroom.** Screen-share and audio will not
come close. **Practical effect: the run gets slower, not wrong.**

## 2. THE ONE THING TO CONFIRM BEFORE REFIRING — is the 18 h budget PER RUN or PER QUEUE?
This is the same class of bug that just killed run 970, and the answer changes whether it recurs.
- One run at 6 reps needs **3.5 h** (293 × 6 × 7.1 s). **Per-run budget of 18 h → 5.2× margin. Safe.**
- All four runs need **13.9 h**. A **whole-queue** 18 h budget fits at full speed — but **at only 1.3× slowdown it
  becomes 18.0 h and run 973 dies mid-flight**, exactly the failure we are recovering from, and your consulting
  sessions are plausibly a 1.2–1.5× load.
**Recommendation: make the budget per-run, or set the queue budget to ≥30 h.** The cost of over-provisioning is
zero; the cost of under-provisioning is a fourth arm lost after 14 hours.

## 3. USE THE 758 DEAD TRIALS TODAY — they can run the pre-registered length gate before the refire
Those trials are a real e2b baseline sample covering roughly 43% of the bank. They are useless for the carrier
contrast (no Lean arm), but they are **exactly what the length gate needs**, and the gate is the one check that
could invalidate the whole bank:
- A **length-only rule scores 0.874 on quant-scope** (majority baseline 0.533). If baseline accuracy is already
  landing near 0.874 with Spearman(length, pass) ≥ 0.30, **the class is partly being scored on stem length** and
  its off-ceiling yield is illusory — which means fixing the bank *before* spending 14 hours, not after.
- **CORRECTION (2026-07-27, auditor-caught): the claim that this "runs in one command" was FALSE when written.**
  `analyse()` blocks baseline-only input *before* reaching the gate — a single carrier trips `len(carriers) != 2`,
  every cell trips `UNPAIRED CELLS`, and the `is_infra_error` rows I asked to be included block as well. The gate
  was unreachable on exactly the input I was requesting. **Fixed:** a standalone entry point now exists —
  `python3 carrier_analysis.py --gate <baseline.csv> <powered_bank_base.json>` — which skips the paired-design
  gates, drops infra rows, reports bank coverage, and **BLOCKS rather than silently skipping when the bank file is
  missing** (previously a bare `try/except` would have omitted the gate with no warning). Verified by self-tests
  T8 (`analyse()` still correctly blocks baseline-only input), T9 (`gate_only()` reaches the gate for both classes),
  T10 (a missing bank blocks instead of skipping). **Export the 758 rows with columns
  `item_id, probe_class, pass` minimum — `is_infra_error` welcome and dropped automatically — plus
  `analysis/powered_bank_base.json`, and the gate runs.**
**This is the highest-value 10 minutes available right now**, because it is the only check that can still change
the decision to spend the machine.

## 4. ON REP COUNT — 6 was the right call, and here is the number behind it
Not a preference, a resolution question. At 293 items the design resolves **d ≥ 0.05 at power ~0.78**; at 3 reps
that falls, and d = 0.05 is precisely the resolution needed to *locate* a threshold rather than merely detect a
large effect. §10.9's question is *where* immunity begins. **6 reps buys the answer to that question; 3 reps buys
only "there is or is not a big effect."** Given the run is now ~14 h rather than ~55 h, the choice is cheap.

## 5. WHAT I AM NOT CLAIMING
- **The 7.1 s/trial figure is from one partial run of one model.** e2b is the smaller model; nemotron at 30B will
  be slower, so 13.9 h is a floor, not a forecast. If nemotron runs 2× slower, expect ~21 h.
- I read the timeout handling from the committed source, **not from a running process**. I have not observed a
  contention-induced timeout being classified; the code path is clear but untested under actual GPU contention.
- **The 90 s timeout applies to the chat call.** Model *load* uses a separate `max_wait_secs`, which I did not
  trace to its default — a load stall under contention may behave differently from an inference stall.
- I have not seen the budget code. §2 is a conditional recommendation based on Hermes's description of "the new 18h
  budget," not a reading of the implementation.
