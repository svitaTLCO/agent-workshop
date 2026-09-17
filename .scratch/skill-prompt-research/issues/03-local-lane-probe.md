# Probe the local model lane (galene via 127.0.0.1:8787)

Type: research
Status: resolved

## Question

The local lane (`OPENAI_BASE_URL=127.0.0.1:8787`, galene.ai models) is the free second trial lane. Establish the facts:

- Is the gateway OpenAI-compatible? Which models are advertised and actually respond?
- Per-response usage/token accounting available (the context-cost metric depends on it)? Max context sizes? Latency ballpark for a single scenario call?
- A recommended call recipe (endpoint paths, headers, model ids) a harness script can reuse

Read-only probes only; never print or persist secret values. Deliverable: a FINDINGS doc linked from this ticket.

## Answer

Resolved by research subagent. Full findings on throwaway branch `research/local-lane-probe` (`FINDINGS.md`, commit `333c12d`, not pushed). Facts: the `127.0.0.1:8787` gateway is a headroom proxy currently routed at a dead DeepSeek upstream — every authed probe 401s and there was zero prior traffic; the galene upstream itself is healthy: `Galene/LLM` (vLLM, Qwen3.8-27B-NVFP4, 120k ctx declared) returned HTTP 200 on a direct call, ~0.37s warm, with full usage accounting (`usage.prompt_tokens/completion_tokens/total_tokens` + `reasoning_tokens`; ~50-token hidden prompt wrap per call). Repair — repointing the proxy target at the galene endpoint using the stored key — graduated into ticket 14.
