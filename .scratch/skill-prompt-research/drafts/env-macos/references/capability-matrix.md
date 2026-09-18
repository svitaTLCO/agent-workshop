# macOS capability matrix — load when choosing/pulling a local model on a Mac, or when a Mac feels misjudged by size

Tier numbers (unified-RAM ladder + Intel ceilings): the `skills/local-models/SKILL.md` table is the single source — load it and size from it. This file adds the Mac-specific detection and MLX/VRAM caveats below.

## Detect first (what `detect-env.sh` does)

```bash
sysctl -n machdep.cpu.brand_string   # "Apple M3 Pro" vs "Intel Core i9 …" → MAC_KIND
echo $(( $(sysctl -n hw.memsize) / 1073741824 ))   # bytes→GiB; on silicon this IS the unified pool
sysctl -n hw.physicalcpu             # CPU_CORES
sysctl -n sysctl.proc_translated     # 1 = x86_64 shell under Rosetta on silicon — trust arm64, not uname
system_profiler SPDisplaysDataType   # Intel Macs only: Chip + VRAM lines (dGPU or shared-memory iGPU)
```

Rosetta caveat: an x86_64 agent shell on Apple Silicon reports `uname -m=x86_64`. If `proc_translated=1`, the machine is silicon — `detect-env.sh` already corrects ARCH.

## Apple Silicon notes

All GPU+CPU share one pool; 4-bit weights ≈ 0.5–0.6 GiB/param plus KV cache headroom. `-mlx`/NVFP4 tags accelerate only on Apple Silicon (fetched elsewhere they just run at CPU speed) — prefer them here. MoE classes at 30–35B keep decode fast because only active params move.

Verify with the smallest tier first (12B), then upgrade — record pick + detected RAM in project `AGENTS.md`.

## Intel Mac notes

There is no MLX acceleration here (Metal/arm64 only); a `-mlx` build fetched here would run at plain-CPU speed — use standard `q4_K_M` tags with plain Ollama (CPU + iGPU Metal path).

- **iGPU only** (Iris/uhd): shares main RAM at low bandwidth → ≤3B comfortable, 8B q4 for short prompts only. Otherwise hybrid/cloud.
- **dGPU** (Radeon Pro / older NVIDIA): hard-VRAM bound — read VRAM from `system_profiler`: 8 GB → 7–8B q4; 16 GB (5600M-class) → 14B q4. Model > VRAM = silent CPU fallback, which collapses throughput.
- Long runs: `caffeinate -dims` applies equally (see `mlx-ollama.md`).

If the workload outgrows either column, the honest answer is a remote model endpoint — say so instead of pulling a model that will thrash.
