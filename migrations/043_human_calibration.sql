-- v043: Human-participant scoring, and the Signal/Carrier split.
--
-- Lets a person take the SAME formal_spec-paraphrase families ('I' plus
-- its 'N' siblings, migration 036 (owl semaphore)) that models get scored on, and stops
-- collapsing the result to one number. Two numbers instead:
--
--   signal_score    — pooled pass rate across EVERY surface form of a
--                      family (the Identity phrasing plus all its N
--                      paraphrases). Format-invariant: did they reach the
--                      right VALID/INVALID regardless of how the question
--                      was worded. This is the real construct.
--   carrier_variance — variance of the PER-SURFACE-FORM pass rate within
--                      a family. High signal + high carrier variance =
--                      the reasoning is there and something about the
--                      wording (notation, verbal density, whatever) is
--                      doing work that has nothing to do with reasoning.
--                      NULL, honestly, when fewer than 2 surface forms
--                      were attempted — you cannot measure variance from
--                      one point, and reporting 0 there would claim
--                      "no swing observed" when the true state is
--                      "not enough data to know."
--
-- Full rationale: docs/OWL_SEMAPHORE.md, "Future direction: human-
-- calibrated modes." This migration builds the scoring half of that
-- section; it does not build a UI for a human to sit and take the
-- battery — that's separate, real, not-yet-scoped work.
--
-- Scope note: computed over owl_type IN ('I','N') only. 'C' and 'M' rows
-- measure different things (a named adversarial trap; the quality of a
-- self-explanation) and would contaminate a same-structure comparison —
-- see migration 036 (owl semaphore)'s header for why those tiers exist separately.

-- ── Where a human lives in this schema ──────────────────────────────────
-- NOT shoehorned into `models` — a person's size_gb/context_length/
-- provider have no meaning, and faking values there would be exactly the
-- kind of dishonest schema this project doesn't write. `kind` is
-- deliberately a one-value enum for now (not overbuilt ahead of an actual
-- second participant type) but exists as a real extension point, same
-- spirit as the reserved columns in metacognitive_scores.
CREATE TABLE IF NOT EXISTS participants (
    id SERIAL PRIMARY KEY,
    kind TEXT NOT NULL DEFAULT 'human' CHECK (kind IN ('human')),
    display_name TEXT NOT NULL,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- test_runs becomes a discriminated union over {model_id, participant_id}.
-- trial_results is UNCHANGED — it already only references run_id, so
-- every existing query, index, and all of migration 036 (owl semaphore)'s owl/
-- metacognitive machinery applies to human runs for free.
ALTER TABLE test_runs ADD COLUMN IF NOT EXISTS participant_id INTEGER REFERENCES participants(id);
ALTER TABLE test_runs ALTER COLUMN model_id DROP NOT NULL;

ALTER TABLE test_runs DROP CONSTRAINT IF EXISTS test_runs_subject_xor;
ALTER TABLE test_runs ADD CONSTRAINT test_runs_subject_xor CHECK (
    (model_id IS NOT NULL AND participant_id IS NULL)
    OR (model_id IS NULL AND participant_id IS NOT NULL)
);

CREATE INDEX IF NOT EXISTS idx_test_runs_participant ON test_runs(participant_id);

-- ── Signal / Carrier scoring, for models and participants alike ────────
-- Same view serves both, keyed by whichever subject actually ran — this
-- is what makes "find the model whose reasoning profile correlates with
-- mine" (Mode 1) a real query instead of a new subsystem: model rows and
-- participant rows land in the same shape, comparable directly.
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
