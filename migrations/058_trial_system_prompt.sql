-- Migration 058: persist the effective system prompt per trial
--
-- Gap surfaced by Claude Science's run-level audit (2026-07-27) and answered
-- by Hermes's prompt_tokens table (2026-07-28): the token signature proved
-- a carrier fired on runs 975/977/978, but the VERBATIM system message the
-- model saw was never persisted per trial — scaffold_supplement lives at
-- run level only, and the effective message (scaffold + leak-free hint,
-- built in executor::build_messages) existed only in memory. The seal
-- covered the response, not the stimulus that produced it.
--
-- This column closes that hole: every trial records the exact system
-- prompt content the model was given (NULL when no scaffold — the clean-
-- room baseline), so any verdict can be traced to its full stimulus and
-- the sealed evidence covers both sides of the conversation.
--
-- Verification: a scaffolded run's trial_results rows carry non-NULL
-- system_prompt whose content starts with the run's scaffold_supplement;
-- clean-room runs carry NULL.

ALTER TABLE trial_results
    ADD COLUMN IF NOT EXISTS system_prompt TEXT;

COMMENT ON COLUMN trial_results.system_prompt IS
    'Effective system message the model saw on this trial (scaffold + leak-free hint), or NULL for clean-room. Sealed into run provenance via evidence_lines.';
