<div align="center">

# 🧠⚡️ agent-workshop

### Turn any coding agent into a disciplined engineer for your exact machine.

**Higher-quality output · smaller context · execution-proven gates · no token bloat**

<br>

![skills](https://img.shields.io/badge/skills-13%20spec--valid-brightgreen?style=for-the-badge)
![quality](https://img.shields.io/badge/quality%20gates-execution--proven-purple?style=for-the-badge)
![tokens](https://img.shields.io/badge/tokens-budgeted-blue?style=for-the-badge)
![agents](https://img.shields.io/badge/agents-opencode%20%C2%B7%20claude%20%C2%B7%20codex%20%C2%B7%20pi%20%C2%B7%20cursor-orange?style=for-the-badge)
![license](https://img.shields.io/badge/license-Apache--2.0-lightgrey?style=for-the-badge)

</div>

---

## 📑 Contents

- [Why](#why)
- [Quick Start](#quick-start)
- [How It Works](#how-it-works)
- [Supported Agents](#supported-agents)
- [Profiles](#profiles)
- [Module Catalog](#module-catalog)
- [Quality & Token Contract](#quality--token-contract)
- [Security Posture](#security-posture)
- [Repo Map](#repo-map)
- [Roadmap](#roadmap)
- [Contributing](#contributing)
- [License](#license)

## Why 🚀

Most agents don’t fail because they lack intelligence. They fail because they arrive **blind**:

- 🌀 No idea whether they’re in WSL, macOS, Docker, Windows, or a bare Linux box
- 📄 Pasted prompts that bloat context and drown the model in irrelevant detail
- 🧨 Shell output flooding the window with logs, colors, and noise
- ❌ “Done” claims with no proof that anything was actually verified

**agent-workshop fixes all four.** It gives every coding agent a machine-aware, quality-gated, token-budgeted onboarding loop:

| Capability | What You Get |
|---|---|
| 🥗 **Context Diet** | Lean instruction files, progressive disclosure, zero padding |
| 🧪 **Quality Gates** | Reproduce → change → prove by execution, never “should work” |
| 🪙 **Token Budgets** | Every module declares what stays *out* of context until needed |
| 🌍 **Machine Awareness** | WSL / macOS / Linux / Windows probes drive sensible defaults |
| 🔁 **Safe Bootstrap** | Idempotent installer, no secrets, no curl-pipe chaos |

> 💡 **Say one phrase** — `init my agent` — and the agent audits your machine, detects what’s missing, asks at most five questions, installs your stack, and proves it worked.

## Quick Start ⚡

### Option A — Skills CLI (recommended)

```bash
# Browse what’s available
npx skills add svitaTLCO/agent-workshop --list

# Install everything globally
npx skills add svitaTLCO/agent-workshop -g -y

# Or pick specific skills + agents
npx skills add svitaTLCO/agent-workshop -s agent-onboard -a opencode -a claude-code -g
```

### Option B — Pure Bash (no Node required)

```bash
git clone https://github.com/svitaTLCO/agent-workshop.git
cd agent-workshop
./scripts/install.sh                                  # global; auto-detects agents present on this machine
./scripts/install.sh --agents opencode,claude-code --skills context-diet   # per-agent + per-skill picks (validated)
./scripts/install.sh --project --copy                 # project-scoped (./.opencode, ./.claude, ./.agents next to cwd), copied not symlinked
```

### Windows

```powershell
powershell -File scripts/install.ps1                                     # global; auto-detects agents
powershell -File scripts/install.ps1 -Agents opencode,codex -Project      # per-agent picks, project-scoped (copy mode)
```

Same adapter table as `install.sh`; not yet run on a Windows host — verify per `docs/compatibility.md`.

### Then, inside any agent:

```text
init my agent
```

or simply: **“bootstrap”**, **“set up”**, **“what’s missing”**, **“refresh my skills”**.

## How It Works 🧭

The core meta-skill (`agent-onboard`) runs a strict, repeatable loop:

1. 🔍 **Audit** — Run `detect-env.sh` to fingerprint OS, arch, shell, WSL, container, RAM, tools
2. 🧭 **Detect Agents** — Map discovered environments to supported agents and scopes
3. ⚖️ **Diff Against Catalog** — Compare installed vs. missing modules, recommend by profile
4. ❓ **Ask (max 5)** — Profile, modules, symlink/copy, local models, keys — nothing else
5. 📦 **Install** — Copy/symlink skills, wire templates, pull CLIs from official sources only
6. ✍️ **Write Instruction Files** — Generate a lean root `AGENTS.md` (+ optional `CLAUDE.md` shim)
7. 🩺 **Verify (`doctor`)** — Run validators, smoke tests, and trigger checks before claiming success
8. 📣 **Report Evidence** — Installed / skipped / deferred / token impact / next step — always with proof

> ✅ **No step reports success without executable evidence.** That’s not a feature; it’s the floor.

## Supported Agents 🤝

One `skills/` directory, installed cleanly across ecosystems:

| Agent | Instruction Root | Skill Discovery Path |
|---|---|---|
| 🟢 **OpenCode** | `AGENTS.md` / `CLAUDE.md` | `.opencode/skills/`, `~/.config/opencode/skills/` |
| 🟠 **Claude Code** | `CLAUDE.md` | `.claude/skills/`, `~/.claude/skills/` |
| 🟣 **Codex** | `AGENTS.md` | `.agents/skills/`, `~/.agents/skills/` |
| 🔵 **Pi** | `AGENTS.md` | `.agents/skills/`, `~/.agents/skills/` |
| 🩵 **Cursor** | `AGENTS.md` | `.agents/skills/`, `~/.agents/skills/` |
| ⚪ **Aider / others** | `AGENTS.md` | `.agents/skills/` |

Root `AGENTS.md` is the single source of truth; shims point to it — no duplicated config.

## Profiles 🎛️

Pick a preset, or let the detector choose based on your machine:

| Profile | Best For | Includes |
|---|---|---|
| 🪶 `minimal` | Any box, lowest footprint | `agent-onboard`, `env-detect`, `context-diet` |
| ⚡ `power` | Daily dev machine | `shell-rtk`, `mcp-essentials`, `memory-system` |
| 🖥️ `windows-native` | Pure native Windows dev box (no WSL dependency) | `power` + `env-windows` |
| 🪟 `windows-wsl` | WSL2 interop setups | `power` + `env-wsl` |
| 🍏 `mac-npu` | Apple Silicon, 32 GB+ | `power` + `env-macos`, `local-models` |
| 📡 `airgapped` | Offline / air-gapped boxes | `minimal` + OS env + `local-models` |

Reference table in [`docs/profiles.md`](docs/profiles.md).

## Module Catalog 🧰

```text
skills/
  🤖 agent-onboard      audit → install → verify (the brain)
  🧪 quality-gates      definition of done + verification ladder
  🥗 context-diet       subtractive context engineering + budgets
  🧭 env-detect         OS / arch / WSL / RAM / tool probe
  🪟 env-wsl            WSL2 home: paths, Docker, daemons/persistence, USB/GPU, network tuning
  🍏 env-macos          capability scan (Silicon vs Intel split), Ollama MLX, brew services, local-model tiers
  🐧 env-linux          systemd daemons, apt/dnf/pacman, toolchains & GPU stacks (CUDA/ROCm/Vulkan), USB/udev, desktop-or-headless
  🖥️  env-windows        pwsh, winget, workload routing, native builds, daemons/Ollama/Docker
  ⌨️  shell-rtk          token-optimized shell wrapper (60–99% savings)
  🧮 local-models       RAM-based model picker + agent wiring
  🔌 mcp-essentials     minimal MCP set per task
  💾 memory-system      global + project MEMORY.md wiring
  🛠️  skill-creator      scaffold new skills with template + lint
```

Templates, scripts, and docs live alongside — see [Repo Map](#repo-map).

## Quality & Token Contract 🧾

This isn’t a slogan. It’s a binding constraint applied **horizontally across the entire core** — every skill, script, template, doc, installer path, and generated file.

- 📏 **Token budgets** declare what stays unloaded by default
- 🧪 **Quality gates** define the executable check that proves a module worked
- 🚫 **Any change that grows context without measured quality gain is a regression**

See [`docs/quality-token-contract.md`](docs/quality-token-contract.md) for the full contract.

## Security Posture 🔐

- 🔒 **Never prints or commits secrets** — key presence checks only, values stay in env files
- 📦 **Official package sources only** — `brew`, `apt`, `winget`, `npm -g`; no curl-pipe
- 🔁 **Idempotent installer** — safe to re-run, no drift
- ✅ **Spec validation** — `python3 scripts/validate-skills.py` enforces naming, description, body limits, and per-skill token-budget/quality-gate declarations

## Repo Map 🗺️

```text
agent-workshop/
├── AGENTS.md               # repo-wide agent instructions + quality/token invariants
├── README.md               # you are here
├── CONTRIBUTING.md         # how to add your own “knife”
├── LICENSE                 # Apache-2.0
├── skills/                 # 13 spec-valid agent skills
│   ├── agent-onboard/
│   ├── quality-gates/
│   ├── context-diet/
│   └── …                   # env, shell, models, memory, MCP, creator
├── templates/              # AGENTS.md base, CLAUDE.md shim, MEMORY.md
├── scripts/
│   ├── detect-env.sh       # machine fingerprint
│   ├── install.sh          # bash installer (symlink or copy)
│   ├── install.ps1         # PowerShell installer (same adapter table, copy mode)
│   └── validate-skills.py  # spec compliance linter
├── docs/
│   ├── compatibility.md    # agent/path mapping
│   ├── profiles.md         # preset definitions
│   └── quality-token-contract.md
└── .claude-plugin/         # Claude plugin manifest
```

## Roadmap 🛰️

- [x] 13 spec-valid skills + meta-skill onboarding loop
- [x] Horizontal quality + token invariants across all core artifacts (machine-enforced by `validate-skills.py`)
- [x] Cross-agent installer (Bash + PowerShell)
- [x] Standalone-home env skills (Linux / WSL / macOS / Windows) with verify + diagnose gate pairs
- [x] Full Apache-2.0 license text in `LICENSE`
- [ ] End-to-end CI validation badge
- [x] `--agents`/`--skills`/`--project` selection honored by `install.sh` (validated; quality gate `scripts/test-install.sh`)
- [x] Richer per-agent discovery adapters beyond the shared `.agents/` path (adapter table in `install.sh` + `docs/compatibility.md`; presence probes in `detect-env.sh`)

## Contributing 🤝

Want to add your personal army-knife? Read [`CONTRIBUTING.md`](CONTRIBUTING.md) and [`skills/skill-creator/SKILL.md`](skills/skill-creator/SKILL.md).

Every PR must include:

- ✅ Spec validation pass (`python3 scripts/validate-skills.py`)
- ✅ Clear statement of which machine/workflow it optimizes
- ✅ Verification evidence (`doctor` output or before/after token measurement)
- ✅ No secrets, no drift, no silent behavior changes

## License 📜

[Apache-2.0](LICENSE) — matching the `anthropics/skills` examples.

<div align="center">

**Built for engineers who refuse to waste context.**

</div>
