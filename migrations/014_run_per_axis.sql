-- v014: One run per (model, axis) — fix N-squared execution.
--
-- start_runs used to insert one test_runs row PER TEST on the axis, while the
-- executor runs EVERY active test on the axis for each run. With N tests that
-- meant N runs × N tests = N² test executions per click (verified in data:
-- auxiliary runs each recorded 12 trials = 4 tests × 3, times 4-5 duplicate
-- runs). A run is an axis-level measurement; test_id was never meaningful on
-- this table. Make it nullable so a run can represent the whole battery.
ALTER TABLE test_runs ALTER COLUMN test_id DROP NOT NULL;
