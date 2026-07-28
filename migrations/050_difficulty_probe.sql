-- Migration 050: difficulty PROBE — 40 items, 4 candidate classes x 10.
-- Source: analysis/probe_items.json (Claude Science PILOT_VERDICT directive).
-- probe_metadata companion: probe_class for per-class off-ceiling gating.

CREATE TABLE IF NOT EXISTS probe_metadata (
  test_name text PRIMARY KEY, probe_class text NOT NULL, note text);

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'PROBE-C1-01', 'reasoning', 'Read this argument:
"The update server logged 4,200 successful installs and zero rollback reports in the first week. Our staged rollout plan called for exactly this signal before widening. The rollout is proceeding as designed."
Which single rhetorical fallacy best describes it? Answer with exactly one word: FALSECAUSE, HASTYGEN, CIRCULAR, ADPOPULUM, or NONE.', 'NONE', 'exact', true, 'I', 3 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'PROBE-C1-01');
INSERT INTO probe_metadata (test_name, probe_class, note) SELECT 'PROBE-C1-01', 'sound-arg', 'sound-arg discrimination (NONE=control)' WHERE NOT EXISTS (SELECT 1 FROM probe_metadata WHERE test_name='PROBE-C1-01');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'PROBE-C1-02', 'reasoning', 'Read this argument:
"Two independent reviewers read the same 30 logs and flagged the same 4 as suspicious. We did not tell them which to flag. Their agreement suggests the 4 logs share a detectable property."
Which single rhetorical fallacy best describes it? Answer with exactly one word: FALSECAUSE, HASTYGEN, CIRCULAR, ADPOPULUM, or NONE.', 'NONE', 'exact', true, 'I', 3 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'PROBE-C1-02');
INSERT INTO probe_metadata (test_name, probe_class, note) SELECT 'PROBE-C1-02', 'sound-arg', 'sound-arg discrimination (NONE=control)' WHERE NOT EXISTS (SELECT 1 FROM probe_metadata WHERE test_name='PROBE-C1-02');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'PROBE-C1-03', 'reasoning', 'Read this argument:
"After we enabled connection pooling, median query latency fell from 180 ms to 40 ms across the same 10,000 queries, holding hardware and query mix constant. Pooling plausibly reduced latency."
Which single rhetorical fallacy best describes it? Answer with exactly one word: FALSECAUSE, HASTYGEN, CIRCULAR, ADPOPULUM, or NONE.', 'NONE', 'exact', true, 'I', 3 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'PROBE-C1-03');
INSERT INTO probe_metadata (test_name, probe_class, note) SELECT 'PROBE-C1-03', 'sound-arg', 'sound-arg discrimination (NONE=control)' WHERE NOT EXISTS (SELECT 1 FROM probe_metadata WHERE test_name='PROBE-C1-03');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'PROBE-C1-04', 'reasoning', 'Read this argument:
"Ever since we hired the new intern, the nightly build has failed three times. Clearly the intern is breaking the build."
Which single rhetorical fallacy best describes it? Answer with exactly one word: FALSECAUSE, HASTYGEN, CIRCULAR, ADPOPULUM, or NONE.', 'FALSECAUSE', 'exact', true, 'I', 3 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'PROBE-C1-04');
INSERT INTO probe_metadata (test_name, probe_class, note) SELECT 'PROBE-C1-04', 'sound-arg', 'sound-arg discrimination (NONE=control)' WHERE NOT EXISTS (SELECT 1 FROM probe_metadata WHERE test_name='PROBE-C1-04');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'PROBE-C1-05', 'reasoning', 'Read this argument:
"We deployed on Friday and by Monday user complaints had doubled. The deployment must be the cause of the complaints."
Which single rhetorical fallacy best describes it? Answer with exactly one word: FALSECAUSE, HASTYGEN, CIRCULAR, ADPOPULUM, or NONE.', 'FALSECAUSE', 'exact', true, 'I', 3 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'PROBE-C1-05');
INSERT INTO probe_metadata (test_name, probe_class, note) SELECT 'PROBE-C1-05', 'sound-arg', 'sound-arg discrimination (NONE=control)' WHERE NOT EXISTS (SELECT 1 FROM probe_metadata WHERE test_name='PROBE-C1-05');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'PROBE-C1-06', 'reasoning', 'Read this argument:
"One user in Oslo reported the app crashed on launch. The app must be broken for all users in Norway."
Which single rhetorical fallacy best describes it? Answer with exactly one word: FALSECAUSE, HASTYGEN, CIRCULAR, ADPOPULUM, or NONE.', 'HASTYGEN', 'exact', true, 'I', 3 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'PROBE-C1-06');
INSERT INTO probe_metadata (test_name, probe_class, note) SELECT 'PROBE-C1-06', 'sound-arg', 'sound-arg discrimination (NONE=control)' WHERE NOT EXISTS (SELECT 1 FROM probe_metadata WHERE test_name='PROBE-C1-06');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'PROBE-C1-07', 'reasoning', 'Read this argument:
"The first two pancakes I flipped burned. This stove clearly can''t cook pancakes."
Which single rhetorical fallacy best describes it? Answer with exactly one word: FALSECAUSE, HASTYGEN, CIRCULAR, ADPOPULUM, or NONE.', 'HASTYGEN', 'exact', true, 'I', 3 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'PROBE-C1-07');
INSERT INTO probe_metadata (test_name, probe_class, note) SELECT 'PROBE-C1-07', 'sound-arg', 'sound-arg discrimination (NONE=control)' WHERE NOT EXISTS (SELECT 1 FROM probe_metadata WHERE test_name='PROBE-C1-07');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'PROBE-C1-08', 'reasoning', 'Read this argument:
"This backup is reliable because it never fails. And we know it never fails because it''s a reliable backup."
Which single rhetorical fallacy best describes it? Answer with exactly one word: FALSECAUSE, HASTYGEN, CIRCULAR, ADPOPULUM, or NONE.', 'CIRCULAR', 'exact', true, 'I', 3 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'PROBE-C1-08');
INSERT INTO probe_metadata (test_name, probe_class, note) SELECT 'PROBE-C1-08', 'sound-arg', 'sound-arg discrimination (NONE=control)' WHERE NOT EXISTS (SELECT 1 FROM probe_metadata WHERE test_name='PROBE-C1-08');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'PROBE-C1-09', 'reasoning', 'Read this argument:
"Everyone on the team already uses this linter, so it must be the right choice for the project."
Which single rhetorical fallacy best describes it? Answer with exactly one word: FALSECAUSE, HASTYGEN, CIRCULAR, ADPOPULUM, or NONE.', 'ADPOPULUM', 'exact', true, 'I', 3 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'PROBE-C1-09');
INSERT INTO probe_metadata (test_name, probe_class, note) SELECT 'PROBE-C1-09', 'sound-arg', 'sound-arg discrimination (NONE=control)' WHERE NOT EXISTS (SELECT 1 FROM probe_metadata WHERE test_name='PROBE-C1-09');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'PROBE-C1-10', 'reasoning', 'Read this argument:
"Thousands of people forward this warning every day, so the threat it describes must be real."
Which single rhetorical fallacy best describes it? Answer with exactly one word: FALSECAUSE, HASTYGEN, CIRCULAR, ADPOPULUM, or NONE.', 'ADPOPULUM', 'exact', true, 'I', 3 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'PROBE-C1-10');
INSERT INTO probe_metadata (test_name, probe_class, note) SELECT 'PROBE-C1-10', 'sound-arg', 'sound-arg discrimination (NONE=control)' WHERE NOT EXISTS (SELECT 1 FROM probe_metadata WHERE test_name='PROBE-C1-10');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'PROBE-C2-01', 'reasoning', 'By default, servers in this cluster are healthy. Node-7 is a server in this cluster. With no other information, is it reasonable to conclude Node-7 is healthy?
Answer with exactly one word: VALID or INVALID.', 'VALID', 'exact', true, 'I', 3 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'PROBE-C2-01');
INSERT INTO probe_metadata (test_name, probe_class, note) SELECT 'PROBE-C2-01', 'defeasible', 'default rule, no defeater' WHERE NOT EXISTS (SELECT 1 FROM probe_metadata WHERE test_name='PROBE-C2-01');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'PROBE-C2-02', 'reasoning', 'By default, servers in this cluster are healthy. Node-7 is a server in this cluster AND Node-7 is currently returning 500s on all probes. Is it reasonable to conclude Node-7 is healthy?
Answer with exactly one word: VALID or INVALID.', 'INVALID', 'exact', true, 'I', 3 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'PROBE-C2-02');
INSERT INTO probe_metadata (test_name, probe_class, note) SELECT 'PROBE-C2-02', 'defeasible', 'defeater present — default retracted' WHERE NOT EXISTS (SELECT 1 FROM probe_metadata WHERE test_name='PROBE-C2-02');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'PROBE-C2-03', 'reasoning', 'Birds typically fly. Tweety is a bird. With no other information, does it follow by default that Tweety flies?
Answer with exactly one word: VALID or INVALID.', 'VALID', 'exact', true, 'I', 3 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'PROBE-C2-03');
INSERT INTO probe_metadata (test_name, probe_class, note) SELECT 'PROBE-C2-03', 'defeasible', 'default rule' WHERE NOT EXISTS (SELECT 1 FROM probe_metadata WHERE test_name='PROBE-C2-03');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'PROBE-C2-04', 'reasoning', 'Birds typically fly. Tweety is a bird AND Tweety is a penguin. Does it follow that Tweety flies?
Answer with exactly one word: VALID or INVALID.', 'INVALID', 'exact', true, 'I', 3 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'PROBE-C2-04');
INSERT INTO probe_metadata (test_name, probe_class, note) SELECT 'PROBE-C2-04', 'defeasible', 'subclass defeater' WHERE NOT EXISTS (SELECT 1 FROM probe_metadata WHERE test_name='PROBE-C2-04');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'PROBE-C2-05', 'reasoning', 'Normally, the backup completes by 3 AM. Last night the disk filled at 2 AM. Should you assume last night''s backup completed by 3 AM?
Answer with exactly one word: VALID or INVALID.', 'INVALID', 'exact', true, 'I', 3 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'PROBE-C2-05');
INSERT INTO probe_metadata (test_name, probe_class, note) SELECT 'PROBE-C2-05', 'defeasible', 'defeater — disk full' WHERE NOT EXISTS (SELECT 1 FROM probe_metadata WHERE test_name='PROBE-C2-05');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'PROBE-C2-06', 'reasoning', 'By default, signed packages install cleanly. This package is signed and the signature verifies. No errors are reported. Is it reasonable to conclude it will install cleanly?
Answer with exactly one word: VALID or INVALID.', 'VALID', 'exact', true, 'I', 3 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'PROBE-C2-06');
INSERT INTO probe_metadata (test_name, probe_class, note) SELECT 'PROBE-C2-06', 'defeasible', 'default, no defeater' WHERE NOT EXISTS (SELECT 1 FROM probe_metadata WHERE test_name='PROBE-C2-06');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'PROBE-C2-07', 'reasoning', 'By default, alarms indicate real faults. The alarm is sounding, and the sensor covering it is documented to be disconnected. Should you conclude there is a real fault?
Answer with exactly one word: VALID or INVALID.', 'INVALID', 'exact', true, 'I', 3 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'PROBE-C2-07');
INSERT INTO probe_metadata (test_name, probe_class, note) SELECT 'PROBE-C2-07', 'defeasible', 'source discredited' WHERE NOT EXISTS (SELECT 1 FROM probe_metadata WHERE test_name='PROBE-C2-07');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'PROBE-C2-08', 'reasoning', 'Students who attend lecture usually pass. Maya attended every lecture. With no other information, is it reasonable to expect Maya to pass?
Answer with exactly one word: VALID or INVALID.', 'VALID', 'exact', true, 'I', 3 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'PROBE-C2-08');
INSERT INTO probe_metadata (test_name, probe_class, note) SELECT 'PROBE-C2-08', 'defeasible', 'default rule' WHERE NOT EXISTS (SELECT 1 FROM probe_metadata WHERE test_name='PROBE-C2-08');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'PROBE-C2-09', 'reasoning', 'Students who attend lecture usually pass. Maya attended every lecture but never submitted any assignment. Is it reasonable to expect Maya to pass?
Answer with exactly one word: VALID or INVALID.', 'INVALID', 'exact', true, 'I', 3 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'PROBE-C2-09');
INSERT INTO probe_metadata (test_name, probe_class, note) SELECT 'PROBE-C2-09', 'defeasible', 'defeater — no assignments' WHERE NOT EXISTS (SELECT 1 FROM probe_metadata WHERE test_name='PROBE-C2-09');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'PROBE-C2-10', 'reasoning', 'By default, cached data is fresh. The cache entry is 40 days old and the TTL is 1 day. Should you treat the cached data as fresh?
Answer with exactly one word: VALID or INVALID.', 'INVALID', 'exact', true, 'I', 3 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'PROBE-C2-10');
INSERT INTO probe_metadata (test_name, probe_class, note) SELECT 'PROBE-C2-10', 'defeasible', 'defeater — TTL expired' WHERE NOT EXISTS (SELECT 1 FROM probe_metadata WHERE test_name='PROBE-C2-10');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'PROBE-C3-01', 'reasoning', '''Every server runs a monitoring agent.'' Does this mean there is ONE single agent that every server runs, or that each server runs SOME agent? It means: for each server there exists an agent (possibly different).
Answer with exactly one word: TRUE or FALSE.', 'TRUE', 'exact', true, 'I', 3 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'PROBE-C3-01');
INSERT INTO probe_metadata (test_name, probe_class, note) SELECT 'PROBE-C3-01', 'quant-scope', 'forall-exists, narrow exists' WHERE NOT EXISTS (SELECT 1 FROM probe_metadata WHERE test_name='PROBE-C3-01');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'PROBE-C3-02', 'reasoning', '''There is a key that opens every door in this building.'' Is the claim that ONE key opens all doors?
Answer with exactly one word: TRUE or FALSE.', 'TRUE', 'exact', true, 'I', 3 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'PROBE-C3-02');
INSERT INTO probe_metadata (test_name, probe_class, note) SELECT 'PROBE-C3-02', 'quant-scope', 'exists-wide — a single master key' WHERE NOT EXISTS (SELECT 1 FROM probe_metadata WHERE test_name='PROBE-C3-02');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'PROBE-C3-03', 'reasoning', '''Every container has a limit.'' Must all containers share the SAME single limit value?
Answer with exactly one word: TRUE or FALSE.', 'FALSE', 'exact', true, 'I', 3 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'PROBE-C3-03');
INSERT INTO probe_metadata (test_name, probe_class, note) SELECT 'PROBE-C3-03', 'quant-scope', 'forall-exists does not imply one shared value' WHERE NOT EXISTS (SELECT 1 FROM probe_metadata WHERE test_name='PROBE-C3-03');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'PROBE-C3-04', 'reasoning', '''Some process is listening on every required port.'' Could this be a DIFFERENT process per port rather than one process on all ports?
Answer with exactly one word: TRUE or FALSE.', 'FALSE', 'exact', true, 'I', 3 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'PROBE-C3-04');
INSERT INTO probe_metadata (test_name, probe_class, note) SELECT 'PROBE-C3-04', 'quant-scope', 'exists-wide reads as one process on every port; different-per-port is the other reading' WHERE NOT EXISTS (SELECT 1 FROM probe_metadata WHERE test_name='PROBE-C3-04');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'PROBE-C3-05', 'reasoning', '''All that glitters is not gold.'' Read literally as: nothing that glitters is gold. Is that literal reading the intended meaning of the proverb?
Answer with exactly one word: TRUE or FALSE.', 'FALSE', 'exact', true, 'I', 3 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'PROBE-C3-05');
INSERT INTO probe_metadata (test_name, probe_class, note) SELECT 'PROBE-C3-05', 'quant-scope', 'scope of negation — intended: not everything that glitters is gold' WHERE NOT EXISTS (SELECT 1 FROM probe_metadata WHERE test_name='PROBE-C3-05');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'PROBE-C3-06', 'reasoning', '''Every minute someone falls for the scam.'' Does this claim there is one specific person who falls for it every minute?
Answer with exactly one word: TRUE or FALSE.', 'FALSE', 'exact', true, 'I', 3 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'PROBE-C3-06');
INSERT INTO probe_metadata (test_name, probe_class, note) SELECT 'PROBE-C3-06', 'quant-scope', 'forall-exists, not a single dupe' WHERE NOT EXISTS (SELECT 1 FROM probe_metadata WHERE test_name='PROBE-C3-06');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'PROBE-C3-07', 'reasoning', '''Each node holds a copy of the ledger.'' Is this consistent with every node holding the SAME ledger contents?
Answer with exactly one word: TRUE or FALSE.', 'TRUE', 'exact', true, 'I', 3 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'PROBE-C3-07');
INSERT INTO probe_metadata (test_name, probe_class, note) SELECT 'PROBE-C3-07', 'quant-scope', 'forall-exists allows identical copies' WHERE NOT EXISTS (SELECT 1 FROM probe_metadata WHERE test_name='PROBE-C3-07');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'PROBE-C3-08', 'reasoning', '''A guard is posted at every entrance.'' Does this logically require the SAME guard at every entrance?
Answer with exactly one word: TRUE or FALSE.', 'FALSE', 'exact', true, 'I', 3 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'PROBE-C3-08');
INSERT INTO probe_metadata (test_name, probe_class, note) SELECT 'PROBE-C3-08', 'quant-scope', 'forall-exists, not one guard' WHERE NOT EXISTS (SELECT 1 FROM probe_metadata WHERE test_name='PROBE-C3-08');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'PROBE-C3-09', 'reasoning', '''Every test imports a shared fixture.'' Does ''a shared fixture'' here guarantee ONE fixture used by all tests?
Answer with exactly one word: TRUE or FALSE.', 'FALSE', 'exact', true, 'I', 3 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'PROBE-C3-09');
INSERT INTO probe_metadata (test_name, probe_class, note) SELECT 'PROBE-C3-09', 'quant-scope', 'scope ambiguous; forall-exists default does not guarantee one' WHERE NOT EXISTS (SELECT 1 FROM probe_metadata WHERE test_name='PROBE-C3-09');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'PROBE-C3-10', 'reasoning', '''There exists a prime number greater than every even number.'' Under the reading ''for every even number there is a greater prime'', is the statement true?
Answer with exactly one word: TRUE or FALSE.', 'TRUE', 'exact', true, 'I', 3 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'PROBE-C3-10');
INSERT INTO probe_metadata (test_name, probe_class, note) SELECT 'PROBE-C3-10', 'quant-scope', 'exists-wide false but the forall-exists reading is true (Euclid)' WHERE NOT EXISTS (SELECT 1 FROM probe_metadata WHERE test_name='PROBE-C3-10');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'PROBE-C4-01', 'reasoning', 'If the cache is warm, responses are fast. The cache is warm. Separately, the office plant needs watering. Are responses fast?
Answer with exactly one word: VALID or INVALID.', 'VALID', 'exact', true, 'I', 3 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'PROBE-C4-01');
INSERT INTO probe_metadata (test_name, probe_class, note) SELECT 'PROBE-C4-01', 'distractor', 'MP + distractor' WHERE NOT EXISTS (SELECT 1 FROM probe_metadata WHERE test_name='PROBE-C4-01');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'PROBE-C4-02', 'reasoning', 'If the cache is warm, responses are fast. Responses are fast. Separately, the office plant needs watering. Is the cache warm?
Answer with exactly one word: VALID or INVALID.', 'INVALID', 'exact', true, 'I', 3 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'PROBE-C4-02');
INSERT INTO probe_metadata (test_name, probe_class, note) SELECT 'PROBE-C4-02', 'distractor', 'converse trap + distractor' WHERE NOT EXISTS (SELECT 1 FROM probe_metadata WHERE test_name='PROBE-C4-02');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'PROBE-C4-03', 'reasoning', 'If P then Q. If Q then R. P. The cafeteria menu changes daily. Does R follow?
Answer with exactly one word: VALID or INVALID.', 'VALID', 'exact', true, 'I', 3 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'PROBE-C4-03');
INSERT INTO probe_metadata (test_name, probe_class, note) SELECT 'PROBE-C4-03', 'distractor', 'chain + distractor' WHERE NOT EXISTS (SELECT 1 FROM probe_metadata WHERE test_name='PROBE-C4-03');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'PROBE-C4-04', 'reasoning', 'If P then Q. If Q then R. R. The cafeteria menu changes daily. Does P follow?
Answer with exactly one word: VALID or INVALID.', 'INVALID', 'exact', true, 'I', 3 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'PROBE-C4-04');
INSERT INTO probe_metadata (test_name, probe_class, note) SELECT 'PROBE-C4-04', 'distractor', 'chain converse + distractor' WHERE NOT EXISTS (SELECT 1 FROM probe_metadata WHERE test_name='PROBE-C4-04');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'PROBE-C4-05', 'reasoning', 'Either the DNS is wrong or the route is down. The DNS is not wrong. The printer is out of toner. Is the route down?
Answer with exactly one word: VALID or INVALID.', 'VALID', 'exact', true, 'I', 3 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'PROBE-C4-05');
INSERT INTO probe_metadata (test_name, probe_class, note) SELECT 'PROBE-C4-05', 'distractor', 'DS + distractor' WHERE NOT EXISTS (SELECT 1 FROM probe_metadata WHERE test_name='PROBE-C4-05');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'PROBE-C4-06', 'reasoning', 'Either the DNS is wrong or the route is down (or both). The DNS is wrong. The printer is out of toner. Can you conclude the route is not down?
Answer with exactly one word: VALID or INVALID.', 'INVALID', 'exact', true, 'I', 3 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'PROBE-C4-06');
INSERT INTO probe_metadata (test_name, probe_class, note) SELECT 'PROBE-C4-06', 'distractor', 'affirm-disjunct + distractor' WHERE NOT EXISTS (SELECT 1 FROM probe_metadata WHERE test_name='PROBE-C4-06');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'PROBE-C4-07', 'reasoning', 'If backups run, data is safe. If data is safe, audits pass. Backups run. The parking lot is full. Do audits pass?
Answer with exactly one word: VALID or INVALID.', 'VALID', 'exact', true, 'I', 3 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'PROBE-C4-07');
INSERT INTO probe_metadata (test_name, probe_class, note) SELECT 'PROBE-C4-07', 'distractor', '2-hop + distractor' WHERE NOT EXISTS (SELECT 1 FROM probe_metadata WHERE test_name='PROBE-C4-07');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'PROBE-C4-08', 'reasoning', 'If backups run, data is safe. If data is safe, audits pass. Audits did not pass. The parking lot is full. Did backups fail to run?
Answer with exactly one word: VALID or INVALID.', 'VALID', 'exact', true, 'I', 3 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'PROBE-C4-08');
INSERT INTO probe_metadata (test_name, probe_class, note) SELECT 'PROBE-C4-08', 'distractor', '2-hop contrapositive + distractor' WHERE NOT EXISTS (SELECT 1 FROM probe_metadata WHERE test_name='PROBE-C4-08');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'PROBE-C4-09', 'reasoning', 'If backups run, data is safe. If data is safe, audits pass. Backups did not run. The parking lot is full. Did audits fail?
Answer with exactly one word: VALID or INVALID.', 'INVALID', 'exact', true, 'I', 3 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'PROBE-C4-09');
INSERT INTO probe_metadata (test_name, probe_class, note) SELECT 'PROBE-C4-09', 'distractor', '2-hop inverse trap + distractor' WHERE NOT EXISTS (SELECT 1 FROM probe_metadata WHERE test_name='PROBE-C4-09');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'PROBE-C4-10', 'reasoning', 'If the key is valid, the door opens. If the door opens, the alarm trips. The alarm did not trip. The weather is mild. Is the key not valid?
Answer with exactly one word: VALID or INVALID.', 'VALID', 'exact', true, 'I', 3 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'PROBE-C4-10');
INSERT INTO probe_metadata (test_name, probe_class, note) SELECT 'PROBE-C4-10', 'distractor', '2-hop contrapositive + distractor' WHERE NOT EXISTS (SELECT 1 FROM probe_metadata WHERE test_name='PROBE-C4-10');
