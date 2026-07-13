-- v034: Persist LM Studio runtime config per run so speculative-decoding
-- experiments are reproducible.
ALTER TABLE test_runs
    ADD COLUMN IF NOT EXISTS lmstudio_runtime_config JSONB;

CREATE INDEX IF NOT EXISTS idx_test_runs_lmstudio_config
    ON test_runs USING GIN (lmstudio_runtime_config);
