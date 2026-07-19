# LM Studio v1 REST API — Verified Contract (Calibration Scope foundation research)

Researched 2026-07-19 from official LM Studio docs (lmstudio.ai/docs/developer/rest)
+ live probes against the local LM Studio server at http://127.0.0.1:1234.
This is the source of truth for any future "download models from the dashboard"
feature. Every claim below was either doc-verified or live-probed.

## Verified endpoints

| Endpoint | Method | Purpose | Verified |
|---|---|---|---|
| `/api/v1/models` | GET | List all models (downloaded + loaded). Returns `{models:[...]}`. | ✅ live (empty now) |
| `/api/v1/models/load` | POST | Load model to RAM. Body: `model`, `context_length`, `flash_attention`, `eval_batch_size`, `offload_kv_cache_to_gpu`, `echo_load_config`. | ✅ doc (Calibration Scope uses this) |
| `/api/v1/models/unload` | POST | Unload by `instance_id`. | ✅ doc |
| `/api/v1/models/download` | POST | Download a model. Body: `model` (HF link or catalog id), `quantization` (HF only). | ✅ doc |
| `/api/v1/models/download/status/:job_id` | GET | Download progress. | ✅ doc |
| `/api/v1/chat` | POST | Chat. `stream:true` → SSE events. `integrations` → ephemeral MCP servers. | ✅ doc |

## Download flow (the important one)

`POST /api/v1/models/download` response (immediate, NOT after download):
```json
{ "job_id": "job_493c7c9ded", "status": "downloading",
  "total_size_bytes": 2279145003, "started_at": "2025-10-03T15:33:23.496Z" }
```
- `job_id` is present only when `status: "downloading"`. If `status: "already_downloaded"`,
  `job_id` is absent.
- `total_size_bytes` is available IMMEDIATELY in the POST response — we do not have to
  wait for the download to compute size. This is the real, honest size-on-disk source.

`GET /api/v1/models/download/status/:job_id`:
```json
{ "job_id": "...", "status": "downloading",           // downloading|paused|completed|failed
  "bytes_per_second": 1234567,                         // present while downloading
  "estimated_completion": "2025-10-03T15:43:12Z",      // present while downloading
  "total_size_bytes": 2279145003,
  "downloaded_bytes": 1139572501,                      // live progress
  "started_at": "...", "completed_at": "..." }         // completed_at when done
```

## Lightweight? YES.
- All calls are JSON over localhost:1234. Zero file I/O on our side — LM Studio writes
  the bytes into its own content-addressed blob store.
- Progress polling is event-driven: only poll `download/status` for jobs WE started
  (we hold the `job_id`). When no downloads are active, the poller does nothing.
- This satisfies the "lightweight, won't bog down the tool" requirement.

## GAPS (smells we found — documented, not hidden)

1. **No "list all downloads" endpoint.** `GET /api/v1/models/download/status` (no job_id)
   → 404 (live-probed). `GET /api/v1/models/download` → 404. So we can ONLY track
   downloads WE initiate (where we hold the job_id). GUI-initiated downloads in LM Studio
   have no job_id we can see → they stay `—` (size unknown) + `⏳ Incomplete` gated until
   fully on disk. This is acceptable and honest.

2. **Cancel / pause via REST is UNVERIFIED.** The `status` field can be `"paused"`, but
   the REST route to trigger pause/cancel is NOT in the v1 docs. Live probes:
   `DELETE /api/v1/models/download/status/job_x` → 404.
   `POST .../status/job_x` (body cancel) → 415.
   → **We will NOT offer an in-tool pause/cancel button.** Instead we tell the user:
     "If you need to pause, use your LM Studio downloader window." This is honest and the
     GUI pause DOES reflect in LM Studio (to be empirically confirmed in first live test).

3. **`/api/v0/models` (legacy) has NO size field.** Open feature request #156 (Dec 2024,
   still unresolved). Local GGUF bytes live in `~/Library/Application Support/LM Studio/
   blob_storage/<hashed-dir>/` — content-addressed, no readable .gguf filenames. So disk
   size reading is impossible without hacking LM Studio internals (forbidden). The
   download/status `total_size_bytes` is the ONLY legitimate size source.

4. **Cloud providers (OpenRouter verified live) send NO size/param-count** — only
   context_length, pricing, modality. So cloud `size_gb` stays `—` permanently.

## Foundation decision (2026-07-19)
- `size_gb` is nullable in the DB. Display `—` when null/0 (commit de6a667).
- For OUR downloads: capture `total_size_bytes` → write `size_gb`. Real, honest.
- For GUI downloads + all cloud: `—`. No fabrication, no derivation.
- Demo Bots click-to-download = ENDORSED foundation feature. Build backend pipeline +
  this contract doc first; Demo Bots UI after live verification.
