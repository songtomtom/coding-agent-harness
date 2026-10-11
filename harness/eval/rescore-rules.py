#!/usr/bin/env python3
"""저장된 패치를 같은 ref 의 worktree 에 적용해 규칙 검사만 다시 하고 JSON 의 rule_* 와 pass 를 갱신한다. 사용: rescore-rules.py <run-id>"""
import json, subprocess, sys, os, glob, shutil
root = subprocess.run(["git","rev-parse","--show-toplevel"],capture_output=True,text=True).stdout.strip(); os.chdir(root)
run = sys.argv[1]; out = f"harness/eval/results/{run}"; sha = json.load(open(f"{out}/run.json"))["sha"]
for jf in sorted(glob.glob(f"{out}/T[0-9][0-9].json")):
    t = os.path.basename(jf)[:-5]; wt = f"/tmp/harness-rescore/{run}/{t}"
    shutil.rmtree(wt, ignore_errors=True); subprocess.run(["git","worktree","prune"]); subprocess.run(["git","worktree","add","--detach","-q",wt,sha],check=True)
    if os.path.exists(f"{out}/{t}.patch") and os.path.getsize(f"{out}/{t}.patch"): subprocess.run(["git","-C",wt,"apply",os.path.abspath(f"{out}/{t}.patch")])
    res = subprocess.run(["python3","harness/rules_diff.py","--root",wt],capture_output=True,text=True).stdout
    lines = [l for l in res.splitlines() if l.startswith("R-")]
    d = json.load(open(jf)); d["rule_violations"] = len(lines); d["rule_lines"] = lines
    d["pass"] = bool(d["typecheck_exit"]==0 and d["lint_exit"]==0 and d["test_exit"]==0 and not lines and not d["missing_expect_files"] and not d["missing_expect_terms"] and (len(d["changed_files"])>0 or d["expect_terms"]))
    json.dump(d, open(jf,"w"), ensure_ascii=False, indent=1); print(t, "rules", len(lines), "pass", d["pass"])
    subprocess.run(["git","worktree","remove","--force",wt])
