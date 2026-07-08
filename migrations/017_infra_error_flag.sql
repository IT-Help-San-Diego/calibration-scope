-- v017: Add trial_results.is_infra_error — distinguish "the model tried and
-- was wrong" from "we never actually reached the model."
--
-- Found live 2026-07-08: hermes-4-14b showed 4 hard fails (FAIL/UNSAFE on
-- every core axis) on the leaderboard, which looked like a genuinely
-- terrible model. Root cause was infrastructure, not capability: every
-- single trial died with detail='execution error: HTTP client error: HTTP
-- status client error (400 Bad Request)...' — the exact speculative-decoding
-- config bug found earlier in this session (draft-model pairing + batched
-- load = LM Studio rejects every request before the model ever answers).
-- 150 of 1158 trial_results database-wide (13%) share this exact prefix.
--
-- This matters beyond one bad number: any future capability-based routing
-- (only send tool-calling jobs to models proven good at tools, never send
-- reasoning jobs to a model proven weak at it) MUST be built on a clean
-- capability signal. Training a router on "hermes-4-14b fails everything"
-- when the truth is "the harness never reached it" would be actively wrong,
-- not just imprecise.
ALTER TABLE trial_results ADD COLUMN IF NOT EXISTS is_infra_error BOOLEAN NOT NULL DEFAULT false;

-- Backfill existing rows from the exact prefix the executor has always used
-- for this failure class (src/executor/mod.rs: format!("execution error: {}", e)).
UPDATE trial_results SET is_infra_error = true WHERE detail LIKE 'execution error:%';

CREATE INDEX IF NOT EXISTS idx_trial_results_infra_error ON trial_results (is_infra_error);
