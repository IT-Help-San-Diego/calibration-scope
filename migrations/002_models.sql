-- v002: Model registry (selectable models for benchmarking)
CREATE TABLE IF NOT EXISTS models (
    id SERIAL PRIMARY KEY,
    key TEXT UNIQUE NOT NULL,
    display_name TEXT NOT NULL,
    provider TEXT NOT NULL,  -- lmstudio|nous|openrouter|other
    location TEXT NOT NULL,  -- local|cloud
    context_length INT DEFAULT 0,
    size_gb FLOAT DEFAULT 0,
    notes TEXT,
    tags TEXT[],             -- PostgreSQL array of tags (vision, tools, reasoning, flaky, safe, etc.)
    active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_models_location ON models(location);
CREATE INDEX IF NOT EXISTS idx_models_provider ON models(provider);
CREATE INDEX IF NOT EXISTS idx_models_active ON models(active);
