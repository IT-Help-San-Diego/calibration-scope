-- v011: LM Studio model registry sync
-- Auto-sync LM Studio's model list into the benchmark registry.
-- Adds new models, updates existing, marks missing as inactive (preserves history).
-- Triggered on dashboard startup (lightweight) and via manual POST /api/lmstudio/sync.
CREATE TABLE IF NOT EXISTS lmstudio_sync_log (
    id SERIAL PRIMARY KEY,
    started_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    finished_at TIMESTAMP,
    models_seen INTEGER DEFAULT 0,
    models_added INTEGER DEFAULT 0,
    models_updated INTEGER DEFAULT 0,
    models_deactivated INTEGER DEFAULT 0,
    error TEXT
);

-- Index for sync history
CREATE INDEX IF NOT EXISTS idx_lmstudio_sync_log_started ON lmstudio_sync_log(started_at DESC);

-- Add tracking columns to models table
ALTER TABLE models ADD COLUMN IF NOT EXISTS lmstudio_key TEXT;
ALTER TABLE models ADD COLUMN IF NOT EXISTS last_seen_in_lmstudio TIMESTAMP;
ALTER TABLE models ADD COLUMN IF NOT EXISTS supports_vision BOOLEAN DEFAULT FALSE;

-- Index for LM Studio key lookups
CREATE INDEX IF NOT EXISTS idx_models_lmstudio_key ON models(lmstudio_key);