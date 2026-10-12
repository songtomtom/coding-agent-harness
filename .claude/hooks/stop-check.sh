#!/usr/bin/env bash
# Stop: 끝내기 전에 typecheck 와 변경 줄 규칙 검사. 남아 있으면 끝내지 못하게 한다(한 번만 — stop_hook_active 면 통과).
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"; mkdir -p "$ROOT/.claude/logs"
ACTIVE="$(cat | python3 -c 'import json,sys; print(json.load(sys.stdin).get("stop_hook_active",False))')"; cd "$ROOT"
git diff --quiet HEAD -- '*.ts' '*.tsx' 2>/dev/null && [[ -z "$(git ls-files --others --exclude-standard -- '*.ts' '*.tsx')" ]] && exit 0
ERR="$(pnpm exec nx run-many -t typecheck --skip-nx-cache --output-style=static 2>&1 | grep 'error TS' || true)"; N=$(printf '%s' "$ERR" | grep -c 'error TS' || true)
VIOL="$(python3 harness/rules_diff.py --root "$ROOT" 2>/dev/null | grep '^R-' || true)"; V=$(printf '%s' "$VIOL" | grep -c '^R-' || true)
python3 - "$ROOT/.claude/logs/hook-blocks.jsonl" "$N" "$V" "$ACTIVE" "$VIOL" <<'PY'
import json,sys,datetime
log,n,v,active,viol=sys.argv[1:6]; rules=[l.split(" ",1)[0] for l in viol.splitlines() if l]
with open(log,"a",encoding="utf-8") as f: f.write(json.dumps({"ts":datetime.datetime.now().isoformat(timespec="seconds"),"hook":"Stop","tool":"typecheck+rules","blocked":(int(n)>0 or int(v)>0) and active!="True","tsc_errors":int(n),"rule_violations":int(v),"rules":rules,"stop_hook_active":active=="True"},ensure_ascii=False)+"\n")
PY
if [[ ( "$N" -gt 0 || "$V" -gt 0 ) && "$ACTIVE" != "True" ]]; then
  [[ "$N" -gt 0 ]] && { echo "typecheck 오류 $N건이 남아 있어 끝낼 수 없습니다:" >&2; echo "$ERR" | head -10 >&2; }
  [[ "$V" -gt 0 ]] && { echo "변경한 줄에 규칙 위반 $V건이 있어 끝낼 수 없습니다:" >&2; echo "$VIOL" >&2; }
  exit 2
fi
exit 0
