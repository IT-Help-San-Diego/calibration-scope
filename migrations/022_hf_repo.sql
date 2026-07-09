-- 022: models.hf_repo — verified link to the maker's own model card.
-- User mandate 2026-07-09: "they need to know what the makers say about it
-- and fact-based information, not from social media but from science."
-- The HuggingFace model card IS the maker's primary document, and the HF API
-- serves factual metadata (license, downloads, linked arXiv papers).
-- EVERY mapping below was verified live against https://huggingface.co/api/models/<repo>
-- (HTTP 200, following case-normalizing redirects) on 2026-07-09. Keys with
-- no verifiable public card (harmonic-hermes local builds, Anthropic cloud
-- models, embedding utility) stay NULL — honest absence, never a guessed URL.
ALTER TABLE models ADD COLUMN hf_repo TEXT;

UPDATE models SET hf_repo = v.repo FROM (VALUES
  ('qwen2.5-vl-7b-instruct',        'Qwen/Qwen2.5-VL-7B-Instruct'),
  ('qwen2.5-coder-7b-instruct-mlx', 'Qwen/Qwen2.5-Coder-7B-Instruct'),
  ('qwen2.5-7b-instruct-mlx',       'Qwen/Qwen2.5-7B-Instruct'),
  ('qwen/qwen3-vl-8b',              'Qwen/Qwen3-VL-8B-Instruct'),
  ('qwen/qwen3-vl-30b',             'Qwen/Qwen3-VL-30B-A3B-Instruct'),
  ('qwen/qwen3-coder-30b',          'Qwen/Qwen3-Coder-30B-A3B-Instruct'),
  ('qwen/qwen3.6-35b-a3b',          'Qwen/Qwen3.6-35B-A3B'),
  ('qwen3-coder-next-mlx',          'Qwen/Qwen3-Coder-Next'),
  ('llama-3.2-3b-instruct',         'meta-llama/Llama-3.2-3B-Instruct'),
  ('hermes-3-llama-3.1-8b',         'NousResearch/Hermes-3-Llama-3.1-8B'),
  ('hermes-4-14b',                  'NousResearch/Hermes-4-14B'),
  ('nousresearch/hermes-4-70b',     'NousResearch/Hermes-4-70B'),
  ('microsoft/phi-4-reasoning-plus','microsoft/Phi-4-reasoning-plus'),
  ('ibm/granite-3.2-8b',            'ibm-granite/granite-3.2-8b-instruct'),
  ('ibm/granite-4-h-tiny',          'ibm-granite/granite-4.0-h-tiny'),
  ('openai/gpt-oss-20b',            'openai/gpt-oss-20b'),
  ('openai/gpt-oss-120b',           'openai/gpt-oss-120b'),
  ('google/gemma-4-e2b',            'google/gemma-4-E2B-it'),
  ('google/gemma-4-31b',            'google/gemma-4-31B'),
  -- QAT variant's own repo is gated; the maker's instruction-tuned card is
  -- the authoritative public document for the model family.
  ('google/gemma-4-12b-qat',        'google/gemma-4-12b-it'),
  ('step-3.7-flash@bf16',           'stepfun-ai/Step-3.7-Flash'),
  ('step-3.7-flash@q8_0',           'stepfun-ai/Step-3.7-Flash'),
  ('zai-org/glm-4.6v-flash',        'zai-org/GLM-4.6V-Flash')
) AS v(key, repo)
WHERE models.key = v.key;
