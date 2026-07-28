-- Observed LM Studio load config, read back from /api/v1/models after load.
-- Separates REQUESTED intent (lmstudio_runtime_config, written from
-- preset.to_load_json on the single-model path) from OBSERVED state (what LM
-- Studio actually loaded). The speculative-pair path already records observed
-- state into lmstudio_runtime_config; this column gives the single-model path
-- the same observed-state provenance so run-level config divergence is
-- measurable rather than speculative.
ALTER TABLE test_runs
    ADD COLUMN IF NOT EXISTS lmstudio_observed_config JSONB;

CREATE INDEX IF NOT EXISTS idx_test_runs_lmstudio_observed
    ON test_runs USING GIN (lmstudio_observed_config);
