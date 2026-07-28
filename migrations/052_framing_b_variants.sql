-- Migration 052: framing-B (neutral) variants of the 20 framing-test items.
INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'PROBE-C1-01 [B-neutral]', 'reasoning', 'Read this argument:
"The update server logged 4,200 successful installs and zero rollback reports in the first week. Our staged rollout plan called for exactly this signal before widening. The rollout is proceeding as designed."
Does this argument commit a rhetorical fallacy? Answer with exactly one word: NONE if it commits no fallacy, otherwise FALSECAUSE, HASTYGEN, CIRCULAR, or ADPOPULUM.', 'NONE', 'exact', true, 'I', 3 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name='PROBE-C1-01 [B-neutral]');
INSERT INTO probe_metadata (test_name, probe_class, note) SELECT 'PROBE-C1-01 [B-neutral]', 'sound-arg', 'framing-B neutral variant' WHERE NOT EXISTS (SELECT 1 FROM probe_metadata WHERE test_name='PROBE-C1-01 [B-neutral]');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'PROBE-C1-02 [B-neutral]', 'reasoning', 'Read this argument:
"Two independent reviewers read the same 30 logs and flagged the same 4 as suspicious. We did not tell them which to flag. Their agreement suggests the 4 logs share a detectable property."
Does this argument commit a rhetorical fallacy? Answer with exactly one word: NONE if it commits no fallacy, otherwise FALSECAUSE, HASTYGEN, CIRCULAR, or ADPOPULUM.', 'NONE', 'exact', true, 'I', 3 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name='PROBE-C1-02 [B-neutral]');
INSERT INTO probe_metadata (test_name, probe_class, note) SELECT 'PROBE-C1-02 [B-neutral]', 'sound-arg', 'framing-B neutral variant' WHERE NOT EXISTS (SELECT 1 FROM probe_metadata WHERE test_name='PROBE-C1-02 [B-neutral]');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'PROBE-C1-03 [B-neutral]', 'reasoning', 'Read this argument:
"After we enabled connection pooling, median query latency fell from 180 ms to 40 ms across the same 10,000 queries, on unchanged hardware and an unchanged query mix, and no other configuration change was made in that window. The evidence supports the conclusion that connection pooling reduced query latency."
Does this argument commit a rhetorical fallacy? Answer with exactly one word: NONE if it commits no fallacy, otherwise FALSECAUSE, HASTYGEN, CIRCULAR, or ADPOPULUM.', 'NONE', 'exact', true, 'I', 3 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name='PROBE-C1-03 [B-neutral]');
INSERT INTO probe_metadata (test_name, probe_class, note) SELECT 'PROBE-C1-03 [B-neutral]', 'sound-arg', 'framing-B neutral variant' WHERE NOT EXISTS (SELECT 1 FROM probe_metadata WHERE test_name='PROBE-C1-03 [B-neutral]');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'PROBE-C1-N01 [B-neutral]', 'reasoning', 'Read this argument:
"The on-call engineer paged the team at 02:10 because the error rate crossed the 5% alert threshold defined in the runbook, and the dashboard shows the error rate at 6.3% at 02:09. The page followed the documented threshold."
Does this argument commit a rhetorical fallacy? Answer with exactly one word: NONE if it commits no fallacy, otherwise FALSECAUSE, HASTYGEN, CIRCULAR, or ADPOPULUM.', 'NONE', 'exact', true, 'I', 3 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name='PROBE-C1-N01 [B-neutral]');
INSERT INTO probe_metadata (test_name, probe_class, note) SELECT 'PROBE-C1-N01 [B-neutral]', 'sound-arg', 'framing-B neutral variant' WHERE NOT EXISTS (SELECT 1 FROM probe_metadata WHERE test_name='PROBE-C1-N01 [B-neutral]');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'PROBE-C1-N02 [B-neutral]', 'reasoning', 'Read this argument:
"We sampled 200 completed transactions and found 0 with a negative amount. Our reconciliation rule requires fewer than 1% anomalies to close the month. The month can be closed under that rule."
Does this argument commit a rhetorical fallacy? Answer with exactly one word: NONE if it commits no fallacy, otherwise FALSECAUSE, HASTYGEN, CIRCULAR, or ADPOPULUM.', 'NONE', 'exact', true, 'I', 3 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name='PROBE-C1-N02 [B-neutral]');
INSERT INTO probe_metadata (test_name, probe_class, note) SELECT 'PROBE-C1-N02 [B-neutral]', 'sound-arg', 'framing-B neutral variant' WHERE NOT EXISTS (SELECT 1 FROM probe_metadata WHERE test_name='PROBE-C1-N02 [B-neutral]');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'PROBE-C1-N03 [B-neutral]', 'reasoning', 'Read this argument:
"Before the schema migration we recorded 120 read timeouts per hour; after the migration, over the same traffic window, we recorded 3 per hour. The migration coincided with a large drop in read timeouts, holding traffic constant."
Does this argument commit a rhetorical fallacy? Answer with exactly one word: NONE if it commits no fallacy, otherwise FALSECAUSE, HASTYGEN, CIRCULAR, or ADPOPULUM.', 'NONE', 'exact', true, 'I', 3 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name='PROBE-C1-N03 [B-neutral]');
INSERT INTO probe_metadata (test_name, probe_class, note) SELECT 'PROBE-C1-N03 [B-neutral]', 'sound-arg', 'framing-B neutral variant' WHERE NOT EXISTS (SELECT 1 FROM probe_metadata WHERE test_name='PROBE-C1-N03 [B-neutral]');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'PROBE-C1-N04 [B-neutral]', 'reasoning', 'Read this argument:
"All three replicas returned identical checksums for the snapshot. The verification procedure requires a 3-of-3 checksum match before marking the snapshot restorable. The snapshot meets the restore criterion."
Does this argument commit a rhetorical fallacy? Answer with exactly one word: NONE if it commits no fallacy, otherwise FALSECAUSE, HASTYGEN, CIRCULAR, or ADPOPULUM.', 'NONE', 'exact', true, 'I', 3 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name='PROBE-C1-N04 [B-neutral]');
INSERT INTO probe_metadata (test_name, probe_class, note) SELECT 'PROBE-C1-N04 [B-neutral]', 'sound-arg', 'framing-B neutral variant' WHERE NOT EXISTS (SELECT 1 FROM probe_metadata WHERE test_name='PROBE-C1-N04 [B-neutral]');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'PROBE-C1-N05 [B-neutral]', 'reasoning', 'Read this argument:
"The cold-storage tier costs $0.004/GB-month and the hot tier costs $0.026/GB-month for the same durability SLA. Moving 80 TB of rarely-read archives to cold storage would reduce that data''s monthly storage cost."
Does this argument commit a rhetorical fallacy? Answer with exactly one word: NONE if it commits no fallacy, otherwise FALSECAUSE, HASTYGEN, CIRCULAR, or ADPOPULUM.', 'NONE', 'exact', true, 'I', 3 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name='PROBE-C1-N05 [B-neutral]');
INSERT INTO probe_metadata (test_name, probe_class, note) SELECT 'PROBE-C1-N05 [B-neutral]', 'sound-arg', 'framing-B neutral variant' WHERE NOT EXISTS (SELECT 1 FROM probe_metadata WHERE test_name='PROBE-C1-N05 [B-neutral]');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'PROBE-C1-N06 [B-neutral]', 'reasoning', 'Read this argument:
"The pen-test report lists no critical findings and two low findings, both patched and re-tested as resolved. Our release gate blocks only on unresolved critical or high findings. The build passes the security gate."
Does this argument commit a rhetorical fallacy? Answer with exactly one word: NONE if it commits no fallacy, otherwise FALSECAUSE, HASTYGEN, CIRCULAR, or ADPOPULUM.', 'NONE', 'exact', true, 'I', 3 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name='PROBE-C1-N06 [B-neutral]');
INSERT INTO probe_metadata (test_name, probe_class, note) SELECT 'PROBE-C1-N06 [B-neutral]', 'sound-arg', 'framing-B neutral variant' WHERE NOT EXISTS (SELECT 1 FROM probe_metadata WHERE test_name='PROBE-C1-N06 [B-neutral]');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'PROBE-C1-N07 [B-neutral]', 'reasoning', 'Read this argument:
"In a 30-day window the service met its 99.9% availability target with 41 minutes of downtime against a budget of 43 minutes. The service stayed within its error budget for the month."
Does this argument commit a rhetorical fallacy? Answer with exactly one word: NONE if it commits no fallacy, otherwise FALSECAUSE, HASTYGEN, CIRCULAR, or ADPOPULUM.', 'NONE', 'exact', true, 'I', 3 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name='PROBE-C1-N07 [B-neutral]');
INSERT INTO probe_metadata (test_name, probe_class, note) SELECT 'PROBE-C1-N07 [B-neutral]', 'sound-arg', 'framing-B neutral variant' WHERE NOT EXISTS (SELECT 1 FROM probe_metadata WHERE test_name='PROBE-C1-N07 [B-neutral]');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'PROBE-C1-04 [B-neutral]', 'reasoning', 'Read this argument:
"Ever since we hired the new intern, the nightly build has failed three times. Clearly the intern is breaking the build."
Does this argument commit a rhetorical fallacy? Answer with exactly one word: NONE if it commits no fallacy, otherwise FALSECAUSE, HASTYGEN, CIRCULAR, or ADPOPULUM.', 'FALSECAUSE', 'exact', true, 'I', 3 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name='PROBE-C1-04 [B-neutral]');
INSERT INTO probe_metadata (test_name, probe_class, note) SELECT 'PROBE-C1-04 [B-neutral]', 'sound-arg', 'framing-B neutral variant' WHERE NOT EXISTS (SELECT 1 FROM probe_metadata WHERE test_name='PROBE-C1-04 [B-neutral]');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'PROBE-C1-05 [B-neutral]', 'reasoning', 'Read this argument:
"We deployed on Friday and by Monday user complaints had doubled. The deployment must be the cause of the complaints."
Does this argument commit a rhetorical fallacy? Answer with exactly one word: NONE if it commits no fallacy, otherwise FALSECAUSE, HASTYGEN, CIRCULAR, or ADPOPULUM.', 'FALSECAUSE', 'exact', true, 'I', 3 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name='PROBE-C1-05 [B-neutral]');
INSERT INTO probe_metadata (test_name, probe_class, note) SELECT 'PROBE-C1-05 [B-neutral]', 'sound-arg', 'framing-B neutral variant' WHERE NOT EXISTS (SELECT 1 FROM probe_metadata WHERE test_name='PROBE-C1-05 [B-neutral]');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'PROBE-C1-C11 [B-neutral]', 'reasoning', 'Read this argument:
"We rolled out the new icon set on Tuesday, and by Thursday our sign-up rate had risen. The new icons must be what drove sign-ups up."
Does this argument commit a rhetorical fallacy? Answer with exactly one word: NONE if it commits no fallacy, otherwise FALSECAUSE, HASTYGEN, CIRCULAR, or ADPOPULUM.', 'FALSECAUSE', 'exact', true, 'I', 3 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name='PROBE-C1-C11 [B-neutral]');
INSERT INTO probe_metadata (test_name, probe_class, note) SELECT 'PROBE-C1-C11 [B-neutral]', 'sound-arg', 'framing-B neutral variant' WHERE NOT EXISTS (SELECT 1 FROM probe_metadata WHERE test_name='PROBE-C1-C11 [B-neutral]');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'PROBE-C1-06 [B-neutral]', 'reasoning', 'Read this argument:
"One user in Oslo reported the app crashed on launch. The app must be broken for all users in Norway."
Does this argument commit a rhetorical fallacy? Answer with exactly one word: NONE if it commits no fallacy, otherwise FALSECAUSE, HASTYGEN, CIRCULAR, or ADPOPULUM.', 'HASTYGEN', 'exact', true, 'I', 3 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name='PROBE-C1-06 [B-neutral]');
INSERT INTO probe_metadata (test_name, probe_class, note) SELECT 'PROBE-C1-06 [B-neutral]', 'sound-arg', 'framing-B neutral variant' WHERE NOT EXISTS (SELECT 1 FROM probe_metadata WHERE test_name='PROBE-C1-06 [B-neutral]');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'PROBE-C1-07 [B-neutral]', 'reasoning', 'Read this argument:
"The first two pancakes I flipped burned. This stove clearly can''t cook pancakes."
Does this argument commit a rhetorical fallacy? Answer with exactly one word: NONE if it commits no fallacy, otherwise FALSECAUSE, HASTYGEN, CIRCULAR, or ADPOPULUM.', 'HASTYGEN', 'exact', true, 'I', 3 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name='PROBE-C1-07 [B-neutral]');
INSERT INTO probe_metadata (test_name, probe_class, note) SELECT 'PROBE-C1-07 [B-neutral]', 'sound-arg', 'framing-B neutral variant' WHERE NOT EXISTS (SELECT 1 FROM probe_metadata WHERE test_name='PROBE-C1-07 [B-neutral]');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'PROBE-C1-C12 [B-neutral]', 'reasoning', 'Read this argument:
"The one beta tester we asked said the onboarding was confusing. Our onboarding is confusing for everyone."
Does this argument commit a rhetorical fallacy? Answer with exactly one word: NONE if it commits no fallacy, otherwise FALSECAUSE, HASTYGEN, CIRCULAR, or ADPOPULUM.', 'HASTYGEN', 'exact', true, 'I', 3 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name='PROBE-C1-C12 [B-neutral]');
INSERT INTO probe_metadata (test_name, probe_class, note) SELECT 'PROBE-C1-C12 [B-neutral]', 'sound-arg', 'framing-B neutral variant' WHERE NOT EXISTS (SELECT 1 FROM probe_metadata WHERE test_name='PROBE-C1-C12 [B-neutral]');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'PROBE-C1-08 [B-neutral]', 'reasoning', 'Read this argument:
"This backup is reliable because it never fails. And we know it never fails because it''s a reliable backup."
Does this argument commit a rhetorical fallacy? Answer with exactly one word: NONE if it commits no fallacy, otherwise FALSECAUSE, HASTYGEN, CIRCULAR, or ADPOPULUM.', 'CIRCULAR', 'exact', true, 'I', 3 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name='PROBE-C1-08 [B-neutral]');
INSERT INTO probe_metadata (test_name, probe_class, note) SELECT 'PROBE-C1-08 [B-neutral]', 'sound-arg', 'framing-B neutral variant' WHERE NOT EXISTS (SELECT 1 FROM probe_metadata WHERE test_name='PROBE-C1-08 [B-neutral]');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'PROBE-C1-C13 [B-neutral]', 'reasoning', 'Read this argument:
"This metric is trustworthy because it is accurate, and we know it is accurate because it is a trustworthy metric."
Does this argument commit a rhetorical fallacy? Answer with exactly one word: NONE if it commits no fallacy, otherwise FALSECAUSE, HASTYGEN, CIRCULAR, or ADPOPULUM.', 'CIRCULAR', 'exact', true, 'I', 3 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name='PROBE-C1-C13 [B-neutral]');
INSERT INTO probe_metadata (test_name, probe_class, note) SELECT 'PROBE-C1-C13 [B-neutral]', 'sound-arg', 'framing-B neutral variant' WHERE NOT EXISTS (SELECT 1 FROM probe_metadata WHERE test_name='PROBE-C1-C13 [B-neutral]');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'PROBE-C1-09 [B-neutral]', 'reasoning', 'Read this argument:
"Everyone on the team already uses this linter, so it must be the right choice for the project."
Does this argument commit a rhetorical fallacy? Answer with exactly one word: NONE if it commits no fallacy, otherwise FALSECAUSE, HASTYGEN, CIRCULAR, or ADPOPULUM.', 'ADPOPULUM', 'exact', true, 'I', 3 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name='PROBE-C1-09 [B-neutral]');
INSERT INTO probe_metadata (test_name, probe_class, note) SELECT 'PROBE-C1-09 [B-neutral]', 'sound-arg', 'framing-B neutral variant' WHERE NOT EXISTS (SELECT 1 FROM probe_metadata WHERE test_name='PROBE-C1-09 [B-neutral]');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'PROBE-C1-10 [B-neutral]', 'reasoning', 'Read this argument:
"Thousands of people forward this warning every day, so the threat it describes must be real."
Does this argument commit a rhetorical fallacy? Answer with exactly one word: NONE if it commits no fallacy, otherwise FALSECAUSE, HASTYGEN, CIRCULAR, or ADPOPULUM.', 'ADPOPULUM', 'exact', true, 'I', 3 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name='PROBE-C1-10 [B-neutral]');
INSERT INTO probe_metadata (test_name, probe_class, note) SELECT 'PROBE-C1-10 [B-neutral]', 'sound-arg', 'framing-B neutral variant' WHERE NOT EXISTS (SELECT 1 FROM probe_metadata WHERE test_name='PROBE-C1-10 [B-neutral]');
