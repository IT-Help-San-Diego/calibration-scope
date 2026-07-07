-- v004: Test runs (one execution of one test against one model)
CREATE TABLE IF NOT EXISTS test_runs (
    id SERIAL PRIMARY KEY,
    model_id INT NOT NULL REFERENCES models(id),
    test_id INT NOT NULL REFERENCES tests(id),
    axis TEXT NOT NULL,  -- vision|tools|reasoning|security
    status TEXT NOT NULL DEFAULT 'queued',  -- queued|loading|running|done|error
    started_at TIMESTAMP,
    finished_at TIMESTAMP,
    num_trials INT DEFAULT 3,
    pass_count INT DEFAULT 0,
    total_count INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT status_check CHECK (status IN ('queued','loading','running','done','error')),
    CONSTRAINT axis_check CHECK (axis IN ('vision','tools','reasoning','security'))
);

CREATE INDEX IF NOT EXISTS idx_test_runs_model ON test_runs(model_id);
CREATE INDEX IF NOT EXISTS idx_test_runs_test ON test_runs(test_id);
CREATE INDEX IF NOT EXISTS idx_test_runs_axis ON test_runs(axis);
CREATE INDEX IF NOT EXISTS idx_test_runs_created ON test_runs(created_at DESC);
