-- v033: Persist speculative-decode stats per trial so the leaderboard can
-- distinguish "ran as a pair" from "ran as a single model".
ALTER TABLE trial_results
    ADD COLUMN IF NOT EXISTS speculative_draft_model TEXT,
    ADD COLUMN IF NOT EXISTS total_draft_tokens_count BIGINT,
    ADD COLUMN IF NOT EXISTS accepted_draft_tokens_count BIGINT,
    ADD COLUMN IF NOT EXISTS rejected_draft_tokens_count BIGINT;
