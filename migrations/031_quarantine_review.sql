-- v031: quarantine/review layer for test_runs
-- quarantined runs are excluded from leaderboard/router scoring but kept
-- for post-mortem analysis and model-config guidance.

ALTER TABLE test_runs
  ADD COLUMN IF NOT EXISTS quarantined BOOLEAN DEFAULT FALSE,
  ADD COLUMN IF NOT EXISTS quarantine_reason TEXT DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS quarantine_notes TEXT DEFAULT NULL;

CREATE INDEX IF NOT EXISTS idx_test_runs_quarantined
  ON test_runs(quarantined, status, model_id);
