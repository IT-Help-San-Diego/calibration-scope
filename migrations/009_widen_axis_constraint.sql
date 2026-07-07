-- v010: Widen axis CHECK constraints to allow 'auxiliary' — the experimental
-- axis added in migration 009 for the Nous-necessity reliability tests.
-- Both tables (tests, test_runs) independently enforce the old 4-axis list.
ALTER TABLE tests DROP CONSTRAINT IF EXISTS axis_check;
ALTER TABLE tests ADD CONSTRAINT axis_check
    CHECK (axis = ANY (ARRAY['vision', 'tools', 'reasoning', 'security', 'auxiliary']));

ALTER TABLE test_runs DROP CONSTRAINT IF EXISTS axis_check;
ALTER TABLE test_runs ADD CONSTRAINT axis_check
    CHECK (axis = ANY (ARRAY['vision', 'tools', 'reasoning', 'security', 'auxiliary']));
