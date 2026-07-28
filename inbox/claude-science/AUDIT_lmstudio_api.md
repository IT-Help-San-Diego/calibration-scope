# LM Studio API audit — where the instrument does not know what it loaded
_Claude Science, 2026-07-27. Read from `src/executor/lmstudio.rs` and `src/executor/mod.rs` at main._
_Carey asked whether the flip-flops trace to the tool not knowing the real loaded config. Substantially yes._

## 0. FIRST, A CORRECTION TO MY OWN FIRST READ
I initially concluded the tool sends only `{"model": key}` on load. **That was wrong** — I found it two call sites
later. `read_stored_model_default()` reads **your GUI-tuned presets** from
`~/.lmstudio/.internal/user-concrete-model-default-config/<model>.json` and merges them into the load body, with
**"stored values win on conflict."** So your presets *are* being honoured — partially. The gaps are narrower than
feared and more specific.

## 1. GAP 1 — the preset translator drops everything it doesn't recognise
`translate()` maps exactly **seven** dotted engine keys to load-API keys:
`contextLength`, `numExperts`, `evalBatchSize`, `physicalBatchSize`, `parallel`, `flashAttention`,
`offloadKvCacheToGpu`.
**Every other key in your saved preset is silently dropped.** There is no warning, no log line naming what was
discarded, and no record in the run of which preset keys were seen-but-unmapped. One drop is deliberate and
documented (`cpuThreadPoolSize` — the load endpoint rejects it with HTTP 400), which is good engineering; **the
silence about the rest is the defect.**

## 2. GAP 2 — the main experimental path records INTENT, not OBSERVED STATE
Two code paths persist `lmstudio_runtime_config`, and they store **different kinds of thing**:
| path | what it writes |
|---|---|
| **single-model** (clean-room / scaffolded — **what runs 974-978 used**) | `preset.to_load_json(...)` — **what we asked for** |
| speculative-pair | `fetch_instance_config(...)` — **what LM Studio reports** |
**The function that reads back reality already exists and is already used — on the path our experiments do not
take.** So for every powered run, the column labelled "runtime config" is our request, and a silent divergence
between request and reality is invisible by construction.

## 3. GAP 3 — "context length" in the model list is the ceiling, not the window
`LsModelInfo` declares `#[serde(rename = "max_context_length")] pub context_length: i64`. **The field named
`context_length` in our code is the model file's maximum**, a static property. It is not the context the instance
was loaded with. Any report of "context length" sourced from `/api/v0/models` is the ceiling.

## 4. SO WHO WAS RIGHT IN YOUR CONVERSATION WITH HERMES?
If you were reading the **LM Studio GUI** and Hermes was reading the **database column**, then **you were looking
at observed state and Hermes was looking at our recorded intent.** The GUI is evidence; the column is a plan.
Hermes "confirming they are different" is **exactly what Gap 2 predicts** — it is not a disagreement about facts,
it is two sources of different kinds being compared as if they were the same kind. **Neither of you was wrong
about what you saw. The instrument was wrong about what it knew.**

## 5. DOES THIS EXPLAIN THE RUN-LEVEL CONFOUND I FOUND AN HOUR AGO?
**It is now the leading candidate, and it is testable.** I found ~50 fully deterministic `6/6 → 0/6` reversals per
model between the baseline and Lean arms — including **51 on nemotron, whose net carrier effect is ~0**. Each arm
is one run, so **carrier is perfectly confounded with run**. If two runs loaded the same model under **different
effective configs** — different context window, different flash-attention or KV-offload state, different unmapped
preset keys — that would produce decisive per-item flips at temperature 0 with no carrier involved at all.
**Gap 2 is precisely why we cannot currently tell.** The column would report identical intent for both runs even
if the loads differed.

## 6. THE FIX, AND IT IS SMALL
1. **On the single-model path, call `fetch_instance_config()` after load and store THAT** — alongside the intent,
   not instead of it. Two columns: `requested` and `observed`. **The function already exists.** This is the
   highest-value change in the project right now: it makes the confound in §5 measurable instead of speculative.
2. **Log unmapped preset keys** when `translate()` returns `None`, into the run record. Silence is the defect.
3. **Rename `context_length` → `max_context_length`** in `LsModelInfo` so the ceiling cannot be mistaken for the
   window, and read the loaded window from the instance config instead.
4. **Retrospectively:** query `lmstudio_runtime_config` for runs 974, 975, 977, 978. If they are byte-identical
   that is consistent with — but does not prove — identical loads, because they record intent.

## 7. WHAT I AM NOT CLAIMING
- **I have not run LM Studio or queried the DB.** This is a source audit; every claim above is a statement about
  code I read, not about observed behaviour.
- I do **not** know whether LM Studio's `/api/v1/models/load` silently ignores unrecognised keys or errors on
  them; the code comment says one key errors, which implies at least some validation.
- **I have not verified that any run actually diverged.** §5 says the confound is *unmeasurable*, not that it
  occurred. Fix 1 is what would settle it.
- Speculative decoding for runs 974-978 was separately confirmed absent from **sealed per-trial evidence**
  (`spec_decode_artifact_ruled_out.json`), which is a stronger source than the config column.
