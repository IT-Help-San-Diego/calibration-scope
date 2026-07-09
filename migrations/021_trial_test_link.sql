-- 021: trial_results.test_id — real provenance linkage, not string parsing.
-- User mandate 2026-07-09: "easily scientific, trackable, traceable artifacts".
-- Until now a trial could only be tied to its test by inferring from the
-- detail string. That's inference, not linkage. Every trial now carries a
-- foreign key to the exact test (prompt + pinned attachment + ground truth)
-- it executed. Historical rows stay NULL — honest: we don't invent provenance
-- for evidence recorded before the link existed.
ALTER TABLE trial_results ADD COLUMN test_id INTEGER REFERENCES tests(id);
CREATE INDEX idx_trial_results_test ON trial_results (test_id);
