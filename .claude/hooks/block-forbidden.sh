#!/usr/bin/env bash
# PreToolUse(Write|Edit|MultiEdit): 쓰려는 내용이 CLAUDE.md 규칙에 걸리면 차단하고 이유를 돌려준다. 기록은 .claude/logs/hook-blocks.jsonl
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"; mkdir -p "$ROOT/.claude/logs"
INPUT="$(cat)"
read -r TOOL FILE MODE < <(printf '%s' "$INPUT" | python3 -c '
import json,sys,os
d=json.load(sys.stdin); t=d.get("tool_name",""); i=d.get("tool_input",{}); f=i.get("file_path","")
root=os.path.realpath(sys.argv[1])
if f:
    rf=os.path.realpath(f)
    if rf.startswith(root+"/"): f=rf[len(root)+1:]
print(t, f, "full" if t=="Write" else "fragment")' "$ROOT")
[[ -z "$FILE" ]] && exit 0
case "$FILE" in *.ts|*.tsx) ;; *) exit 0;; esac
CONTENT="$(printf '%s' "$INPUT" | python3 -c '
import json,sys
d=json.load(sys.stdin); t=d.get("tool_name",""); i=d.get("tool_input",{})
print(i.get("content","") if t=="Write" else i.get("new_string","") if t=="Edit" else "\n".join(e.get("new_string","") for e in i.get("edits",[])))')"
FLAG=""; [[ "$MODE" == "fragment" ]] && FLAG="--fragment"
VIOL="$(printf '%s' "$CONTENT" | python3 "$ROOT/harness/rules.py" --text "$FILE" $FLAG 2>/dev/null | grep '^R-' || true)"
python3 - "$ROOT/.claude/logs/hook-blocks.jsonl" "$TOOL" "$FILE" "$MODE" "$VIOL" <<'PY'
import json,sys,datetime
log,tool,file,mode,viol=sys.argv[1:6]; rules=[l.split(" ",1)[0] for l in viol.splitlines() if l]
with open(log,"a",encoding="utf-8") as f: f.write(json.dumps({"ts":datetime.datetime.now().isoformat(timespec="seconds"),"hook":"PreToolUse","tool":tool,"file":file,"mode":mode,"blocked":bool(rules),"rules":rules,"lines":viol.splitlines()},ensure_ascii=False)+"\n")
PY
if [[ -n "$VIOL" ]]; then echo "CLAUDE.md 규칙 위반으로 쓰기를 막았습니다. 고쳐서 다시 쓰세요:" >&2; echo "$VIOL" >&2; exit 2; fi
exit 0
