-- Migration 059: owl_signal_carrier — exclude infrastructure errors (CS-005)
--
-- THE BUG. The view created in 043_human_calibration.sql joins trial_results
-- with NO is_infra_error exclusion. An infra error is a trial where the model
-- never got to answer — a backend outage, a transport failure, a timeout —
-- and migration 017 added the column precisely to separate "the model tried
-- and was wrong" from "the model never answered". Without the filter, every
-- such trial lands in COUNT(*) as a non-pass, so a provider outage reads as
-- the model reasoning badly. There are 1,574 infra-error trials in the
-- development database, touching 1,542 of the view's 3,372 rows.
--
-- Every other analysis path in this repo already excludes them with the same
-- predicate (`is_infra_error = false` — see src/db/queries.rs and the scoring
-- queries). This view was the one that didn't, which made it the one place
-- where signal_score could be deflated by someone else's 5xx.
--
-- WHAT IS DELIBERATELY NOT CHANGED. VARIANCE() stays VARIANCE() — i.e.
-- var_samp. Ruled by Claude Science (2026-07-28) when this card was opened:
-- at n=1 var_pop returns 0 while var_samp returns NULL, and 0 asserts "this
-- carrier showed no variance" where the truth is "one surface form is not
-- enough information to say". NULL is the honest answer and the aggregate
-- must keep saying it. Changing it would also move already-published
-- numbers, which is a separate decision with a separate blast radius.
--
-- The filter goes in subject_test_rate, before the per-surface-form pass_rate
-- is computed, so an infra trial affects neither the numerator nor the
-- denominator at any level of the rollup. Placing it in the outer query
-- would have been too late: pass_rate would already be wrong.
--
-- VERIFICATION. After applying, no trial counted by the view may carry
-- is_infra_error, and total_trials must drop by exactly the number of
-- infra-error trials joinable to an I/N family member:
--
--   SELECT SUM(total_trials) FROM owl_signal_carrier;   -- before vs after
--   SELECT COUNT(*) FROM trial_results trr
--     JOIN tests t ON t.id = trr.test_id
--    WHERE trr.is_infra_error AND t.owl_type IN ('I','N');   -- the delta

CREATE OR REPLACE VIEW owl_signal_carrier AS
WITH family_member AS (
    SELECT
        id AS test_id,
        CASE WHEN owl_type = 'I' THEN id ELSE owl_root_id END AS family_root_id,
        axis
    FROM tests
    WHERE owl_type IN ('I', 'N')
),
subject_test_rate AS (
    SELECT
        tr.model_id,
        tr.participant_id,
        fm.family_root_id,
        fm.test_id,
        fm.axis,
        COUNT(*) AS total,
        COUNT(*) FILTER (WHERE trr.passed) AS passes,
        COUNT(*) FILTER (WHERE trr.passed)::FLOAT / NULLIF(COUNT(*), 0) AS pass_rate
    FROM trial_results trr
    JOIN test_runs tr ON tr.id = trr.run_id
    JOIN family_member fm ON fm.test_id = trr.test_id
    -- The fix. Same predicate as every other scoring path: a trial where the
    -- model never answered is not evidence about the model.
    WHERE trr.is_infra_error = false
    GROUP BY tr.model_id, tr.participant_id, fm.family_root_id, fm.test_id, fm.axis
)
SELECT
    model_id,
    participant_id,
    family_root_id,
    (SELECT name FROM tests WHERE id = family_root_id) AS family_name,
    axis,
    COUNT(DISTINCT test_id) AS surface_forms_attempted,
    SUM(total) AS total_trials,
    SUM(passes) AS total_passes,
    SUM(passes)::FLOAT / NULLIF(SUM(total), 0) AS signal_score,
    VARIANCE(pass_rate) AS carrier_variance
FROM subject_test_rate
GROUP BY model_id, participant_id, family_root_id, axis;
