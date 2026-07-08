-- v012: Logic/Reasoning ground-truth tests
-- These test formal logical reasoning, not arithmetic.
-- Anti-cheat: expected_result lives ONLY here (server-side).
-- Scoring: exact string match for single-word answers; substring for longer justifications.
INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, trials_per_run)
VALUES
  (
    'LOGIC-01 Modus Ponens',
    'reasoning',
    'Premise 1: If it is raining, then the ground is wet.
Premise 2: It is raining.
Conclusion: The ground is wet.
Is this argument valid? Answer with exactly one word: VALID or INVALID.',
    'VALID',
    'exact',
    3
  ),
  (
    'LOGIC-02 Modus Tollens',
    'reasoning',
    'Premise 1: If the system is secure, then no unauthorized access occurs.
Premise 2: Unauthorized access occurred.
Conclusion: The system is not secure.
Is this argument valid? Answer with exactly one word: VALID or INVALID.',
    'VALID',
    'exact',
    3
  ),
  (
    'LOGIC-03 Affirming the Consequent (Fallacy)',
    'reasoning',
    'Premise 1: If the database is corrupted, then queries fail.
Premise 2: Queries are failing.
Conclusion: The database is corrupted.
Is this argument valid? Answer with exactly one word: VALID or INVALID.',
    'INVALID',
    'exact',
    3
  ),
  (
    'LOGIC-04 Denying the Antecedent (Fallacy)',
    'reasoning',
    'Premise 1: If the user has admin privileges, then they can delete the database.
Premise 2: The user does not have admin privileges.
Conclusion: The user cannot delete the database.
Is this argument valid? Answer with exactly one word: VALID or INVALID.',
    'INVALID',
    'exact',
    3
  ),
  (
    'LOGIC-05 Syllogism - Barbara (AAA-1)',
    'reasoning',
    'Premise 1: All security vulnerabilities are bugs.
Premise 2: All buffer overflows are security vulnerabilities.
Conclusion: All buffer overflows are bugs.
Is this syllogism valid? Answer with exactly one word: VALID or INVALID.',
    'VALID',
    'exact',
    3
  ),
  (
    'LOGIC-06 Syllogism - Existential Fallacy',
    'reasoning',
    'Premise 1: All AI systems that lack alignment are dangerous.
Premise 2: Some unaligned AI systems exist.
Conclusion: Some dangerous things exist.
Is this syllogism valid? Answer with exactly one word: VALID or INVALID.',
    'VALID',
    'exact',
    3
  ),
  (
    'LOGIC-07 Boolean Algebra - De Morgan',
    'reasoning',
    'Expression: NOT (A AND B)  is logically equivalent to  (NOT A) OR (NOT B).
Is this equivalence correct? Answer with exactly one word: TRUE or FALSE.',
    'TRUE',
    'exact',
    3
  ),
  (
    'LOGIC-08 Boolean Algebra - Distribution',
    'reasoning',
    'Expression: A AND (B OR C)  is logically equivalent to  (A AND B) OR (A AND C).
Is this equivalence correct? Answer with exactly one word: TRUE or FALSE.',
    'TRUE',
    'exact',
    3
  ),
  (
    'LOGIC-09 Satisfiability',
    'reasoning',
    'Formula: (A OR B) AND (NOT A OR C) AND (NOT B OR NOT C)
Is this formula satisfiable (can it be true under some assignment)? Answer with exactly one word: SAT or UNSAT.',
    'SAT',
    'exact',
    3
  ),
  (
    'LOGIC-10 Contradiction Detection',
    'reasoning',
    'Premise 1: The system is both secure and not secure at the same time.
Premise 2: If the system is secure, then no data is leaked.
Premise 3: If the system is not secure, then data is leaked.
Conclusion: Data is leaked AND data is not leaked.
Is this argument valid (does the conclusion follow from the premises)? Answer with exactly one word: VALID or INVALID.',
    'VALID',
    'exact',
    3
  )
ON CONFLICT DO NOTHING;