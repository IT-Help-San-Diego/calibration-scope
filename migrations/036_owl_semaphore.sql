-- v036: Owl Semaphore epistemic taxonomy — tags each test by its epistemic
-- role in a machine-verified family, and adds objective (non-LLM-judge)
-- scoring of a model's self-explanation, not just its final answer.
--
-- Four owl_type values, following the Owl Semaphore notation (Balboa,
-- dnstool.it-help.tech/owl-semaphore, DOI 10.5281/zenodo.18854899) — the
-- identity plus three non-identity symmetries of the Klein four-group
-- V4 = {I, σᵥ, C2, σₕ}, operationalized onto THIS schema as follows:
--
--   I  (identity)        — ground truth. The whole pre-existing battery
--                           (013/025/027): one formal_spec, one Lean
--                           theorem in lean/ArchetypeMesh.lean, one
--                           Python-oracle check in
--                           scripts/verify_logic_ground_truth.py. Every
--                           row seeded before this migration is owl_type
--                           = 'I' by default — nothing about the existing
--                           battery's CONTENT changes here. (LOGIC-12 /
--                           LOGIC-13's discrimination pair looked like a
--                           tempting fit for 'C' on first read — it is
--                           NOT: they're two independently-valid formal
--                           structures, not one structure in two surface
--                           forms. Left as two Identity rows rather than
--                           guessed into a taxonomy they don't fit.)
--
--   N  (non-normative,
--       σᵥ — reworded, truth-value invariant) — the SAME formal_spec /
--                           theorem as its owl_root_id, different surface
--                           text. Anti-memorization: if a model passes the
--                           'I' phrasing but fails an 'N' paraphrase of the
--                           identical structure, that's pattern-matching,
--                           not reasoning — exactly the concern migration
--                           025 already raised about "negative conjunction
--                           vibes."
--
--   C  (critical,
--       C2 — the 180° rotation, σᵥ∘σₕ) — a reworded item (like N) that is
--                           ALSO deliberately loaded with a named
--                           pattern-matching trap (owl_flaw). The
--                           composition is literal, not poetic: a critical
--                           row carries both an owl_transform (what
--                           changed at the surface, like N) and a reason
--                           to run it through metacognitive scoring (did
--                           the model's OWN trace show it fell for the
--                           trap or saw through it, like M). Enforced
--                           below by owl_c_completeness.
--
--   M  (metacognitive,
--       σₕ — reflects the axis being measured, not the prompt) — does not
--                           reword anything; it evaluates the EXPLANATION
--                           a model already gave for an I/N/C item, not a
--                           new question. Operationalized as
--                           metacognitive_scores below, scored against
--                           trial_results.reasoning_content (migration
--                           018) by scoring::score_metacognition — pure
--                           keyword match, no second model ever grades
--                           the first.
--
-- HONESTY NOTE: this is Claude's proposed operationalization of your V4
-- structure onto this schema, not a restatement of the Zenodo paper's own
-- algebra — only the summary was available, not the full text. Worth
-- confirming the mapping matches your intent before leaning on group
-- closure as a correctness argument anywhere else in the codebase.

ALTER TABLE tests ADD COLUMN IF NOT EXISTS owl_type CHAR(1) NOT NULL DEFAULT 'I';
ALTER TABLE tests DROP CONSTRAINT IF EXISTS owl_type_check;
ALTER TABLE tests ADD CONSTRAINT owl_type_check
    CHECK (owl_type IN ('I', 'N', 'C', 'M'));

-- The Identity test this row's formal_spec/theorem is shared with.
-- NULL for 'I' rows (an Identity test IS its own root — nothing to point
-- to). NOT NULL for 'N'/'C'/'M' — every non-Identity owl must be able to
-- answer "which ground truth am I a transformation of?"
ALTER TABLE tests ADD COLUMN IF NOT EXISTS owl_root_id INTEGER REFERENCES tests(id);

-- 'N' and 'C' rows: what changed at the surface. Free text by design (this
-- taxonomy will grow with use); values anticipated so far:
-- lexical_substitution | narrative_reframing | domain_transfer |
-- unit_conversion.
ALTER TABLE tests ADD COLUMN IF NOT EXISTS owl_transform TEXT;

-- 'C' rows only: the SPECIFIC shortcut/pattern-match this item is built to
-- expose, in plain English — e.g. "surface keyword bait: premise contains
-- the word 'not' three times, priming a 'looks negative -> INVALID' guess
-- that is wrong here." This is what makes a 'C' row critical and not just
-- another paraphrase — the flaw is named, not implicit.
ALTER TABLE tests ADD COLUMN IF NOT EXISTS owl_flaw TEXT;

-- Group-closure rules, made checkable rather than left as metaphor:
ALTER TABLE tests DROP CONSTRAINT IF EXISTS owl_root_consistency;
ALTER TABLE tests ADD CONSTRAINT owl_root_consistency CHECK (
    (owl_type = 'I' AND owl_root_id IS NULL)
    OR (owl_type != 'I' AND owl_root_id IS NOT NULL)
);

ALTER TABLE tests DROP CONSTRAINT IF EXISTS owl_n_completeness;
ALTER TABLE tests ADD CONSTRAINT owl_n_completeness CHECK (
    owl_type != 'N' OR owl_transform IS NOT NULL
);

-- C = sigma_v . sigma_h in name only if it actually carries both halves:
-- a surface transform (like N) AND a named flaw (what M-scoring is meant
-- to catch it doing). A 'C' row missing either is just an 'N' row that
-- forgot to say why it's adversarial.
ALTER TABLE tests DROP CONSTRAINT IF EXISTS owl_c_completeness;
ALTER TABLE tests ADD CONSTRAINT owl_c_completeness CHECK (
    owl_type != 'C' OR (owl_transform IS NOT NULL AND owl_flaw IS NOT NULL)
);

CREATE INDEX IF NOT EXISTS idx_tests_owl_type ON tests(owl_type);
CREATE INDEX IF NOT EXISTS idx_tests_owl_root ON tests(owl_root_id);

-- ── Metacognitive scoring (the σₕ axis) ─────────────────────────────────
-- One row per trial. Evaluates the explanation the model ALREADY produced
-- (trial_results.reasoning_content, migration 018) — not a new question
-- asked of it, and not a second model asked to grade the first. This
-- project's hard rule, unchanged: "Objective verdict computation. No model
-- self-assessment, no opinion scoring" (src/executor/scoring.rs header).
-- cites_correct_rule is a deterministic keyword match against the test's
-- own name (scoring::score_metacognition) — auditable, re-derivable by
-- anyone reading the code, same discipline as score_response.
CREATE TABLE IF NOT EXISTS metacognitive_scores (
    id SERIAL PRIMARY KEY,
    trial_result_id INTEGER NOT NULL REFERENCES trial_results(id) ON DELETE CASCADE,
    cites_correct_rule BOOLEAN,        -- NULL = no reasoning_content to check
    acknowledges_uncertainty BOOLEAN,  -- NULL = reserved, not yet scored
    explains_distractor BOOLEAN,       -- NULL = reserved, not yet scored —
                                        -- see scoring.rs: deliberately not
                                        -- faked with a heuristic that would
                                        -- just be noise wearing a checkbox
    rubric_notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT one_score_per_trial UNIQUE (trial_result_id)
);

CREATE INDEX IF NOT EXISTS idx_metacognitive_scores_trial ON metacognitive_scores(trial_result_id);

-- ── Family coverage view — the Klein four-group made checkable ─────────
-- For each Identity test: does it have >=1 N sibling (anti-memorization
-- coverage) and >=1 C sibling (adversarial coverage)? A "fully
-- instrumented" family has both. This is what makes V4-completeness an
-- operational property of the test registry instead of a metaphor — query
-- it, don't just believe it. Immediately after this migration, EVERY row
-- will show zero N / zero C (no paraphrase or critical variants have been
-- written yet) — that's an honest starting state, not a bug.
CREATE OR REPLACE VIEW owl_family_coverage AS
SELECT
    i.id AS identity_id,
    i.name AS identity_name,
    i.axis,
    i.formal_spec,
    COUNT(*) FILTER (WHERE c.owl_type = 'N') AS non_normative_count,
    COUNT(*) FILTER (WHERE c.owl_type = 'C') AS critical_count,
    (COUNT(*) FILTER (WHERE c.owl_type = 'N') > 0
     AND COUNT(*) FILTER (WHERE c.owl_type = 'C') > 0) AS fully_instrumented
FROM tests i
LEFT JOIN tests c ON c.owl_root_id = i.id
WHERE i.owl_type = 'I'
GROUP BY i.id, i.name, i.axis, i.formal_spec
ORDER BY i.id;
