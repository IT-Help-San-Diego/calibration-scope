# RENAMING — the renameability contract

The product name ("Archetype Mesh" / `archetype-mesh`) is treated as a
**renameable constant**, not a baked-in identity. This document is the contract
that keeps it that way, so the product can be rebranded when the final
name/domain is chosen — without touching business logic.

## Why this matters

The user requires the entire product to stay **renameable and modular** so it
can be rebranded cleanly. A rename must be a mechanical string-swap in a few
anchored locations — never an architecture change.

## Where the name lives (the anchor points)

Verified 2026-07-19 by grep (~39 references total, but only ~4 are code
anchors; the rest are doc prose):

| File | Role | What to change |
|------|------|----------------|
| `Cargo.toml` | package name `archetype-mesh-benchmark`, binary `archetype-mesh-dashboard` | package + binary name |
| `src/main.rs` | process name; `ARCHETYPE_MESH_*` env prefix (e.g. `ARCHETYPE_MESH_DATABASE_URL`) | process name + env prefix |
| `assets/dashboard.html` | title string + visible labels | titled literals |
| `README.md` | 11 doc references | prose |

## Rename procedure (mechanical)

1. `Cargo.toml` → update `package.name` and `[[bin]] name`.
2. `src/main.rs` → update process name string + `ARCHETYPE_MESH_` env prefix
   (rename the prefix consistently; it is the config-key namespace).
3. `assets/dashboard.html` → global replace the visible product name in the
   title and labels.
4. `README.md` + other docs → global replace prose references.
5. `git grep` the old name → confirm zero code-logic references remain
   (doc references are fine if intentional).

Expected effort: ~15 minutes. No logic depends on the name as a magic string.

## Hard rule (enforced in review)

> Never hardcode the product name as a magic string inside business logic
> (e.g. `if config.name == "Archetype Mesh"`). The name belongs in:
> `Cargo.toml` (package/binary), `main.rs` (env prefix + process name), and
> titled string literals only.

If a code path ever needs the product name at runtime, it must read it from a
single configured constant (Cargo package metadata or a `main.rs` const), not
an inline literal scattered across modules.

## Domain note

Intended final domain: `archetypemesh.com` (NO "test" — earlier
`arctypemeshtest.com` was a throwaway example). The local-access subdomain
would be `local.archetypemesh.com A 127.0.0.1` (see
`docs/local-access-strategy.md`). Not yet registered (budget).

## Status

- Repo is already modular enough to rename (name anchored in ≤4 code files).
- No rename pending — this doc exists so the contract is preserved before the
  final name lands.
