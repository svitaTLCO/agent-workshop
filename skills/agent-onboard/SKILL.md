---
name: agent-onboard
description: Bootstrap any coding agent on a new machine. Use when the user says init my agent, bootstrap, set up, configure my environment, what's missing, or refresh my skills.
license: Apache-2.0
---

# Agent Onboard — meta-skill

Prime directive: every machine you configure must produce higher-quality output at lower token cost. Apply `quality-gates` to your own work and `context-diet` to every file you write. Idempotent: safe to re-run. Missing API keys never block installation.

Trigger phrases (EN/中文): `init my agent`, `set up`, `bootstrap`, `configure my environment`, `what's missing`, `refresh my skills`, `开箱`, `初始化`, `配置 agent`, `补全环境`.

## Step 1 — Audit current state

Run `bash scripts/detect-env.sh` from repo root. Then check:

- Skills present in agent discovery paths (`.opencode/skills/`, `~/.config/opencode/skills/`, `.claude/skills/`, `~/.claude/skills/`, `.agents/skills/`, `~/.agents/skills/`).
- CLIs: `rtk`, `ollama`, `docker`, `gh`, `node`, `python3`.
- Keys: only presence (env var set?), never print values.
- Agent identity: config dirs / binaries / env vars for opencode, claude-code, codex, pi, cursor.

## Step 2 — Detect agents

Map what you found to the `npx skills` agent table (see `docs/compatibility.md`). Record project vs global scope.

## Step 3 — Diff against catalog

Compare with `skills/*/SKILL.md` in this repo. List installed / missing / outdated. Recommend by profile (`docs/profiles.md`): ask user to pick `minimal`, `power`, `mac-npu`, `windows-wsl`, or `airgapped` — default to auto-detected OS.

## Step 4 — Ask (max 5 questions)

1. Profile + agents to configure (project, global, or both)?
2. Which missing modules to install?
3. Symlink (recommended, easy update) or copy?
4. Local models? (only on macOS 32GB+ / Linux+GPU — else skip)
5. Keys now or later? If now: which keys, target file (`~/.bashrc` AFTER `case $-` guard so non-interactive shells see them, `~/.zshenv`, or `.env`).

## Step 5 — Install

- Skills: copy/symlink canonical `skills/<name>/` into each target discovery path, or run `npx skills add <repo> -s <names> -a <agents> [-g]`.
- CLIs: official sources only (`brew`, `apt`, `winget`, `npm -g`). Never curl-pipe unreviewed scripts.
- Keys: append `export KEY=...` to agreed env file only; ensure file is gitignored when inside a repo.

## Step 6 — Write instruction files

Generate from `templates/AGENTS.md` + selected modules. Write root `AGENTS.md` (≤ 150 lines — split overflow into a skill, never pad); add `CLAUDE.md`/`GEMINI.md` shims only if that agent is a target (one-line pointer, no duplication). Wire memory per `skills/memory-system/SKILL.md` when requested.

## Step 7 — Verify (`doctor`)

- `python3 scripts/validate-skills.py` passes.
- `npx skills list` (or `ls` of each discovery path) shows new skills.
- One trigger test: ask agent to load a new skill and summarize its `description`.
- If `rtk` installed: `rtk git status` smoke test. If Ollama: `ollama list`.

## Step 8 — Report

Installed / skipped (with reason) / keys deferred / token impact (skills added, AGENTS.md line count, `rtk` savings where measured) / verification output / next step (`refresh my skills` to re-run). Never claim success on failed checks — apply `quality-gates` ladder to this report itself.
