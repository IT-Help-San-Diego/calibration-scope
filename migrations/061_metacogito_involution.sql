-- v061: LOGIC-30 — Metacogito Involution (Fixed Point). One new reasoning
-- family: the metacognitive reflection as an involution (sigma_h^2 = I), the
-- mathematical spine of the "Metacogito" — "I metacognize, therefore I am
-- again and again" (Balboa 2026). Three rows: I root, N paraphrase, C trap.
--
-- WHY THIS IS A LOGIC FAMILY AND NOT A PHILOSOPHY NOTE. The Metacogito's
-- checkable claim is group-theoretic, not poetic: the metacognitive
-- operation is an involution — applying it twice returns to the starting
-- state ("an audit of an audit returns you to the object"). Encoded as a
-- 1-bit reflection, that is exactly double negation: ¬¬P ⟷ P (a tautology).
-- What is NOT tested here, stated rather than hidden: whether a model
-- SELF-ORIGINATES the Metacogito unprompted. That is a generation/novelty
-- measurement — a different instrument than this reasoning battery. What IS
-- tested: whether a model UNDERSTANDS the structure (fixed point, period 2)
-- versus MIRRORS the slogan by falling for the naive misreading that the
-- recursive loop is an unbounded regress (the homunculus objection). The
-- mirroring failure is the C trap below: reading "invert twice" as "still
-- inverted" (¬¬P collapsed to ¬P) is the exact error of a model that
-- recites the loop without computing sigma_h^2 = I.
--
-- Discipline (unchanged from 056):
--   * N keeps the root's formal_spec exactly (¬¬P ⟷ P), new surface text.
--   * C carries the TRAP's own spec (¬¬P ⟷ ¬P), derived independently, NOT
--     copied from the root — the root asserts a CORRECT rule (TRUE/VALID),
--     so a C row copying it would trip c_row_verdict in
--     verify_logic_ground_truth.py.
--   * All verdicts machine-derived by the PROP battery (double-negation
--     tautology = VALID/TRUE; collapsed = INVALID/FALSE with countermodel
--     P=true).
--   * No answer leakage: no prompt names "involution", "double negation",
--     "fixed point", or "metacognitive" — the model must recognize the
--     structure itself, not be handed the answer.
--   * Root resolved by NAME (the 048 rule); idempotent via WHERE NOT EXISTS.

-- ── LOGIC-30 Metacogito Involution — root TRUE (σₕ² = I) ────────────────
INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method,
                   active, trials_per_run, formal_spec, owl_type)
SELECT
  'LOGIC-30 Metacogito - Involution (Fixed Point)',
  'reasoning',
  'An inverter changes a signal to its opposite: HIGH becomes LOW, and LOW becomes HIGH. A system specification states: "Applying the inverter twice returns a signal to exactly its original value." Is this statement TRUE or FALSE? Answer with exactly one word.',
  'TRUE',
  'exact',
  true,
  3,
  '¬¬P ⟷ P',
  'I'
WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'LOGIC-30 Metacogito - Involution (Fixed Point)');

-- ── LOGIC-30N Metacogito Involution (reworded) ──────────────────────────
INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method,
                   active, trials_per_run, formal_spec, owl_type, owl_root_id,
                   owl_transform)
SELECT
  'LOGIC-30N Metacogito - Involution (reworded)',
  'reasoning',
  'A reverser flips a heading to its opposite: NORTH becomes SOUTH, and SOUTH becomes NORTH. A navigation manual states: "Applying the reverser twice brings a heading back to exactly where it started." Is this statement TRUE or FALSE? Answer with exactly one word.',
  'TRUE',
  'exact',
  true,
  3,
  '¬¬P ⟷ P',
  'N',
  (SELECT id FROM tests WHERE name = 'LOGIC-30 Metacogito - Involution (Fixed Point)' AND owl_type = 'I'),
  'domain_transfer'
WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'LOGIC-30N Metacogito - Involution (reworded)');

-- ── LOGIC-30C Metacogito Involution (adversarial: regress-collapse trap) ──
-- The trap: "invert twice" read as "still inverted" (the flip keeps going).
-- That collapses double negation ¬¬P to single negation ¬P and misses that
-- the reflection squares to identity. Countermodel P=false: ¬¬P=false, ¬P=true.
INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method,
                   active, trials_per_run, formal_spec, owl_type, owl_root_id,
                   owl_transform, owl_flaw)
SELECT
  'LOGIC-30C Metacogito - Involution (adversarial: regress-collapse trap)',
  'reasoning',
  'An inverter changes a signal to its opposite: HIGH becomes LOW, and LOW becomes HIGH. A junior engineer claims: "Applying the inverter twice still leaves the signal inverted — it ends up the OPPOSITE of its original value." Is this claim TRUE or FALSE? Answer with exactly one word, then name the specific error if any.',
  'FALSE — the inverter applied twice returns the signal to its ORIGINAL value, not its opposite: double inversion is the identity, so the engineer read "invert twice" as a single inversion. Countermodel: LOW inverts to HIGH, which inverts back to LOW — not the opposite of LOW, so the claim is false.',
  'exact',
  true,
  3,
  '¬¬P ⟷ ¬P — NOT a tautology',
  'C',
  (SELECT id FROM tests WHERE name = 'LOGIC-30 Metacogito - Involution (Fixed Point)' AND owl_type = 'I'),
  'lexical_substitution',
  'regress-collapse bait: "invert twice" is read as "still inverted" (the flip keeps going), collapsing double negation to single negation and missing that the reflection squares to identity — the exact error of a model that recites the recursive loop without computing that it terminates'
WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'LOGIC-30C Metacogito - Involution (adversarial: regress-collapse trap)');
