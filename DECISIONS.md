# DECISIONS — cross-agent source of truth

This file is the **shared brain** for the humans and AI agents working on
Calibration Scope. The two AI agents have **separate memories** and cannot read
each other's minds; the git repo is the only substrate both can see. **If a
decision matters, it lives here.** Read this first; append to it when a decision
is made.

- **Claude Code** — authors the repo: code, tests, migrations, the running
  instrument. Commits directly to `main`. Fast loop.
- **Claude Science** — the lab + packaging + remote compute: analysis/figures,
  open-science packaging (data package, DOI, ontology crosswalk), and heavy
  remote jobs (e.g. the seL4 build/boot on AWS). Produces **artifacts**; does
  **not** have commit access and by design stays out of the commit path so it
  remains an independent validation stage.
- **The human (Carey)** — the router. Relays decisions between the two agents
  and holds final say. This is a legitimate, auditable design for two
  separate-memory agents, not a workaround.

> Ethos (applies to every decision below): **accuracy before speed, validation
> before trust.** Don't trust a fix — gate it. Aspire to seL4-level: machine-
> checked, not asserted.

---

## Workflow policy (decided 2026-07-21)

- **`main`-direct.** Claude Code commits straight to `main` (matching the Hermes
  agent's workflow). PRs are optional, used only when a second set of eyes is
  wanted before merge.
- **The logic ground-truth verifier gates the science.** Before trusting any
  change to the test battery or the seeded ground truths, the complete
  decision-procedure verifier must pass (see below). This is the seL4 discipline
  applied to our own repo.
- **Handoff is files through git.** When Claude Science produces something meant
  to live in the repo (`datapackage.json`, `CITATION.cff`, a validated build
  log), Claude Code commits it. When Claude Code changes the schema or battery,
  Claude Science reads the committed state from GitHub and re-runs against it.

---

## Repo / instrument state (Claude Code, updated 2026-07-21)

Two adversarially-verified audit sweeps of the foundations have been remediated
and merged to `main` (PR #1, merge `3261a85`). Highlights:

- **Anti-cheat (answer leakage) fixed.** Scaffolded runs were pasting each
  test's `formal_spec` — whose `⊢`/`⊬` turnstile *is* the VALID/INVALID answer —
  into the model's prompt. Replaced with a **leak-free scaffold**: the argument
  form as an open question (`⊢?`), verdict withheld — the legitimate "you seem
  weak here, look at this structure" hint. 6 unit tests prove no verdict leaks.
  The 27 contaminated `scaffolded` runs are quarantined
  (`answer_leak_contamination`); the **508 clean-room runs — the real science —
  were never contaminated.**
- **Quarantine fixed** to fire only when infra noise *dominates* a run, so a
  perfect run is never hidden for one infra blip (migrations 044–046 reconciled
  history; run 915 restored).
- **Fabricated "3× / 88%" spec-decode metric removed** — now aggregated from
  real persisted draft-token counters.
- **Security:** DNS-rebinding Host-header guard; `/api/cloud-keys` no longer
  leaks the secrets path or key prefixes.
- Plus ~15 correctness fixes (spec-decode v0 counters, Run-Just-This axis
  filter, fountain verdicts, scoring parse, identifier normalization, …).
- **Status:** 92 tests pass, clippy clean.

### Known-open (Claude Code, next up)
1. Remaining test-battery data fixes (VVP-01 prompt leak, fib `\n`,
   substring-scored numerics, fallacy label mismatches).
3. Provenance sealing (I3/I6) — test fields editable after seal; aborted/errored
   runs unsealed.
4. Aggregate honesty — exclude `scaffolded` runs from leaderboards; PASS-RATE
   dial relabel.
5. **GUI magic** — replace the duplicate-ID `cloneNode` Focused mode with a
   single-source render; make the spec-stream (lean formulas) *pop*; clear
   "loaded / running" indicators.
6. Strategic refactors (green-lit): runtime seam for ollama/llama.cpp; dashboard
   split; trial-granular quarantine; unify config-scan/normalizer/DB/executor.

---

## Logic ground-truth verifier (the seL4-style gate)

`scripts/verify_logic_ground_truth.py` — a **complete decision procedure**
(exhaustive truth-tables for propositional tests; finite-model search with the
finite-model-property justification for monadic FOL; every INVALID backed by an
explicit countermodel). It proves the seeded logic ground truths are logically
correct — nobody takes them on faith. Currently **28/28 verified**.

Run: `python3 scripts/verify_logic_ground_truth.py` (exit 0 = all correct).
Live-DB drift check: `... --check-owl-families` (needs `DATABASE_URL`).

**Now enforced in CI** (`.github/workflows/ci.yml`): both the offline decision
procedure and the owl-family live-DB check run on every push/PR, so `main`
cannot regress a logic ground truth. _Future deepening: parse EVERY logic test's
`formal_spec` from the live DB and re-derive its verdict, so a NEW test (not in
the hardcoded battery) is validated too._

---

## Compute / seL4 (Claude Science domain — maintained by relay)

> Claude Code cannot see the EC2 box or Claude Science's artifacts directly.
> These entries are relayed by Carey; Claude Science should correct/extend them.

- An **EC2 box is running** an seL4 build/boot pipeline (public
  `seL4/rust-root-task-demo` clone on the remote box — independent of this repo).
- A **validated `image.elf`** was produced and a **`TEST_PASS`** observed.
- _(Claude Science: fill in the compute lifecycle — instance type, cost posture,
  start/stop policy, where the validated artifacts live, and the seL4
  proof/build steps.)_

## Open-science roadmap (from `ingest/artifacts/DIRECTION_open_science.md`)

Ship the instrument as a **citable dataset + standard schema + importable
client**, in neuroscientists' vocabulary:
1. Frictionless `datapackage.json` alongside every CSV export.
2. Zenodo DOI + `CITATION.cff`.
3. A thin `calibration-scope-py` (PyPI) client + the planned MCP server layer.
4. `ontology_crosswalk.json`: test family → cognitive construct → Cognitive
   Atlas / NeuroVault — the human⇄silicon crossover, made queryable.

_(Note: the `ingest/` folder is an idea dumping-ground. Anything validated and
kept should be moved to its proper home — e.g. the verifier → `scripts/`.)_

---

## Operational notes (Claude Code)

- Service is launchd-managed (`ai.hermes.calibration-scope-dashboard`); serves
  `assets/dashboard.html` from disk (UI edits live without rebuild). Rust changes
  need `cargo build --release` + restart. Project enforces **0 clippy warnings**.
- LM Studio spec-decode counters are only in `/api/v0/chat/completions` `usage`
  (`accepted_draft_tokens_count`), never in `/v1`.
- Known gotcha: a freshly-built binary can stall the **launchd exec** in a macOS
  security scan (`dyld3::open`); the same binary runs fine in a foreground
  shell. Recovers after the scan settles / a reboot.
