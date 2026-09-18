# Fix the local lane config for trials

Type: task
Status: resolved
Blocked by: 03

## Question

The probe (03) found the headroom proxy at `127.0.0.1:8787` routes to a dead DeepSeek upstream (every authed probe 401s), while the galene upstream itself is healthy: `Galene/LLM` (vLLM, Qwen3.8-27B-NVFP4) answered a direct call ~0.4s warm with full usage accounting. Repoint the service's target at the galene endpoint (`api-tlco.elettra.ai/v1`, using the stored key location noted in the 03 findings) and verify end-to-end: `/v1/models` advertises `Galene/LLM` and a minimal chat completion returns 200 with `usage` tokens. Record the config change made and the verified call recipe. Never persist secret values into the repo.

## Answer

Resolved 2026-09-17. Applied option 1 from the 03 findings.

**Config change (one line, outside the repo):** `~/.config/systemd/user/headroom.service` `[Service]` — `Environment=OPENAI_TARGET_API_URL=https://api.deepseek.com` → `Environment=OPENAI_TARGET_API_URL=https://api-tlco.elettra.ai/v1`; then `systemctl --user daemon-reload && systemctl --user restart headroom`. Before-state recorded in this ticket's history (DeepSeek target confirmed in unit file and process environ). Service active; new MainPID's environ carries the new target; listener back on `127.0.0.1:8787` (loopback-only unchanged). No key material added to the service — the proxy forwards the caller's bearer verbatim, so clients keep supplying the key from env, per the 03 findings.

**Verification (run, not assumed — through the lane, not upstream direct):**
- Warm-up `GET /v1/models` with the stored galene key (extracted in-session from the 03-noted location `~/.local/share/opencode/auth.json` `.galeneai.key`, length 68, value never printed): HTTP 200 in 8.5 s cold (matches the ≥10 s cold-start finding); advertised ids `Galene/LLM`, `Galene/Embedding-Multimodal`.
- `POST /v1/chat/completions` `{"model":"Galene/LLM","max_tokens":64}` via `http://127.0.0.1:8787/v1`: HTTP 200, `finish_reason:"stop"`, content `"ok"`, `usage:{prompt_tokens:57, completion_tokens:24 (reasoning_tokens:20), total_tokens:81}` — the ~50-token fixed prompt-wrap and the reasoning-first behavior both reproduced through the proxy. Usage pass-through through headroom is now VERIFIED end-to-end (was labeled INFERENCE in 03).

**Call recipe (verified verbatim shape):** base `http://127.0.0.1:8787/v1` (ends in `/v1`, don't double-prefix); header `Authorization: Bearer <galeneai key>`; optional `X-Client: harness`; body OpenAI `chat.completions`, `model:"Galene/LLM"`; read `choices[0].message.content` + `usage.*`. Key handling: extract to a 0600 env file in `/tmp/opencode` (transient, deleted after this session) or hold in-process — never committed, never echoed. Scripts used this session: `/tmp/opencode/lane-key.py`, `/tmp/opencode/lane-verify.sh` (throwaway, outside the repo).

**Residual:** declared limits (120k ctx / 81.9k out) still UNVERIFIED — first real ceiling hit happens in the harness (06/07); proxy has no budget governor (`headroom doctor`), so the harness remains the only spend control (feeds the trial-spend-cap fog item).
