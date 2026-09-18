# Profiles

A **profile** is a composition: `level` × `platform`, optionally with the `airgapped` modifier. Profiles are advisory — tooling never enforces them; this file is the single source of truth (README quotes examples only).

## Levels

Strict superset chain, ascending context cost. Each row adds on top of the previous:

| Level | Adds | Anchor case |
|---|---|---|
| `micro` | core: `env-detect`, `context-diet` | CI runners, containers, ephemeral VMs |
| `lean` | + `agent-onboard` | older / low-RAM personal boxes |
| `daily` | + `shell-rtk`, `memory-system` | workhorse dev box (default) |
| `power` | + `mcp-essentials` | boxes running MCP servers |
| `station` | + `local-models` (where platform offers) | NPU/GPU research box |

`quality-gates` ships inline via `templates/AGENTS.md`; `skill-creator` targets repo authors — neither belongs in any level by design. `station` forces `local-models` regardless of the recommendation column; where the detector shows no viable local sizing (e.g. Windows without nvidia GPU) it is equivalent to `power` — that equivalence is a reading of the machine, not a platform exception.

## Platforms

Picked by detector from `scripts/detect-env.sh` output:

| Platform | Env modules | `local-models` recommended when | Detector signal |
|---|---|---|---|
| `linux` | `env-linux` | any box with RAM (sized by `local-models` tables; nvidia GPU raises the ceiling) | `OS=linux`, `IS_WSL=0` |
| `mac` | `env-macos` | `NPU=1` & `RAM_GB≥32` | `OS=darwin` |
| `windows-native` | `env-windows` | `GPU=nvidia` (VRAM-bound sizing; else remote endpoint) | `OS=windows` |
| `windows-wsl` | `env-windows` + `env-wsl` | `GPU=nvidia` (WSL CUDA passthrough; else remote endpoint) | `IS_WSL=1` (beats `OS=linux`) |

Unknown platform → level only, no env modules.

## Defaults

Deterministic first-match over `detect-env.sh` output:

- Level: `IS_CONTAINER=1 → micro` · `RAM_GB≤8 → lean` · (`NPU=1` & `RAM_GB≥32`) or `GPU=nvidia → station` · else `daily`.
- Platform: per signals above.
- The `daily` ↔ `power` step is **always an explicit question** at install time — no probe can know MCP usage for certain. `HAS_MCP` (a presence heuristic over known agent config paths) is shown as evidence with that question; it never sets a default.

## airgapped modifier

User-declared (no network probe exists). Keeps `shell-rtk` + `memory-system` (purely local), drops `mcp-essentials`, forces platform env + `local-models` where offered. Composes with every level; offline, `power ≡ daily`.

Examples: `daily+linux`, `power+windows-wsl` (both Windows skills), `airgapped+mac`.
