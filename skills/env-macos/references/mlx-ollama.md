# macOS MLX/Ollama reference — load only when tuning local inference

## brew services lifecycle

```bash
brew services list              # state of ollama + friends
brew services start ollama      # launch now + on login
brew services restart ollama    # after config changes
brew logs ollama --last 50      # why is it not answering?
```

## Ollama knobs (env for the service)

Set before `brew services restart ollama` (or in `~/.config/ollama/ollama.env`):

| Variable | Use |
|---|---|
| `OLLAMA_HOST` | bind address; keep `127.0.0.1:11434` for agent-only use |
| `OLLAMA_KEEP_ALIVE` | e.g. `30m` so models stay resident between tasks |
| `OLLAMA_NUM_PARALLEL` | concurrent requests; leave 1–2 unless RAM is huge |
| `OLLAMA_MAX_LOADED_MODELS` | 1 unless you deliberately juggle two model sizes |

Per-request context: API `options.num_ctx` (or Modelfile `NUM_CTX`). Local ctx should stay ≤ what RAM allows after weights; KV cache grows linearly with ctx length.

## Sizing rule of thumb

4-bit weights ≈ bytes-per-param 0.5–0.6 → 30B ≈ 18 GB weights + KV/headroom → needs 32 GB unified. If `verify-macos.sh` WARNs on RAM, drop one tier in `local-models`.

## mlx_lm.server alternative

```bash
pip install mlx-lm
mlx_lm.server --model <hf-tag-with--mlx-suffix> --host 127.0.0.1 --port 8080 \
  --chat-template auto            # run `--help` first; flag set moves fast
```

Point the same OpenAI-compatible baseURL at `http://localhost:8080/v1`. Tool calling requires a tool-capable checkpoint; chat-only tags will silently ignore tools.

## Long-run power settings

```bash
caffeinate -dims bash -c '<agent session>'     # sleep-blocked for its duration
pmset -g batt                                   # verify battery/AC state first
```

Do not edit `pmset -a ...` defaults without an explicit ask; they persist after the task.
