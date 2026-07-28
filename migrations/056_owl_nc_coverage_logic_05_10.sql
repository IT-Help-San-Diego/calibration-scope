-- v056: Owl Semaphore N/C family coverage — instrument five one-form logic
-- families: LOGIC-05, LOGIC-07, LOGIC-08, LOGIC-09, LOGIC-10.
--
-- SCOPE, stated plainly: these five are NOT the last one-form families.
-- After this migration 19 LOGIC-* families are still not fully instrumented
-- (LOGIC-02, which has a C but no N, and LOGIC-12 through LOGIC-29, which
-- have neither), plus the PILOT-*, PROBE-*, QS*, DF*, LIT-*, VVP-*, TOOL-*
-- and SEC-* families. This migration takes fully_instrumented families from
-- 5 to 10 out of the registry. It does not finish the job.
--
-- STATE BEFORE THIS MIGRATION (verified against the live registry, not
-- assumed from the handoff note): those five Identity rows each had zero
-- N and zero C siblings, so owl_family_coverage reported them
-- fully_instrumented = false. With one surface form apiece, the pooled
-- pass rate for those families is a single measurement and the across-form
-- variance is not measurable at all — the view was honestly reporting a
-- gap, and this migration closes it. LOGIC-01/02/03/04/06/11 already had
-- siblings (047/048) and are untouched here.
--
-- Discipline (unchanged from 047/048/036):
--   * N rows keep the EXACT formal_spec of their root — a rewording that
--     changed the logic would not be a rewording. The one-word answer is
--     the demodulated truth value: TRUE/FALSE for the equivalence items and
--     SAT/UNSAT for satisfiability, which are the roots' own vocabularies;
--     FOLLOWS/DOESNOTFOLLOW for the two entailment items, whose roots
--     (LOGIC-05, LOGIC-10) actually answer VALID/INVALID. That token swap
--     is deliberate — it follows 047's N-row shape, and scoring.rs
--     verdicts_match treats each row against its OWN expected_result, so
--     the roots and their N rows are graded independently.
--   * C rows carry a DIFFERENT formal_spec — the TRAP's own structure,
--     truthfully labelled — plus owl_transform and owl_flaw (DB-enforced
--     by owl_c_completeness, migration 036).
--   * Every C row's expected_result is computed from the TRAP's spec, NOT
--     copied from the root. All ten verdicts below were machine-derived by
--     scripts/verify_logic_ground_truth.py before this file was written,
--     and each new row now has a matching entry in that oracle's battery
--     so the derivation is re-runnable rather than taken on faith. The
--     countermodels quoted in the C expected_result strings are the ones
--     the oracle prints.
--   * No answer leakage: no prompt names the fallacy it is testing; the C
--     prompts ask for the error only AFTER the verdict, mirroring 047.
--   * Roots are resolved by NAME, never by raw id (the rule 048 put on the
--     record). If a root name ever fails to resolve, owl_root_id lands
--     NULL and owl_root_consistency aborts the migration — loud failure,
--     not a silently mis-rooted family.
--   * Idempotent via WHERE NOT EXISTS on the child name (the 051/052
--     pattern); `tests` has no unique index on name, so re-running an
--     unguarded INSERT would duplicate rows.
--
-- owl_transform vocabulary: 036 anticipated lexical_substitution |
-- narrative_reframing | domain_transfer | unit_conversion and declared the
-- column free text so the taxonomy could grow. Three of those are used
-- below as-is — domain_transfer (x4), narrative_reframing (x3) and
-- lexical_substitution (x2); unit_conversion does not fit any row here and
-- is not used. LOGIC-09C needed a value outside that set — its surface change is neither a
-- reword nor a domain move but two extra clauses appended to the same
-- formula — so it is labelled 'clause_extension' rather than forced into
-- an existing value that would describe it inaccurately.
--
-- NOT claimed here: nothing in this migration measures across-form
-- variance. It makes that measurement POSSIBLE for five more families by
-- giving each of them more than one form; whether the variance is then
-- worth anything is a separate question this file takes no position on.

-- ── LOGIC-05 Syllogism - Barbara (AAA-1) — root VALID ───────────────────
-- N: same ∀x(M→P), ∀x(S→M) ⊢ ∀x(S→P), new domain, demodulated answer.
INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method,
                   active, trials_per_run, formal_spec, owl_type, owl_root_id,
                   owl_transform)
SELECT
  'LOGIC-05N Barbara (reworded)',
  'reasoning',
  'Every deprecated API call is a compatibility hazard. Every call to sysctl_v1 is a deprecated API call. A migration guide states: "Every call to sysctl_v1 is a compatibility hazard." Does the guide''s statement follow from the two facts? Answer with exactly one word: FOLLOWS or DOESNOTFOLLOW.',
  'FOLLOWS',
  'exact',
  true,
  3,
  '∀x(M→P), ∀x(S→M) ⊢ ∀x(S→P)',
  'N',
  (SELECT id FROM tests WHERE name = 'LOGIC-05 Syllogism - Barbara (AAA-1)' AND owl_type = 'I'),
  'domain_transfer'
WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'LOGIC-05N Barbara (reworded)');

-- C: undistributed middle (AAA-2). Same three terms, same universal-
-- affirmative conclusion as Barbara — only the MAJOR premise is flipped,
-- putting the middle term in the predicate position of both premises.
-- Trap spec ∀x(S→M), ∀x(P→M) ⊬ ∀x(S→P); countermodel dom={0},
-- M(0)=true, P(0)=false, S(0)=true.
INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method,
                   active, trials_per_run, formal_spec, owl_type, owl_root_id,
                   owl_transform, owl_flaw)
SELECT
  'LOGIC-05C Barbara (adversarial: undistributed-middle trap)',
  'reasoning',
  'Premise 1: Every kernel panic is written to the crash log. Premise 2: Every OOM kill is written to the crash log. A triage note concludes: "Therefore every kernel panic is an OOM kill." Is this conclusion logically valid? Answer YES or NO, then name the specific error if any.',
  'NO — undistributed middle. Both premises only place kernel panics and OOM kills INSIDE the crash-log class; neither links the two classes to each other, so they may be entirely disjoint. The middle term ("written to the crash log") is the predicate of both premises and is therefore never distributed.',
  'exact',
  true,
  3,
  '∀x(S→M), ∀x(P→M) ⊬ ∀x(S→P)',
  'C',
  (SELECT id FROM tests WHERE name = 'LOGIC-05 Syllogism - Barbara (AAA-1)' AND owl_type = 'I'),
  'domain_transfer',
  'Barbara-shape bait: two universal affirmatives over three terms yielding a universal affirmative — visually identical to the valid AAA-1 root — but the middle term sits in the predicate slot of BOTH premises (figure 2), which makes the inference invalid'
WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'LOGIC-05C Barbara (adversarial: undistributed-middle trap)');

-- ── LOGIC-07 Boolean Algebra - De Morgan — root TRUE ────────────────────
-- N: same ¬(P∧Q) ⟷ ¬P∨¬Q, symbolic form restated as a narrative condition.
INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method,
                   active, trials_per_run, formal_spec, owl_type, owl_root_id,
                   owl_transform)
SELECT
  'LOGIC-07N De Morgan (reworded)',
  'reasoning',
  'A firewall raises a review flag whenever it is NOT the case that both the source is allowlisted and the port is open. An engineer rewrites that trigger as: the source is not allowlisted, OR the port is not open. Do the original trigger and the rewrite hold in exactly the same situations? Answer with exactly one word: TRUE or FALSE.',
  'TRUE',
  'exact',
  true,
  3,
  '¬(P∧Q) ⟷ ¬P∨¬Q',
  'N',
  (SELECT id FROM tests WHERE name = 'LOGIC-07 Boolean Algebra - De Morgan' AND owl_type = 'I'),
  'narrative_reframing'
WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'LOGIC-07N De Morgan (reworded)');

-- C: the negation pushed inside WITHOUT flipping the connective — one
-- symbol away from the correct law. Trap spec ¬(P∧Q) ⟷ ¬P∧¬Q;
-- countermodel A=false, B=true (left side true, right side false).
INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method,
                   active, trials_per_run, formal_spec, owl_type, owl_root_id,
                   owl_transform, owl_flaw)
SELECT
  'LOGIC-07C De Morgan (adversarial: connective-preserved trap)',
  'reasoning',
  'Expression: NOT (A AND B)  is logically equivalent to  (NOT A) AND (NOT B). Is this equivalence correct? Answer TRUE or FALSE, then name the specific error if any.',
  'FALSE — the negation was distributed over the conjunction without flipping the connective. De Morgan turns AND into OR: NOT (A AND B) is equivalent to (NOT A) OR (NOT B). Countermodel A=false, B=true: the left side is true, the right side is false.',
  'exact',
  true,
  3,
  '¬(P∧Q) ⟷ ¬P∧¬Q — NOT a tautology',
  'C',
  (SELECT id FROM tests WHERE name = 'LOGIC-07 Boolean Algebra - De Morgan' AND owl_type = 'I'),
  'lexical_substitution',
  'connective-preservation bait: differs from the correct De Morgan rewrite by a single symbol (AND where OR belongs), so "push the NOT inside" — the half-remembered version of the rule that omits the flip — produces exactly this string'
WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'LOGIC-07C De Morgan (adversarial: connective-preserved trap)');

-- ── LOGIC-08 Boolean Algebra - Distribution — root TRUE ─────────────────
INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method,
                   active, trials_per_run, formal_spec, owl_type, owl_root_id,
                   owl_transform)
SELECT
  'LOGIC-08N Distribution (reworded)',
  'reasoning',
  'A batch job runs when the queue is drained AND either the nightly window is open or an operator forced it. A colleague restates the rule as: the job runs when (the queue is drained and the nightly window is open) OR (the queue is drained and an operator forced it). Do the two statements of the rule fire in exactly the same situations? Answer with exactly one word: TRUE or FALSE.',
  'TRUE',
  'exact',
  true,
  3,
  'P∧(Q∨R) ⟷ (P∧Q)∨(P∧R)',
  'N',
  (SELECT id FROM tests WHERE name = 'LOGIC-08 Boolean Algebra - Distribution' AND owl_type = 'I'),
  'narrative_reframing'
WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'LOGIC-08N Distribution (reworded)');

-- C: A distributed over only the FIRST disjunct — the correct expansion
-- with one term dropped, so it reads as a tidy simplification. Trap spec
-- P∧(Q∨R) ⟷ (P∧Q)∨R; countermodel A=false, B=false, C=true.
INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method,
                   active, trials_per_run, formal_spec, owl_type, owl_root_id,
                   owl_transform, owl_flaw)
SELECT
  'LOGIC-08C Distribution (adversarial: partial-distribution trap)',
  'reasoning',
  'Expression: A AND (B OR C)  is logically equivalent to  (A AND B) OR C. Is this equivalence correct? Answer TRUE or FALSE, then name the specific error if any.',
  'FALSE — A was distributed over only the first disjunct. Correct distribution copies A into BOTH: (A AND B) OR (A AND C). Countermodel A=false, B=false, C=true: the left side is false, the right side is true.',
  'exact',
  true,
  3,
  'P∧(Q∨R) ⟷ (P∧Q)∨R — NOT a tautology',
  'C',
  (SELECT id FROM tests WHERE name = 'LOGIC-08 Boolean Algebra - Distribution' AND owl_type = 'I'),
  'lexical_substitution',
  'partial-distribution bait: the right-hand side is the correct expansion with one copy of A deleted, so it reads as a simplification rather than an error, and the two sides agree on every assignment except the ones where A is false and C is true'
WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'LOGIC-08C Distribution (adversarial: partial-distribution trap)');

-- ── LOGIC-09 Satisfiability — root SAT ──────────────────────────────────
-- N: the SAME formula, clause-for-clause, restated as three policy rules.
-- Clause 2 (¬A∨C) is stated as the implication it is; clause 3 (¬B∨¬C) as
-- a mutual-exclusion. Satisfying assignments (A,B,C) = (false,true,false)
-- and (true,false,true) — the same two the root has.
INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method,
                   active, trials_per_run, formal_spec, owl_type, owl_root_id,
                   owl_transform)
SELECT
  'LOGIC-09N Satisfiability (reworded)',
  'reasoning',
  'Three feature flags — ALPHA, BETA and GAMMA — are each either on or off. The rollout policy requires all three of these rules to hold at the same time: (1) at least one of ALPHA or BETA is on; (2) if ALPHA is on then GAMMA is on; (3) BETA and GAMMA are never both on. Is there any setting of the three flags that satisfies all three rules at once? Answer with exactly one word: SAT or UNSAT.',
  'SAT',
  'exact',
  true,
  3,
  '(A∨B)∧(¬A∨C)∧(¬B∨¬C) — SAT',
  'N',
  (SELECT id FROM tests WHERE name = 'LOGIC-09 Satisfiability' AND owl_type = 'I'),
  'narrative_reframing'
WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'LOGIC-09N Satisfiability (reworded)');

-- C: the root formula with two more individually-easy clauses appended.
-- (A∨C) kills the (false,true,false) model, (B∨¬C) kills (true,false,true);
-- nothing else satisfied the first three clauses, so the conjunction is
-- UNSAT. Exhaustively checked over all 8 assignments by the oracle.
INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method,
                   active, trials_per_run, formal_spec, owl_type, owl_root_id,
                   owl_transform, owl_flaw)
SELECT
  'LOGIC-09C Satisfiability (adversarial: local-satisfiability trap)',
  'reasoning',
  'Formula: (A OR B) AND (NOT A OR C) AND (NOT B OR NOT C) AND (A OR C) AND (B OR NOT C). Is this formula satisfiable (can it be true under some assignment)? Answer SAT or UNSAT, then name the specific reason.',
  'UNSAT — the first three clauses admit exactly two assignments, (A,B,C) = (false,true,false) and (true,false,true). The fourth clause (A OR C) rules out the first of those and the fifth clause (B OR NOT C) rules out the second, so no assignment satisfies all five.',
  'exact',
  true,
  3,
  '(A∨B)∧(¬A∨C)∧(¬B∨¬C)∧(A∨C)∧(B∨¬C) — UNSAT',
  'C',
  (SELECT id FROM tests WHERE name = 'LOGIC-09 Satisfiability' AND owl_type = 'I'),
  'clause_extension',
  'local-satisfiability bait: every clause is individually satisfiable and the formula is the SAT root with two more easy-looking clauses appended, so a clause-by-clause scan answers SAT; the unsatisfiability only appears when the whole conjunction is searched at once'
WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'LOGIC-09C Satisfiability (adversarial: local-satisfiability trap)');

-- ── LOGIC-10 Contradiction Detection — root VALID (ex falso) ────────────
INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method,
                   active, trials_per_run, formal_spec, owl_type, owl_root_id,
                   owl_transform)
SELECT
  'LOGIC-10N Contradiction Detection (reworded)',
  'reasoning',
  'Premise 1: The ledger is both balanced and not balanced at the same moment. Premise 2: If the ledger is balanced, the audit passes. Premise 3: If the ledger is not balanced, the audit fails. A reviewer states: "Therefore the audit both passes and fails." Does the reviewer''s statement follow from the premises? Answer with exactly one word: FOLLOWS or DOESNOTFOLLOW.',
  'FOLLOWS',
  'exact',
  true,
  3,
  'P∧¬P ⊢ anything (ex falso quodlibet)',
  'N',
  (SELECT id FROM tests WHERE name = 'LOGIC-10 Contradiction Detection' AND owl_type = 'I'),
  'domain_transfer'
WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'LOGIC-10N Contradiction Detection (reworded)');

-- C: the root argument with its contradictory PREMISE deleted and the
-- eye-catching contradictory CONCLUSION left in place. The two remaining
-- conditionals are jointly consistent, so nothing explodes. Trap spec
-- P → ¬Q, ¬P → Q ⊬ Q∧¬Q; countermodel P=false, Q=true.
INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method,
                   active, trials_per_run, formal_spec, owl_type, owl_root_id,
                   owl_transform, owl_flaw)
SELECT
  'LOGIC-10C Contradiction Detection (adversarial: missing-premise trap)',
  'reasoning',
  'Premise 1: If the pipeline is healthy, then no alert is raised. Premise 2: If the pipeline is not healthy, then an alert is raised. A runbook concludes: "Therefore an alert is both raised and not raised." Is this conclusion logically valid? Answer YES or NO, then name the specific error if any.',
  'NO — the two premises are jointly consistent, so no contradiction follows from them. Ex falso quodlibet licenses an arbitrary conclusion only when the PREMISES are contradictory; a contradictory conclusion is not itself a premise. Countermodel: the pipeline is not healthy and an alert is raised — both premises hold and the conclusion is false.',
  'exact',
  true,
  3,
  'P → ¬Q, ¬P → Q ⊬ Q∧¬Q',
  'C',
  (SELECT id FROM tests WHERE name = 'LOGIC-10 Contradiction Detection' AND owl_type = 'I'),
  'domain_transfer',
  'missing-premise bait: this is the root argument with its contradictory premise ("both secure and not secure") removed while the contradictory conclusion stays, priming the memorized "a contradiction is in play, so ex falso applies, so VALID" response even though nothing contradictory remains among the premises'
WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'LOGIC-10C Contradiction Detection (adversarial: missing-premise trap)');
