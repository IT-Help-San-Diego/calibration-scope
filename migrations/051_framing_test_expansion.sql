-- Migration 051: framing-test expansion — 7 NONE items + 6 controls, reword applied separately.
INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'PROBE-C1-N01', 'reasoning', 'Read this argument:
"The on-call engineer paged the team at 02:10 because the error rate crossed the 5% alert threshold defined in the runbook, and the dashboard shows the error rate at 6.3% at 02:09. The page followed the documented threshold."
Which single rhetorical fallacy best describes it? Answer with exactly one word: FALSECAUSE, HASTYGEN, CIRCULAR, ADPOPULUM, or NONE.', 'NONE', 'exact', true, 'I', 3 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name='PROBE-C1-N01');
INSERT INTO probe_metadata (test_name, probe_class, note) SELECT 'PROBE-C1-N01', 'sound-arg', 'framing-test expansion' WHERE NOT EXISTS (SELECT 1 FROM probe_metadata WHERE test_name='PROBE-C1-N01');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'PROBE-C1-N02', 'reasoning', 'Read this argument:
"We sampled 200 completed transactions and found 0 with a negative amount. Our reconciliation rule requires fewer than 1% anomalies to close the month. The month can be closed under that rule."
Which single rhetorical fallacy best describes it? Answer with exactly one word: FALSECAUSE, HASTYGEN, CIRCULAR, ADPOPULUM, or NONE.', 'NONE', 'exact', true, 'I', 3 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name='PROBE-C1-N02');
INSERT INTO probe_metadata (test_name, probe_class, note) SELECT 'PROBE-C1-N02', 'sound-arg', 'framing-test expansion' WHERE NOT EXISTS (SELECT 1 FROM probe_metadata WHERE test_name='PROBE-C1-N02');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'PROBE-C1-N03', 'reasoning', 'Read this argument:
"Before the schema migration we recorded 120 read timeouts per hour; after the migration, over the same traffic window, we recorded 3 per hour. The migration coincided with a large drop in read timeouts, holding traffic constant."
Which single rhetorical fallacy best describes it? Answer with exactly one word: FALSECAUSE, HASTYGEN, CIRCULAR, ADPOPULUM, or NONE.', 'NONE', 'exact', true, 'I', 3 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name='PROBE-C1-N03');
INSERT INTO probe_metadata (test_name, probe_class, note) SELECT 'PROBE-C1-N03', 'sound-arg', 'framing-test expansion' WHERE NOT EXISTS (SELECT 1 FROM probe_metadata WHERE test_name='PROBE-C1-N03');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'PROBE-C1-N04', 'reasoning', 'Read this argument:
"All three replicas returned identical checksums for the snapshot. The verification procedure requires a 3-of-3 checksum match before marking the snapshot restorable. The snapshot meets the restore criterion."
Which single rhetorical fallacy best describes it? Answer with exactly one word: FALSECAUSE, HASTYGEN, CIRCULAR, ADPOPULUM, or NONE.', 'NONE', 'exact', true, 'I', 3 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name='PROBE-C1-N04');
INSERT INTO probe_metadata (test_name, probe_class, note) SELECT 'PROBE-C1-N04', 'sound-arg', 'framing-test expansion' WHERE NOT EXISTS (SELECT 1 FROM probe_metadata WHERE test_name='PROBE-C1-N04');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'PROBE-C1-N05', 'reasoning', 'Read this argument:
"The cold-storage tier costs $0.004/GB-month and the hot tier costs $0.026/GB-month for the same durability SLA. Moving 80 TB of rarely-read archives to cold storage would reduce that data''s monthly storage cost."
Which single rhetorical fallacy best describes it? Answer with exactly one word: FALSECAUSE, HASTYGEN, CIRCULAR, ADPOPULUM, or NONE.', 'NONE', 'exact', true, 'I', 3 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name='PROBE-C1-N05');
INSERT INTO probe_metadata (test_name, probe_class, note) SELECT 'PROBE-C1-N05', 'sound-arg', 'framing-test expansion' WHERE NOT EXISTS (SELECT 1 FROM probe_metadata WHERE test_name='PROBE-C1-N05');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'PROBE-C1-N06', 'reasoning', 'Read this argument:
"The pen-test report lists no critical findings and two low findings, both patched and re-tested as resolved. Our release gate blocks only on unresolved critical or high findings. The build passes the security gate."
Which single rhetorical fallacy best describes it? Answer with exactly one word: FALSECAUSE, HASTYGEN, CIRCULAR, ADPOPULUM, or NONE.', 'NONE', 'exact', true, 'I', 3 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name='PROBE-C1-N06');
INSERT INTO probe_metadata (test_name, probe_class, note) SELECT 'PROBE-C1-N06', 'sound-arg', 'framing-test expansion' WHERE NOT EXISTS (SELECT 1 FROM probe_metadata WHERE test_name='PROBE-C1-N06');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'PROBE-C1-N07', 'reasoning', 'Read this argument:
"In a 30-day window the service met its 99.9% availability target with 41 minutes of downtime against a budget of 43 minutes. The service stayed within its error budget for the month."
Which single rhetorical fallacy best describes it? Answer with exactly one word: FALSECAUSE, HASTYGEN, CIRCULAR, ADPOPULUM, or NONE.', 'NONE', 'exact', true, 'I', 3 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name='PROBE-C1-N07');
INSERT INTO probe_metadata (test_name, probe_class, note) SELECT 'PROBE-C1-N07', 'sound-arg', 'framing-test expansion' WHERE NOT EXISTS (SELECT 1 FROM probe_metadata WHERE test_name='PROBE-C1-N07');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'PROBE-C1-C11', 'reasoning', 'Read this argument:
"We rolled out the new icon set on Tuesday, and by Thursday our sign-up rate had risen. The new icons must be what drove sign-ups up."
Which single rhetorical fallacy best describes it? Answer with exactly one word: FALSECAUSE, HASTYGEN, CIRCULAR, ADPOPULUM, or NONE.', 'FALSECAUSE', 'exact', true, 'I', 3 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name='PROBE-C1-C11');
INSERT INTO probe_metadata (test_name, probe_class, note) SELECT 'PROBE-C1-C11', 'sound-arg', 'framing-test expansion' WHERE NOT EXISTS (SELECT 1 FROM probe_metadata WHERE test_name='PROBE-C1-C11');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'PROBE-C1-C12', 'reasoning', 'Read this argument:
"The one beta tester we asked said the onboarding was confusing. Our onboarding is confusing for everyone."
Which single rhetorical fallacy best describes it? Answer with exactly one word: FALSECAUSE, HASTYGEN, CIRCULAR, ADPOPULUM, or NONE.', 'HASTYGEN', 'exact', true, 'I', 3 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name='PROBE-C1-C12');
INSERT INTO probe_metadata (test_name, probe_class, note) SELECT 'PROBE-C1-C12', 'sound-arg', 'framing-test expansion' WHERE NOT EXISTS (SELECT 1 FROM probe_metadata WHERE test_name='PROBE-C1-C12');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'PROBE-C1-C13', 'reasoning', 'Read this argument:
"This metric is trustworthy because it is accurate, and we know it is accurate because it is a trustworthy metric."
Which single rhetorical fallacy best describes it? Answer with exactly one word: FALSECAUSE, HASTYGEN, CIRCULAR, ADPOPULUM, or NONE.', 'CIRCULAR', 'exact', true, 'I', 3 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name='PROBE-C1-C13');
INSERT INTO probe_metadata (test_name, probe_class, note) SELECT 'PROBE-C1-C13', 'sound-arg', 'framing-test expansion' WHERE NOT EXISTS (SELECT 1 FROM probe_metadata WHERE test_name='PROBE-C1-C13');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'PROBE-C1-C14', 'reasoning', 'Read this argument:
"Most of the team voted to keep the old framework, so the old framework is the technically better choice."
Which single rhetorical fallacy best describes it? Answer with exactly one word: FALSECAUSE, HASTYGEN, CIRCULAR, ADPOPULUM, or NONE.', 'ADPOPULUM', 'exact', true, 'I', 3 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name='PROBE-C1-C14');
INSERT INTO probe_metadata (test_name, probe_class, note) SELECT 'PROBE-C1-C14', 'sound-arg', 'framing-test expansion' WHERE NOT EXISTS (SELECT 1 FROM probe_metadata WHERE test_name='PROBE-C1-C14');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'PROBE-C1-C15', 'reasoning', 'Read this argument:
"Sales rose right after we changed the login button color, so the new color caused the sales increase."
Which single rhetorical fallacy best describes it? Answer with exactly one word: FALSECAUSE, HASTYGEN, CIRCULAR, ADPOPULUM, or NONE.', 'FALSECAUSE', 'exact', true, 'I', 3 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name='PROBE-C1-C15');
INSERT INTO probe_metadata (test_name, probe_class, note) SELECT 'PROBE-C1-C15', 'sound-arg', 'framing-test expansion' WHERE NOT EXISTS (SELECT 1 FROM probe_metadata WHERE test_name='PROBE-C1-C15');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'PROBE-C1-C16', 'reasoning', 'Read this argument:
"My two coworkers both dislike the new ticket system, so the whole company must hate it."
Which single rhetorical fallacy best describes it? Answer with exactly one word: FALSECAUSE, HASTYGEN, CIRCULAR, ADPOPULUM, or NONE.', 'HASTYGEN', 'exact', true, 'I', 3 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name='PROBE-C1-C16');
INSERT INTO probe_metadata (test_name, probe_class, note) SELECT 'PROBE-C1-C16', 'sound-arg', 'framing-test expansion' WHERE NOT EXISTS (SELECT 1 FROM probe_metadata WHERE test_name='PROBE-C1-C16');
