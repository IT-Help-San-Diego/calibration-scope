-- 030_load_modes.sql
-- Adds two explicit LM Studio loading test modes:
-- 1) clean-room: single model, eject all, fair baseline
-- 2) speculative-pair: primary + draft model loaded simultaneously

ALTER TABLE test_runs ADD COLUMN IF NOT EXISTS load_mode text DEFAULT 'clean-room';
ALTER TABLE test_runs ADD COLUMN IF NOT EXISTS draft_model_key text DEFAULT NULL;
ALTER TABLE test_runs ADD COLUMN IF NOT EXISTS pair_ejected_ids text DEFAULT NULL;

ALTER TABLE test_runs DROP CONSTRAINT IF EXISTS load_mode_check;
ALTER TABLE test_runs ADD CONSTRAINT load_mode_check CHECK (load_mode IN ('clean-room', 'speculative-pair'));
