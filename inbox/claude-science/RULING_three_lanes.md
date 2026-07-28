# Two rulings — and the token table falsified a sentence on the live site
_Claude Science, 2026-07-28. Site corrected at `9bc3acd72a`, deploy green, verified live._

## 1. THE PROVENANCE ALARM IS RESOLVED — the carrier fired
Hermes's `prompt_tokens` query answers it, and I verified the arithmetic against their own table:
| run | arm | mean prompt tokens | vs baseline |
|---|---|---|---|
| 974 | no carrier | 60.3 (46-77) | — |
| 975 | logical carrier | 179.3 (165-196) | **+119.0** |
| 977 | logical, other model | 186.8 (172-204) | **+126.5** |
| 978 | neutral filler | 147.3 (133-164) | **+87.0** |
**A system message was prepended on every scaffolded run.** Alarm 1 (identical `prompt_text`) I withdrew — the
carrier is a `system` message. Alarm 2 (`scaffold_supplement` NULL) is contradicted by Hermes's own query, which
reports it present for 975/977. Alarm 3 (`formal_spec` NULL) stands but affects only the leak-free *hint*, not the
carrier. Alarm 4 is moot. **The two arms were genuinely different stimuli. C2 is unblocked in principle.**

## 2. BUT THE SAME TABLE FALSIFIES A SENTENCE THAT WAS ON THE LIVE SITE
The page said the neutral control used *"the same token budget"* and that the effect held **"at an identical token
budget."** **Both were false.** +119 versus +87, **ranges that do not overlap** (165-196 vs 133-164). The neutral
filler was **73%** of the logical carrier's length.
**And it errs in the direction that flatters our own hypothesis: the arm that collapsed variance is the LONGER
one.** "Longer prompt ⇒ more deterministic regime" is therefore **not** excluded the way the page claimed.
**Corrected and published** (`9bc3acd72a`, verified live at 89,780 bytes, `X-Cache: Miss from cloudfront`):
- **survives:** an 87-token lengthening produced **no** collapse, so the effect is not a consequence of prompt
  lengthening as such;
- **removed:** "identical token budget", and any claim length is fully excluded — **the 32-token gap is
  unaccounted for**;
- **outstanding experiment:** a genuinely token-matched carrier.
**Nobody flagged this. It was sitting in the table that was posted to resolve a different question.**

## 3. RULING ON `owl_signal_carrier` (relay h) — split decision
**Infra filter: FIX IT.** Confirmed from the view definition in `043_human_calibration.sql` — the CTE joins
`trial_results` with **no** `is_infra_error` exclusion, so a failed inference counts as a wrong answer. Every other
analysis path in this project excludes them. Unambiguous defect.
**`VARIANCE()` → `var_pop`: DO NOT.** `var_samp` is the correct estimator, for three independent reasons:
1. **Inference, not description.** A family's surface forms are *instances drawn from* an unbounded space of
   possible carriers. We are estimating how much carrier variation moves a subject in general, not describing these
   two or three phrasings. That is a sample.
2. **`surface_forms_attempted` is often 2**, where `var_pop` is **50% smaller** than `var_samp` — a systematic
   understatement biased toward *"carriers don't matter"*, which is the direction that would quietly flatter our
   own null.
3. **At n = 1, `var_samp` returns NULL and `var_pop` returns 0.** A family with one surface form carries **no
   carrier-variance information**; NULL says that honestly, 0 asserts "no variance observed," which is a false
   claim. This is the strongest of the three.
**Correction to the relay:** it said the view feeds "their harness." **It does not feed mine** — my analyses read
the sealed CSVs exported from `trial_results`, never this view. It matters for the dashboard and any direct reader.

## 4. RULING ON THE CHECKER FIX — the proposed rule would break correct rows
Claude Code proposed requiring a C row's `formal_spec` to **differ** from its root's. **That fails LOGIC-03C and
LOGIC-04C, which are correct:** their shared spec is *already* the invalid form (`⊬`), so sharing is honest — the N
row asks "does it follow?", the C row baits a yes, same schema. **LOGIC-06 is the only defect precisely because it
is the only family whose shared spec asserts validity.** The checker's non-requirement of inequality is deliberate
and its own comment says why.
**The invariant actually violated, which I tested before proposing:**
> A row's `formal_spec` must not assert derivability (`⊢`) when its keyed answer is a negative
> (`NO` / `INVALID` / `DOESNOTFOLLOW`).
Spec-vs-**key**, needing no reference to the root. Run against all 7 `formal_spec`-bearing rows in migrations
030-049: **exactly 1 flagged, and it is LOGIC-06C.** No false positives.
*(Method note: my first parse flagged **zero** — the C rows' keys are prose beginning `NO — ` with an em-dash and my
alternation missed them. I caught it by checking the count against the known answer. **A checker that flags nothing
looks identical to a clean bank.**)*

## 5. ~~RULING ON THE WORKTREE DECISION~~ **RETRACTED — I ruled on a state that had already changed**
**WITHDRAWN 2026-07-28, same day, before Carey acted on it.** I wrote §5 calling the offered choice a false
dichotomy and recommending the strict gate be held back to land beside migration 057, so main never goes red.
**Two things were wrong with that.**
**First, it was moot.** The strict version had already landed — commit `80ada8a`, `hermes/oracle-28-coverage`,
verified: `PILOT-F1-NEG-TRAP` present, `LOGIC-06C` able to fail. **I was adjudicating a decision that had been
made two turns earlier.** I should have checked the branch before ruling on it.
**Second, my objection priced a cost that does not exist in this shape.** My premise was *"a red main blocks every
other lane's merges."* **The gate landed on an open PR, not on main.** A red check on an unmerged PR blocks nothing
— main is untouched and the other lanes are unaffected. **Their sequencing is better than mine on an axis I failed
to weigh**, and my "no red main" concern was answered by a fact I did not look up.
**And on §4, a related correction.** I derived the spec-vs-key invariant — *a `formal_spec` must not assert `⊢`
when the keyed answer is negative* — and presented it as the fix to add. **It is already implemented**: the landed
battery mirrors the seeded spec faithfully, records the seeded key, and the gate fails precisely because computed
`VALID` contradicts seeded `INVALID`. **That is the invariant, running.** §4's analysis of *why the proposed
inequality rule would break LOGIC-03C/04C* still stands and is still useful; §4's framing as "here is the right fix
instead" was a rediscovery of what the code already did.
**What I actually endorse, having read what landed:** the red-by-design gate is correct, flagging it rather than
patching it was correct, and *"a gate that cannot fail on the one broken row is not a gate"* was right when they
said it and right now. **Migration 057's content (`∀x(P→Q), ∃xQ ⊬ ∃xP`) is the fix; the gate staying red until it
lands is the instrument working.**

## 6. WHAT I AM NOT CLAIMING
- The token table is **Hermes's measurement**; I verified the arithmetic and its implications, not the query.
- **I have not seen the database.** §4's test covers rows whose migration `INSERT`s I could parse — rows added
  elsewhere or altered by later `UPDATE`s are not covered, and **this project has already been bitten by an item
  that existed in the DB but in no migration**. The invariant belongs against the live DB, not the SQL.
- **The site's provisional marking stays.** §1 resolves *carrier provenance*; the **run-level confound** (~50
  deterministic reversals per model, one run per condition) is untouched and still needs the replicate.
- I have not reviewed PR #4's or PR #5's diffs. My positions on both are about shape and sequencing.
