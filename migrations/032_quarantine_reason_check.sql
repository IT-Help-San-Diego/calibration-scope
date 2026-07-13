-- v032: enforce valid quarantine_reason values on test_runs
-- Quarantine is boolean-overlay, not a status replacement: keep existing
-- status_check intact and add a separate reason whitelist so bad runs stay
-- auditable instead of silently disappearing from scoring.

ALTER TABLE test_runs DROP CONSTRAINT IF EXISTS quarantine_reason_check;
ALTER TABLE test_runs ADD CONSTRAINT quarantine_reason_check
    CHECK (quarantine_reason IS NULL OR quarantine_reason = ANY (
        ARRAY[
            'infrastructure_error'::text,
            'blank_responses'::text,
            'all_failed'::text,
            'timeout'::text,
            'user_excluded'::text,
            'draft_stats_mismatch'::text
        ]
    ));
