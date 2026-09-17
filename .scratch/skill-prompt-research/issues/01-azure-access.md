# Secure a working Azure model endpoint for trials

Type: task
Status: resolved

## Question

Trials run on a pinned Azure model as the ruler (map Notes). The env exposes `AZURE_COGNITIVE_SERVICES_RESOURCE_NAME`, but no API key is visible in the environment and the `az` CLI is not installed. Establish a working, repeatable call path to an Azure model deployment and record:

- Endpoint URL and auth mechanism (env var name/location for the key — never the value)
- Which model deployments/versions exist and which suit a pinned baseline
- An exact call recipe (curl or SDK snippet) a harness script can reuse

Look first at project `.env` files and existing config; only if a key must be obtained does the human get a precise portal/CLI checklist. The resolution records the facts tickets 04 and 06 depend on: credential location, pinned model id, call recipe.

## Recon (2026-09-17)

Credential source found (authorized): `/home/adminmatto/progetti/rd/radix-db-exporter/.env` vars `AZURE_OPENAI_ENDPOINT` / `AZURE_OPENAI_API_KEY` / `AZURE_OPENAI_API_VERSION`. Copied (values never printed) into **`~/.config/agent-workshop/eval-azure.env`** as `AZURE_EVAL_*` (mode 600, outside repo tree). Radix's own code uses the stock `openai` SDK `AzureOpenAI(endpoint, api_key, api_version)` → deployment-path REST.

Verified with that key:
- `GET {endpoint}/openai/models?api-version=2024-12-01-preview` → HTTP 200, **444 catalog models** (gpt-5.x/5.6, gpt-6-astra, claude-sonnet-5, DeepSeek-V3.2/V4, grok, Kimi, Llama-4, qwen, Mistral, Phi, MAI, …). This list is the Foundry hub *catalog*, not local deployments.
- AAD client-credentials token from the same .env works, but `GET /subscriptions` returns an empty list → no ARM visibility, cannot enumerate or create deployments.

Blocker: **no model is invokable.** ~30 probes all returned 404 `DeploymentNotFound` (auth itself fine — bad key gives 401):
- routes tried: `/openai/deployments/{m}/chat/completions` and `/openai/v1/chat/completions`, plus `/openai/chat/completions` with model-in-body
- auth tried: `api-key:` header and `Authorization: Bearer`
- api-versions: 2024-12-01-preview, 2025-03-01-preview, 2024-06-01
- 25+ diverse GA catalog ids (gpt-5.2-chat-2026-02-10, gpt-5.5-2026-04-24, gpt-6-astra-2026-09-03, claude-sonnet-5-2, qwen3-32b-v2, DeepSeek-V3.2-Speciale, Llama-4-Maverick…, aliases + dated names)
- `AZURE_OPENAI_COMPANION_PREVIEW_DEPLOYMENT` in radix .env is set but EMPTY; live model targets live in postgres `llm_routing_config.model_target`, unreachable locally.

Call recipe (ready to run once ANY model resolves), harness-friendly, secrets stay in shell vars:
```bash
set -a; source ~/.config/agent-workshop/eval-azure.env; set +a
curl -sS "$AZURE_EVAL_ENDPOINT/openai/deployments/{MODEL}/chat/completions?api-version=$AZURE_EVAL_API_VERSION" \
  -H "api-key: $AZURE_EVAL_API_KEY" -H 'Content-Type: application/json' \
  -d '{"messages":[{"role":"user","content":"…"}],"max_tokens":N}'
# expect 200 + usage.{prompt_tokens,completion_tokens,total_tokens}
```

The 404 matrix above was wrong only by sampling: the hub's real local deployments are the **gpt-5.4 family** (user-read from the portal; the rest of the paste was truncated — treat this list as verified set, not exhaustive):

## Answer

Verified 2026-09-17 with live completions (each returned 200 + full `usage.{prompt_tokens,completion_tokens,total_tokens}`):

| deployment | resolves to | prompt/compl tokens ("Reply OK", cap 10) |
|---|---|---|
| `gpt-5.4` | `gpt-5.4-2026-03-05` | 11 / 4 |
| `gpt-5.4-mini` | `gpt-5.4-mini-2026-03-17` | 11 / 4 |
| `gpt-5.4-nano` | `gpt-5.4-nano-2026-03-17` | 11 / 4 |

Suggested roles for the harness (final pick is "Decide the harness architecture"): **ruler = `gpt-5.4`**, cheap bulk workhorse = `gpt-5.4-mini`.

Call recipe (determinism knobs verified working on `gpt-5.4`):
```bash
set -a; source ~/.config/agent-workshop/eval-azure.env; set +a   # AZURE_EVAL_ENDPOINT/API_KEY/API_VERSION, mode 600
curl -sS "$AZURE_EVAL_ENDPOINT/openai/deployments/gpt-5.4/chat/completions?api-version=$AZURE_EVAL_API_VERSION" \
  -H "api-key: $AZURE_EVAL_API_KEY" -H 'Content-Type: application/json' \
  -d '{"messages":[…],"max_completion_tokens":N,"temperature":0}'        # temperature ✓
  # response_format:{"type":"json_object"} ✓ for structured judge output
```
GPT-5.x gotchas baked into the recipe: use `max_completion_tokens` (NOT `max_tokens` → `unsupported_parameter`); auth via `api-key:` header; no secrets in repo (key lives only in the env file above, copied from `radix-db-exporter/.env`).
