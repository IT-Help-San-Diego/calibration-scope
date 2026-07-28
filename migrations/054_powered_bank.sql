-- Migration 054: powered bank — 293 items, quant-scope + defeasible (HOLDS/DEFEATED).
-- Claude Science CORRECTION_powered_run_sizing (~320 target). 6 reps per item.
CREATE TABLE IF NOT EXISTS powered_metadata (test_name text PRIMARY KEY, probe_class text, family_id text, note text);

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS001A', 'reasoning', '''Every server runs an agent.'' Does this claim require that ONE single entity serves all servers, or only that each server has some (possibly different) one? It claims: for each server there exists one (not necessarily the same). Answer with exactly one word: TRUE or FALSE.', 'TRUE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS001A');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS001A', 'quant-scope', 'QS-FA01', 'forall-exists narrow scope' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS001A');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS001B', 'reasoning', '''Every server runs an agent.'' Does this logically require that all servers share the SAME single one? Answer with exactly one word: TRUE or FALSE.', 'FALSE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS001B');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS001B', 'quant-scope', 'QS-FA01', 'forall-exists does not force one shared' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS001B');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS002A', 'reasoning', '''Every node holds a token.'' Does this claim require that ONE single entity serves all nodes, or only that each node has some (possibly different) one? It claims: for each node there exists one (not necessarily the same). Answer with exactly one word: TRUE or FALSE.', 'TRUE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS002A');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS002A', 'quant-scope', 'QS-FA02', 'forall-exists narrow scope' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS002A');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS002B', 'reasoning', '''Every node holds a token.'' Does this logically require that all nodes share the SAME single one? Answer with exactly one word: TRUE or FALSE.', 'FALSE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS002B');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS002B', 'quant-scope', 'QS-FA02', 'forall-exists does not force one shared' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS002B');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS003A', 'reasoning', '''Every replica has a copy.'' Does this claim require that ONE single entity serves all replicas, or only that each replica has some (possibly different) one? It claims: for each replica there exists one (not necessarily the same). Answer with exactly one word: TRUE or FALSE.', 'TRUE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS003A');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS003A', 'quant-scope', 'QS-FA03', 'forall-exists narrow scope' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS003A');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS003B', 'reasoning', '''Every replica has a copy.'' Does this logically require that all replicas share the SAME single one? Answer with exactly one word: TRUE or FALSE.', 'FALSE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS003B');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS003B', 'quant-scope', 'QS-FA03', 'forall-exists does not force one shared' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS003B');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS004A', 'reasoning', '''Every container has a limit.'' Does this claim require that ONE single entity serves all containers, or only that each container has some (possibly different) one? It claims: for each container there exists one (not necessarily the same). Answer with exactly one word: TRUE or FALSE.', 'TRUE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS004A');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS004A', 'quant-scope', 'QS-FA04', 'forall-exists narrow scope' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS004A');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS004B', 'reasoning', '''Every container has a limit.'' Does this logically require that all containers share the SAME single one? Answer with exactly one word: TRUE or FALSE.', 'FALSE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS004B');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS004B', 'quant-scope', 'QS-FA04', 'forall-exists does not force one shared' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS004B');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS005A', 'reasoning', '''Every test imports a fixture.'' Does this claim require that ONE single entity serves all tests, or only that each test has some (possibly different) one? It claims: for each test there exists one (not necessarily the same). Answer with exactly one word: TRUE or FALSE.', 'TRUE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS005A');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS005A', 'quant-scope', 'QS-FA05', 'forall-exists narrow scope' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS005A');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS005B', 'reasoning', '''Every test imports a fixture.'' Does this logically require that all tests share the SAME single one? Answer with exactly one word: TRUE or FALSE.', 'FALSE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS005B');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS005B', 'quant-scope', 'QS-FA05', 'forall-exists does not force one shared' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS005B');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS006A', 'reasoning', '''Every port has a listener.'' Does this claim require that ONE single entity serves all ports, or only that each port has some (possibly different) one? It claims: for each port there exists one (not necessarily the same). Answer with exactly one word: TRUE or FALSE.', 'TRUE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS006A');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS006A', 'quant-scope', 'QS-FA06', 'forall-exists narrow scope' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS006A');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS006B', 'reasoning', '''Every port has a listener.'' Does this logically require that all ports share the SAME single one? Answer with exactly one word: TRUE or FALSE.', 'FALSE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS006B');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS006B', 'quant-scope', 'QS-FA06', 'forall-exists does not force one shared' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS006B');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS007A', 'reasoning', '''Every file has an owner.'' Does this claim require that ONE single entity serves all files, or only that each file has some (possibly different) one? It claims: for each file there exists one (not necessarily the same). Answer with exactly one word: TRUE or FALSE.', 'TRUE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS007A');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS007A', 'quant-scope', 'QS-FA07', 'forall-exists narrow scope' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS007A');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS007B', 'reasoning', '''Every file has an owner.'' Does this logically require that all files share the SAME single one? Answer with exactly one word: TRUE or FALSE.', 'FALSE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS007B');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS007B', 'quant-scope', 'QS-FA07', 'forall-exists does not force one shared' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS007B');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS008A', 'reasoning', '''Every task has a deadline.'' Does this claim require that ONE single entity serves all tasks, or only that each task has some (possibly different) one? It claims: for each task there exists one (not necessarily the same). Answer with exactly one word: TRUE or FALSE.', 'TRUE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS008A');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS008A', 'quant-scope', 'QS-FA08', 'forall-exists narrow scope' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS008A');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS008B', 'reasoning', '''Every task has a deadline.'' Does this logically require that all tasks share the SAME single one? Answer with exactly one word: TRUE or FALSE.', 'FALSE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS008B');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS008B', 'quant-scope', 'QS-FA08', 'forall-exists does not force one shared' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS008B');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS009A', 'reasoning', '''Every user has a role.'' Does this claim require that ONE single entity serves all users, or only that each user has some (possibly different) one? It claims: for each user there exists one (not necessarily the same). Answer with exactly one word: TRUE or FALSE.', 'TRUE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS009A');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS009A', 'quant-scope', 'QS-FA09', 'forall-exists narrow scope' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS009A');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS009B', 'reasoning', '''Every user has a role.'' Does this logically require that all users share the SAME single one? Answer with exactly one word: TRUE or FALSE.', 'FALSE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS009B');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS009B', 'quant-scope', 'QS-FA09', 'forall-exists does not force one shared' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS009B');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS010A', 'reasoning', '''Every backup has a checksum.'' Does this claim require that ONE single entity serves all backups, or only that each backup has some (possibly different) one? It claims: for each backup there exists one (not necessarily the same). Answer with exactly one word: TRUE or FALSE.', 'TRUE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS010A');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS010A', 'quant-scope', 'QS-FA10', 'forall-exists narrow scope' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS010A');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS010B', 'reasoning', '''Every backup has a checksum.'' Does this logically require that all backups share the SAME single one? Answer with exactly one word: TRUE or FALSE.', 'FALSE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS010B');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS010B', 'quant-scope', 'QS-FA10', 'forall-exists does not force one shared' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS010B');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS011A', 'reasoning', '''Every queue has a consumer.'' Does this claim require that ONE single entity serves all queues, or only that each queue has some (possibly different) one? It claims: for each queue there exists one (not necessarily the same). Answer with exactly one word: TRUE or FALSE.', 'TRUE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS011A');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS011A', 'quant-scope', 'QS-FA11', 'forall-exists narrow scope' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS011A');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS011B', 'reasoning', '''Every queue has a consumer.'' Does this logically require that all queues share the SAME single one? Answer with exactly one word: TRUE or FALSE.', 'FALSE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS011B');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS011B', 'quant-scope', 'QS-FA11', 'forall-exists does not force one shared' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS011B');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS012A', 'reasoning', '''Every shard has a leader.'' Does this claim require that ONE single entity serves all shards, or only that each shard has some (possibly different) one? It claims: for each shard there exists one (not necessarily the same). Answer with exactly one word: TRUE or FALSE.', 'TRUE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS012A');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS012A', 'quant-scope', 'QS-FA12', 'forall-exists narrow scope' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS012A');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS012B', 'reasoning', '''Every shard has a leader.'' Does this logically require that all shards share the SAME single one? Answer with exactly one word: TRUE or FALSE.', 'FALSE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS012B');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS012B', 'quant-scope', 'QS-FA12', 'forall-exists does not force one shared' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS012B');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS013A', 'reasoning', '''Every endpoint has a certificate.'' Does this claim require that ONE single entity serves all endpoints, or only that each endpoint has some (possibly different) one? It claims: for each endpoint there exists one (not necessarily the same). Answer with exactly one word: TRUE or FALSE.', 'TRUE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS013A');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS013A', 'quant-scope', 'QS-FA13', 'forall-exists narrow scope' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS013A');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS013B', 'reasoning', '''Every endpoint has a certificate.'' Does this logically require that all endpoints share the SAME single one? Answer with exactly one word: TRUE or FALSE.', 'FALSE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS013B');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS013B', 'quant-scope', 'QS-FA13', 'forall-exists does not force one shared' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS013B');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS014A', 'reasoning', '''Every job has a priority.'' Does this claim require that ONE single entity serves all jobs, or only that each job has some (possibly different) one? It claims: for each job there exists one (not necessarily the same). Answer with exactly one word: TRUE or FALSE.', 'TRUE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS014A');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS014A', 'quant-scope', 'QS-FA14', 'forall-exists narrow scope' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS014A');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS014B', 'reasoning', '''Every job has a priority.'' Does this logically require that all jobs share the SAME single one? Answer with exactly one word: TRUE or FALSE.', 'FALSE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS014B');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS014B', 'quant-scope', 'QS-FA14', 'forall-exists does not force one shared' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS014B');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS015A', 'reasoning', '''Every table has an index.'' Does this claim require that ONE single entity serves all tables, or only that each table has some (possibly different) one? It claims: for each table there exists one (not necessarily the same). Answer with exactly one word: TRUE or FALSE.', 'TRUE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS015A');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS015A', 'quant-scope', 'QS-FA15', 'forall-exists narrow scope' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS015A');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS015B', 'reasoning', '''Every table has an index.'' Does this logically require that all tables share the SAME single one? Answer with exactly one word: TRUE or FALSE.', 'FALSE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS015B');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS015B', 'quant-scope', 'QS-FA15', 'forall-exists does not force one shared' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS015B');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS016A', 'reasoning', '''Every worker has a queue.'' Does this claim require that ONE single entity serves all workers, or only that each worker has some (possibly different) one? It claims: for each worker there exists one (not necessarily the same). Answer with exactly one word: TRUE or FALSE.', 'TRUE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS016A');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS016A', 'quant-scope', 'QS-FA16', 'forall-exists narrow scope' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS016A');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS016B', 'reasoning', '''Every worker has a queue.'' Does this logically require that all workers share the SAME single one? Answer with exactly one word: TRUE or FALSE.', 'FALSE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS016B');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS016B', 'quant-scope', 'QS-FA16', 'forall-exists does not force one shared' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS016B');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS017A', 'reasoning', '''Every session has an expiry.'' Does this claim require that ONE single entity serves all sessions, or only that each session has some (possibly different) one? It claims: for each session there exists one (not necessarily the same). Answer with exactly one word: TRUE or FALSE.', 'TRUE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS017A');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS017A', 'quant-scope', 'QS-FA17', 'forall-exists narrow scope' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS017A');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS017B', 'reasoning', '''Every session has an expiry.'' Does this logically require that all sessions share the SAME single one? Answer with exactly one word: TRUE or FALSE.', 'FALSE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS017B');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS017B', 'quant-scope', 'QS-FA17', 'forall-exists does not force one shared' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS017B');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS018A', 'reasoning', '''Every bucket has a policy.'' Does this claim require that ONE single entity serves all buckets, or only that each bucket has some (possibly different) one? It claims: for each bucket there exists one (not necessarily the same). Answer with exactly one word: TRUE or FALSE.', 'TRUE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS018A');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS018A', 'quant-scope', 'QS-FA18', 'forall-exists narrow scope' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS018A');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS018B', 'reasoning', '''Every bucket has a policy.'' Does this logically require that all buckets share the SAME single one? Answer with exactly one word: TRUE or FALSE.', 'FALSE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS018B');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS018B', 'quant-scope', 'QS-FA18', 'forall-exists does not force one shared' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS018B');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS019A', 'reasoning', '''Every stream has a partition.'' Does this claim require that ONE single entity serves all streams, or only that each stream has some (possibly different) one? It claims: for each stream there exists one (not necessarily the same). Answer with exactly one word: TRUE or FALSE.', 'TRUE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS019A');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS019A', 'quant-scope', 'QS-FA19', 'forall-exists narrow scope' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS019A');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS019B', 'reasoning', '''Every stream has a partition.'' Does this logically require that all streams share the SAME single one? Answer with exactly one word: TRUE or FALSE.', 'FALSE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS019B');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS019B', 'quant-scope', 'QS-FA19', 'forall-exists does not force one shared' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS019B');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS020A', 'reasoning', '''Every cache has a TTL.'' Does this claim require that ONE single entity serves all caches, or only that each cache has some (possibly different) one? It claims: for each cache there exists one (not necessarily the same). Answer with exactly one word: TRUE or FALSE.', 'TRUE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS020A');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS020A', 'quant-scope', 'QS-FA20', 'forall-exists narrow scope' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS020A');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS020B', 'reasoning', '''Every cache has a TTL.'' Does this logically require that all caches share the SAME single one? Answer with exactly one word: TRUE or FALSE.', 'FALSE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS020B');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS020B', 'quant-scope', 'QS-FA20', 'forall-exists does not force one shared' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS020B');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS021A', 'reasoning', '''Every secret has an expiry.'' Does this claim require that ONE single entity serves all secrets, or only that each secret has some (possibly different) one? It claims: for each secret there exists one (not necessarily the same). Answer with exactly one word: TRUE or FALSE.', 'TRUE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS021A');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS021A', 'quant-scope', 'QS-FA21', 'forall-exists narrow scope' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS021A');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS021B', 'reasoning', '''Every secret has an expiry.'' Does this logically require that all secrets share the SAME single one? Answer with exactly one word: TRUE or FALSE.', 'FALSE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS021B');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS021B', 'quant-scope', 'QS-FA21', 'forall-exists does not force one shared' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS021B');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS022A', 'reasoning', '''Every pipeline has a stage.'' Does this claim require that ONE single entity serves all pipelines, or only that each pipeline has some (possibly different) one? It claims: for each pipeline there exists one (not necessarily the same). Answer with exactly one word: TRUE or FALSE.', 'TRUE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS022A');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS022A', 'quant-scope', 'QS-FA22', 'forall-exists narrow scope' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS022A');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS022B', 'reasoning', '''Every pipeline has a stage.'' Does this logically require that all pipelines share the SAME single one? Answer with exactly one word: TRUE or FALSE.', 'FALSE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS022B');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS022B', 'quant-scope', 'QS-FA22', 'forall-exists does not force one shared' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS022B');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS023A', 'reasoning', '''Every cluster has a quorum.'' Does this claim require that ONE single entity serves all clusters, or only that each cluster has some (possibly different) one? It claims: for each cluster there exists one (not necessarily the same). Answer with exactly one word: TRUE or FALSE.', 'TRUE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS023A');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS023A', 'quant-scope', 'QS-FA23', 'forall-exists narrow scope' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS023A');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS023B', 'reasoning', '''Every cluster has a quorum.'' Does this logically require that all clusters share the SAME single one? Answer with exactly one word: TRUE or FALSE.', 'FALSE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS023B');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS023B', 'quant-scope', 'QS-FA23', 'forall-exists does not force one shared' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS023B');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS024A', 'reasoning', '''Every log has a level.'' Does this claim require that ONE single entity serves all logs, or only that each log has some (possibly different) one? It claims: for each log there exists one (not necessarily the same). Answer with exactly one word: TRUE or FALSE.', 'TRUE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS024A');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS024A', 'quant-scope', 'QS-FA24', 'forall-exists narrow scope' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS024A');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS024B', 'reasoning', '''Every log has a level.'' Does this logically require that all logs share the SAME single one? Answer with exactly one word: TRUE or FALSE.', 'FALSE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS024B');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS024B', 'quant-scope', 'QS-FA24', 'forall-exists does not force one shared' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS024B');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS025A', 'reasoning', '''Every metric has a label.'' Does this claim require that ONE single entity serves all metrics, or only that each metric has some (possibly different) one? It claims: for each metric there exists one (not necessarily the same). Answer with exactly one word: TRUE or FALSE.', 'TRUE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS025A');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS025A', 'quant-scope', 'QS-FA25', 'forall-exists narrow scope' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS025A');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS025B', 'reasoning', '''Every metric has a label.'' Does this logically require that all metrics share the SAME single one? Answer with exactly one word: TRUE or FALSE.', 'FALSE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS025B');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS025B', 'quant-scope', 'QS-FA25', 'forall-exists does not force one shared' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS025B');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS026A', 'reasoning', '''Every alert has a severity.'' Does this claim require that ONE single entity serves all alerts, or only that each alert has some (possibly different) one? It claims: for each alert there exists one (not necessarily the same). Answer with exactly one word: TRUE or FALSE.', 'TRUE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS026A');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS026A', 'quant-scope', 'QS-FA26', 'forall-exists narrow scope' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS026A');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS026B', 'reasoning', '''Every alert has a severity.'' Does this logically require that all alerts share the SAME single one? Answer with exactly one word: TRUE or FALSE.', 'FALSE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS026B');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS026B', 'quant-scope', 'QS-FA26', 'forall-exists does not force one shared' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS026B');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS027A', 'reasoning', '''Every build has an artifact.'' Does this claim require that ONE single entity serves all builds, or only that each build has some (possibly different) one? It claims: for each build there exists one (not necessarily the same). Answer with exactly one word: TRUE or FALSE.', 'TRUE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS027A');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS027A', 'quant-scope', 'QS-FA27', 'forall-exists narrow scope' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS027A');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS027B', 'reasoning', '''Every build has an artifact.'' Does this logically require that all builds share the SAME single one? Answer with exactly one word: TRUE or FALSE.', 'FALSE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS027B');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS027B', 'quant-scope', 'QS-FA27', 'forall-exists does not force one shared' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS027B');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS028A', 'reasoning', '''Every branch has a protector.'' Does this claim require that ONE single entity serves all branchs, or only that each branch has some (possibly different) one? It claims: for each branch there exists one (not necessarily the same). Answer with exactly one word: TRUE or FALSE.', 'TRUE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS028A');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS028A', 'quant-scope', 'QS-FA28', 'forall-exists narrow scope' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS028A');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS028B', 'reasoning', '''Every branch has a protector.'' Does this logically require that all branchs share the SAME single one? Answer with exactly one word: TRUE or FALSE.', 'FALSE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS028B');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS028B', 'quant-scope', 'QS-FA28', 'forall-exists does not force one shared' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS028B');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS029A', 'reasoning', '''Every token has a scope.'' Does this claim require that ONE single entity serves all tokens, or only that each token has some (possibly different) one? It claims: for each token there exists one (not necessarily the same). Answer with exactly one word: TRUE or FALSE.', 'TRUE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS029A');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS029A', 'quant-scope', 'QS-FA29', 'forall-exists narrow scope' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS029A');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS029B', 'reasoning', '''Every token has a scope.'' Does this logically require that all tokens share the SAME single one? Answer with exactly one word: TRUE or FALSE.', 'FALSE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS029B');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS029B', 'quant-scope', 'QS-FA29', 'forall-exists does not force one shared' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS029B');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS030A', 'reasoning', '''Every mount has a filesystem.'' Does this claim require that ONE single entity serves all mounts, or only that each mount has some (possibly different) one? It claims: for each mount there exists one (not necessarily the same). Answer with exactly one word: TRUE or FALSE.', 'TRUE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS030A');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS030A', 'quant-scope', 'QS-FA30', 'forall-exists narrow scope' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS030A');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS030B', 'reasoning', '''Every mount has a filesystem.'' Does this logically require that all mounts share the SAME single one? Answer with exactly one word: TRUE or FALSE.', 'FALSE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS030B');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS030B', 'quant-scope', 'QS-FA30', 'forall-exists does not force one shared' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS030B');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS031A', 'reasoning', '''Every dataset has a schema.'' Does this claim require that ONE single entity serves all datasets, or only that each dataset has some (possibly different) one? It claims: for each dataset there exists one (not necessarily the same). Answer with exactly one word: TRUE or FALSE.', 'TRUE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS031A');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS031A', 'quant-scope', 'QS-FA31', 'forall-exists narrow scope' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS031A');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS031B', 'reasoning', '''Every dataset has a schema.'' Does this logically require that all datasets share the SAME single one? Answer with exactly one word: TRUE or FALSE.', 'FALSE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS031B');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS031B', 'quant-scope', 'QS-FA31', 'forall-exists does not force one shared' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS031B');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS032A', 'reasoning', '''Every model has a version.'' Does this claim require that ONE single entity serves all models, or only that each model has some (possibly different) one? It claims: for each model there exists one (not necessarily the same). Answer with exactly one word: TRUE or FALSE.', 'TRUE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS032A');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS032A', 'quant-scope', 'QS-FA32', 'forall-exists narrow scope' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS032A');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS032B', 'reasoning', '''Every model has a version.'' Does this logically require that all models share the SAME single one? Answer with exactly one word: TRUE or FALSE.', 'FALSE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS032B');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS032B', 'quant-scope', 'QS-FA32', 'forall-exists does not force one shared' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS032B');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS033A', 'reasoning', '''Every feature has a flag.'' Does this claim require that ONE single entity serves all features, or only that each feature has some (possibly different) one? It claims: for each feature there exists one (not necessarily the same). Answer with exactly one word: TRUE or FALSE.', 'TRUE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS033A');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS033A', 'quant-scope', 'QS-FA33', 'forall-exists narrow scope' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS033A');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS033B', 'reasoning', '''Every feature has a flag.'' Does this logically require that all features share the SAME single one? Answer with exactly one word: TRUE or FALSE.', 'FALSE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS033B');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS033B', 'quant-scope', 'QS-FA33', 'forall-exists does not force one shared' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS033B');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS034A', 'reasoning', '''Every tenant has a quota.'' Does this claim require that ONE single entity serves all tenants, or only that each tenant has some (possibly different) one? It claims: for each tenant there exists one (not necessarily the same). Answer with exactly one word: TRUE or FALSE.', 'TRUE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS034A');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS034A', 'quant-scope', 'QS-FA34', 'forall-exists narrow scope' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS034A');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS034B', 'reasoning', '''Every tenant has a quota.'' Does this logically require that all tenants share the SAME single one? Answer with exactly one word: TRUE or FALSE.', 'FALSE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS034B');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS034B', 'quant-scope', 'QS-FA34', 'forall-exists does not force one shared' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS034B');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS035A', 'reasoning', '''Every volume has a snapshot.'' Does this claim require that ONE single entity serves all volumes, or only that each volume has some (possibly different) one? It claims: for each volume there exists one (not necessarily the same). Answer with exactly one word: TRUE or FALSE.', 'TRUE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS035A');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS035A', 'quant-scope', 'QS-FA35', 'forall-exists narrow scope' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS035A');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS035B', 'reasoning', '''Every volume has a snapshot.'' Does this logically require that all volumes share the SAME single one? Answer with exactly one word: TRUE or FALSE.', 'FALSE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS035B');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS035B', 'quant-scope', 'QS-FA35', 'forall-exists does not force one shared' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS035B');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS036A', 'reasoning', '''Every function has a timeout.'' Does this claim require that ONE single entity serves all functions, or only that each function has some (possibly different) one? It claims: for each function there exists one (not necessarily the same). Answer with exactly one word: TRUE or FALSE.', 'TRUE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS036A');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS036A', 'quant-scope', 'QS-FA36', 'forall-exists narrow scope' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS036A');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS036B', 'reasoning', '''Every function has a timeout.'' Does this logically require that all functions share the SAME single one? Answer with exactly one word: TRUE or FALSE.', 'FALSE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS036B');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS036B', 'quant-scope', 'QS-FA36', 'forall-exists does not force one shared' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS036B');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS037A', 'reasoning', '''Every topic has a subscriber.'' Does this claim require that ONE single entity serves all topics, or only that each topic has some (possibly different) one? It claims: for each topic there exists one (not necessarily the same). Answer with exactly one word: TRUE or FALSE.', 'TRUE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS037A');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS037A', 'quant-scope', 'QS-FA37', 'forall-exists narrow scope' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS037A');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS037B', 'reasoning', '''Every topic has a subscriber.'' Does this logically require that all topics share the SAME single one? Answer with exactly one word: TRUE or FALSE.', 'FALSE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS037B');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS037B', 'quant-scope', 'QS-FA37', 'forall-exists does not force one shared' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS037B');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS038A', 'reasoning', '''Every cell has a coordinator.'' Does this claim require that ONE single entity serves all cells, or only that each cell has some (possibly different) one? It claims: for each cell there exists one (not necessarily the same). Answer with exactly one word: TRUE or FALSE.', 'TRUE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS038A');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS038A', 'quant-scope', 'QS-FA38', 'forall-exists narrow scope' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS038A');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS038B', 'reasoning', '''Every cell has a coordinator.'' Does this logically require that all cells share the SAME single one? Answer with exactly one word: TRUE or FALSE.', 'FALSE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS038B');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS038B', 'quant-scope', 'QS-FA38', 'forall-exists does not force one shared' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS038B');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS039A', 'reasoning', '''Every zone has a nameserver.'' Does this claim require that ONE single entity serves all zones, or only that each zone has some (possibly different) one? It claims: for each zone there exists one (not necessarily the same). Answer with exactly one word: TRUE or FALSE.', 'TRUE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS039A');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS039A', 'quant-scope', 'QS-FA39', 'forall-exists narrow scope' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS039A');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS039B', 'reasoning', '''Every zone has a nameserver.'' Does this logically require that all zones share the SAME single one? Answer with exactly one word: TRUE or FALSE.', 'FALSE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS039B');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS039B', 'quant-scope', 'QS-FA39', 'forall-exists does not force one shared' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS039B');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS040A', 'reasoning', '''Every image has a digest.'' Does this claim require that ONE single entity serves all images, or only that each image has some (possibly different) one? It claims: for each image there exists one (not necessarily the same). Answer with exactly one word: TRUE or FALSE.', 'TRUE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS040A');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS040A', 'quant-scope', 'QS-FA40', 'forall-exists narrow scope' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS040A');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS040B', 'reasoning', '''Every image has a digest.'' Does this logically require that all images share the SAME single one? Answer with exactly one word: TRUE or FALSE.', 'FALSE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS040B');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS040B', 'quant-scope', 'QS-FA40', 'forall-exists does not force one shared' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS040B');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS041A', 'reasoning', '''Every package has a maintainer.'' Does this claim require that ONE single entity serves all packages, or only that each package has some (possibly different) one? It claims: for each package there exists one (not necessarily the same). Answer with exactly one word: TRUE or FALSE.', 'TRUE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS041A');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS041A', 'quant-scope', 'QS-FA41', 'forall-exists narrow scope' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS041A');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS041B', 'reasoning', '''Every package has a maintainer.'' Does this logically require that all packages share the SAME single one? Answer with exactly one word: TRUE or FALSE.', 'FALSE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS041B');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS041B', 'quant-scope', 'QS-FA41', 'forall-exists does not force one shared' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS041B');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS042A', 'reasoning', '''Every driver has a version.'' Does this claim require that ONE single entity serves all drivers, or only that each driver has some (possibly different) one? It claims: for each driver there exists one (not necessarily the same). Answer with exactly one word: TRUE or FALSE.', 'TRUE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS042A');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS042A', 'quant-scope', 'QS-FA42', 'forall-exists narrow scope' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS042A');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS042B', 'reasoning', '''Every driver has a version.'' Does this logically require that all drivers share the SAME single one? Answer with exactly one word: TRUE or FALSE.', 'FALSE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS042B');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS042B', 'quant-scope', 'QS-FA42', 'forall-exists does not force one shared' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS042B');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS043A', 'reasoning', '''Every mailbox has a filter.'' Does this claim require that ONE single entity serves all mailboxs, or only that each mailbox has some (possibly different) one? It claims: for each mailbox there exists one (not necessarily the same). Answer with exactly one word: TRUE or FALSE.', 'TRUE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS043A');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS043A', 'quant-scope', 'QS-FA43', 'forall-exists narrow scope' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS043A');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS043B', 'reasoning', '''Every mailbox has a filter.'' Does this logically require that all mailboxs share the SAME single one? Answer with exactly one word: TRUE or FALSE.', 'FALSE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS043B');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS043B', 'quant-scope', 'QS-FA43', 'forall-exists does not force one shared' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS043B');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS044A', 'reasoning', '''Every contact has a tag.'' Does this claim require that ONE single entity serves all contacts, or only that each contact has some (possibly different) one? It claims: for each contact there exists one (not necessarily the same). Answer with exactly one word: TRUE or FALSE.', 'TRUE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS044A');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS044A', 'quant-scope', 'QS-FA44', 'forall-exists narrow scope' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS044A');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS044B', 'reasoning', '''Every contact has a tag.'' Does this logically require that all contacts share the SAME single one? Answer with exactly one word: TRUE or FALSE.', 'FALSE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS044B');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS044B', 'quant-scope', 'QS-FA44', 'forall-exists does not force one shared' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS044B');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS045A', 'reasoning', '''Every invoice has a status.'' Does this claim require that ONE single entity serves all invoices, or only that each invoice has some (possibly different) one? It claims: for each invoice there exists one (not necessarily the same). Answer with exactly one word: TRUE or FALSE.', 'TRUE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS045A');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS045A', 'quant-scope', 'QS-FA45', 'forall-exists narrow scope' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS045A');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS045B', 'reasoning', '''Every invoice has a status.'' Does this logically require that all invoices share the SAME single one? Answer with exactly one word: TRUE or FALSE.', 'FALSE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS045B');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS045B', 'quant-scope', 'QS-FA45', 'forall-exists does not force one shared' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS045B');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS046A', 'reasoning', '''Every ticket has an assignee.'' Does this claim require that ONE single entity serves all tickets, or only that each ticket has some (possibly different) one? It claims: for each ticket there exists one (not necessarily the same). Answer with exactly one word: TRUE or FALSE.', 'TRUE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS046A');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS046A', 'quant-scope', 'QS-FA46', 'forall-exists narrow scope' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS046A');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS046B', 'reasoning', '''Every ticket has an assignee.'' Does this logically require that all tickets share the SAME single one? Answer with exactly one word: TRUE or FALSE.', 'FALSE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS046B');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS046B', 'quant-scope', 'QS-FA46', 'forall-exists does not force one shared' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS046B');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS047A', 'reasoning', '''Every review has an approver.'' Does this claim require that ONE single entity serves all reviews, or only that each review has some (possibly different) one? It claims: for each review there exists one (not necessarily the same). Answer with exactly one word: TRUE or FALSE.', 'TRUE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS047A');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS047A', 'quant-scope', 'QS-FA47', 'forall-exists narrow scope' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS047A');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS047B', 'reasoning', '''Every review has an approver.'' Does this logically require that all reviews share the SAME single one? Answer with exactly one word: TRUE or FALSE.', 'FALSE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS047B');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS047B', 'quant-scope', 'QS-FA47', 'forall-exists does not force one shared' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS047B');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS048A', 'reasoning', '''Every release has a changelog.'' Does this claim require that ONE single entity serves all releases, or only that each release has some (possibly different) one? It claims: for each release there exists one (not necessarily the same). Answer with exactly one word: TRUE or FALSE.', 'TRUE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS048A');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS048A', 'quant-scope', 'QS-FA48', 'forall-exists narrow scope' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS048A');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS048B', 'reasoning', '''Every release has a changelog.'' Does this logically require that all releases share the SAME single one? Answer with exactly one word: TRUE or FALSE.', 'FALSE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS048B');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS048B', 'quant-scope', 'QS-FA48', 'forall-exists does not force one shared' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS048B');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS049A', 'reasoning', '''Every webhook has a secret.'' Does this claim require that ONE single entity serves all webhooks, or only that each webhook has some (possibly different) one? It claims: for each webhook there exists one (not necessarily the same). Answer with exactly one word: TRUE or FALSE.', 'TRUE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS049A');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS049A', 'quant-scope', 'QS-FA49', 'forall-exists narrow scope' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS049A');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS049B', 'reasoning', '''Every webhook has a secret.'' Does this logically require that all webhooks share the SAME single one? Answer with exactly one word: TRUE or FALSE.', 'FALSE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS049B');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS049B', 'quant-scope', 'QS-FA49', 'forall-exists does not force one shared' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS049B');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS050A', 'reasoning', '''Every gateway route has a weight.'' Does this claim require that ONE single entity serves all gateway routes, or only that each gateway route has some (possibly different) one? It claims: for each gateway route there exists one (not necessarily the same). Answer with exactly one word: TRUE or FALSE.', 'TRUE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS050A');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS050A', 'quant-scope', 'QS-FA50', 'forall-exists narrow scope' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS050A');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS050B', 'reasoning', '''Every gateway route has a weight.'' Does this logically require that all gateway routes share the SAME single one? Answer with exactly one word: TRUE or FALSE.', 'FALSE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS050B');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS050B', 'quant-scope', 'QS-FA50', 'forall-exists does not force one shared' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS050B');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS051A', 'reasoning', '''Every cron has a schedule.'' Does this claim require that ONE single entity serves all crons, or only that each cron has some (possibly different) one? It claims: for each cron there exists one (not necessarily the same). Answer with exactly one word: TRUE or FALSE.', 'TRUE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS051A');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS051A', 'quant-scope', 'QS-FA51', 'forall-exists narrow scope' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS051A');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS051B', 'reasoning', '''Every cron has a schedule.'' Does this logically require that all crons share the SAME single one? Answer with exactly one word: TRUE or FALSE.', 'FALSE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS051B');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS051B', 'quant-scope', 'QS-FA51', 'forall-exists does not force one shared' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS051B');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS052A', 'reasoning', '''Every snapshot has a parent.'' Does this claim require that ONE single entity serves all snapshots, or only that each snapshot has some (possibly different) one? It claims: for each snapshot there exists one (not necessarily the same). Answer with exactly one word: TRUE or FALSE.', 'TRUE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS052A');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS052A', 'quant-scope', 'QS-FA52', 'forall-exists narrow scope' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS052A');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS052B', 'reasoning', '''Every snapshot has a parent.'' Does this logically require that all snapshots share the SAME single one? Answer with exactly one word: TRUE or FALSE.', 'FALSE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS052B');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS052B', 'quant-scope', 'QS-FA52', 'forall-exists does not force one shared' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS052B');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS053A', 'reasoning', '''Every vlan has a tag.'' Does this claim require that ONE single entity serves all vlans, or only that each vlan has some (possibly different) one? It claims: for each vlan there exists one (not necessarily the same). Answer with exactly one word: TRUE or FALSE.', 'TRUE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS053A');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS053A', 'quant-scope', 'QS-FA53', 'forall-exists narrow scope' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS053A');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS053B', 'reasoning', '''Every vlan has a tag.'' Does this logically require that all vlans share the SAME single one? Answer with exactly one word: TRUE or FALSE.', 'FALSE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS053B');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS053B', 'quant-scope', 'QS-FA53', 'forall-exists does not force one shared' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS053B');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS054A', 'reasoning', '''Every subnet has a CIDR.'' Does this claim require that ONE single entity serves all subnets, or only that each subnet has some (possibly different) one? It claims: for each subnet there exists one (not necessarily the same). Answer with exactly one word: TRUE or FALSE.', 'TRUE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS054A');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS054A', 'quant-scope', 'QS-FA54', 'forall-exists narrow scope' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS054A');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS054B', 'reasoning', '''Every subnet has a CIDR.'' Does this logically require that all subnets share the SAME single one? Answer with exactly one word: TRUE or FALSE.', 'FALSE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS054B');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS054B', 'quant-scope', 'QS-FA54', 'forall-exists does not force one shared' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS054B');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS055A', 'reasoning', '''Every certificate has a chain.'' Does this claim require that ONE single entity serves all certificates, or only that each certificate has some (possibly different) one? It claims: for each certificate there exists one (not necessarily the same). Answer with exactly one word: TRUE or FALSE.', 'TRUE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS055A');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS055A', 'quant-scope', 'QS-FA55', 'forall-exists narrow scope' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS055A');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS055B', 'reasoning', '''Every certificate has a chain.'' Does this logically require that all certificates share the SAME single one? Answer with exactly one word: TRUE or FALSE.', 'FALSE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS055B');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS055B', 'quant-scope', 'QS-FA55', 'forall-exists does not force one shared' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS055B');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS056A', 'reasoning', '''Every key has a rotation.'' Does this claim require that ONE single entity serves all keys, or only that each key has some (possibly different) one? It claims: for each key there exists one (not necessarily the same). Answer with exactly one word: TRUE or FALSE.', 'TRUE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS056A');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS056A', 'quant-scope', 'QS-FA56', 'forall-exists narrow scope' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS056A');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS056B', 'reasoning', '''Every key has a rotation.'' Does this logically require that all keys share the SAME single one? Answer with exactly one word: TRUE or FALSE.', 'FALSE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS056B');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS056B', 'quant-scope', 'QS-FA56', 'forall-exists does not force one shared' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS056B');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS057A', 'reasoning', '''Every audit has a trail.'' Does this claim require that ONE single entity serves all audits, or only that each audit has some (possibly different) one? It claims: for each audit there exists one (not necessarily the same). Answer with exactly one word: TRUE or FALSE.', 'TRUE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS057A');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS057A', 'quant-scope', 'QS-FA57', 'forall-exists narrow scope' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS057A');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS057B', 'reasoning', '''Every audit has a trail.'' Does this logically require that all audits share the SAME single one? Answer with exactly one word: TRUE or FALSE.', 'FALSE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS057B');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS057B', 'quant-scope', 'QS-FA57', 'forall-exists does not force one shared' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS057B');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS058A', 'reasoning', '''There is a key that opens every door.'' Is the claim that ONE key does this for all of them? Answer with exactly one word: TRUE or FALSE.', 'TRUE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS058A');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS058A', 'quant-scope', 'QS-EA01', 'exists-wide: single entity for all' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS058A');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS059B', 'reasoning', '''There is a key that opens every door.'' Could this be satisfied by a DIFFERENT key for each one rather than one for all? Answer with exactly one word: TRUE or FALSE.', 'FALSE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS059B');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS059B', 'quant-scope', 'QS-EA01', 'exists-wide requires one entity' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS059B');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS060C', 'reasoning', '''For each of them, there exists a key that opens every door.'' Does this reading allow a DIFFERENT key per case (not necessarily one for all)? Answer with exactly one word: TRUE or FALSE.', 'TRUE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS060C');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS060C', 'quant-scope', 'QS-EA01', 'forall-exists permits different-per-case' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS060C');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS061A', 'reasoning', '''There is a master token that authorizes every request.'' Is the claim that ONE master token does this for all of them? Answer with exactly one word: TRUE or FALSE.', 'TRUE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS061A');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS061A', 'quant-scope', 'QS-EA02', 'exists-wide: single entity for all' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS061A');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS062B', 'reasoning', '''There is a master token that authorizes every request.'' Could this be satisfied by a DIFFERENT master token for each one rather than one for all? Answer with exactly one word: TRUE or FALSE.', 'FALSE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS062B');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS062B', 'quant-scope', 'QS-EA02', 'exists-wide requires one entity' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS062B');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS063C', 'reasoning', '''For each of them, there exists a master token that authorizes every request.'' Does this reading allow a DIFFERENT master token per case (not necessarily one for all)? Answer with exactly one word: TRUE or FALSE.', 'TRUE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS063C');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS063C', 'quant-scope', 'QS-EA02', 'forall-exists permits different-per-case' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS063C');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS064A', 'reasoning', '''There is a root CA that signs every certificate.'' Is the claim that ONE root CA does this for all of them? Answer with exactly one word: TRUE or FALSE.', 'TRUE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS064A');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS064A', 'quant-scope', 'QS-EA03', 'exists-wide: single entity for all' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS064A');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS065B', 'reasoning', '''There is a root CA that signs every certificate.'' Could this be satisfied by a DIFFERENT root CA for each one rather than one for all? Answer with exactly one word: TRUE or FALSE.', 'FALSE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS065B');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS065B', 'quant-scope', 'QS-EA03', 'exists-wide requires one entity' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS065B');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS066C', 'reasoning', '''For each of them, there exists a root CA that signs every certificate.'' Does this reading allow a DIFFERENT root CA per case (not necessarily one for all)? Answer with exactly one word: TRUE or FALSE.', 'TRUE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS066C');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS066C', 'quant-scope', 'QS-EA03', 'forall-exists permits different-per-case' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS066C');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS067A', 'reasoning', '''There is a leader that coordinates every shard.'' Is the claim that ONE leader does this for all of them? Answer with exactly one word: TRUE or FALSE.', 'TRUE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS067A');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS067A', 'quant-scope', 'QS-EA04', 'exists-wide: single entity for all' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS067A');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS068B', 'reasoning', '''There is a leader that coordinates every shard.'' Could this be satisfied by a DIFFERENT leader for each one rather than one for all? Answer with exactly one word: TRUE or FALSE.', 'FALSE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS068B');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS068B', 'quant-scope', 'QS-EA04', 'exists-wide requires one entity' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS068B');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS069C', 'reasoning', '''For each of them, there exists a leader that coordinates every shard.'' Does this reading allow a DIFFERENT leader per case (not necessarily one for all)? Answer with exactly one word: TRUE or FALSE.', 'TRUE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS069C');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS069C', 'quant-scope', 'QS-EA04', 'forall-exists permits different-per-case' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS069C');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS070A', 'reasoning', '''There is a admin that can reach every host.'' Is the claim that ONE admin does this for all of them? Answer with exactly one word: TRUE or FALSE.', 'TRUE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS070A');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS070A', 'quant-scope', 'QS-EA05', 'exists-wide: single entity for all' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS070A');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS071B', 'reasoning', '''There is a admin that can reach every host.'' Could this be satisfied by a DIFFERENT admin for each one rather than one for all? Answer with exactly one word: TRUE or FALSE.', 'FALSE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS071B');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS071B', 'quant-scope', 'QS-EA05', 'exists-wide requires one entity' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS071B');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS072C', 'reasoning', '''For each of them, there exists a admin that can reach every host.'' Does this reading allow a DIFFERENT admin per case (not necessarily one for all)? Answer with exactly one word: TRUE or FALSE.', 'TRUE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS072C');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS072C', 'quant-scope', 'QS-EA05', 'forall-exists permits different-per-case' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS072C');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS073A', 'reasoning', '''There is a seed that reproduces every run.'' Is the claim that ONE seed does this for all of them? Answer with exactly one word: TRUE or FALSE.', 'TRUE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS073A');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS073A', 'quant-scope', 'QS-EA06', 'exists-wide: single entity for all' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS073A');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS074B', 'reasoning', '''There is a seed that reproduces every run.'' Could this be satisfied by a DIFFERENT seed for each one rather than one for all? Answer with exactly one word: TRUE or FALSE.', 'FALSE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS074B');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS074B', 'quant-scope', 'QS-EA06', 'exists-wide requires one entity' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS074B');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS075C', 'reasoning', '''For each of them, there exists a seed that reproduces every run.'' Does this reading allow a DIFFERENT seed per case (not necessarily one for all)? Answer with exactly one word: TRUE or FALSE.', 'TRUE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS075C');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS075C', 'quant-scope', 'QS-EA06', 'forall-exists permits different-per-case' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS075C');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS076A', 'reasoning', '''There is a primary that owns every write.'' Is the claim that ONE primary does this for all of them? Answer with exactly one word: TRUE or FALSE.', 'TRUE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS076A');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS076A', 'quant-scope', 'QS-EA07', 'exists-wide: single entity for all' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS076A');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS077B', 'reasoning', '''There is a primary that owns every write.'' Could this be satisfied by a DIFFERENT primary for each one rather than one for all? Answer with exactly one word: TRUE or FALSE.', 'FALSE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS077B');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS077B', 'quant-scope', 'QS-EA07', 'exists-wide requires one entity' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS077B');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS078C', 'reasoning', '''For each of them, there exists a primary that owns every write.'' Does this reading allow a DIFFERENT primary per case (not necessarily one for all)? Answer with exactly one word: TRUE or FALSE.', 'TRUE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS078C');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS078C', 'quant-scope', 'QS-EA07', 'forall-exists permits different-per-case' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS078C');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS079A', 'reasoning', '''There is a gateway that routes every packet.'' Is the claim that ONE gateway does this for all of them? Answer with exactly one word: TRUE or FALSE.', 'TRUE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS079A');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS079A', 'quant-scope', 'QS-EA08', 'exists-wide: single entity for all' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS079A');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS080B', 'reasoning', '''There is a gateway that routes every packet.'' Could this be satisfied by a DIFFERENT gateway for each one rather than one for all? Answer with exactly one word: TRUE or FALSE.', 'FALSE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS080B');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS080B', 'quant-scope', 'QS-EA08', 'exists-wide requires one entity' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS080B');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS081C', 'reasoning', '''For each of them, there exists a gateway that routes every packet.'' Does this reading allow a DIFFERENT gateway per case (not necessarily one for all)? Answer with exactly one word: TRUE or FALSE.', 'TRUE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS081C');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS081C', 'quant-scope', 'QS-EA08', 'forall-exists permits different-per-case' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS081C');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS082A', 'reasoning', '''There is a license that covers every seat.'' Is the claim that ONE license does this for all of them? Answer with exactly one word: TRUE or FALSE.', 'TRUE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS082A');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS082A', 'quant-scope', 'QS-EA09', 'exists-wide: single entity for all' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS082A');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS083B', 'reasoning', '''There is a license that covers every seat.'' Could this be satisfied by a DIFFERENT license for each one rather than one for all? Answer with exactly one word: TRUE or FALSE.', 'FALSE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS083B');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS083B', 'quant-scope', 'QS-EA09', 'exists-wide requires one entity' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS083B');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS084C', 'reasoning', '''For each of them, there exists a license that covers every seat.'' Does this reading allow a DIFFERENT license per case (not necessarily one for all)? Answer with exactly one word: TRUE or FALSE.', 'TRUE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS084C');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS084C', 'quant-scope', 'QS-EA09', 'forall-exists permits different-per-case' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS084C');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS085A', 'reasoning', '''There is a schema that validates every record.'' Is the claim that ONE schema does this for all of them? Answer with exactly one word: TRUE or FALSE.', 'TRUE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS085A');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS085A', 'quant-scope', 'QS-EA10', 'exists-wide: single entity for all' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS085A');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS086B', 'reasoning', '''There is a schema that validates every record.'' Could this be satisfied by a DIFFERENT schema for each one rather than one for all? Answer with exactly one word: TRUE or FALSE.', 'FALSE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS086B');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS086B', 'quant-scope', 'QS-EA10', 'exists-wide requires one entity' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS086B');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS087C', 'reasoning', '''For each of them, there exists a schema that validates every record.'' Does this reading allow a DIFFERENT schema per case (not necessarily one for all)? Answer with exactly one word: TRUE or FALSE.', 'TRUE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS087C');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS087C', 'quant-scope', 'QS-EA10', 'forall-exists permits different-per-case' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS087C');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS088A', 'reasoning', '''There is a policy that governs every bucket.'' Is the claim that ONE policy does this for all of them? Answer with exactly one word: TRUE or FALSE.', 'TRUE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS088A');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS088A', 'quant-scope', 'QS-EA11', 'exists-wide: single entity for all' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS088A');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS089B', 'reasoning', '''There is a policy that governs every bucket.'' Could this be satisfied by a DIFFERENT policy for each one rather than one for all? Answer with exactly one word: TRUE or FALSE.', 'FALSE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS089B');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS089B', 'quant-scope', 'QS-EA11', 'exists-wide requires one entity' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS089B');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS090C', 'reasoning', '''For each of them, there exists a policy that governs every bucket.'' Does this reading allow a DIFFERENT policy per case (not necessarily one for all)? Answer with exactly one word: TRUE or FALSE.', 'TRUE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS090C');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS090C', 'quant-scope', 'QS-EA11', 'forall-exists permits different-per-case' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS090C');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS091A', 'reasoning', '''There is a schedule that triggers every job.'' Is the claim that ONE schedule does this for all of them? Answer with exactly one word: TRUE or FALSE.', 'TRUE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS091A');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS091A', 'quant-scope', 'QS-EA12', 'exists-wide: single entity for all' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS091A');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS092B', 'reasoning', '''There is a schedule that triggers every job.'' Could this be satisfied by a DIFFERENT schedule for each one rather than one for all? Answer with exactly one word: TRUE or FALSE.', 'FALSE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS092B');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS092B', 'quant-scope', 'QS-EA12', 'exists-wide requires one entity' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS092B');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS093C', 'reasoning', '''For each of them, there exists a schedule that triggers every job.'' Does this reading allow a DIFFERENT schedule per case (not necessarily one for all)? Answer with exactly one word: TRUE or FALSE.', 'TRUE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS093C');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS093C', 'quant-scope', 'QS-EA12', 'forall-exists permits different-per-case' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS093C');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS094A', 'reasoning', '''There is a role that grants every permission.'' Is the claim that ONE role does this for all of them? Answer with exactly one word: TRUE or FALSE.', 'TRUE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS094A');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS094A', 'quant-scope', 'QS-EA13', 'exists-wide: single entity for all' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS094A');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS095B', 'reasoning', '''There is a role that grants every permission.'' Could this be satisfied by a DIFFERENT role for each one rather than one for all? Answer with exactly one word: TRUE or FALSE.', 'FALSE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS095B');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS095B', 'quant-scope', 'QS-EA13', 'exists-wide requires one entity' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS095B');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS096C', 'reasoning', '''For each of them, there exists a role that grants every permission.'' Does this reading allow a DIFFERENT role per case (not necessarily one for all)? Answer with exactly one word: TRUE or FALSE.', 'TRUE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS096C');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS096C', 'quant-scope', 'QS-EA13', 'forall-exists permits different-per-case' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS096C');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS097A', 'reasoning', '''There is a proxy that forwards every request.'' Is the claim that ONE proxy does this for all of them? Answer with exactly one word: TRUE or FALSE.', 'TRUE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS097A');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS097A', 'quant-scope', 'QS-EA14', 'exists-wide: single entity for all' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS097A');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS098B', 'reasoning', '''There is a proxy that forwards every request.'' Could this be satisfied by a DIFFERENT proxy for each one rather than one for all? Answer with exactly one word: TRUE or FALSE.', 'FALSE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS098B');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS098B', 'quant-scope', 'QS-EA14', 'exists-wide requires one entity' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS098B');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS099C', 'reasoning', '''For each of them, there exists a proxy that forwards every request.'' Does this reading allow a DIFFERENT proxy per case (not necessarily one for all)? Answer with exactly one word: TRUE or FALSE.', 'TRUE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS099C');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS099C', 'quant-scope', 'QS-EA14', 'forall-exists permits different-per-case' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS099C');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS100A', 'reasoning', '''There is a umbrella cert that secures every subdomain.'' Is the claim that ONE umbrella cert does this for all of them? Answer with exactly one word: TRUE or FALSE.', 'TRUE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS100A');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS100A', 'quant-scope', 'QS-EA15', 'exists-wide: single entity for all' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS100A');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS101B', 'reasoning', '''There is a umbrella cert that secures every subdomain.'' Could this be satisfied by a DIFFERENT umbrella cert for each one rather than one for all? Answer with exactly one word: TRUE or FALSE.', 'FALSE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS101B');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS101B', 'quant-scope', 'QS-EA15', 'exists-wide requires one entity' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS101B');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS102C', 'reasoning', '''For each of them, there exists a umbrella cert that secures every subdomain.'' Does this reading allow a DIFFERENT umbrella cert per case (not necessarily one for all)? Answer with exactly one word: TRUE or FALSE.', 'TRUE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS102C');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS102C', 'quant-scope', 'QS-EA15', 'forall-exists permits different-per-case' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS102C');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS103A', 'reasoning', '''There is a config that configures every node.'' Is the claim that ONE config does this for all of them? Answer with exactly one word: TRUE or FALSE.', 'TRUE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS103A');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS103A', 'quant-scope', 'QS-EA16', 'exists-wide: single entity for all' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS103A');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS104B', 'reasoning', '''There is a config that configures every node.'' Could this be satisfied by a DIFFERENT config for each one rather than one for all? Answer with exactly one word: TRUE or FALSE.', 'FALSE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS104B');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS104B', 'quant-scope', 'QS-EA16', 'exists-wide requires one entity' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS104B');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS105C', 'reasoning', '''For each of them, there exists a config that configures every node.'' Does this reading allow a DIFFERENT config per case (not necessarily one for all)? Answer with exactly one word: TRUE or FALSE.', 'TRUE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS105C');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS105C', 'quant-scope', 'QS-EA16', 'forall-exists permits different-per-case' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS105C');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS106A', 'reasoning', '''There is a template that renders every page.'' Is the claim that ONE template does this for all of them? Answer with exactly one word: TRUE or FALSE.', 'TRUE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS106A');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS106A', 'quant-scope', 'QS-EA17', 'exists-wide: single entity for all' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS106A');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS107B', 'reasoning', '''There is a template that renders every page.'' Could this be satisfied by a DIFFERENT template for each one rather than one for all? Answer with exactly one word: TRUE or FALSE.', 'FALSE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS107B');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS107B', 'quant-scope', 'QS-EA17', 'exists-wide requires one entity' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS107B');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS108C', 'reasoning', '''For each of them, there exists a template that renders every page.'' Does this reading allow a DIFFERENT template per case (not necessarily one for all)? Answer with exactly one word: TRUE or FALSE.', 'TRUE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS108C');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS108C', 'quant-scope', 'QS-EA17', 'forall-exists permits different-per-case' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS108C');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS109A', 'reasoning', '''There is a manifest that describes every artifact.'' Is the claim that ONE manifest does this for all of them? Answer with exactly one word: TRUE or FALSE.', 'TRUE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS109A');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS109A', 'quant-scope', 'QS-EA18', 'exists-wide: single entity for all' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS109A');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS110B', 'reasoning', '''There is a manifest that describes every artifact.'' Could this be satisfied by a DIFFERENT manifest for each one rather than one for all? Answer with exactly one word: TRUE or FALSE.', 'FALSE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS110B');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS110B', 'quant-scope', 'QS-EA18', 'exists-wide requires one entity' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS110B');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS111C', 'reasoning', '''For each of them, there exists a manifest that describes every artifact.'' Does this reading allow a DIFFERENT manifest per case (not necessarily one for all)? Answer with exactly one word: TRUE or FALSE.', 'TRUE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS111C');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS111C', 'quant-scope', 'QS-EA18', 'forall-exists permits different-per-case' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS111C');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS112A', 'reasoning', '''There is a router that reaches every subnet.'' Is the claim that ONE router does this for all of them? Answer with exactly one word: TRUE or FALSE.', 'TRUE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS112A');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS112A', 'quant-scope', 'QS-EA19', 'exists-wide: single entity for all' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS112A');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS113B', 'reasoning', '''There is a router that reaches every subnet.'' Could this be satisfied by a DIFFERENT router for each one rather than one for all? Answer with exactly one word: TRUE or FALSE.', 'FALSE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS113B');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS113B', 'quant-scope', 'QS-EA19', 'exists-wide requires one entity' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS113B');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS114C', 'reasoning', '''For each of them, there exists a router that reaches every subnet.'' Does this reading allow a DIFFERENT router per case (not necessarily one for all)? Answer with exactly one word: TRUE or FALSE.', 'TRUE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS114C');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS114C', 'quant-scope', 'QS-EA19', 'forall-exists permits different-per-case' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS114C');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS115A', 'reasoning', '''There is a keypair that unlocks every vault.'' Is the claim that ONE keypair does this for all of them? Answer with exactly one word: TRUE or FALSE.', 'TRUE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS115A');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS115A', 'quant-scope', 'QS-EA20', 'exists-wide: single entity for all' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS115A');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS116B', 'reasoning', '''There is a keypair that unlocks every vault.'' Could this be satisfied by a DIFFERENT keypair for each one rather than one for all? Answer with exactly one word: TRUE or FALSE.', 'FALSE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS116B');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS116B', 'quant-scope', 'QS-EA20', 'exists-wide requires one entity' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS116B');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS117C', 'reasoning', '''For each of them, there exists a keypair that unlocks every vault.'' Does this reading allow a DIFFERENT keypair per case (not necessarily one for all)? Answer with exactly one word: TRUE or FALSE.', 'TRUE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS117C');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS117C', 'quant-scope', 'QS-EA20', 'forall-exists permits different-per-case' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS117C');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS118A', 'reasoning', '''All that is cached is not fresh.'' Read literally as: nothing cached is fresh. Is that literal universal-negative reading the usual intended meaning? Answer with exactly one word: TRUE or FALSE.', 'FALSE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS118A');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS118A', 'quant-scope', 'QS-NEG01', 'negation scope: literal vs intended' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS118A');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS119B', 'reasoning', '''All that is cached is not fresh.'' Under the reading ''not everything cached is fresh'', is the statement making a universal claim about all of them? Answer with exactly one word: TRUE or FALSE.', 'FALSE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS119B');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS119B', 'quant-scope', 'QS-NEG01', 'negation scope: partial not universal' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS119B');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS120A', 'reasoning', '''Every log is not an error.'' Read literally as: no log is an error. Is that literal universal-negative reading the usual intended meaning? Answer with exactly one word: TRUE or FALSE.', 'FALSE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS120A');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS120A', 'quant-scope', 'QS-NEG02', 'negation scope: literal vs intended' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS120A');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS121B', 'reasoning', '''Every log is not an error.'' Under the reading ''not every log is an error'', is the statement making a universal claim about all of them? Answer with exactly one word: TRUE or FALSE.', 'FALSE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS121B');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS121B', 'quant-scope', 'QS-NEG02', 'negation scope: partial not universal' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS121B');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS122A', 'reasoning', '''All replicas are not in sync.'' Read literally as: no replica is in sync. Is that literal universal-negative reading the usual intended meaning? Answer with exactly one word: TRUE or FALSE.', 'FALSE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS122A');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS122A', 'quant-scope', 'QS-NEG03', 'negation scope: literal vs intended' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS122A');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS123B', 'reasoning', '''All replicas are not in sync.'' Under the reading ''not all replicas are in sync'', is the statement making a universal claim about all of them? Answer with exactly one word: TRUE or FALSE.', 'FALSE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS123B');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS123B', 'quant-scope', 'QS-NEG03', 'negation scope: partial not universal' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS123B');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS124A', 'reasoning', '''Every token is not expired.'' Read literally as: no token is expired. Is that literal universal-negative reading the usual intended meaning? Answer with exactly one word: TRUE or FALSE.', 'FALSE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS124A');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS124A', 'quant-scope', 'QS-NEG04', 'negation scope: literal vs intended' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS124A');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'QS125B', 'reasoning', '''Every token is not expired.'' Under the reading ''not every token is expired'', is the statement making a universal claim about all of them? Answer with exactly one word: TRUE or FALSE.', 'FALSE', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'QS125B');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'QS125B', 'quant-scope', 'QS-NEG04', 'negation scope: partial not universal' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='QS125B');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'DF001A', 'reasoning', 'By default, servers in this cluster are healthy. Node is a server in this cluster. With no other information, does it follow by default that the expected outcome holds? Answer with exactly one word: HOLDS or DEFEATED.', 'HOLDS', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'DF001A');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'DF001A', 'defeasible', 'DF-01', 'default rule, no defeater' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='DF001A');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'DF001B', 'reasoning', 'By default, servers in this cluster are healthy. Node is a server in this cluster, AND Node is returning 500s on all probes. Does the expected outcome still hold by default? Answer with exactly one word: HOLDS or DEFEATED.', 'DEFEATED', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'DF001B');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'DF001B', 'defeasible', 'DF-01', 'defeater present' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='DF001B');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'DF001C', 'reasoning', 'By default, servers in this cluster are healthy. Node is a server in this cluster, and the operator noted the weather was overcast (unrelated). With no other relevant information, does the expected outcome hold by default? Answer with exactly one word: HOLDS or DEFEATED.', 'HOLDS', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'DF001C');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'DF001C', 'defeasible', 'DF-01', 'default rule, irrelevant non-defeater' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='DF001C');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'DF002A', 'reasoning', 'By default, signed packages install cleanly. This package is signed and the signature verifies. With no other information, does it follow by default that the expected outcome holds? Answer with exactly one word: HOLDS or DEFEATED.', 'HOLDS', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'DF002A');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'DF002A', 'defeasible', 'DF-02', 'default rule, no defeater' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='DF002A');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'DF002B', 'reasoning', 'By default, signed packages install cleanly. This package is signed and the signature verifies, AND The package''s dependency is missing. Does the expected outcome still hold by default? Answer with exactly one word: HOLDS or DEFEATED.', 'DEFEATED', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'DF002B');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'DF002B', 'defeasible', 'DF-02', 'defeater present' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='DF002B');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'DF002C', 'reasoning', 'By default, signed packages install cleanly. This package is signed and the signature verifies, and the operator noted the weather was overcast (unrelated). With no other relevant information, does the expected outcome hold by default? Answer with exactly one word: HOLDS or DEFEATED.', 'HOLDS', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'DF002C');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'DF002C', 'defeasible', 'DF-02', 'default rule, irrelevant non-defeater' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='DF002C');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'DF003A', 'reasoning', 'By default, the backup completes by 3 AM. The backup ran last night. With no other information, does it follow by default that the expected outcome holds? Answer with exactly one word: HOLDS or DEFEATED.', 'HOLDS', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'DF003A');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'DF003A', 'defeasible', 'DF-03', 'default rule, no defeater' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='DF003A');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'DF003B', 'reasoning', 'By default, the backup completes by 3 AM. The backup ran last night, AND The disk filled at 2 AM. Does the expected outcome still hold by default? Answer with exactly one word: HOLDS or DEFEATED.', 'DEFEATED', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'DF003B');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'DF003B', 'defeasible', 'DF-03', 'defeater present' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='DF003B');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'DF003C', 'reasoning', 'By default, the backup completes by 3 AM. The backup ran last night, and the operator noted the weather was overcast (unrelated). With no other relevant information, does the expected outcome hold by default? Answer with exactly one word: HOLDS or DEFEATED.', 'HOLDS', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'DF003C');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'DF003C', 'defeasible', 'DF-03', 'default rule, irrelevant non-defeater' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='DF003C');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'DF004A', 'reasoning', 'By default, alarms indicate real faults. The alarm is sounding. With no other information, does it follow by default that the expected outcome holds? Answer with exactly one word: HOLDS or DEFEATED.', 'HOLDS', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'DF004A');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'DF004A', 'defeasible', 'DF-04', 'default rule, no defeater' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='DF004A');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'DF004B', 'reasoning', 'By default, alarms indicate real faults. The alarm is sounding, AND The sensor covering it is disconnected. Does the expected outcome still hold by default? Answer with exactly one word: HOLDS or DEFEATED.', 'DEFEATED', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'DF004B');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'DF004B', 'defeasible', 'DF-04', 'defeater present' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='DF004B');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'DF004C', 'reasoning', 'By default, alarms indicate real faults. The alarm is sounding, and the operator noted the weather was overcast (unrelated). With no other relevant information, does the expected outcome hold by default? Answer with exactly one word: HOLDS or DEFEATED.', 'HOLDS', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'DF004C');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'DF004C', 'defeasible', 'DF-04', 'default rule, irrelevant non-defeater' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='DF004C');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'DF005A', 'reasoning', 'By default, cached data is fresh. This entry is in the cache. With no other information, does it follow by default that the expected outcome holds? Answer with exactly one word: HOLDS or DEFEATED.', 'HOLDS', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'DF005A');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'DF005A', 'defeasible', 'DF-05', 'default rule, no defeater' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='DF005A');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'DF005B', 'reasoning', 'By default, cached data is fresh. This entry is in the cache, AND The entry is 40 days old with a 1-day TTL. Does the expected outcome still hold by default? Answer with exactly one word: HOLDS or DEFEATED.', 'DEFEATED', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'DF005B');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'DF005B', 'defeasible', 'DF-05', 'defeater present' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='DF005B');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'DF005C', 'reasoning', 'By default, cached data is fresh. This entry is in the cache, and the operator noted the weather was overcast (unrelated). With no other relevant information, does the expected outcome hold by default? Answer with exactly one word: HOLDS or DEFEATED.', 'HOLDS', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'DF005C');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'DF005C', 'defeasible', 'DF-05', 'default rule, irrelevant non-defeater' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='DF005C');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'DF006A', 'reasoning', 'By default, students who attend lecture pass. Maya attended every lecture. With no other information, does it follow by default that the expected outcome holds? Answer with exactly one word: HOLDS or DEFEATED.', 'HOLDS', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'DF006A');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'DF006A', 'defeasible', 'DF-06', 'default rule, no defeater' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='DF006A');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'DF006B', 'reasoning', 'By default, students who attend lecture pass. Maya attended every lecture, AND Maya never submitted any assignment. Does the expected outcome still hold by default? Answer with exactly one word: HOLDS or DEFEATED.', 'DEFEATED', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'DF006B');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'DF006B', 'defeasible', 'DF-06', 'defeater present' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='DF006B');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'DF006C', 'reasoning', 'By default, students who attend lecture pass. Maya attended every lecture, and the operator noted the weather was overcast (unrelated). With no other relevant information, does the expected outcome hold by default? Answer with exactly one word: HOLDS or DEFEATED.', 'HOLDS', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'DF006C');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'DF006C', 'defeasible', 'DF-06', 'default rule, irrelevant non-defeater' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='DF006C');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'DF007A', 'reasoning', 'By default, retries succeed. The job retried. With no other information, does it follow by default that the expected outcome holds? Answer with exactly one word: HOLDS or DEFEATED.', 'HOLDS', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'DF007A');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'DF007A', 'defeasible', 'DF-07', 'default rule, no defeater' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='DF007A');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'DF007B', 'reasoning', 'By default, retries succeed. The job retried, AND The downstream service is permanently down. Does the expected outcome still hold by default? Answer with exactly one word: HOLDS or DEFEATED.', 'DEFEATED', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'DF007B');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'DF007B', 'defeasible', 'DF-07', 'defeater present' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='DF007B');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'DF007C', 'reasoning', 'By default, retries succeed. The job retried, and the operator noted the weather was overcast (unrelated). With no other relevant information, does the expected outcome hold by default? Answer with exactly one word: HOLDS or DEFEATED.', 'HOLDS', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'DF007C');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'DF007C', 'defeasible', 'DF-07', 'default rule, irrelevant non-defeater' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='DF007C');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'DF008A', 'reasoning', 'By default, TLS certs are trusted. This cert was presented. With no other information, does it follow by default that the expected outcome holds? Answer with exactly one word: HOLDS or DEFEATED.', 'HOLDS', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'DF008A');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'DF008A', 'defeasible', 'DF-08', 'default rule, no defeater' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='DF008A');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'DF008B', 'reasoning', 'By default, TLS certs are trusted. This cert was presented, AND The cert is self-signed and not in the trust store. Does the expected outcome still hold by default? Answer with exactly one word: HOLDS or DEFEATED.', 'DEFEATED', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'DF008B');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'DF008B', 'defeasible', 'DF-08', 'defeater present' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='DF008B');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'DF008C', 'reasoning', 'By default, TLS certs are trusted. This cert was presented, and the operator noted the weather was overcast (unrelated). With no other relevant information, does the expected outcome hold by default? Answer with exactly one word: HOLDS or DEFEATED.', 'HOLDS', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'DF008C');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'DF008C', 'defeasible', 'DF-08', 'default rule, irrelevant non-defeater' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='DF008C');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'DF009A', 'reasoning', 'By default, the queue drains overnight. The queue had 10k items at midnight. With no other information, does it follow by default that the expected outcome holds? Answer with exactly one word: HOLDS or DEFEATED.', 'HOLDS', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'DF009A');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'DF009A', 'defeasible', 'DF-09', 'default rule, no defeater' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='DF009A');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'DF009B', 'reasoning', 'By default, the queue drains overnight. The queue had 10k items at midnight, AND A poison message halted the consumer. Does the expected outcome still hold by default? Answer with exactly one word: HOLDS or DEFEATED.', 'DEFEATED', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'DF009B');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'DF009B', 'defeasible', 'DF-09', 'defeater present' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='DF009B');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'DF009C', 'reasoning', 'By default, the queue drains overnight. The queue had 10k items at midnight, and the operator noted the weather was overcast (unrelated). With no other relevant information, does the expected outcome hold by default? Answer with exactly one word: HOLDS or DEFEATED.', 'HOLDS', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'DF009C');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'DF009C', 'defeasible', 'DF-09', 'default rule, irrelevant non-defeater' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='DF009C');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'DF010A', 'reasoning', 'By default, elections of a primary succeed. The cluster held an election. With no other information, does it follow by default that the expected outcome holds? Answer with exactly one word: HOLDS or DEFEATED.', 'HOLDS', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'DF010A');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'DF010A', 'defeasible', 'DF-10', 'default rule, no defeater' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='DF010A');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'DF010B', 'reasoning', 'By default, elections of a primary succeed. The cluster held an election, AND A network partition split the quorum. Does the expected outcome still hold by default? Answer with exactly one word: HOLDS or DEFEATED.', 'DEFEATED', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'DF010B');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'DF010B', 'defeasible', 'DF-10', 'defeater present' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='DF010B');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'DF010C', 'reasoning', 'By default, elections of a primary succeed. The cluster held an election, and the operator noted the weather was overcast (unrelated). With no other relevant information, does the expected outcome hold by default? Answer with exactly one word: HOLDS or DEFEATED.', 'HOLDS', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'DF010C');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'DF010C', 'defeasible', 'DF-10', 'default rule, irrelevant non-defeater' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='DF010C');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'DF011A', 'reasoning', 'By default, migrations are reversible. The migration ran. With no other information, does it follow by default that the expected outcome holds? Answer with exactly one word: HOLDS or DEFEATED.', 'HOLDS', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'DF011A');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'DF011A', 'defeasible', 'DF-11', 'default rule, no defeater' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='DF011A');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'DF011B', 'reasoning', 'By default, migrations are reversible. The migration ran, AND The migration dropped a column with no backup. Does the expected outcome still hold by default? Answer with exactly one word: HOLDS or DEFEATED.', 'DEFEATED', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'DF011B');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'DF011B', 'defeasible', 'DF-11', 'defeater present' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='DF011B');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'DF011C', 'reasoning', 'By default, migrations are reversible. The migration ran, and the operator noted the weather was overcast (unrelated). With no other relevant information, does the expected outcome hold by default? Answer with exactly one word: HOLDS or DEFEATED.', 'HOLDS', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'DF011C');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'DF011C', 'defeasible', 'DF-11', 'default rule, irrelevant non-defeater' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='DF011C');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'DF012A', 'reasoning', 'By default, health checks pass after warmup. The service just started. With no other information, does it follow by default that the expected outcome holds? Answer with exactly one word: HOLDS or DEFEATED.', 'HOLDS', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'DF012A');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'DF012A', 'defeasible', 'DF-12', 'default rule, no defeater' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='DF012A');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'DF012B', 'reasoning', 'By default, health checks pass after warmup. The service just started, AND The service''s config file is unreadable. Does the expected outcome still hold by default? Answer with exactly one word: HOLDS or DEFEATED.', 'DEFEATED', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'DF012B');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'DF012B', 'defeasible', 'DF-12', 'defeater present' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='DF012B');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'DF012C', 'reasoning', 'By default, health checks pass after warmup. The service just started, and the operator noted the weather was overcast (unrelated). With no other relevant information, does the expected outcome hold by default? Answer with exactly one word: HOLDS or DEFEATED.', 'HOLDS', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'DF012C');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'DF012C', 'defeasible', 'DF-12', 'default rule, irrelevant non-defeater' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='DF012C');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'DF013A', 'reasoning', 'By default, disk alerts mean the disk is filling. The disk alert fired. With no other information, does it follow by default that the expected outcome holds? Answer with exactly one word: HOLDS or DEFEATED.', 'HOLDS', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'DF013A');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'DF013A', 'defeasible', 'DF-13', 'default rule, no defeater' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='DF013A');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'DF013B', 'reasoning', 'By default, disk alerts mean the disk is filling. The disk alert fired, AND A logging bug wrote debug lines at error level. Does the expected outcome still hold by default? Answer with exactly one word: HOLDS or DEFEATED.', 'DEFEATED', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'DF013B');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'DF013B', 'defeasible', 'DF-13', 'defeater present' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='DF013B');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'DF013C', 'reasoning', 'By default, disk alerts mean the disk is filling. The disk alert fired, and the operator noted the weather was overcast (unrelated). With no other relevant information, does the expected outcome hold by default? Answer with exactly one word: HOLDS or DEFEATED.', 'HOLDS', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'DF013C');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'DF013C', 'defeasible', 'DF-13', 'default rule, irrelevant non-defeater' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='DF013C');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'DF014A', 'reasoning', 'By default, idempotent requests are safe to retry. The client retried the charge. With no other information, does it follow by default that the expected outcome holds? Answer with exactly one word: HOLDS or DEFEATED.', 'HOLDS', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'DF014A');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'DF014A', 'defeasible', 'DF-14', 'default rule, no defeater' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='DF014A');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'DF014B', 'reasoning', 'By default, idempotent requests are safe to retry. The client retried the charge, AND The request was a non-idempotent refund. Does the expected outcome still hold by default? Answer with exactly one word: HOLDS or DEFEATED.', 'DEFEATED', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'DF014B');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'DF014B', 'defeasible', 'DF-14', 'defeater present' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='DF014B');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'DF014C', 'reasoning', 'By default, idempotent requests are safe to retry. The client retried the charge, and the operator noted the weather was overcast (unrelated). With no other relevant information, does the expected outcome hold by default? Answer with exactly one word: HOLDS or DEFEATED.', 'HOLDS', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'DF014C');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'DF014C', 'defeasible', 'DF-14', 'default rule, irrelevant non-defeater' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='DF014C');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'DF015A', 'reasoning', 'By default, the cache invalidates on write. A write just committed. With no other information, does it follow by default that the expected outcome holds? Answer with exactly one word: HOLDS or DEFEATED.', 'HOLDS', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'DF015A');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'DF015A', 'defeasible', 'DF-15', 'default rule, no defeater' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='DF015A');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'DF015B', 'reasoning', 'By default, the cache invalidates on write. A write just committed, AND The invalidation bus is down. Does the expected outcome still hold by default? Answer with exactly one word: HOLDS or DEFEATED.', 'DEFEATED', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'DF015B');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'DF015B', 'defeasible', 'DF-15', 'defeater present' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='DF015B');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'DF015C', 'reasoning', 'By default, the cache invalidates on write. A write just committed, and the operator noted the weather was overcast (unrelated). With no other relevant information, does the expected outcome hold by default? Answer with exactly one word: HOLDS or DEFEATED.', 'HOLDS', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'DF015C');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'DF015C', 'defeasible', 'DF-15', 'default rule, irrelevant non-defeater' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='DF015C');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'DF016A', 'reasoning', 'By default, the standby takes over on failover. The primary just failed. With no other information, does it follow by default that the expected outcome holds? Answer with exactly one word: HOLDS or DEFEATED.', 'HOLDS', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'DF016A');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'DF016A', 'defeasible', 'DF-16', 'default rule, no defeater' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='DF016A');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'DF016B', 'reasoning', 'By default, the standby takes over on failover. The primary just failed, AND The standby is three days behind on replication. Does the expected outcome still hold by default? Answer with exactly one word: HOLDS or DEFEATED.', 'DEFEATED', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'DF016B');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'DF016B', 'defeasible', 'DF-16', 'defeater present' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='DF016B');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'DF016C', 'reasoning', 'By default, the standby takes over on failover. The primary just failed, and the operator noted the weather was overcast (unrelated). With no other relevant information, does the expected outcome hold by default? Answer with exactly one word: HOLDS or DEFEATED.', 'HOLDS', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'DF016C');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'DF016C', 'defeasible', 'DF-16', 'default rule, irrelevant non-defeater' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='DF016C');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'DF017A', 'reasoning', 'By default, expired tokens are rejected. This token is expired. With no other information, does it follow by default that the expected outcome holds? Answer with exactly one word: HOLDS or DEFEATED.', 'HOLDS', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'DF017A');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'DF017A', 'defeasible', 'DF-17', 'default rule, no defeater' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='DF017A');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'DF017B', 'reasoning', 'By default, expired tokens are rejected. This token is expired, AND The auth server''s clock is 10 minutes slow. Does the expected outcome still hold by default? Answer with exactly one word: HOLDS or DEFEATED.', 'DEFEATED', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'DF017B');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'DF017B', 'defeasible', 'DF-17', 'defeater present' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='DF017B');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'DF017C', 'reasoning', 'By default, expired tokens are rejected. This token is expired, and the operator noted the weather was overcast (unrelated). With no other relevant information, does the expected outcome hold by default? Answer with exactly one word: HOLDS or DEFEATED.', 'HOLDS', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'DF017C');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'DF017C', 'defeasible', 'DF-17', 'default rule, irrelevant non-defeater' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='DF017C');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'DF018A', 'reasoning', 'By default, schema changes are backward compatible. The schema changed. With no other information, does it follow by default that the expected outcome holds? Answer with exactly one word: HOLDS or DEFEATED.', 'HOLDS', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'DF018A');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'DF018A', 'defeasible', 'DF-18', 'default rule, no defeater' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='DF018A');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'DF018B', 'reasoning', 'By default, schema changes are backward compatible. The schema changed, AND The change renamed a field clients depend on. Does the expected outcome still hold by default? Answer with exactly one word: HOLDS or DEFEATED.', 'DEFEATED', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'DF018B');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'DF018B', 'defeasible', 'DF-18', 'defeater present' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='DF018B');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'DF018C', 'reasoning', 'By default, schema changes are backward compatible. The schema changed, and the operator noted the weather was overcast (unrelated). With no other relevant information, does the expected outcome hold by default? Answer with exactly one word: HOLDS or DEFEATED.', 'HOLDS', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'DF018C');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'DF018C', 'defeasible', 'DF-18', 'default rule, irrelevant non-defeater' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='DF018C');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'DF019A', 'reasoning', 'By default, logs can be trusted for forensics. The log shows an intrusion. With no other information, does it follow by default that the expected outcome holds? Answer with exactly one word: HOLDS or DEFEATED.', 'HOLDS', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'DF019A');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'DF019A', 'defeasible', 'DF-19', 'default rule, no defeater' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='DF019A');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'DF019B', 'reasoning', 'By default, logs can be trusted for forensics. The log shows an intrusion, AND The log transport was compromised upstream. Does the expected outcome still hold by default? Answer with exactly one word: HOLDS or DEFEATED.', 'DEFEATED', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'DF019B');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'DF019B', 'defeasible', 'DF-19', 'defeater present' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='DF019B');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'DF019C', 'reasoning', 'By default, logs can be trusted for forensics. The log shows an intrusion, and the operator noted the weather was overcast (unrelated). With no other relevant information, does the expected outcome hold by default? Answer with exactly one word: HOLDS or DEFEATED.', 'HOLDS', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'DF019C');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'DF019C', 'defeasible', 'DF-19', 'default rule, irrelevant non-defeater' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='DF019C');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'DF020A', 'reasoning', 'By default, a green dashboard means the service is up. The dashboard is green. With no other information, does it follow by default that the expected outcome holds? Answer with exactly one word: HOLDS or DEFEATED.', 'HOLDS', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'DF020A');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'DF020A', 'defeasible', 'DF-20', 'default rule, no defeater' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='DF020A');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'DF020B', 'reasoning', 'By default, a green dashboard means the service is up. The dashboard is green, AND The monitoring agent froze hours ago. Does the expected outcome still hold by default? Answer with exactly one word: HOLDS or DEFEATED.', 'DEFEATED', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'DF020B');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'DF020B', 'defeasible', 'DF-20', 'defeater present' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='DF020B');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'DF020C', 'reasoning', 'By default, a green dashboard means the service is up. The dashboard is green, and the operator noted the weather was overcast (unrelated). With no other relevant information, does the expected outcome hold by default? Answer with exactly one word: HOLDS or DEFEATED.', 'HOLDS', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'DF020C');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'DF020C', 'defeasible', 'DF-20', 'default rule, irrelevant non-defeater' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='DF020C');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'DF021A', 'reasoning', 'By default, a 200 status means the request succeeded. The API returned 200. With no other information, does it follow by default that the expected outcome holds? Answer with exactly one word: HOLDS or DEFEATED.', 'HOLDS', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'DF021A');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'DF021A', 'defeasible', 'DF-21', 'default rule, no defeater' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='DF021A');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'DF021B', 'reasoning', 'By default, a 200 status means the request succeeded. The API returned 200, AND A proxy returns 200 for cached error pages. Does the expected outcome still hold by default? Answer with exactly one word: HOLDS or DEFEATED.', 'DEFEATED', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'DF021B');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'DF021B', 'defeasible', 'DF-21', 'defeater present' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='DF021B');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'DF021C', 'reasoning', 'By default, a 200 status means the request succeeded. The API returned 200, and the operator noted the weather was overcast (unrelated). With no other relevant information, does the expected outcome hold by default? Answer with exactly one word: HOLDS or DEFEATED.', 'HOLDS', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'DF021C');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'DF021C', 'defeasible', 'DF-21', 'default rule, irrelevant non-defeater' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='DF021C');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'DF022A', 'reasoning', 'By default, emails marked sent were delivered. The email is marked sent. With no other information, does it follow by default that the expected outcome holds? Answer with exactly one word: HOLDS or DEFEATED.', 'HOLDS', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'DF022A');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'DF022A', 'defeasible', 'DF-22', 'default rule, no defeater' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='DF022A');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'DF022B', 'reasoning', 'By default, emails marked sent were delivered. The email is marked sent, AND The recipient''s server silently dropped it as spam. Does the expected outcome still hold by default? Answer with exactly one word: HOLDS or DEFEATED.', 'DEFEATED', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'DF022B');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'DF022B', 'defeasible', 'DF-22', 'defeater present' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='DF022B');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'DF022C', 'reasoning', 'By default, emails marked sent were delivered. The email is marked sent, and the operator noted the weather was overcast (unrelated). With no other relevant information, does the expected outcome hold by default? Answer with exactly one word: HOLDS or DEFEATED.', 'HOLDS', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'DF022C');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'DF022C', 'defeasible', 'DF-22', 'default rule, irrelevant non-defeater' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='DF022C');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'DF023A', 'reasoning', 'By default, high CPU means a runaway process. CPU is at 99%. With no other information, does it follow by default that the expected outcome holds? Answer with exactly one word: HOLDS or DEFEATED.', 'HOLDS', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'DF023A');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'DF023A', 'defeasible', 'DF-23', 'default rule, no defeater' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='DF023A');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'DF023B', 'reasoning', 'By default, high CPU means a runaway process. CPU is at 99%, AND A scheduled batch job runs at this hour. Does the expected outcome still hold by default? Answer with exactly one word: HOLDS or DEFEATED.', 'DEFEATED', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'DF023B');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'DF023B', 'defeasible', 'DF-23', 'defeater present' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='DF023B');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'DF023C', 'reasoning', 'By default, high CPU means a runaway process. CPU is at 99%, and the operator noted the weather was overcast (unrelated). With no other relevant information, does the expected outcome hold by default? Answer with exactly one word: HOLDS or DEFEATED.', 'HOLDS', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'DF023C');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'DF023C', 'defeasible', 'DF-23', 'default rule, irrelevant non-defeater' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='DF023C');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'DF024A', 'reasoning', 'By default, a locked account means an intruder. The account is locked. With no other information, does it follow by default that the expected outcome holds? Answer with exactly one word: HOLDS or DEFEATED.', 'HOLDS', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'DF024A');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'DF024A', 'defeasible', 'DF-24', 'default rule, no defeater' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='DF024A');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'DF024B', 'reasoning', 'By default, a locked account means an intruder. The account is locked, AND The user mistyped their password five times. Does the expected outcome still hold by default? Answer with exactly one word: HOLDS or DEFEATED.', 'DEFEATED', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'DF024B');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'DF024B', 'defeasible', 'DF-24', 'defeater present' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='DF024B');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'DF024C', 'reasoning', 'By default, a locked account means an intruder. The account is locked, and the operator noted the weather was overcast (unrelated). With no other relevant information, does the expected outcome hold by default? Answer with exactly one word: HOLDS or DEFEATED.', 'HOLDS', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'DF024C');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'DF024C', 'defeasible', 'DF-24', 'default rule, irrelevant non-defeater' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='DF024C');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'DF025A', 'reasoning', 'By default, slow queries mean missing indexes. Queries are slow. With no other information, does it follow by default that the expected outcome holds? Answer with exactly one word: HOLDS or DEFEATED.', 'HOLDS', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'DF025A');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'DF025A', 'defeasible', 'DF-25', 'default rule, no defeater' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='DF025A');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'DF025B', 'reasoning', 'By default, slow queries mean missing indexes. Queries are slow, AND A backup is saturating disk I/O right now. Does the expected outcome still hold by default? Answer with exactly one word: HOLDS or DEFEATED.', 'DEFEATED', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'DF025B');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'DF025B', 'defeasible', 'DF-25', 'defeater present' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='DF025B');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'DF025C', 'reasoning', 'By default, slow queries mean missing indexes. Queries are slow, and the operator noted the weather was overcast (unrelated). With no other relevant information, does the expected outcome hold by default? Answer with exactly one word: HOLDS or DEFEATED.', 'HOLDS', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'DF025C');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'DF025C', 'defeasible', 'DF-25', 'default rule, irrelevant non-defeater' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='DF025C');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'DF026A', 'reasoning', 'By default, a timeout means the service is down. The request timed out. With no other information, does it follow by default that the expected outcome holds? Answer with exactly one word: HOLDS or DEFEATED.', 'HOLDS', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'DF026A');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'DF026A', 'defeasible', 'DF-26', 'default rule, no defeater' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='DF026A');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'DF026B', 'reasoning', 'By default, a timeout means the service is down. The request timed out, AND The client''s network lost connectivity. Does the expected outcome still hold by default? Answer with exactly one word: HOLDS or DEFEATED.', 'DEFEATED', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'DF026B');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'DF026B', 'defeasible', 'DF-26', 'defeater present' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='DF026B');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'DF026C', 'reasoning', 'By default, a timeout means the service is down. The request timed out, and the operator noted the weather was overcast (unrelated). With no other relevant information, does the expected outcome hold by default? Answer with exactly one word: HOLDS or DEFEATED.', 'HOLDS', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'DF026C');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'DF026C', 'defeasible', 'DF-26', 'default rule, irrelevant non-defeater' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='DF026C');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'DF027A', 'reasoning', 'By default, more replicas mean more capacity. We added replicas. With no other information, does it follow by default that the expected outcome holds? Answer with exactly one word: HOLDS or DEFEATED.', 'HOLDS', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'DF027A');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'DF027A', 'defeasible', 'DF-27', 'default rule, no defeater' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='DF027A');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'DF027B', 'reasoning', 'By default, more replicas mean more capacity. We added replicas, AND All replicas landed on the same overloaded host. Does the expected outcome still hold by default? Answer with exactly one word: HOLDS or DEFEATED.', 'DEFEATED', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'DF027B');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'DF027B', 'defeasible', 'DF-27', 'defeater present' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='DF027B');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'DF027C', 'reasoning', 'By default, more replicas mean more capacity. We added replicas, and the operator noted the weather was overcast (unrelated). With no other relevant information, does the expected outcome hold by default? Answer with exactly one word: HOLDS or DEFEATED.', 'HOLDS', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'DF027C');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'DF027C', 'defeasible', 'DF-27', 'default rule, irrelevant non-defeater' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='DF027C');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'DF028A', 'reasoning', 'By default, a retry storm means a bug. Retries spiked. With no other information, does it follow by default that the expected outcome holds? Answer with exactly one word: HOLDS or DEFEATED.', 'HOLDS', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'DF028A');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'DF028A', 'defeasible', 'DF-28', 'default rule, no defeater' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='DF028A');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'DF028B', 'reasoning', 'By default, a retry storm means a bug. Retries spiked, AND The load balancer''s health-check interval is too short. Does the expected outcome still hold by default? Answer with exactly one word: HOLDS or DEFEATED.', 'DEFEATED', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'DF028B');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'DF028B', 'defeasible', 'DF-28', 'defeater present' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='DF028B');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'DF028C', 'reasoning', 'By default, a retry storm means a bug. Retries spiked, and the operator noted the weather was overcast (unrelated). With no other relevant information, does the expected outcome hold by default? Answer with exactly one word: HOLDS or DEFEATED.', 'HOLDS', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'DF028C');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'DF028C', 'defeasible', 'DF-28', 'default rule, irrelevant non-defeater' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='DF028C');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'DF029A', 'reasoning', 'By default, stale DNS means a propagation delay. DNS is stale. With no other information, does it follow by default that the expected outcome holds? Answer with exactly one word: HOLDS or DEFEATED.', 'HOLDS', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'DF029A');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'DF029A', 'defeasible', 'DF-29', 'default rule, no defeater' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='DF029A');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'DF029B', 'reasoning', 'By default, stale DNS means a propagation delay. DNS is stale, AND Someone hardcoded the old IP in /etc/hosts. Does the expected outcome still hold by default? Answer with exactly one word: HOLDS or DEFEATED.', 'DEFEATED', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'DF029B');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'DF029B', 'defeasible', 'DF-29', 'defeater present' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='DF029B');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'DF029C', 'reasoning', 'By default, stale DNS means a propagation delay. DNS is stale, and the operator noted the weather was overcast (unrelated). With no other relevant information, does the expected outcome hold by default? Answer with exactly one word: HOLDS or DEFEATED.', 'HOLDS', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'DF029C');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'DF029C', 'defeasible', 'DF-29', 'default rule, irrelevant non-defeater' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='DF029C');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'DF030A', 'reasoning', 'By default, a full connection pool means high load. The pool is full. With no other information, does it follow by default that the expected outcome holds? Answer with exactly one word: HOLDS or DEFEATED.', 'HOLDS', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'DF030A');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'DF030A', 'defeasible', 'DF-30', 'default rule, no defeater' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='DF030A');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'DF030B', 'reasoning', 'By default, a full connection pool means high load. The pool is full, AND Connections are leaking and never released. Does the expected outcome still hold by default? Answer with exactly one word: HOLDS or DEFEATED.', 'DEFEATED', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'DF030B');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'DF030B', 'defeasible', 'DF-30', 'defeater present' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='DF030B');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'DF030C', 'reasoning', 'By default, a full connection pool means high load. The pool is full, and the operator noted the weather was overcast (unrelated). With no other relevant information, does the expected outcome hold by default? Answer with exactly one word: HOLDS or DEFEATED.', 'HOLDS', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'DF030C');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'DF030C', 'defeasible', 'DF-30', 'default rule, irrelevant non-defeater' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='DF030C');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'DF031A', 'reasoning', 'By default, a dropped packet means congestion. Packets are dropping. With no other information, does it follow by default that the expected outcome holds? Answer with exactly one word: HOLDS or DEFEATED.', 'HOLDS', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'DF031A');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'DF031A', 'defeasible', 'DF-31', 'default rule, no defeater' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='DF031A');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'DF031B', 'reasoning', 'By default, a dropped packet means congestion. Packets are dropping, AND A cable is partially unplugged. Does the expected outcome still hold by default? Answer with exactly one word: HOLDS or DEFEATED.', 'DEFEATED', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'DF031B');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'DF031B', 'defeasible', 'DF-31', 'defeater present' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='DF031B');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'DF031C', 'reasoning', 'By default, a dropped packet means congestion. Packets are dropping, and the operator noted the weather was overcast (unrelated). With no other relevant information, does the expected outcome hold by default? Answer with exactly one word: HOLDS or DEFEATED.', 'HOLDS', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'DF031C');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'DF031C', 'defeasible', 'DF-31', 'default rule, irrelevant non-defeater' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='DF031C');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'DF032A', 'reasoning', 'By default, a slow deploy means a large diff. The deploy is slow. With no other information, does it follow by default that the expected outcome holds? Answer with exactly one word: HOLDS or DEFEATED.', 'HOLDS', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'DF032A');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'DF032A', 'defeasible', 'DF-32', 'default rule, no defeater' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='DF032A');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'DF032B', 'reasoning', 'By default, a slow deploy means a large diff. The deploy is slow, AND A node is throttled by the cloud provider. Does the expected outcome still hold by default? Answer with exactly one word: HOLDS or DEFEATED.', 'DEFEATED', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'DF032B');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'DF032B', 'defeasible', 'DF-32', 'defeater present' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='DF032B');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'DF032C', 'reasoning', 'By default, a slow deploy means a large diff. The deploy is slow, and the operator noted the weather was overcast (unrelated). With no other relevant information, does the expected outcome hold by default? Answer with exactly one word: HOLDS or DEFEATED.', 'HOLDS', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'DF032C');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'DF032C', 'defeasible', 'DF-32', 'default rule, irrelevant non-defeater' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='DF032C');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'DF033A', 'reasoning', 'By default, a failed health check means a crash. The health check failed. With no other information, does it follow by default that the expected outcome holds? Answer with exactly one word: HOLDS or DEFEATED.', 'HOLDS', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'DF033A');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'DF033A', 'defeasible', 'DF-33', 'default rule, no defeater' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='DF033A');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'DF033B', 'reasoning', 'By default, a failed health check means a crash. The health check failed, AND The health endpoint''s dependency is slow. Does the expected outcome still hold by default? Answer with exactly one word: HOLDS or DEFEATED.', 'DEFEATED', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'DF033B');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'DF033B', 'defeasible', 'DF-33', 'defeater present' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='DF033B');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'DF033C', 'reasoning', 'By default, a failed health check means a crash. The health check failed, and the operator noted the weather was overcast (unrelated). With no other relevant information, does the expected outcome hold by default? Answer with exactly one word: HOLDS or DEFEATED.', 'HOLDS', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'DF033C');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'DF033C', 'defeasible', 'DF-33', 'default rule, irrelevant non-defeater' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='DF033C');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'DF034A', 'reasoning', 'By default, rising memory means a leak. Memory is climbing. With no other information, does it follow by default that the expected outcome holds? Answer with exactly one word: HOLDS or DEFEATED.', 'HOLDS', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'DF034A');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'DF034A', 'defeasible', 'DF-34', 'default rule, no defeater' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='DF034A');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'DF034B', 'reasoning', 'By default, rising memory means a leak. Memory is climbing, AND The cache is warming after a cold start. Does the expected outcome still hold by default? Answer with exactly one word: HOLDS or DEFEATED.', 'DEFEATED', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'DF034B');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'DF034B', 'defeasible', 'DF-34', 'defeater present' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='DF034B');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'DF034C', 'reasoning', 'By default, rising memory means a leak. Memory is climbing, and the operator noted the weather was overcast (unrelated). With no other relevant information, does the expected outcome hold by default? Answer with exactly one word: HOLDS or DEFEATED.', 'HOLDS', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'DF034C');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'DF034C', 'defeasible', 'DF-34', 'default rule, irrelevant non-defeater' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='DF034C');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'DF035A', 'reasoning', 'By default, a 503 means the app is down. The app returned 503. With no other information, does it follow by default that the expected outcome holds? Answer with exactly one word: HOLDS or DEFEATED.', 'HOLDS', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'DF035A');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'DF035A', 'defeasible', 'DF-35', 'default rule, no defeater' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='DF035A');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'DF035B', 'reasoning', 'By default, a 503 means the app is down. The app returned 503, AND The rate limiter is shedding load deliberately. Does the expected outcome still hold by default? Answer with exactly one word: HOLDS or DEFEATED.', 'DEFEATED', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'DF035B');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'DF035B', 'defeasible', 'DF-35', 'defeater present' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='DF035B');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'DF035C', 'reasoning', 'By default, a 503 means the app is down. The app returned 503, and the operator noted the weather was overcast (unrelated). With no other relevant information, does the expected outcome hold by default? Answer with exactly one word: HOLDS or DEFEATED.', 'HOLDS', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'DF035C');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'DF035C', 'defeasible', 'DF-35', 'default rule, irrelevant non-defeater' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='DF035C');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'DF036A', 'reasoning', 'By default, a missing metric means no traffic. The metric vanished. With no other information, does it follow by default that the expected outcome holds? Answer with exactly one word: HOLDS or DEFEATED.', 'HOLDS', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'DF036A');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'DF036A', 'defeasible', 'DF-36', 'default rule, no defeater' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='DF036A');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'DF036B', 'reasoning', 'By default, a missing metric means no traffic. The metric vanished, AND The metrics exporter crashed. Does the expected outcome still hold by default? Answer with exactly one word: HOLDS or DEFEATED.', 'DEFEATED', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'DF036B');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'DF036B', 'defeasible', 'DF-36', 'defeater present' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='DF036B');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'DF036C', 'reasoning', 'By default, a missing metric means no traffic. The metric vanished, and the operator noted the weather was overcast (unrelated). With no other relevant information, does the expected outcome hold by default? Answer with exactly one word: HOLDS or DEFEATED.', 'HOLDS', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'DF036C');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'DF036C', 'defeasible', 'DF-36', 'default rule, irrelevant non-defeater' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='DF036C');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'DF037A', 'reasoning', 'By default, identical configs mean identical behavior. Both nodes have the same config. With no other information, does it follow by default that the expected outcome holds? Answer with exactly one word: HOLDS or DEFEATED.', 'HOLDS', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'DF037A');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'DF037A', 'defeasible', 'DF-37', 'default rule, no defeater' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='DF037A');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'DF037B', 'reasoning', 'By default, identical configs mean identical behavior. Both nodes have the same config, AND One node is running an older binary. Does the expected outcome still hold by default? Answer with exactly one word: HOLDS or DEFEATED.', 'DEFEATED', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'DF037B');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'DF037B', 'defeasible', 'DF-37', 'defeater present' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='DF037B');

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, active, owl_type, trials_per_run)
SELECT 'DF037C', 'reasoning', 'By default, identical configs mean identical behavior. Both nodes have the same config, and the operator noted the weather was overcast (unrelated). With no other relevant information, does the expected outcome hold by default? Answer with exactly one word: HOLDS or DEFEATED.', 'HOLDS', 'exact', true, 'I', 6 WHERE NOT EXISTS (SELECT 1 FROM tests WHERE name = 'DF037C');
INSERT INTO powered_metadata (test_name, probe_class, family_id, note) SELECT 'DF037C', 'defeasible', 'DF-37', 'default rule, irrelevant non-defeater' WHERE NOT EXISTS (SELECT 1 FROM powered_metadata WHERE test_name='DF037C');
