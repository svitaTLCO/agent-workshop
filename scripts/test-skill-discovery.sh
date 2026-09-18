#!/bin/sh
# Consumer-compatibility gate: executes the real installer CLI (`npx skills add ./ --list`)
# and proves every skills/*/SKILL.md is discovered, with exit 0 and no YAML parse errors.
# Runs in any Node image (POSIX sh + node only: no bash, sed, or extra libs required).
set -u
fail(){ printf 'FAIL: %s\n' "$1" >&2; exit 1; }
ROOT=$(cd -- "$(dirname -- "$0")/.." && pwd) || exit 1
cd "$ROOT" || exit 1
EXPECTED=""
for d in skills/*/; do
  if [ -f "${d}SKILL.md" ]; then EXPECTED="$EXPECTED $(basename "$d")"; fi
done
EXPECTED=${EXPECTED# }
[ -n "$EXPECTED" ] || fail "no skills/*/SKILL.md found on disk"
for req in env-windows repo-review; do
  case " $EXPECTED " in *" $req "*) ;; *) fail "disk regression: $req missing from skills/";; esac
done
OUT="/tmp/.test-skill-discovery.$$"
trap 'rm -f "$OUT"' EXIT
rc=0
npx --yes skills add ./ --list >"$OUT" 2>&1 || rc=$?
[ "$rc" = 0 ] || { cat "$OUT" >&2; fail "consumer exit $rc (want 0)"; }
node -e '
const fs = require("fs");
const [outFile, expArg] = process.argv.slice(1);
const clean = fs.readFileSync(outFile, "utf8").replace(/\x1b\[[0-9;?]*[@-~]/g, "").replace(/[\u0080-\uFFFF]/g, "");
if (/yaml\s+parse\s+error/i.test(clean)) { console.error(clean); process.exit(1); }
if (/skipped [^\n]*SKILL\.md/i.test(clean)) { console.error(clean); process.exit(1); }
const names = new Set();
for (const line of clean.split("\n")) {
  const t = line.trim();
  if (/^[a-z0-9]+(?:-[a-z0-9]+)*$/.test(t) && t.length <= 64) names.add(t);
}
const exp = expArg.trim().split(" ");
const missing = exp.filter((n) => !names.has(n));
if (missing.length) { console.error("undiscovered: " + missing.join(", ") + "\n" + clean); process.exit(1); }
console.log("ok: consumer discovered all " + exp.length + " skills: " + exp.join(" "));
' "$OUT" "$EXPECTED" || fail "consumer did not list every skill (see output above)"
echo "test-skill-discovery: all checks passed"
