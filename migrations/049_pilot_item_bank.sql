-- Migration 049: item-bank pilot — 34 new harder items + pilot_metadata companion.
-- owl_root_consistency: N/C items need a non-NULL owl_root_id, resolved by NAME post-insert.

CREATE TABLE IF NOT EXISTS pilot_metadata (
  test_name text PRIMARY KEY, family_id text NOT NULL, difficulty_lever text NOT NULL,
  sibling_id text, sha3_512 text);

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, formal_spec, fallacy_tag, owl_type) SELECT 'PILOT-F1-MP', 'reasoning', 'If the patch is healthy, then the service is reachable. The patch is healthy. Does it follow that the service is reachable?
Answer with exactly one word: VALID or INVALID.', 'VALID', 'exact', true, 'P→Q, P ⊢ Q', '', 'I' WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'PILOT-F1-MP');
INSERT INTO pilot_metadata (test_name, family_id, difficulty_lever, sibling_id) SELECT 'PILOT-F1-MP', 'F1', 'chain', NULL WHERE NOT EXISTS (SELECT 1 FROM pilot_metadata WHERE test_name='PILOT-F1-MP');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, formal_spec, fallacy_tag, owl_type, owl_root_id, owl_transform, owl_flaw) SELECT 'PILOT-F1-TRAP-AC', 'reasoning', 'If the patch is healthy, then the service is reachable. The service is reachable. Does it follow that the patch is healthy?
Answer with exactly one word: VALID or INVALID.', 'INVALID', 'exact', true, 'P→Q, Q ⊬ P', 'affirming_the_consequent', 'C', COALESCE((SELECT id FROM tests WHERE name = 'PILOT-F1-MP' AND owl_type='I' LIMIT 1), (SELECT id FROM tests WHERE owl_type='I' AND name LIKE 'PILOT-%' LIMIT 1)), 'pilot_trap', 'affirming_the_consequent' WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'PILOT-F1-TRAP-AC');
INSERT INTO pilot_metadata (test_name, family_id, difficulty_lever, sibling_id) SELECT 'PILOT-F1-TRAP-AC', 'F1', 'trap', 'PILOT-F1-MP' WHERE NOT EXISTS (SELECT 1 FROM pilot_metadata WHERE test_name='PILOT-F1-TRAP-AC');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, formal_spec, fallacy_tag, owl_type) SELECT 'PILOT-F1-NEG-MT', 'reasoning', 'If the patch is healthy, then the service is reachable. It is not the case that the service is reachable. Does it follow that it is not the case that the patch is healthy?
Answer with exactly one word: VALID or INVALID.', 'VALID', 'exact', true, 'P→Q, ¬Q ⊢ ¬P', '', 'I' WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'PILOT-F1-NEG-MT');
INSERT INTO pilot_metadata (test_name, family_id, difficulty_lever, sibling_id) SELECT 'PILOT-F1-NEG-MT', 'F1', 'negdepth', NULL WHERE NOT EXISTS (SELECT 1 FROM pilot_metadata WHERE test_name='PILOT-F1-NEG-MT');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, formal_spec, fallacy_tag, owl_type, owl_root_id, owl_transform, owl_flaw) SELECT 'PILOT-F1-NEG-TRAP', 'reasoning', 'If the patch is healthy, then the service is reachable. It is not the case that the patch is healthy. Does it follow that it is not the case that the service is reachable?
Answer with exactly one word: VALID or INVALID.', 'INVALID', 'exact', true, 'P→Q, ¬P ⊬ ¬Q', 'denying_the_antecedent', 'C', COALESCE((SELECT id FROM tests WHERE name = 'PILOT-F1-NEG-MT' AND owl_type='I' LIMIT 1), (SELECT id FROM tests WHERE owl_type='I' AND name LIKE 'PILOT-%' LIMIT 1)), 'pilot_trap', 'denying_the_antecedent' WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'PILOT-F1-NEG-TRAP');
INSERT INTO pilot_metadata (test_name, family_id, difficulty_lever, sibling_id) SELECT 'PILOT-F1-NEG-TRAP', 'F1', 'trap', 'PILOT-F1-NEG-MT' WHERE NOT EXISTS (SELECT 1 FROM pilot_metadata WHERE test_name='PILOT-F1-NEG-TRAP');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, formal_spec, fallacy_tag, owl_type) SELECT 'PILOT-F1-CHAIN-HS', 'reasoning', 'If the patch is healthy, then the service is reachable. If the service is reachable, then the container is signed. The patch is healthy. Does it follow that the container is signed?
Answer with exactly one word: VALID or INVALID.', 'VALID', 'exact', true, 'P→Q, Q→R, P ⊢ R', '', 'I' WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'PILOT-F1-CHAIN-HS');
INSERT INTO pilot_metadata (test_name, family_id, difficulty_lever, sibling_id) SELECT 'PILOT-F1-CHAIN-HS', 'F1', 'chain', NULL WHERE NOT EXISTS (SELECT 1 FROM pilot_metadata WHERE test_name='PILOT-F1-CHAIN-HS');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, formal_spec, fallacy_tag, owl_type, owl_root_id, owl_transform, owl_flaw) SELECT 'PILOT-F1-TRAP-HS', 'reasoning', 'If the patch is healthy, then the service is reachable. If the service is reachable, then the container is signed. The container is signed. Does it follow that the patch is healthy?
Answer with exactly one word: VALID or INVALID.', 'INVALID', 'exact', true, 'P→Q, Q→R, R ⊬ P', 'chained_affirming_consequent', 'C', COALESCE((SELECT id FROM tests WHERE name = 'PILOT-F1-CHAIN-HS' AND owl_type='I' LIMIT 1), (SELECT id FROM tests WHERE owl_type='I' AND name LIKE 'PILOT-%' LIMIT 1)), 'pilot_trap', 'chained_affirming_consequent' WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'PILOT-F1-TRAP-HS');
INSERT INTO pilot_metadata (test_name, family_id, difficulty_lever, sibling_id) SELECT 'PILOT-F1-TRAP-HS', 'F1', 'trap', 'PILOT-F1-CHAIN-HS' WHERE NOT EXISTS (SELECT 1 FROM pilot_metadata WHERE test_name='PILOT-F1-TRAP-HS');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, formal_spec, fallacy_tag, owl_type) SELECT 'PILOT-F2-MP', 'reasoning', 'If the deployment is current, then the node is replicated. The deployment is current. Does it follow that the node is replicated?
Answer with exactly one word: VALID or INVALID.', 'VALID', 'exact', true, 'P→Q, P ⊢ Q', '', 'I' WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'PILOT-F2-MP');
INSERT INTO pilot_metadata (test_name, family_id, difficulty_lever, sibling_id) SELECT 'PILOT-F2-MP', 'F2', 'negdepth', NULL WHERE NOT EXISTS (SELECT 1 FROM pilot_metadata WHERE test_name='PILOT-F2-MP');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, formal_spec, fallacy_tag, owl_type, owl_root_id, owl_transform, owl_flaw) SELECT 'PILOT-F2-TRAP-AC', 'reasoning', 'If the deployment is current, then the node is replicated. The node is replicated. Does it follow that the deployment is current?
Answer with exactly one word: VALID or INVALID.', 'INVALID', 'exact', true, 'P→Q, Q ⊬ P', 'affirming_the_consequent', 'C', COALESCE((SELECT id FROM tests WHERE name = 'PILOT-F2-MP' AND owl_type='I' LIMIT 1), (SELECT id FROM tests WHERE owl_type='I' AND name LIKE 'PILOT-%' LIMIT 1)), 'pilot_trap', 'affirming_the_consequent' WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'PILOT-F2-TRAP-AC');
INSERT INTO pilot_metadata (test_name, family_id, difficulty_lever, sibling_id) SELECT 'PILOT-F2-TRAP-AC', 'F2', 'trap', 'PILOT-F2-MP' WHERE NOT EXISTS (SELECT 1 FROM pilot_metadata WHERE test_name='PILOT-F2-TRAP-AC');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, formal_spec, fallacy_tag, owl_type) SELECT 'PILOT-F2-NEG-MT', 'reasoning', 'If the deployment is current, then the node is replicated. It is not the case that the node is replicated. Does it follow that it is not the case that the deployment is current?
Answer with exactly one word: VALID or INVALID.', 'VALID', 'exact', true, 'P→Q, ¬Q ⊢ ¬P', '', 'I' WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'PILOT-F2-NEG-MT');
INSERT INTO pilot_metadata (test_name, family_id, difficulty_lever, sibling_id) SELECT 'PILOT-F2-NEG-MT', 'F2', 'negdepth', NULL WHERE NOT EXISTS (SELECT 1 FROM pilot_metadata WHERE test_name='PILOT-F2-NEG-MT');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, formal_spec, fallacy_tag, owl_type) SELECT 'PILOT-F2-CHAIN', 'reasoning', 'If the deployment is current, then the node is replicated. If the node is replicated, then the certificate is encrypted. It is not the case that the certificate is encrypted. Does it follow that it is not the case that the deployment is current?
Answer with exactly one word: VALID or INVALID.', 'VALID', 'exact', true, 'P→Q, Q→R, ¬R ⊢ ¬P', '', 'I' WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'PILOT-F2-CHAIN');
INSERT INTO pilot_metadata (test_name, family_id, difficulty_lever, sibling_id) SELECT 'PILOT-F2-CHAIN', 'F2', 'chain', NULL WHERE NOT EXISTS (SELECT 1 FROM pilot_metadata WHERE test_name='PILOT-F2-CHAIN');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, formal_spec, fallacy_tag, owl_type, owl_root_id, owl_transform, owl_flaw) SELECT 'PILOT-F2-TRAP-CHAIN', 'reasoning', 'If the deployment is current, then the node is replicated. If the node is replicated, then the certificate is encrypted. The certificate is encrypted. Does it follow that the deployment is current?
Answer with exactly one word: VALID or INVALID.', 'INVALID', 'exact', true, 'P→Q, Q→R, R ⊬ P', 'chained_affirming_consequent', 'C', COALESCE((SELECT id FROM tests WHERE name = 'PILOT-F2-CHAIN' AND owl_type='I' LIMIT 1), (SELECT id FROM tests WHERE owl_type='I' AND name LIKE 'PILOT-%' LIMIT 1)), 'pilot_trap', 'chained_affirming_consequent' WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'PILOT-F2-TRAP-CHAIN');
INSERT INTO pilot_metadata (test_name, family_id, difficulty_lever, sibling_id) SELECT 'PILOT-F2-TRAP-CHAIN', 'F2', 'trap', 'PILOT-F2-CHAIN' WHERE NOT EXISTS (SELECT 1 FROM pilot_metadata WHERE test_name='PILOT-F2-TRAP-CHAIN');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, formal_spec, fallacy_tag, owl_type) SELECT 'PILOT-F3-DS', 'reasoning', 'Either the backup is monitored or the endpoint is throttled. It is not the case that the backup is monitored. Does it follow that the endpoint is throttled?
Answer with exactly one word: VALID or INVALID.', 'VALID', 'exact', true, 'P∨Q, ¬P ⊢ Q', '', 'I' WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'PILOT-F3-DS');
INSERT INTO pilot_metadata (test_name, family_id, difficulty_lever, sibling_id) SELECT 'PILOT-F3-DS', 'F3', 'chain', NULL WHERE NOT EXISTS (SELECT 1 FROM pilot_metadata WHERE test_name='PILOT-F3-DS');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, formal_spec, fallacy_tag, owl_type, owl_root_id, owl_transform, owl_flaw) SELECT 'PILOT-F3-TRAP-AD', 'reasoning', 'Either the backup is monitored or the endpoint is throttled (or both). The backup is monitored. Does it follow that it is not the case that the endpoint is throttled?
Answer with exactly one word: VALID or INVALID.', 'INVALID', 'exact', true, 'P∨Q, P ⊬ ¬Q', 'affirming_a_disjunct', 'C', COALESCE((SELECT id FROM tests WHERE name = 'PILOT-F3-DS' AND owl_type='I' LIMIT 1), (SELECT id FROM tests WHERE owl_type='I' AND name LIKE 'PILOT-%' LIMIT 1)), 'pilot_trap', 'affirming_a_disjunct' WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'PILOT-F3-TRAP-AD');
INSERT INTO pilot_metadata (test_name, family_id, difficulty_lever, sibling_id) SELECT 'PILOT-F3-TRAP-AD', 'F3', 'trap', 'PILOT-F3-DS' WHERE NOT EXISTS (SELECT 1 FROM pilot_metadata WHERE test_name='PILOT-F3-TRAP-AD');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, formal_spec, fallacy_tag, owl_type) SELECT 'PILOT-F3-NEG', 'reasoning', 'Either it is not the case that the backup is monitored, or the endpoint is throttled. The backup is monitored. Does it follow that the endpoint is throttled?
Answer with exactly one word: VALID or INVALID.', 'VALID', 'exact', true, '¬P∨Q, P ⊢ Q', '', 'I' WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'PILOT-F3-NEG');
INSERT INTO pilot_metadata (test_name, family_id, difficulty_lever, sibling_id) SELECT 'PILOT-F3-NEG', 'F3', 'negdepth', NULL WHERE NOT EXISTS (SELECT 1 FROM pilot_metadata WHERE test_name='PILOT-F3-NEG');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, formal_spec, fallacy_tag, owl_type, owl_root_id, owl_transform, owl_flaw) SELECT 'PILOT-F3-TRAP-DC', 'reasoning', 'It is not the case that both the backup is monitored and the endpoint is throttled. It is not the case that the backup is monitored. Does it follow that it is not the case that the endpoint is throttled?
Answer with exactly one word: VALID or INVALID.', 'INVALID', 'exact', true, '¬(P∧Q), ¬P ⊬ ¬Q', 'denying_a_conjunct', 'C', COALESCE((SELECT id FROM tests WHERE name = 'PILOT-F3-DS' AND owl_type='I' LIMIT 1), (SELECT id FROM tests WHERE owl_type='I' AND name LIKE 'PILOT-%' LIMIT 1)), 'pilot_trap', 'denying_a_conjunct' WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'PILOT-F3-TRAP-DC');
INSERT INTO pilot_metadata (test_name, family_id, difficulty_lever, sibling_id) SELECT 'PILOT-F3-TRAP-DC', 'F3', 'trap', 'PILOT-F3-DS' WHERE NOT EXISTS (SELECT 1 FROM pilot_metadata WHERE test_name='PILOT-F3-TRAP-DC');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, formal_spec, fallacy_tag, owl_type) SELECT 'PILOT-F3-CHAIN', 'reasoning', 'Either the backup is monitored or the endpoint is throttled. It is not the case that the backup is monitored. If the endpoint is throttled, then the replica is drained. Does it follow that the replica is drained?
Answer with exactly one word: VALID or INVALID.', 'VALID', 'exact', true, 'P∨Q, ¬P, Q→R ⊢ R', '', 'I' WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'PILOT-F3-CHAIN');
INSERT INTO pilot_metadata (test_name, family_id, difficulty_lever, sibling_id) SELECT 'PILOT-F3-CHAIN', 'F3', 'chain', NULL WHERE NOT EXISTS (SELECT 1 FROM pilot_metadata WHERE test_name='PILOT-F3-CHAIN');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, formal_spec, fallacy_tag, owl_type) SELECT 'PILOT-F4-DEMORGAN', 'reasoning', 'Is the following equivalence true? ''Not both P and Q'' is equivalent to ''not P or not Q''.
Answer with exactly one word: TRUE or FALSE.', 'TRUE', 'exact', true, '¬(P∧Q) ⊢ ¬P∨¬Q', '', 'I' WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'PILOT-F4-DEMORGAN');
INSERT INTO pilot_metadata (test_name, family_id, difficulty_lever, sibling_id) SELECT 'PILOT-F4-DEMORGAN', 'F4', 'negdepth', NULL WHERE NOT EXISTS (SELECT 1 FROM pilot_metadata WHERE test_name='PILOT-F4-DEMORGAN');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, formal_spec, fallacy_tag, owl_type, owl_root_id, owl_transform, owl_flaw) SELECT 'PILOT-F4-TRAP-DEM', 'reasoning', 'Is the following equivalence true? ''Not (P or Q)'' is equivalent to ''not P or not Q''.
Answer with exactly one word: TRUE or FALSE.', 'FALSE', 'exact', true, '¬(P∨Q) ⊬ ¬P∨¬Q', 'de_morgan_misapplication', 'C', COALESCE((SELECT id FROM tests WHERE name = 'PILOT-F4-DEMORGAN' AND owl_type='I' LIMIT 1), (SELECT id FROM tests WHERE owl_type='I' AND name LIKE 'PILOT-%' LIMIT 1)), 'pilot_trap', 'de_morgan_misapplication' WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'PILOT-F4-TRAP-DEM');
INSERT INTO pilot_metadata (test_name, family_id, difficulty_lever, sibling_id) SELECT 'PILOT-F4-TRAP-DEM', 'F4', 'trap', 'PILOT-F4-DEMORGAN' WHERE NOT EXISTS (SELECT 1 FROM pilot_metadata WHERE test_name='PILOT-F4-TRAP-DEM');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, formal_spec, fallacy_tag, owl_type) SELECT 'PILOT-F4-DIST', 'reasoning', 'Is the following equivalence true? ''P and (Q or R)'' is equivalent to ''(P and Q) or (P and R)''.
Answer with exactly one word: TRUE or FALSE.', 'TRUE', 'exact', true, 'P∧(Q∨R) ⊢ (P∧Q)∨(P∧R)', '', 'I' WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'PILOT-F4-DIST');
INSERT INTO pilot_metadata (test_name, family_id, difficulty_lever, sibling_id) SELECT 'PILOT-F4-DIST', 'F4', 'negdepth', NULL WHERE NOT EXISTS (SELECT 1 FROM pilot_metadata WHERE test_name='PILOT-F4-DIST');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, formal_spec, fallacy_tag, owl_type, owl_root_id, owl_transform, owl_flaw) SELECT 'PILOT-F4-TRAP-DIST', 'reasoning', 'Is the following equivalence true? ''P or (Q and R)'' is equivalent to ''(P or Q) and R''.
Answer with exactly one word: TRUE or FALSE.', 'FALSE', 'exact', true, 'P∨(Q∧R) ⊬ (P∨Q)∧R', 'distribution_misapplication', 'C', COALESCE((SELECT id FROM tests WHERE name = 'PILOT-F4-DIST' AND owl_type='I' LIMIT 1), (SELECT id FROM tests WHERE owl_type='I' AND name LIKE 'PILOT-%' LIMIT 1)), 'pilot_trap', 'distribution_misapplication' WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'PILOT-F4-TRAP-DIST');
INSERT INTO pilot_metadata (test_name, family_id, difficulty_lever, sibling_id) SELECT 'PILOT-F4-TRAP-DIST', 'F4', 'trap', 'PILOT-F4-DIST' WHERE NOT EXISTS (SELECT 1 FROM pilot_metadata WHERE test_name='PILOT-F4-TRAP-DIST');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, formal_spec, fallacy_tag, owl_type) SELECT 'PILOT-F4-CHAIN', 'reasoning', 'Not both P and Q. P holds. Does it follow that Q does not hold?
Answer with exactly one word: VALID or INVALID.', 'VALID', 'exact', true, '¬(P∧Q), P ⊢ ¬Q', '', 'I' WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'PILOT-F4-CHAIN');
INSERT INTO pilot_metadata (test_name, family_id, difficulty_lever, sibling_id) SELECT 'PILOT-F4-CHAIN', 'F4', 'chain', NULL WHERE NOT EXISTS (SELECT 1 FROM pilot_metadata WHERE test_name='PILOT-F4-CHAIN');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, formal_spec, fallacy_tag, owl_type) SELECT 'PILOT-F5-EXFALSO', 'reasoning', 'Suppose P holds and P also does not hold. Does it follow that an unrelated claim Q holds (in classical logic)?
Answer with exactly one word: VALID or INVALID.', 'VALID', 'exact', true, 'P∧¬P ⊢ Q', '', 'I' WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'PILOT-F5-EXFALSO');
INSERT INTO pilot_metadata (test_name, family_id, difficulty_lever, sibling_id) SELECT 'PILOT-F5-EXFALSO', 'F5', 'negdepth', NULL WHERE NOT EXISTS (SELECT 1 FROM pilot_metadata WHERE test_name='PILOT-F5-EXFALSO');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, formal_spec, fallacy_tag, owl_type) SELECT 'PILOT-F5-SAT', 'reasoning', 'Is this set satisfiable: (P or Q), (not P or R), (not Q or not R)?
Answer with exactly one word: SAT or UNSAT.', 'SAT', 'exact', true, 'P∨Q, ¬P∨R, ¬Q∨¬R ⊢ SAT', '', 'I' WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'PILOT-F5-SAT');
INSERT INTO pilot_metadata (test_name, family_id, difficulty_lever, sibling_id) SELECT 'PILOT-F5-SAT', 'F5', 'chain', NULL WHERE NOT EXISTS (SELECT 1 FROM pilot_metadata WHERE test_name='PILOT-F5-SAT');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, formal_spec, fallacy_tag, owl_type, owl_root_id, owl_transform, owl_flaw) SELECT 'PILOT-F5-TRAP-SAT', 'reasoning', 'Is this set satisfiable: P, and not P?
Answer with exactly one word: SAT or UNSAT.', 'UNSAT', 'exact', true, 'P, ¬P ⊬ SAT', 'contradiction_satisfiable', 'C', COALESCE((SELECT id FROM tests WHERE name = 'PILOT-F5-SAT' AND owl_type='I' LIMIT 1), (SELECT id FROM tests WHERE owl_type='I' AND name LIKE 'PILOT-%' LIMIT 1)), 'pilot_trap', 'contradiction_satisfiable' WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'PILOT-F5-TRAP-SAT');
INSERT INTO pilot_metadata (test_name, family_id, difficulty_lever, sibling_id) SELECT 'PILOT-F5-TRAP-SAT', 'F5', 'trap', 'PILOT-F5-SAT' WHERE NOT EXISTS (SELECT 1 FROM pilot_metadata WHERE test_name='PILOT-F5-TRAP-SAT');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, formal_spec, fallacy_tag, owl_type) SELECT 'PILOT-F5-NEG', 'reasoning', 'Does ''it is not the case that it is not the case that P'' entail P (in classical logic)?
Answer with exactly one word: VALID or INVALID.', 'VALID', 'exact', true, '¬¬P ⊢ P', '', 'I' WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'PILOT-F5-NEG');
INSERT INTO pilot_metadata (test_name, family_id, difficulty_lever, sibling_id) SELECT 'PILOT-F5-NEG', 'F5', 'negdepth', NULL WHERE NOT EXISTS (SELECT 1 FROM pilot_metadata WHERE test_name='PILOT-F5-NEG');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, formal_spec, fallacy_tag, owl_type, owl_root_id, owl_transform, owl_flaw) SELECT 'PILOT-F5-TRAP-DNEG', 'reasoning', 'Does ''it is not the case that it is not the case that P'' entail not-P (in classical logic)?
Answer with exactly one word: VALID or INVALID.', 'INVALID', 'exact', true, '¬¬P ⊬ ¬P', 'double_negation_inversion', 'C', COALESCE((SELECT id FROM tests WHERE name = 'PILOT-F5-NEG' AND owl_type='I' LIMIT 1), (SELECT id FROM tests WHERE owl_type='I' AND name LIKE 'PILOT-%' LIMIT 1)), 'pilot_trap', 'double_negation_inversion' WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'PILOT-F5-TRAP-DNEG');
INSERT INTO pilot_metadata (test_name, family_id, difficulty_lever, sibling_id) SELECT 'PILOT-F5-TRAP-DNEG', 'F5', 'trap', 'PILOT-F5-NEG' WHERE NOT EXISTS (SELECT 1 FROM pilot_metadata WHERE test_name='PILOT-F5-TRAP-DNEG');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, formal_spec, fallacy_tag, owl_type) SELECT 'PILOT-F5-CHAIN', 'reasoning', 'P or Q. Not P. Not Q. From these, does an arbitrary claim R follow (in classical logic)?
Answer with exactly one word: VALID or INVALID.', 'VALID', 'exact', true, 'P∨Q, ¬P, ¬Q ⊢ R', '', 'I' WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'PILOT-F5-CHAIN');
INSERT INTO pilot_metadata (test_name, family_id, difficulty_lever, sibling_id) SELECT 'PILOT-F5-CHAIN', 'F5', 'chain', NULL WHERE NOT EXISTS (SELECT 1 FROM pilot_metadata WHERE test_name='PILOT-F5-CHAIN');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, formal_spec, fallacy_tag, owl_type) SELECT 'PILOT-F6-RES', 'reasoning', 'Given (P or Q) and (not P or R), does it follow that (Q or R)?
Answer with exactly one word: VALID or INVALID.', 'VALID', 'exact', true, 'P∨Q, ¬P∨R ⊢ Q∨R', '', 'I' WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'PILOT-F6-RES');
INSERT INTO pilot_metadata (test_name, family_id, difficulty_lever, sibling_id) SELECT 'PILOT-F6-RES', 'F6', 'chain', NULL WHERE NOT EXISTS (SELECT 1 FROM pilot_metadata WHERE test_name='PILOT-F6-RES');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, formal_spec, fallacy_tag, owl_type, owl_root_id, owl_transform, owl_flaw) SELECT 'PILOT-F6-TRAP-RES', 'reasoning', 'Given (P or Q) and (P or R), does it follow that (Q or R)?
Answer with exactly one word: VALID or INVALID.', 'INVALID', 'exact', true, 'P∨Q, P∨R ⊬ Q∨R', 'resolution_misapplication', 'C', COALESCE((SELECT id FROM tests WHERE name = 'PILOT-F6-RES' AND owl_type='I' LIMIT 1), (SELECT id FROM tests WHERE owl_type='I' AND name LIKE 'PILOT-%' LIMIT 1)), 'pilot_trap', 'resolution_misapplication' WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'PILOT-F6-TRAP-RES');
INSERT INTO pilot_metadata (test_name, family_id, difficulty_lever, sibling_id) SELECT 'PILOT-F6-TRAP-RES', 'F6', 'trap', 'PILOT-F6-RES' WHERE NOT EXISTS (SELECT 1 FROM pilot_metadata WHERE test_name='PILOT-F6-TRAP-RES');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, formal_spec, fallacy_tag, owl_type) SELECT 'PILOT-F6-CHAIN3', 'reasoning', 'If P then Q. If Q then R. If R then S. P. Does it follow that S?
Answer with exactly one word: VALID or INVALID.', 'VALID', 'exact', true, 'P→Q, Q→R, R→S, P ⊢ S', '', 'I' WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'PILOT-F6-CHAIN3');
INSERT INTO pilot_metadata (test_name, family_id, difficulty_lever, sibling_id) SELECT 'PILOT-F6-CHAIN3', 'F6', 'chain', NULL WHERE NOT EXISTS (SELECT 1 FROM pilot_metadata WHERE test_name='PILOT-F6-CHAIN3');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, formal_spec, fallacy_tag, owl_type, owl_root_id, owl_transform, owl_flaw) SELECT 'PILOT-F6-TRAP-CHAIN', 'reasoning', 'If P then Q. If Q then R. If R then S. S. Does it follow that P?
Answer with exactly one word: VALID or INVALID.', 'INVALID', 'exact', true, 'P→Q, Q→R, R→S, S ⊬ P', 'chained_affirming_consequent', 'C', COALESCE((SELECT id FROM tests WHERE name = 'PILOT-F6-CHAIN3' AND owl_type='I' LIMIT 1), (SELECT id FROM tests WHERE owl_type='I' AND name LIKE 'PILOT-%' LIMIT 1)), 'pilot_trap', 'chained_affirming_consequent' WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'PILOT-F6-TRAP-CHAIN');
INSERT INTO pilot_metadata (test_name, family_id, difficulty_lever, sibling_id) SELECT 'PILOT-F6-TRAP-CHAIN', 'F6', 'trap', 'PILOT-F6-CHAIN3' WHERE NOT EXISTS (SELECT 1 FROM pilot_metadata WHERE test_name='PILOT-F6-TRAP-CHAIN');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, formal_spec, fallacy_tag, owl_type) SELECT 'PILOT-F6-NEG', 'reasoning', 'If P then Q. If Q then R. Not R. Does it follow that not P?
Answer with exactly one word: VALID or INVALID.', 'VALID', 'exact', true, 'P→Q, Q→R, ¬R ⊢ ¬P', '', 'I' WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'PILOT-F6-NEG');
INSERT INTO pilot_metadata (test_name, family_id, difficulty_lever, sibling_id) SELECT 'PILOT-F6-NEG', 'F6', 'negdepth', NULL WHERE NOT EXISTS (SELECT 1 FROM pilot_metadata WHERE test_name='PILOT-F6-NEG');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, formal_spec, fallacy_tag, owl_type, owl_root_id, owl_transform, owl_flaw) SELECT 'PILOT-F4-TRAP-CHAIN2', 'reasoning', 'Not both P and Q. Q does not hold. Does it follow that P does not hold?
Answer with exactly one word: VALID or INVALID.', 'INVALID', 'exact', true, '¬(P∧Q), ¬Q ⊬ ¬P', 'denying_a_conjunct', 'C', COALESCE((SELECT id FROM tests WHERE name = 'PILOT-F4-CHAIN' AND owl_type='I' LIMIT 1), (SELECT id FROM tests WHERE owl_type='I' AND name LIKE 'PILOT-%' LIMIT 1)), 'pilot_trap', 'denying_a_conjunct' WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'PILOT-F4-TRAP-CHAIN2');
INSERT INTO pilot_metadata (test_name, family_id, difficulty_lever, sibling_id) SELECT 'PILOT-F4-TRAP-CHAIN2', 'F4', 'trap', 'PILOT-F4-CHAIN' WHERE NOT EXISTS (SELECT 1 FROM pilot_metadata WHERE test_name='PILOT-F4-TRAP-CHAIN2');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, formal_spec, fallacy_tag, owl_type, owl_root_id, owl_transform, owl_flaw) SELECT 'PILOT-F6-TRAP-MPCHAIN', 'reasoning', 'If P then Q. If Q then R. R holds. Does it follow that P holds?
Answer with exactly one word: VALID or INVALID.', 'INVALID', 'exact', true, 'P→Q, Q→R, R ⊬ P', 'chained_affirming_consequent', 'C', COALESCE((SELECT id FROM tests WHERE name = 'PILOT-F6-NEG' AND owl_type='I' LIMIT 1), (SELECT id FROM tests WHERE owl_type='I' AND name LIKE 'PILOT-%' LIMIT 1)), 'pilot_trap', 'chained_affirming_consequent' WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'PILOT-F6-TRAP-MPCHAIN');
INSERT INTO pilot_metadata (test_name, family_id, difficulty_lever, sibling_id) SELECT 'PILOT-F6-TRAP-MPCHAIN', 'F6', 'trap', 'PILOT-F6-NEG' WHERE NOT EXISTS (SELECT 1 FROM pilot_metadata WHERE test_name='PILOT-F6-TRAP-MPCHAIN');
