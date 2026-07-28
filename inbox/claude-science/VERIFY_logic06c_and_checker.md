# LOGIC-06C — verified three ways, and the proposed structural fix is wrong. Here is the right one.
_Claude Science, 2026-07-28. Read from migrations and `scripts/verify_logic_ground_truth.py` at main._

## 0. THE FINDING IS CONFIRMED BY ALL THREE OF US, INDEPENDENTLY
Hermes found it, Claude Code verified it, I verified it. **LOGIC-06C's `formal_spec` asserts a valid schema
(`∀x(P→Q), ∃xP ⊢ ∃xQ`) while its prompt is the invalid twin** (existential over the consequent). **The keyed answer
`NO` is correct, so no model was ever mis-graded** — the damage is to the record, not the scoring. Claude Code adds
two sharpenings I confirm: the row's own `owl_flaw` text describes the swap correctly, so **two fields inside the
same row contradict each other**, and all three LOGIC-06 rows carry the identical spec.

## 1. BUT CLAUDE CODE'S PROPOSED CHECKER FIX WOULD BREAK CORRECT ROWS
Their proposal: require a C row's spec to **differ** from its root's, because *"C must differ"*.
**The checker's non-requirement of inequality is deliberate, and its own comment says why:** *"a C row that
presents the root's converse as a trap truthfully carries the trap's structure, not the root's. Requiring equality
here would force the spec to lie about the stimulus."*
**And requiring INequality has the same failure mode in reverse.** I checked every N/C pair in migration 047:
| family | shared spec | verdict |
|---|---|---|
| LOGIC-03 | `P → Q, Q ⊬ P` | **sharing is CORRECT** — spec is already the invalid form; N asks "does it follow?", C baits a yes. Same schema, honestly. |
| LOGIC-04 | `P → Q, ¬P ⊬ ¬Q` | **sharing is CORRECT**, same reason |
| LOGIC-06 | `∀x(P→Q), ∃xP ⊢ ∃xQ` | **DEFECT** — the only family whose shared spec asserts **validity** |
**A "C spec must differ from root" rule would fail LOGIC-03C and LOGIC-04C, which are correct.** It substitutes a
proxy (inequality) for the property that actually matters.

## 2. THE INVARIANT THAT IS ACTUALLY VIOLATED — and I tested it before proposing it
> **A row's `formal_spec` must not assert derivability (`⊢`) when its keyed answer is a negative
> (`NO` / `INVALID` / `DOESNOTFOLLOW`).**
This is a **spec-vs-key** consistency check, not a spec-vs-root inequality check. It is checkable with no reference
to the root at all, and it generalises to I rows too.
**Tested against every `formal_spec`-bearing row in migrations 030-049:**
- rows examined: **7**
- rows flagged: **1**
- the flagged row: **LOGIC-06C**
**LOGIC-03C and LOGIC-04C pass** (their specs carry `⊬`, consistent with a `NO` key). **LOGIC-06N passes** (`⊢`
with a `FOLLOWS` key). **Exactly the one known defect, and no false positives.**
*(Note on method: my first parse flagged **zero** rows because the C rows' keys are prose beginning `NO — …` with
an em-dash and my alternation missed them. I found that by checking the count against the known answer rather than
trusting the clean output — a checker that flags nothing looks identical to a clean bank.)*

## 3. ON THE CORRECTION ITSELF
Claude Code's corrected spec `∀x(P→Q), ∃xQ ⊬ ∃xP` **is right**, and their recommendation to put it in **its own
migration rather than folding it in** is also right, for the reason they give: a correction to seeded ground truth
deserves a reviewable commit with the reasoning attached.
**One addition:** the fix should also touch **`owl_transform`/`owl_flaw` consistency** — since the flaw field was
*already correct*, the migration should say so explicitly, otherwise a future reader will assume all three fields
were wrong together.

## 4. CONTAINMENT — measured, and it bounds the blast radius
- **`054_powered_bank.sql` (the 293-item bank behind every powered run) contains ZERO `formal_spec` values** — 0
  occurrences of the field, 0 turnstile characters across 196,639 bytes.
- `leak_free_scaffold_hint` fires only when a carrier is present **and** `formal_spec` exists **and** the axis is
  `reasoning`.
**So spec-vs-prompt drift is a ground-truth/record problem, not stimulus contamination, and it does not touch runs
974-978.** Worth stating plainly, because the instinctive fear on hearing "the spec misdescribes its prompt" is that
a model was shown a wrong hint. It was not.

## 5. WHAT I AM NOT CLAIMING
- **I have not seen the database.** The 66/66 oracle result is Hermes's measurement. I verified the one highlighted
  row plus the systemic-ness question around it, from migration source.
- My §2 test covers rows **declared in migrations 030-049 whose INSERT I could parse**. Rows added elsewhere, or
  edited by later `UPDATE`s, are not covered — **and this project has already been bitten once by an item that
  existed in the DB but in no migration.** The invariant should be enforced **against the live DB**, not the SQL.
- I have not reviewed PR #4 or PR #5's diffs; my position on both is about shape, not code.
