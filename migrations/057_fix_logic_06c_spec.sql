-- Migration 057: fix LOGIC-06C formal_spec (test id 87) — spec-vs-prompt drift
--
-- Defect surfaced 2026-07-28 by the oracle extension (PR #5, commit 80ada8a):
-- test 87's formal_spec is '∀x(P→Q), ∃xP ⊢ ∃xQ' — a verbatim copy of its
-- LOGIC-06 root, which is VALID. Its expected_result correctly keys
-- 'NO — illicit existential conversion…' (INVALID). A spec asserting ⊢
-- cannot carry the answer NO; the row contradicted itself.
--
-- The prompt's actual argument is 'every leak is a defect' + 'some defects
-- exist' ⊬ 'some leaks exist' — existential over the SECOND (predicate)
-- term, illicit existential conversion, genuinely INVALID. The corrected
-- spec below encodes exactly that: ∀x(P→Q), ∃xQ ⊬ ∃xP.
--
-- The oracle's LOGIC-06C battery entry records the seeded answer (INVALID),
-- so the logic gate is red by design until this migration lands. After it
-- does, the spec's computed verdict (INVALID) matches the seeded answer and
-- the gate returns to green (67/67).
--
-- Verification: python3 scripts/verify_logic_ground_truth.py

UPDATE tests
SET formal_spec = '∀x(P→Q), ∃xQ ⊬ ∃xP',
    updated_at = now()
WHERE id = 87
  AND name = 'LOGIC-06C Existential Syllogism (adversarial: quantifier-swap trap)';
