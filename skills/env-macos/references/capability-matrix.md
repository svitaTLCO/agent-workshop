# macOS capability matrix — load when choosing/pulling a local model, or when a Mac feels misjudged by size

## Detect first (what `detect-env.sh` does)

```bash
sysctl -n machdep.cpu.brand_string   # "Apple M3 Pro" vs "Intel Core i9 …" → MAC_KIND
echo $(( $(sysctl -n hw.memsize) / 1073741824 ))   # bytes→GiB; on silicon this IS the unified pool
sysctl -n hw.physicalcpu             # CPU_CORES
sysctl -n sysctl.proc_translated     # 1 = x86_64 shell under Rosetta on silicon — trust arm64, not uname
system_profiler SPDisplaysDataType   # Intel Macs only: Chip + VRAM lines (dGPU or shared-memory iGPU)
```

Rosetta caveat: an x86_64 agent shell on Apple Silicon reports `uname -m=x86_64`. If `proc_translated=1`, the machine is silicon — `detect-env.sh` already corrects ARCH.

## Apple Silicon — unified memory ladder

All GPU+CPU share one pool; 4-bit weights ≈ 0.5–0.6 GiB/param plus KV cache headroom. `-mlx`/NVFP4 tags accelerate only on Apple Silicon (fetched elsewhere they just run at CPU speed) — prefer them here.

| Unified RAM | Realistic ceiling | Notes |
|---|---|---|
| ≤16 GB | 12B q4 (`gemma4:12b-mlx`) | fine; skip long contexts (>8K) |
| 16–32 GB | 14B coder; 24B tight | `Qwen2.5-Coder-14B`; 24B KV eats the margin |
| 32–48 GB | 30–35B-class MoE | `qwen3.5-35b-a3b` / `Qwen3-Coder-30B-A3B` — active-param count keeps decode fast |
| 64 GB+ | 70B q4 | dense; prefer 30B-A3B with 256K ctx for agentic work |

Verify with the smallest tier first (12B), then upgrade — record pick + detected RAM in project `AGENTS.md`.

## Intel Mac — no unified memory, ceilings lower

There is no MLX acceleration here (Metal/arm64 only); a `-mlx` build fetched here would run at plain-CPU speed — use standard `q4_K_M` tags with plain Ollama (CPU + iGPU Metal path).

- **iGPU only** (Iris/uhd): shares main RAM at low bandwidth → ≤3B comfortable, 8B q4 for short prompts only. Otherwise hybrid/cloud.
- **dGPU** (Radeon Pro / older NVIDIA): hard-VRAM bound — read VRAM from `system_profiler`: 8 GB → 7–8B q4; 16 GB (5600M-class) → 14B q4. Model > VRAM = silent CPU fallback, which collapses throughput.
- Long runs: `caffeinate -dims` applies equally (see `mlx-ollama.md`).

If the workload outgrows either column, the honest answer is a remote model endpoint — say so instead of pulling a model that will thrash.
