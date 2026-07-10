-- 023: a cloud model id can exist on multiple providers (e.g.
-- anthropic/claude-sonnet-5 is served by BOTH Nous and OpenRouter with
-- different routing and pricing). Those are distinct test subjects.
-- Replace the key-only uniqueness with (key, provider).
ALTER TABLE models DROP CONSTRAINT IF EXISTS models_key_key;
CREATE UNIQUE INDEX IF NOT EXISTS idx_models_key_provider ON models (key, provider);
