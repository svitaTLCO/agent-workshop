#!/usr/bin/env python3
"""Skill-trigger evaluation harness v1.

Protocol: .scratch/skill-prompt-research/issues/04-harness-design.md (Answer, 2026-09-17).
One protocol, two rulers: the identical canonical request (temperature=0,
response_format=json_object) is sent to the pinned Azure deployment (lane `azure`)
and the local galene lane (lane `galene`). Selection domain = corpus names + null;
anything else is a run-error row. Verdicts are majority-vote with an UNSTABLE flag;
cost = raw usage + calibrated material tokens (prompt - lane wrapper constant).

Storage: eval/runs/<id>/{manifest.yaml, results.jsonl, summary.md} (committed),
raw API payloads in eval/runs/<id>/raw/ (gitignored). Campaign spend cap is
enforced via eval/spend.log (every call appends one line; caps: azure 1500,
galene 100; smoke runs count too).

Usage:
  python3 eval/run.py run   --id <run-id> [--lane azure|galene|both]
                            [--kind smoke|baseline|trial] [--corpus live|draft]
                            [--scenarios all|id1,id2,...] [--r N]
  python3 eval/run.py score --id <run-id>
  python3 eval/run.py cap                     # show cumulative spend vs caps

Dependencies: Python stdlib + PyYAML. Secrets stay outside this tree:
Azure creds in ~/.config/agent-workshop/eval-azure.env, galene key in
~/.local/share/opencode/auth.json (.galeneai.key).
"""
import argparse
import hashlib
import json
import platform
import shutil
import sys
import time
import urllib.error
import urllib.request
from datetime import datetime
from pathlib import Path

EVAL = Path(__file__).resolve().parent
REPO = EVAL.parent
SUITE = EVAL / "scenarios.yaml"
RUNS = EVAL / "runs"
SPEND = EVAL / "spend.log"
CAPS = {"azure": 1500, "galene": 100}
AZURE_DEPLOYMENT = "gpt-5.4"
GALENE_BASE = "http://127.0.0.1:8787/v1"
GALENE_MODEL = "Galene/LLM"
MAX_COMPLETION_TOKENS = 256
CONSECUTIVE_ERROR_STOP = 5

# Wrapper constants: prompt_tokens of an empty-catalog call under the exact
# selection template below ("ping" user message). Measured 2026-09-17 on the
# pinned endpoints; pinned here because material tokens depend on them.
C0 = {"azure": 77, "galene": 123}

# Selection template T -- frozen verbatim (see ticket 04 Recon); do not edit.
TEMPLATE = (
    "You are an agent that can load specialized skill instructions by name. "
    "Read the user's request. If a listed skill is clearly applicable to the task, select it; "
    "if none applies, select nothing. Select at most one skill.\n\n"
    "Available skills:\n%s\n\n"
    'Respond with JSON only: {"skill": "<name>"} or {"skill": null}'
)


def die(msg, code=1):
    print(f"error: {msg}", file=sys.stderr)
    sys.exit(code)


def frontmatter_field(fm, key):
    """Single-line value, plus support for | / |- block scalars."""
    import re
    m = re.search(rf"^{key}:\s*(.*)$", fm, re.M)
    if not m:
        return None
    val = m.group(1).strip()
    if val in ("|", "|-", ">"):
        lines = []
        for line in fm[m.end():].splitlines()[1:]:
            if not line.strip() or not line.startswith((" ", "\t")):
                break
            lines.append(line.strip())
        return " ".join(lines)
    return val


def corpus_files(corpus):
    root = REPO / ("skills" if corpus == "live" else ".scratch/skill-prompt-research/drafts")
    files = sorted(root.glob("*/SKILL.md")) + [root / "skill-creator" / "template" / "SKILL.md"]
    missing = [str(f) for f in files if not f.exists()]
    if missing:
        die(f"corpus {corpus}: missing files: {missing}")
    return files


def build_catalog(corpus):
    entries, names = [], set()
    for f in corpus_files(corpus):
        fm = f.read_text(encoding="utf-8").split("---", 2)[1]
        name = frontmatter_field(fm, "name")
        desc = frontmatter_field(fm, "description")
        if not name or not desc:
            die(f"catalog: bad frontmatter in {f}")
        names.add(name)
        entries.append(f"- {name}: {desc}")
    return "\n".join(entries), sorted(names)


def load_suite(ids):
    import yaml
    doc = yaml.safe_load(SUITE.read_text(encoding="utf-8"))
    scens = doc["scenarios"]
    have = {s["id"] for s in scens}
    if ids and ids != "all":
        want = [x.strip() for x in ids.split(",")]
        unknown = [w for w in want if w not in have]
        if unknown:
            die(f"unknown scenario ids: {unknown}")
        scens = [s for s in scens if s["id"] in want]
    return scens, hashlib.sha256(SUITE.read_bytes()).hexdigest()[:12], len(doc["scenarios"])


def lane_config(lane):
    if lane == "azure":
        env = {}
        p = Path.home() / ".config/agent-workshop/eval-azure.env"
        if not p.exists():
            die("Azure env file missing: ~/.config/agent-workshop/eval-azure.env")
        for line in p.read_text().splitlines():
            line = line.strip()
            if line.startswith("#") or "=" not in line:
                continue
            k, v = line.split("=", 1)
            env[k.strip()] = v.strip().strip('"').strip("'")
        need = ("AZURE_EVAL_ENDPOINT", "AZURE_EVAL_API_KEY", "AZURE_EVAL_API_VERSION")
        if any(not env.get(k) for k in need):
            die("Azure env vars incomplete")
        url = f"{env['AZURE_EVAL_ENDPOINT']}/openai/deployments/{AZURE_DEPLOYMENT}/chat/completions?api-version={env['AZURE_EVAL_API_VERSION']}"
        headers = {"api-key": env["AZURE_EVAL_API_KEY"], "Content-Type": "application/json"}
        pin = f"azure openai deployment {AZURE_DEPLOYMENT} @ ai-hub-fantuzzi (api-version {env['AZURE_EVAL_API_VERSION']})"
        return url, headers, pin, False
    key = json.loads((Path.home() / ".local/share/opencode/auth.json").read_text())["galeneai"]["key"]
    return (
        f"{GALENE_BASE}/chat/completions",
        {"Authorization": f"Bearer {key}", "Content-Type": "application/json"},
        f"local vllm lane {GALENE_MODEL} via {GALENE_BASE}",
        True,
    )


def spend_count(lane):
    if not SPEND.exists():
        return 0
    return sum(1 for line in SPEND.read_text().splitlines() if f"\t{lane}\t" in line)


def spend_guard(lane):
    n = spend_count(lane)
    if n >= CAPS[lane]:
        die(f"hard cap reached for lane {lane}: {n}/{CAPS[lane]} calls; refusing further spend")


def spend_append(lane, run_id, scenario, rep):
    SPEND.parent.mkdir(parents=True, exist_ok=True)
    with SPEND.open("a") as fh:
        fh.write(f"{datetime.now().isoformat(timespec='seconds')}\t{lane}\t{run_id}\t{scenario}\tr{rep}\n")


def invoke(lane, system, prompt, raw_dir, tag):
    url, headers, _pin, is_galene = lane_config(lane)
    body = {
        "messages": [{"role": "system", "content": system}, {"role": "user", "content": prompt}],
        "temperature": 0,
        "max_completion_tokens": MAX_COMPLETION_TOKENS,
        "response_format": {"type": "json_object"},
    }
    if is_galene:
        body["model"] = GALENE_MODEL
    req = urllib.request.Request(url, data=json.dumps(body).encode(), headers=headers)
    t0 = time.time()
    status, raw = 0, b""
    try:
        with urllib.request.urlopen(req, timeout=300) as r:
            status, raw = r.status, r.read()
    except urllib.error.HTTPError as e:
        status, raw = e.code, e.read()
    except Exception as e:  # network-level
        return {"http": 0, "error": f"network:{e.__class__.__name__}", "elapsed_s": round(time.time() - t0, 2),
                "prompt_tokens": None, "completion_tokens": None, "reasoning_tokens": None,
                "selected": None, "finish": None}
    dt = round(time.time() - t0, 2)
    (raw_dir / f"{tag}.json").write_bytes(raw)
    row = {"http": status, "elapsed_s": dt, "prompt_tokens": None, "completion_tokens": None,
           "reasoning_tokens": None, "selected": None, "finish": None, "error": None}
    try:
        j = json.loads(raw)
        content = j["choices"][0]["message"]["content"].strip()
        u = j.get("usage", {}) or {}
        row.update(prompt_tokens=u.get("prompt_tokens"), completion_tokens=u.get("completion_tokens"),
                   finish=j["choices"][0].get("finish_reason"))
        det = u.get("completion_tokens_details") or {}
        row["reasoning_tokens"] = det.get("reasoning_tokens")
        sel = json.loads(content).get("skill")
        row["selected"] = sel if isinstance(sel, str) else None
    except Exception as e:
        row["error"] = f"parse:{e.__class__.__name__}" if status == 200 else f"http_{status}"
    return row


def score_lane(rows, scenarios_order):
    groups = {}
    for r in rows:
        groups.setdefault(r["scenario_id"], []).append(r)
    out = []
    for sid in scenarios_order:
        grp = groups.get(sid, [])
        vals = [g["selected"] for g in grp if not g["error"]]
        from collections import Counter
        cnt = Counter(vals)
        if not vals:
            verdict, stable, k, tied = None, False, 0, True
        else:
            top, top_n = cnt.most_common(1)[0]
            tied = not (top_n * 2 > len(vals))
            verdict = None if tied else top
            stable = len(cnt) == 1
            k = top_n
        errs = sum(1 for g in grp if g["error"])
        out.append({"scenario_id": sid, "verdict": verdict, "agree": k, "of": len(grp),
                    "stable": stable, "errors": errs, "tied": tied})
    return out


def write_results(run_dir, rows):
    with (run_dir / "results.jsonl").open("w") as fh:
        for r in rows:
            fh.write(json.dumps(r, sort_keys=True, ensure_ascii=False, separators=(",", ":")) + "\n")


def read_results(run_dir):
    out = []
    with (run_dir / "results.jsonl").open() as fh:
        for line in fh:
            if line.strip():
                out.append(json.loads(line))
    return out


def write_summary(run_dir, manifest):
    rows = read_results(run_dir)
    lanes = manifest["lanes"]
    all_scens, _, _ = load_suite("all")
    scens = {s["id"]: s for s in all_scens}
    subset = manifest.get("suite_subset", "all")
    ordered = [s for s in all_scens if s["id"] in subset] if isinstance(subset, list) else list(all_scens)
    kinds_in_run = sorted({s["kind"] for s in ordered})
    run_totals = {k: sum(1 for s in ordered if s["kind"] == k) for k in kinds_in_run}
    md = [f"# Run {manifest['run_id']} ({manifest['kind']})",
          "",
          f"suite `{manifest['suite_sha']}` ({manifest['suite_records']} records, "
          f"{len(ordered)} in this run) - corpus `{manifest['corpus']}` - R={manifest['r']} - template T pinned in manifest",
          ""]
    for lane in lanes:
        lrows = [r for r in rows if r["lane"] == lane]
        scores = score_lane(lrows, [s["id"] for s in ordered])
        md += [f"## {lane} (calls {len(lrows)})", "",
               "| scenario | kind | expected | verdict | k/R | status |",
               "|---|---|---|---|---|---|"]
        acc = {}
        for s in scores:
            sid = s["scenario_id"]
            exp = scens[sid]["expected"]
            exp_s = "(none)" if exp is None else exp
            if s["of"] == 0:
                st = "NO-DATA"
            elif s["errors"] == s["of"]:
                st = "ERROR"
            elif s["tied"]:
                st = "NO-MAJORITY"
            elif s["verdict"] == exp:
                st = "OK"
            else:
                st = "MISS"
            ver_s = "(none)" if s["verdict"] is None else s["verdict"]
            if not s["stable"] and not s["tied"] and s["of"] > 0:
                ver_s += "!"
            if st == "OK":
                acc[scens[sid]["kind"]] = acc.get(scens[sid]["kind"], 0) + 1
            md.append(f"| {sid} | {scens[sid]['kind']} | {exp_s} | {ver_s} | {s['agree']}/{s['of']} | {st} |")
        prompts = sum(r["prompt_tokens"] or 0 for r in lrows)
        complet = sum(r["completion_tokens"] or 0 for r in lrows)
        reason = sum(r["reasoning_tokens"] or 0 for r in lrows)
        mat = sum(max(0, (r["prompt_tokens"] or 0) - C0[lane]) for r in lrows)
        ndet = max(1, len(lrows) - sum(1 for r in lrows if r["error"]))
        errs_l = sum(1 for r in lrows if r["error"])
        okline = " / ".join(f"{k}: {acc.get(k,0)}/{run_totals[k]}" for k in kinds_in_run)
        axnote = f"; {errs_l} error rows" if errs_l else ""
        md += ["", f"axes: accuracy {okline}; prompt {prompts} tok; completion {complet} tok "
                 f"(reasoning {reason}); material {mat} tok (mean {round(mat/ndet)} per call){axnote}", ""]
    md += ["Verdict = strict majority over repeats (>R/2); `!` = non-unanimous repeats (UNSTABLE); "
           "NO-MAJORITY = tie (no strict majority), including ties involving null.",
           "material tokens = prompt_tokens - lane wrapper constant (manifest). Rescoring is deterministic over results.jsonl."]
    (run_dir / "summary.md").write_text("\n".join(md) + "\n", encoding="utf-8")


def write_manifest(run_dir, m):
    import yaml
    (run_dir / "manifest.yaml").write_text(yaml.safe_dump(m, sort_keys=True, allow_unicode=True), encoding="utf-8")


def cmd_run(a):
    lanes = ["azure", "galene"] if a.lane == "both" else [a.lane]
    r = a.r if a.r else (3 if a.kind == "smoke" else 5)
    scenarios, suite_sha, total = load_suite(a.scenarios)
    catalog, names = build_catalog(a.corpus)
    cat_sha = hashlib.sha256(catalog.encode()).hexdigest()[:12]
    planned = {ln: len(scenarios) * r for ln in lanes}
    for ln in lanes:
        used, cap = spend_count(ln), CAPS[ln]
        if used + planned[ln] > cap:
            print(f"warn: lane {ln} planned {planned[ln]} would exceed cap {cap} "
                  f"(already {used}); per-call guard will hard-stop at {cap - used}")
    run_dir = RUNS / a.id
    ceil_per_call = int(len(catalog) * 0.28) + 150
    est_total = sum(planned.values()) * ceil_per_call
    used_now = {ln: spend_count(ln) for ln in lanes}
    print(f"estimate: {len(scenarios)} scenario-runs x R={r} -> "
          + " ".join(f"{ln}:{planned[ln]}" for ln in lanes) + " calls; "
          f"input-token ceiling ~{est_total:,} (~{ceil_per_call}/call, catalog {len(catalog)} chars); "
          "ledger post-run " + " ".join(f"{ln} {used_now[ln] + planned[ln]}/{CAPS[ln]}" for ln in lanes))
    if run_dir.exists():
        shutil.rmtree(run_dir)  # rerun overwrite is deliberate (spend still counts)
    (run_dir / "raw").mkdir(parents=True)
    system = TEMPLATE % catalog
    rows = []
    consec = {ln: 0 for ln in lanes}
    aborted = {}
    for ln in lanes:
        for s in scenarios:
            for rep in range(1, r + 1):
                if aborted.get(ln):
                    break
                spend_guard(ln)
                tag = f"{ln}-{s['id']}-r{rep}".replace(".", "-")
                row = invoke(ln, system, s["prompt"], run_dir / "raw", tag)
                spend_append(ln, a.id, s["id"], rep)
                rs = row.get("selected")
                if rs is not None and rs not in names:
                    row["error"] = f"out_of_domain:{rs}"
                    row["selected"] = None
                match = None
                if not row.get("error"):
                    match = (row["selected"] == s["expected"])
                row.update(lane=ln, kind=a.kind, scenario_id=s["id"], scen_kind=s["kind"],
                           target=s["target"], expected=s["expected"], repeat=rep,
                           match=match, ts=datetime.now().isoformat(timespec="seconds"))
                rows.append(row)
                consec[ln] = 0 if row.get("error") is None else consec[ln] + 1
                if consec[ln] >= CONSECUTIVE_ERROR_STOP:
                    aborted[ln] = True
                    print(f"abort: lane {ln} stopped after {consec[ln]} consecutive errors", file=sys.stderr)
            if aborted.get(ln):
                break
    write_results(run_dir, rows)
    manifest = {
        "run_id": a.id, "kind": a.kind, "lanes": lanes, "corpus": a.corpus,
        "corpus_paths": [str(p.relative_to(REPO)) for p in corpus_files(a.corpus)],
        "catalog_chars": len(catalog), "catalog_sha": cat_sha, "catalog_names": names,
        "suite_sha": suite_sha, "suite_records": total,
        "suite_subset": [s["id"] for s in scenarios] if len(scenarios) != total else "all",
        "r": r, "caps": dict(CAPS),
        "model_pins": {ln: lane_config(ln)[2] for ln in lanes},
        "wrapper_constants": {**C0, "provenance": "empty-catalog 'ping' under template T, 2026-09-17"},
        "template": TEMPLATE,
        "max_completion_tokens": MAX_COMPLETION_TOKENS,
        "degraded": bool(aborted),
        "made_calls": {ln: sum(1 for x in rows if x["lane"] == ln) for ln in lanes},
        "date": datetime.now().strftime("%Y-%m-%d"),
        "python": platform.python_version(),
    }
    write_manifest(run_dir, manifest)
    write_summary(run_dir, manifest)
    errs = sum(1 for x in rows if x.get("error"))
    print(f"run {a.id}: lanes={lanes} scenarios={len(scenarios)} R={r} rows={len(rows)} errors={errs} "
          f"-> {run_dir.relative_to(REPO)}" + (" [DEGRADED]" if aborted else ""))
    if aborted:
        sys.exit(2)


def cmd_score(a):
    run_dir = RUNS / a.id
    import yaml
    m = yaml.safe_load((run_dir / "manifest.yaml").read_text())
    write_summary(run_dir, m)
    print(f"rescored {a.id} -> {run_dir.joinpath('summary.md').relative_to(REPO)}")


def cmd_cap(_a):
    for ln in ("azure", "galene"):
        n = spend_count(ln)
        print(f"{ln}: {n}/{CAPS[ln]} calls")


def main():
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    sub = ap.add_subparsers(dest="cmd", required=True)
    p = sub.add_parser("run", help="execute trials and score")
    p.add_argument("--id", required=True)
    p.add_argument("--lane", default="azure", choices=["azure", "galene", "both"])
    p.add_argument("--kind", default="trial", choices=["smoke", "baseline", "trial"])
    p.add_argument("--corpus", default="live", choices=["live", "draft"])
    p.add_argument("--scenarios", default="all")
    p.add_argument("--r", type=int, default=None)
    p.set_defaults(fn=cmd_run)
    p = sub.add_parser("score", help="rescore an existing run (idempotency check)")
    p.add_argument("--id", required=True)
    p.set_defaults(fn=cmd_score)
    p = sub.add_parser("cap", help="show cumulative spend vs caps")
    p.set_defaults(fn=cmd_cap)
    args = ap.parse_args()
    args.fn(args)


if __name__ == "__main__":
    main()
