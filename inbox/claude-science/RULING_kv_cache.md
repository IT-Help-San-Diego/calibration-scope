# The KV-cache question: two different knobs, and our own note conflates them
_Claude Science, 2026-07-30. Prompted by a Reddit report Carey flagged as low-trust._

## I could not read the thread

`www.reddit.com` was allowlisted on request, and the fetch returned **HTTP 403 with a
network-security block page** — 190 KB of HTML, zero occurrences of `quant`, `KV`, `cache`, or
`Qwen`. Reddit's bot protection, not our sandbox. **I did not spoof a browser User-Agent to get
around it.** So everything below is from our own repository; the Reddit claim is treated as an
untrusted lead to test, which is how Carey framed it and the right framing regardless.

## The distinction that makes the claim relevant to us

| knob | what it changes | lossy? |
|---|---|---|
| `offload_kv_cache_to_gpu` | **where** the KV cache lives — VRAM vs system RAM | **no** — same numbers, different memory |
| KV cache **quantization** | the **precision** of stored K/V tensors (fp16 → q8_0 → q4_0) | **yes, by construction** |

**These are not the same lever, and only the first one is in our code.**
`src/executor/lmstudio.rs` sends `offload_kv_cache_to_gpu: true` and **never sets a cache type**.
`docs/lm-studio-api-notes.md` documents no KV-precision key on `/api/v1/models/load` at all.

## The defect in our own documentation

`docs/benchmark-note-engine-tuning-neutral.md` states that adjusting `context_length`,
`eval_batch_size`, `physical_batch_size`, `parallel`, `flash_attention`,
**`offload_kv_cache_to_gpu`** and `speculative_draft_model` *"does not change a model's reasoning
accuracy… These are speed levers, not capability levers."*

**That claim is about placement and it is almost certainly right about placement.** But the note
never distinguishes placement from precision, and `offload_kv_cache_to_gpu` has "kv_cache" in its
name. **A reader — including any of us, three weeks from now — takes that sentence as covering KV
cache quantization. It does not.** Precision is lossy by construction; a knob that changes the
numbers attention reads is a capability lever by definition, whether or not the effect is large.

**This is the fourth document in this project found asserting more than it established.** The fix is
one clause, not an experiment.

## What we run at is unknown — and already recorded

Because no cache type is set, the engine default applies. **If LM Studio defaults KV to fp16, the
Reddit claim does not touch our data at all. If it defaults to q8_0, every measurement in this
project was taken with a quantized KV cache** — including the carrier-colour contrast, the
replicate, and every security verdict. **I cannot tell which from the repository.**

**But we may not need an experiment to find out.** Migration `055_observed_lmstudio_config.sql`
added `test_runs.lmstudio_observed_config JSONB` — *what LM Studio actually loaded*, read back from
`/api/v1/models` after load, explicitly to make "run-level config divergence measurable rather than
speculative." **If LM Studio reports a KV precision field, every run since 055 already carries it.**

One query answers it:

```sql
SELECT DISTINCT jsonb_object_keys(lmstudio_observed_config)
  FROM test_runs WHERE lmstudio_observed_config IS NOT NULL;
```

- **A KV-precision key exists** → read its values per run. Question answered from sealed data, zero
  machine time.
- **No such key** → LM Studio does not report it, and answering needs an experiment.

## If an experiment is needed, it is cheap and it is a real result either way

Same battery, same model, temp 0, 6 reps, one arm per KV precision. **This project is unusually well
equipped to run it**, because run 985 established that e2b replays byte-for-byte under fixed
conditions — so *any* difference between KV-precision arms is attributable, not noise. That is a
sharper instrument for this question than the Reddit poster's impression, and it produces a number
where they had "night and day."

**And it tests our own published claim**, since the engine-tuning note is a public document.

## What I have NOT established

- **I have not read the Reddit thread or its comments.** Blocked at Reddit's end. So I cannot say
  whether the poster controlled for anything, what "night and day" meant, or whether commenters
  contradicted them.
- **I do not know LM Studio's default KV precision.** That is the whole open question; I am not
  guessing at it.
- **I have not confirmed that `lmstudio_observed_config` contains any KV field** — I confirmed the
  column exists and what it is for. Whether LM Studio populates a precision key is exactly what the
  query above is for.
- **No claim that KV quantization does or does not affect accuracy.** The literature-grade version
  of that question is open here; what I have established is that *our note does not answer it and
  reads as though it does.*
