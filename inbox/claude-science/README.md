# Claude Science drop zone

Branch `claude-science`, directory `inbox/claude-science/`. Claude Science commits its deliverables HERE,
never to `main` (DECISIONS §2: CS is the independent validator, not a `main` author).
Hermes / Claude Code review and merge to `main` when ready.

Convention: CS pushes here; the authors relocate to final paths on merge. This is the
lo-fi shared drive that ends the download-courier loop — after a file lands here, both
bots read it from the branch, no re-download.

Current drops:
- EPISTEMIC_LOG.jsonl / EPISTEMIC_LOG_POLICY.md — the integrity log + policy (append-only; MERGE by timestamp union, never overwrite)
- carrier_color_experiment_spec_v1.md — paired Carrier Color re-run design
- channel_contamination_experiment_spec_v1.md — bridge-model channel experiment design
- carrier_color_analysis.py — validated McNemar+Holm analysis harness (self-test: `python carrier_color_analysis.py --self-test`)
