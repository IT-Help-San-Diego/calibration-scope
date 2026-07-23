-- v048: Re-point migration 047's owl_root_id values by NAME, not hardcoded ID.
--
-- THE BUG (caught by CI's owl-family gate, run 29969989008): migration 047
-- inserted N/C siblings with hardcoded owl_root_id integers (28, 29, 31, 40)
-- that match the DEVELOPMENT database's test IDs. Test IDs are sequence-
-- assigned and differ across environments — in CI's freshly-seeded database
-- the same integers land on entirely different tests (id 28 = LOGIC-18
-- Destructive Dilemma there, not LOGIC-03). The gate reported 8/8 families
-- drifted: children claiming 'P → Q, Q ⊬ P' rooted on a destructive-dilemma
-- spec. Locally everything looked consistent, which is exactly why hardcoded
-- cross-row IDs in migrations are a trap: the error is invisible in the
-- environment that wrote it.
--
-- THE FIX: idempotent name-based re-pointing. Correct in every environment,
-- past and future — a fresh install runs 047 (wrong roots) then 048
-- (re-pointed), and an existing install where 047 happened to be right is
-- a no-op. RULE going forward: a migration must never reference another
-- row by raw id; always resolve through a stable natural key (name).

UPDATE tests SET owl_root_id =
    (SELECT id FROM tests WHERE name = 'LOGIC-03 Affirming the Consequent (Fallacy)' AND owl_type = 'I')
  WHERE name IN (
    'LOGIC-03N Affirming the Consequent (reworded)',
    'LOGIC-03C Affirming the Consequent (adversarial: reverse-causal trap)'
  );

UPDATE tests SET owl_root_id =
    (SELECT id FROM tests WHERE name = 'LOGIC-04 Denying the Antecedent (Fallacy)' AND owl_type = 'I')
  WHERE name IN (
    'LOGIC-04N Denying the Antecedent (reworded)',
    'LOGIC-04C Denying the Antecedent (adversarial: inverse trap)'
  );

UPDATE tests SET owl_root_id =
    (SELECT id FROM tests WHERE name = 'LOGIC-06 Syllogism - Existential Fallacy' AND owl_type = 'I')
  WHERE name IN (
    'LOGIC-06N Existential Syllogism (reworded)',
    'LOGIC-06C Existential Syllogism (adversarial: quantifier-swap trap)'
  );

UPDATE tests SET owl_root_id =
    (SELECT id FROM tests WHERE name = 'LOGIC-11 Affirming a Disjunct (Fallacy)' AND owl_type = 'I')
  WHERE name IN (
    'LOGIC-11N Affirming a Disjunct (reworded)',
    'LOGIC-11C Affirming a Disjunct (adversarial: exclusive-or trap)'
  );
