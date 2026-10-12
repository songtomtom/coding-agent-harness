#!/usr/bin/env bash
# PostToolUse(Bash): 셸로 파일을 고쳤을 수 있으니 변경된 줄 전체를 규칙 검사한다.
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"; mkdir -p "$ROOT/.claude/logs"; cat >/dev/null; cd "$ROOT"
git diff --quiet HEAD -- '*.ts' '*.tsx' 2>/dev/null && [[ -z "$(git ls-files --others --exclude-standard -- '*.ts' '*.tsx')" ]] && exit 0
VIOL="$(python3 harness/rules_diff.py --root "$ROOT" 2>/dev/null | grep '^R-' || true)"
python3 - "$ROOT/.claude/logs/hook-blocks.jsonl" "$VIOL" <<'PY'
import json,sys,datetime
log,viol=sys.argv[1:3]; rules=[l.split(" ",1)[0] for l in viol.splitlines() if l]
with open(log,"a",encoding="utf-8") as f: f.write(json.dumps({"ts":datetime.datetime.now().isoformat(timespec="seconds"),"hook":"PostToolUse","tool":"Bash-diff","blocked":bool(rules),"rules":rules,"lines":viol.splitlines()},ensure_ascii=False)+"\n")
PY
if [[ -n "$VIOL" ]]; then echo "방금 변경한 코드가 CLAUDE.md 규칙에 걸립니다. 고치세요:" >&2; echo "$VIOL" >&2; exit 2; fi
exit 0
