-- Scaffold experiment: track targeted fallacy tags and optional run-level
-- system-prompt supplements without breaking existing test/run contracts.
BEGIN;

ALTER TABLE tests ADD COLUMN IF NOT EXISTS fallacy_tag text DEFAULT NULL;
ALTER TABLE test_runs ADD COLUMN IF NOT EXISTS scaffold_supplement text DEFAULT NULL;

COMMIT;
