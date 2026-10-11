#!/usr/bin/env python3
"""HEAD 대비 변경 중 추가된 줄(과 신규 파일)만 규칙 검사. 쓰기 도구가 무엇이든 잡힌다. 사용: rules_diff.py [--root <repo>]"""
import re, subprocess, sys, os
root = os.path.realpath(sys.argv[sys.argv.index("--root")+1]) if "--root" in sys.argv else os.getcwd()
os.chdir(root); sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))  # 규칙은 이 스크립트 옆의 rules.py (worktree 의 옛 버전이 아니라)
from rules import check
sh = lambda *a: subprocess.run(a, capture_output=True, text=True).stdout
changed = [f for f in sh("git","diff","--name-only","HEAD").split() if f.endswith((".ts",".tsx"))]
new = [f for f in sh("git","ls-files","--others","--exclude-standard").split() if f.endswith((".ts",".tsx"))]
added, cur = {}, None
for line in (sh("git","diff","-U0","HEAD","--",*changed).splitlines() if changed else []):
    if line.startswith("+++ b/"): cur = line[6:].strip(); added.setdefault(cur,set())
    elif line.startswith("@@") and cur:
        m = re.search(r"\+(\d+)(?:,(\d+))?", line); a=int(m.group(1)); n=int(m.group(2) or 1); added[cur].update(range(a,a+n))
out = []
for f in changed + new:
    if not os.path.isfile(f): continue
    for h in check(f, open(f,encoding="utf-8",errors="ignore").read(), root="."):
        ln = int(re.match(r"R-\S+ \S+?:(\d+): ", h).group(1))
        if f in new or (ln > 0 and ln in added.get(f,set())): out.append(h)
print("\n".join(out))
