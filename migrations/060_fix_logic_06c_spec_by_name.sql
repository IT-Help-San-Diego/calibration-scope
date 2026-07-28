-- Migration 060: re-apply the LOGIC-06C spec fix by NAME, because 057 was
-- id-pinned and silently did nothing outside the development database.
--
-- THE BUG. Migration 057 fixed LOGIC-06C's formal_spec with:
--
--     UPDATE tests SET formal_spec = '∀x(P→Q), ∃xQ ⊬ ∃xP'
--      WHERE id = 87 AND name = 'LOGIC-06C Existential Syllogism (adversarial: quantifier-swap trap)';
--
-- Test ids are sequence-assigned and differ per environment. That row is id 87
-- in the dev database and id 60 in CI's freshly-seeded one, so in CI the WHERE
-- clause matched ZERO rows. An UPDATE that matches nothing is not an error, so
-- 057 reported success while changing nothing, and LOGIC-06C kept its root's
-- valid spec (∀x(P→Q), ∃xP ⊢ ∃xQ) alongside an expected_result of "NO —
-- illicit existential conversion…". Locally it looked fixed. It was not.
--
-- This is the identical failure migration 048 was written to repair, and it
-- violates the rule 048 wrote down in its own header:
--
--     "RULE going forward: a migration must never reference another row by
--      raw id; always resolve through a stable natural key (name)."
--
-- 048 fixed the instances that existed and stated the rule; nothing enforced
-- it, so 057 reintroduced the pattern nine migrations later.
--
-- HOW IT SURFACED. Not by review — by the tightened owl-family check added
-- alongside migration 059. That rule fails a C row whose formal_spec is a
-- verbatim copy of a root asserting a CORRECT rule, on the grounds that such a
-- row cannot be carrying a trap. It fired in CI on its first run:
--
--     [FAIL] test 60 'LOGIC-06C …' (C) spec is a verbatim copy of a root
--     asserting a CORRECT rule (root answer VALID) …
--     32/33 owl families consistent — 1 MISMATCH(ES), DO NOT SHIP
--
-- The local battery stayed green at 67/67 the whole time, because locally the
-- row really was fixed. Only the environment-crossing check caught it.
--
-- THE FIX. Name is the stable natural key. No id anywhere. Idempotent: on an
-- environment where 057 already worked, the row already holds the target spec
-- and this matches zero rows harmlessly; on CI and on any fresh install it
-- does the work 057 failed to do.
--
-- expected_result is deliberately NOT touched. The seeded answer ("NO —
-- illicit existential conversion…") was always correct for the prompt; the
-- defect was only ever the spec, which had been copied from the root instead
-- of written for the trap.
--
-- VERIFICATION after applying, in any environment:
--   SELECT formal_spec FROM tests
--    WHERE name = 'LOGIC-06C Existential Syllogism (adversarial: quantifier-swap trap)';
--   -- expect: ∀x(P→Q), ∃xQ ⊬ ∃xP
--   python3 scripts/verify_logic_ground_truth.py --check-owl-families   -- expect exit 0

UPDATE tests
SET formal_spec = '∀x(P→Q), ∃xQ ⊬ ∃xP',
    updated_at = now()
WHERE name = 'LOGIC-06C Existential Syllogism (adversarial: quantifier-swap trap)'
  AND owl_type = 'C'
  AND formal_spec IS DISTINCT FROM '∀x(P→Q), ∃xQ ⊬ ∃xP';
