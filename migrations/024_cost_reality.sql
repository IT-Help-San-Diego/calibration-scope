-- v024: Cost reality — the free→trickle→fountain axis, measured not promised.
--
-- Philosophy (provenance principle): store raw MEASUREMENTS, derive verdicts
-- at read time. We store catalog unit prices (what the provider CLAIMS) and
-- per-trial token usage (what a run ACTUALLY consumed). Dollar cost is always
-- computed at read time = tokens × unit price; never persisted, so a pricing
-- correction never orphans historical rows.

-- Catalog pricing, captured at sync time from the provider's own /v1/models.
-- USD per single token (the APIs report strings like "0.0000002000").
-- NULL = provider doesn't publish pricing (LM Studio local models: electricity
-- is real but not the provider's price sheet — local cost model comes later).
ALTER TABLE models ADD COLUMN IF NOT EXISTS price_prompt NUMERIC;
ALTER TABLE models ADD COLUMN IF NOT EXISTS price_completion NUMERIC;
ALTER TABLE models ADD COLUMN IF NOT EXISTS pricing_updated_at TIMESTAMP;

-- Per-trial usage, read back from the response's usage object. NULL = the
-- provider omitted usage (rare) or the row predates this migration. Never
-- guessed, never backfilled with estimates.
ALTER TABLE trial_results ADD COLUMN IF NOT EXISTS prompt_tokens BIGINT;
ALTER TABLE trial_results ADD COLUMN IF NOT EXISTS completion_tokens BIGINT;

-- Fountain probes: sustained-throughput interrogation of a model's REAL
-- rate posture. A model advertised "free" that 429s on request 2 is a lie;
-- one that sustains N sequential requests is a genuine trickle/fountain.
-- One row per probe run; per-request evidence lives in fountain_probe_requests.
CREATE TABLE IF NOT EXISTS fountain_probes (
    id SERIAL PRIMARY KEY,
    model_key TEXT NOT NULL,
    provider TEXT NOT NULL,
    requests_planned INT NOT NULL,
    requests_sent INT NOT NULL DEFAULT 0,
    requests_ok INT NOT NULL DEFAULT 0,
    requests_rate_limited INT NOT NULL DEFAULT 0,
    requests_errored INT NOT NULL DEFAULT 0,
    first_429_at_request INT,          -- NULL = never rate-limited
    total_prompt_tokens BIGINT NOT NULL DEFAULT 0,
    total_completion_tokens BIGINT NOT NULL DEFAULT 0,
    duration_ms BIGINT,
    verdict TEXT,                      -- FOUNTAIN | TRICKLE | THROTTLED | MIRAGE (see routes/fountain.rs)
    status TEXT NOT NULL DEFAULT 'running',  -- running|done|error|aborted
    sha3_provenance TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS fountain_probe_requests (
    id SERIAL PRIMARY KEY,
    probe_id INT NOT NULL REFERENCES fountain_probes(id) ON DELETE CASCADE,
    request_num INT NOT NULL,
    http_status INT,                   -- 0 = transport error (no HTTP response)
    ok BOOLEAN NOT NULL,
    latency_ms BIGINT,
    prompt_tokens BIGINT,
    completion_tokens BIGINT,
    retry_after TEXT,                  -- Retry-After header verbatim, when sent
    error_snippet TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_fountain_probes_model ON fountain_probes(model_key);
CREATE INDEX IF NOT EXISTS idx_fountain_probe_requests_probe ON fountain_probe_requests(probe_id);
