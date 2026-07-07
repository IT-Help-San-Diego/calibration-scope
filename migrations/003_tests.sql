-- v003: Test definitions (editable benchmarks)
CREATE TABLE IF NOT EXISTS tests (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    axis TEXT NOT NULL,  -- vision|tools|reasoning|security
    prompt_text TEXT NOT NULL,
    attachment_path TEXT,
    attachment_sha3 TEXT,
    expected_result TEXT,
    scoring_method TEXT NOT NULL DEFAULT 'exact',  -- exact|substring|spatial|nested_tool|security
    trials_per_run INT DEFAULT 3,
    flaky_threshold FLOAT DEFAULT 0.67,
    active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT axis_check CHECK (axis IN ('vision','tools','reasoning','security'))
);

CREATE INDEX IF NOT EXISTS idx_tests_axis ON tests(axis);
CREATE INDEX IF NOT EXISTS idx_tests_active ON tests(active);
