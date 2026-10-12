#!/usr/bin/env bash
# 리뷰 시나리오 채점: 응답에 심은 위반 파일 3개가 전부 언급됐는지, 에이전트(Task 도구)를 썼는지.
set -uo pipefail
WT="$1"; T="$2"; OUT="$(cd "$3" && pwd)"; TASK_MD="$(cd "$(dirname "$4")" && pwd)/$(basename "$4")"
python3 - "$WT" "$T" "$OUT" "$TASK_MD" <<'PY'
import json,sys,re,os
wt,t,out,md=sys.argv[1:5]
fm=re.search(r'^---\n(.*?)\n---',open(md,encoding='utf-8').read(),re.S).group(1)
terms=[x.strip().strip('"') for x in re.search(r'^expect_terms:\s*\[(.*?)\]',fm,re.M).group(1).split(',')]
tools={}; subagents=[]
for line in open(f"{out}/{t}.stream.jsonl",encoding='utf-8',errors='ignore'):
    try: e=json.loads(line)
    except: continue
    if e.get('type')=='assistant':
        for b in (e.get('message') or {}).get('content') or []:
            if b.get('type')=='tool_use':
                tools[b['name']]=tools.get(b['name'],0)+1
                if b['name'] in ('Task','Agent'): subagents.append(b.get('input',{}).get('subagent_type') or b.get('input',{}).get('description'))
c=json.load(open(f"{out}/{t}.claude.json")) if os.path.exists(f"{out}/{t}.claude.json") else {}
res=c.get('result') or ''
found=[x for x in terms if x in res]; missing=[x for x in terms if x not in res]
d=dict(task=t,title=re.search(r'^title:\s*(.*)$',fm,re.M).group(1),pass=not missing,found=found,missing=missing,subagents=subagents,tools=tools,
       claude=dict(num_turns=c.get('num_turns'),cost_usd=c.get('total_cost_usd')),result=res)
json.dump(d,open(f"{out}/{t}.json","w"),ensure_ascii=False,indent=1)
print(f"   {'PASS' if not missing else 'FAIL'} found={len(found)}/{len(terms)} missing={missing} subagents={subagents} turns={c.get('num_turns')} cost={c.get('total_cost_usd')}")
PY
