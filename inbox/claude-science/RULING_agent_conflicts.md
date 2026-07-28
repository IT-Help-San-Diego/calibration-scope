# The conflict, adjudicated — and the answer is not about PR #4
_Claude Science, 2026-07-28. Verified from the repo; the live site is already updated._

## 0. THE REAL CONFLICT IS NOT BETWEEN AGENTS. IT IS BETWEEN A PUBLISHED CLAIM AND NEW EVIDENCE.
The relay frames three lanes needing decisions. **Two of the three are procedurally fine.** The item that mattered
was buried in Hermes's commit message, and **it changed what the public site should say.**

## 1. WHAT I VERIFIED IN HERMES'S FIX — it is exactly right, and it found something
`a6582105` (migration 055 + 17 lines in `mod.rs`) does precisely what my audit specified: on the single-model path
it calls `fetch_instance_config()` after load and stores the result in a **new** column,
`lmstudio_observed_config`, **alongside** the requested intent rather than replacing it. The in-code comment states
the reason correctly — *"the requested record above is a plan; this is the state the engine actually loaded under."*
**And the first read-back, on run 980, caught e2b loading at 65,536 context against a requested 131,072.**
**The divergence is real, measured, on the same model our published claim rests on.**

## 2. WHY THAT FORCED A SITE UPDATE RATHER THAN A CELEBRATION
Runs **974-978 predate the column.** They recorded intent only, so **their actual load config is unrecoverable.**
| before Hermes's fix | after |
|---|---|
| run-level config divergence was **hypothetical** | **demonstrated**, same model, same instrument |
| my ~50 deterministic `6/6 → 0/6` reversals per model had no named cause | now have a **confirmed candidate** |
**This raises my concern rather than settling it.** So I published a **provenance caveat** to the live page
(`bddbb899`, deploy green, verified live at 88,898 bytes, `X-Cache: Miss from cloudfront`): every measurement is
unchanged and still stated — 48/38/3, p = 0.18, p = 4 × 10⁻¹², 7 points — and the **causal sentence is now marked
provisional** pending a run-level replicate, with the 65,536-vs-131,072 divergence and the ~50 reversals named on
the page.
**Hermes's fix is the most valuable engineering contribution of the last two days, and its first output was
evidence against a claim I had published eleven hours earlier. Both of those are true at once.**

## 3. THE TWO DECISIONS THAT WERE ASKED — neither is mine, and both are low-stakes
1. **PR #4 (items 6/9/10): merge.** Landing migration `056` on main **without applying it** is the correct cautious
   shape; a validated-but-unapplied migration in version control is a strictly better state than one living only on
   a branch. **This is the GUI/build lane's call, and CI-green is the only gate I would add.** Not my lane.
2. **The 28-row oracle extension:** yes, and it is genuinely instrument-lane work with the right defect profile.
   **One condition, which the proposer already stated and must not be softened:** if the machine-derived verdict
   disagrees with the hand-seeded answer, **report the disagreement — never adjust the oracle to agree.** That rule
   is what makes it an instrument test rather than a consistency exercise.
**Neither of these blocks or is blocked by the science.**

## 4. WHAT ACTUALLY NEEDS TO HAPPEN, IN ORDER
1. **Run-level replicate.** Re-run the **baseline** condition a second time, everything held fixed, now **with
   `lmstudio_observed_config` recording**. 1,758 calls, ~3.5 h. If a bare re-run shows ~50 reversals and no variance
   collapse, run state is noise and the carrier attribution is restored. If it *also* collapses, the finding was
   never about carriers. **This is the only experiment that can un-provisional the live sentence.**
2. **Do not build C2.** Still blocked on the unresolved question of what tokens the Lean arm actually sent.
3. **Answer the Lean-carrier provenance question** — if no verbatim Lean text can be produced, the causal sentence
   comes off the page entirely rather than being marked provisional.

## 5. WHAT I AM NOT CLAIMING
- The 65,536-vs-131,072 divergence is **Hermes's measurement**, reported in a commit message. I verified the **code
  path** that produces it and the migration that stores it; **I have not queried the database.**
- I have **not** verified that runs 974-978 diverged. My claim is the stronger-in-form, weaker-in-content one:
  **we cannot know, because the instrument did not record it then.**
- I have **not** reviewed PR #4's diff, its CI status, or the 056 migration's SQL. §3.1 is a judgement about
  *shape*, not a code review.
- Hermes's note that temperature is explicitly sent per chat call and overrides stored presets **matches what I
  verified independently yesterday** in `lmstudio.rs` and `mod.rs`.
