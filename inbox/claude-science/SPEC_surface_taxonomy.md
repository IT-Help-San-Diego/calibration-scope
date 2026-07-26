# Surface taxonomy — where prompt provenance is obtainable, and where asking is worse than useless
_Claude Science, 2026-07-26. Answering "what surfaces will users encounter on their Mac/Linux box."_
_Grounded in what calibration-scope actually supports, read from src/ first-hand._

## 0. A FALSE NEGATIVE OF MY OWN, FLAGGED FIRST
I probed for config files that hold system prompts (`~/.hermes/config.yaml`, `~/.ollama`, LM Studio's app
support dir, `~/.claude.json`, …) and every one came back **absent**. **That result is worthless.** I then
checked whether I can list the home directory at all: **I cannot** — my grants cover only `~/Downloads`,
`~/Documents/GitHub`, `~/My Drive`, `~/Pictures/Screenshots`. So "absent" means *"outside my sandbox,"* not
*"not on the machine."* Reporting it as evidence would have been a fabricated negative.
**This matters for the design, not just for my honesty:** a tool that reads config files to establish provenance
hits the same wall — **macOS permission scoping**. A GUI app cannot silently read `~/.config/*` for other
vendors' apps without a user-granted permission, and if it asks, the user grants it blind. Config-scraping is
not a reliable provenance mechanism. That kills the most obvious "just read it" answer before we build on it.

## 1. WHAT THE TOOL ACTUALLY TALKS TO (verified from `src/`)
Provider references in the codebase: **gemini (12), nous (11), openrouter (10), openai (10), lmstudio (2)**.
`load_mode` values in code and migrations: exactly **`clean-room` | `scaffolded`**.
**Every native provider is an API provider.** That single fact reorganizes the whole problem.

## 2. THE SURFACE TAXONOMY — four tiers, by whether provenance is OBTAINABLE
| Tier | Surface | Who authors the system prompt | Provenance | What claims the data supports |
|---|---|---|---|---|
| **P0** | Cloud API (openai / gemini / openrouter / nous) | **we do, byte-for-byte** | **TOTAL** | anything, including cross-model comparison |
| **P1** | Local runner with an HTTP API (LM Studio, Ollama, llama.cpp, vLLM) | **we do**, via the API — the runner's own preset is *overridden* by the request | **TOTAL when we send an explicit system message; UNKNOWN if we send none** | same as P0, *conditional on always sending an explicit system field* |
| **P2** | Desktop chat app (Claude Desktop, ChatGPT app, Hermes Desktop) | **vendor + possibly user custom instructions**, unpublished and version-drifting | **IMPOSSIBLE** | within-subject / paired only; never cross-vendor capability claims |
| **P3** | Web chat UI | same as P2 plus session state, A/B assignment, retrieval | **IMPOSSIBLE and unstable** | shakedown / feasibility only |
**The critical line is between P1 and P2, and it is not "local vs cloud" — it is "does the harness author the
prompt."** A local model in LM Studio is P1 because we control the request. The same weights driven through a
chat UI are P2.
### The P1 trap worth naming
LM Studio and Ollama both let a user save a **system-prompt preset** in the UI. If our request omits the system
field, that preset applies silently and we are in P2 while believing we are in P1. **Rule: always send an
explicit system message — including an explicitly empty one — never omit the field.** That is a two-line code
requirement and it is the difference between total and unknown provenance for the entire local path.

## 3. THE REFRAME THAT DISSOLVES CAREY'S PROBLEM
Carey: *"Maybe someone is using Claude and Desktop and Claude is the only thing they have. Claude is going to be
the thing they say, 'Help me get this downloaded and installed.' … It shouldn't matter. It should be the same
process."*
**He is right, and the reason he is right is that those are two different roles:**
- **OPERATOR** — the human's assistant that helps them install, configure, and interpret. ChatGPT, Claude
  Desktop, Hermes, a friend, a YouTube video. **The operator is out-of-band. It is never measured.** Its system
  prompt is irrelevant because it never answers a test item.
- **SUBJECT** — whatever the harness sends items to over an API. **Provenance is total by construction.**
So "what's your system prompt?" is a question about the **operator**, and the operator does not matter. **We
should not ask it.** The install path can be ChatGPT, Claude, Hermes, or a printed sheet of paper — the
measurement is identical, because the subject is reached through our own API call either way.
**Asking is worse than useless:** it invites a confident wrong answer (Carey's point — no user tracks
"before/after this morning" edits), it implies the answer affects validity, and a recorded-but-false declaration
is *more* corrupting than an honest `unknown`, because it looks like provenance.

## 4. SO WHERE DOES THE PROBLEM ACTUALLY LIVE? ONLY IN P2/P3 — THE MANUAL CHANNEL
The manual paste channel exists precisely for models with no API. That channel is P2 **by definition** and no
schema field fixes it. The honest architecture:
1. **Tag every run with its tier** (`provenance_tier`: P0/P1/P2/P3) — computed by the harness from the code path
   taken, **not declared by the user.** A field the user cannot fill in cannot be filled in wrong.
2. **Tier gates the claim, in code.** P2/P3 runs are admissible for within-subject paired comparisons and
   excluded from cross-model leaderboards by the same mechanism that already excludes quarantined runs.
3. **For P1, assert the override** — send an explicit system field always; record `system_prompt_sha256` of what
   *we sent*. That is a fact about our own request, verifiable, not a claim about someone's hidden state.
4. **Never ask the user for their system prompt.** Ask instead: *"which app will the model answer in?"* — a
   question about a **surface**, which users can answer correctly, and which determines the tier deterministically.
**That is the whole fix, and it removes the human from the trust path.**

## 5. CAREY'S TWO OPEN EMPIRICAL QUESTIONS — both now testable, one already specced
### (a) "Have people been fighting reality all along by writing system prompts?"
Genuinely unknown, and **not answerable from the current record.** It is exactly `SPEC_reconciliation_cost.md`
H1/H2/H3: does a prompt layer cost tokens, does conflict cost more, and does an opinionated prompt *buy*
accuracy (permission-grant) or merely tax it. **768 API calls.** Until then the honest position is: nobody
knows, including the vendors.
### (b) "Hermes Desktop has no system-prompt field — I can't confirm that."
**Correct to withhold it, and worth checking properly, because it is a vendor design datum.** A vendor that
deliberately omits the field is either (i) implementing the anti-scaffolding thesis, or (ii) hiding the layer.
**This is verifiable from primary sources** — the Nous Research docs and the open-source `hermes-agent` repo —
not from clicking around a UI. Per the house standard: primary source first, then audit it against behaviour.
If Hermes truly has no user prompt layer, it is the **natural P1 control** for the reconciliation experiment: a
subject with one fewer layer by construction.

## 6. WHAT I AM NOT CLAIMING
- I have **not** verified any config-file location on this machine (§0) — the sandbox blocks it, and the paths I
  listed are candidates from memory, not observations.
- The provider counts in §1 are **occurrence counts of string literals in `src/`**, which establish that a
  provider is referenced, not that its integration is complete. Earlier this session Claude Code reported that
  `annotate_runnable` leaves openrouter/openai/gemini permanently `runnable=false` — so "referenced" and
  "working" differ, and that relay item is still open.
- The P0/P1 "TOTAL provenance" claim assumes the vendor honours the API's system field and injects nothing of its
  own. For an OpenAI-compatible local runner that is safe. **For a hosted API it is an assumption, not a
  verified fact** — and it is the one thing in this taxonomy that a determined audit should test (a canary item
  that would answer differently under an injected safety preamble).
