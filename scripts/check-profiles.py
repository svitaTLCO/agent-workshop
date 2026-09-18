#!/usr/bin/env python3
"""Consistency guard for docs/profiles.md vs README, agent-onboard, env skill descriptions, detect-env.sh. Stdlib only."""
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
LEVELS = ["micro", "lean", "daily", "power", "station"]
PLATFORMS = ["linux", "mac", "windows-native", "windows-wsl"]
CORE = {"env-detect", "context-diet"}
FULL = CORE | {"agent-onboard", "shell-rtk", "memory-system", "mcp-essentials", "local-models"}
ERRORS = []


def check(cond, msg):
    if not cond:
        ERRORS.append(msg)


def section(text, header):
    return text.split(header, 1)[1].split("\n## ", 1)[0]


def rows_of(section_text):
    out = []
    for l in section_text.splitlines():
        if l.startswith("|") and "---" not in l and not l.strip().startswith("| Level") and not l.strip().startswith("| Platform"):
            out.append([c.strip() for c in l.strip().strip("|").split("|")])
    return out


def mods(cell):
    return set(re.findall(r"`([a-z0-9][a-z0-9-]*)`", cell))


def main():
    profiles = (ROOT / "docs/profiles.md").read_text()
    readme = (ROOT / "README.md").read_text()
    onboard = (ROOT / "skills/agent-onboard/SKILL.md").read_text()
    win_fm = (ROOT / "skills/env-windows/SKILL.md").read_text().split("---")[1]
    wsl_fm = (ROOT / "skills/env-wsl/SKILL.md").read_text().split("---")[1]
    context = (ROOT / "CONTEXT.md").read_text()

    lrows = rows_of(section(profiles, "## Levels"))
    names, acc, core_set = [], set(), None
    for cells in lrows:
        name = re.search(r"`([^`]+)`", cells[0]).group(1)
        adds = mods(cells[1])
        check(not (acc & adds), f"level {name}: overlaps previous levels")
        acc |= adds
        names.append(name)
        if cells[1].startswith("core"):
            core_set = adds
    check(names == LEVELS, f"levels order drifted: {names}")
    check(core_set == CORE, f"core level modules drifted: {core_set}")
    check(acc == FULL, f"station composition drifted: {sorted(acc)}")

    lsec = section(profiles, "## Levels")
    check("regardless of the recommendation column" in lsec, "station rule lost (forces local-models per reading)")

    prows = rows_of(section(profiles, "## Platforms"))
    pnames = [re.search(r"`([^`]+)`", c[0]).group(1) for c in prows]
    check(pnames == PLATFORMS, f"platforms drifted: {pnames}")
    wsl = [c for c in prows if "windows-wsl" in c[0]][0]
    check(mods(wsl[1]) >= {"env-windows", "env-wsl"}, "windows-wsl must load both Windows skills")
    for c in prows:
        check(len(c) > 2 and c[2] != "—" and len(c[2]) > 2, f"platform {c[0]}: 'recommended when' cell empty")

    defaults = section(profiles, "## Defaults")
    check("upgraded to `power` when `HAS_MCP" not in profiles, "implicit HAS_MCP auto-upgrade rule must stay deleted")
    check("explicit" in defaults.lower() and "HAS_MCP" in defaults, "daily↔power must be an explicit question citing HAS_MCP as heuristic")
    check("airgapped" in section(profiles, "## airgapped modifier"), "airgapped rule missing")

    rprof = section(readme, "## Profiles")
    for lvl in LEVELS:
        check(f"`{lvl}`" in rprof, f"README profiles section missing level {lvl}")
    for plat in PLATFORMS:
        check(f"`{plat}`" in rprof, f"README profiles section missing platform {plat}")
    check("`minimal`" not in rprof and "`mac-npu`" not in rprof, "README still carries legacy preset names")
    check("canonical" in rprof, "README must mark docs/profiles.md canonical")
    check("docs/profiles.md" in rprof, "README lost canonical pointer")
    check("explicit question" in rprof, "README lost the daily↔power explicit-question note")

    check("docs/profiles.md" in onboard, "agent-onboard lost profiles pointer")
    check("HAS_MCP" in onboard, "agent-onboard lost HAS_MCP reference")
    check(re.search(r"MCP servers\?", onboard) is not None, "agent-onboard lost the explicit daily↔power question")

    mcp_body = (ROOT / "skills/mcp-essentials/SKILL.md").read_text()
    check("63%" not in mcp_body and "evals show" not in mcp_body,
          "mcp-essentials carries an unsourced metrics claim again")

    check("windows-wsl platform" in win_fm, "env-windows frontmatter lost pairing clause")
    check("Pairs with env-windows" in wsl_fm, "env-wsl frontmatter lost pairing clause")

    for f in ("README.md", "docs/profiles.md", "templates/AGENTS.md", "skills/agent-onboard/SKILL.md"):
        text = (ROOT / f).read_text()
        check("mac-npu" not in text, f"{f} still contains legacy token mac-npu")

    out = subprocess.run(["bash", str(ROOT / "scripts/detect-env.sh")], capture_output=True, text=True).stdout
    check(re.search(r"^HAS_MCP=[01]$", out, re.M) is not None, "detect-env.sh no longer emits HAS_MCP")

    check("**Level**:" in context and "**Profile**:" in context, "CONTEXT.md lost Level/Profile terms")

    if ERRORS:
        print("\n".join("FAIL: " + e for e in ERRORS))
        sys.exit(1)
    print(f"check-profiles: all checks passed ({len(LEVELS)} levels x {len(PLATFORMS)} platforms)")


if __name__ == "__main__":
    main()
