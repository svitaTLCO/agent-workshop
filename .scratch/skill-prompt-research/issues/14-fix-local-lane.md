# Fix the local lane config for trials

Type: task
Status: open
Blocked by: 03

## Question

The probe (03) found the headroom proxy at `127.0.0.1:8787` routes to a dead DeepSeek upstream (every authed probe 401s), while the galene upstream itself is healthy: `Galene/LLM` (vLLM, Qwen3.8-27B-NVFP4) answered a direct call ~0.4s warm with full usage accounting. Repoint the service's target at the galene endpoint (`api-tlco.elettra.ai/v1`, using the stored key location noted in the 03 findings) and verify end-to-end: `/v1/models` advertises `Galene/LLM` and a minimal chat completion returns 200 with `usage` tokens. Record the config change made and the verified call recipe. Never persist secret values into the repo.
