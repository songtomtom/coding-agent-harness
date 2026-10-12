#!/usr/bin/env bash
# QA 시나리오 채점: 도구 호출 순서(브라우저 실행 여부)와 산출물로 게이트 준수를 본다.
set -uo pipefail
WT="$1"; T="$2"; OUT="$(cd "$3" && pwd)"; TASK_MD="$(cd "$(dirname "$4")" && pwd)/$(basename "$4")"
python3 - "$WT" "$T" "$OUT" "$TASK_MD" <<'PY'
import json,sys,re,os,glob
wt,t,out,md=sys.argv[1:5]
fm=re.search(r'^---\n(.*?)\n---',open(md,encoding='utf-8').read(),re.S).group(1)
flag=lambda k: re.search(rf'^{k}:\s*true',fm,re.M) is not None
lst=lambda k: [x.strip().strip('"') for x in (re.search(rf'^{k}:\s*\[(.*?)\]',fm,re.M).group(1).split(',') if re.search(rf'^{k}:\s*\[(.*?)\]',fm,re.M) else []) if x.strip()]
cmds=[];tools={}
for line in open(f"{out}/{t}.stream.jsonl",encoding='utf-8',errors='ignore'):
    try: e=json.loads(line)
    except: continue
    if e.get('type')=='assistant':
        for b in (e.get('message') or {}).get('content') or []:
            if b.get('type')=='tool_use':
                tools[b['name']]=tools.get(b['name'],0)+1
                if b['name']=='Bash': cmds.append(b.get('input',{}).get('command',''))
ran=[c for c in cmds if re.search(r'run\.mjs|playwright|chromium',c)]
try: res=json.load(open(f"{out}/{t}.claude.json")).get('result') or ''
except: res=''
files=[]
for g in lst('expect_files_glob'): files+= [os.path.relpath(p,wt) for p in glob.glob(os.path.join(wt,g))]
missing_terms=[x for x in lst('expect_terms') if x not in res]
ok=True; reasons=[]
if flag('expect_no_run') and ran: ok=False; reasons.append(f"브라우저 실행 {len(ran)}회 (실행하면 안 됨)")
if flag('expect_run') and not ran: ok=False; reasons.append("브라우저 실행 없음")
for g in lst('expect_files_glob'):
    if not glob.glob(os.path.join(wt,g)): ok=False; reasons.append(f"산출물 없음 {g}")
if missing_terms: ok=False; reasons.append(f"응답에 없음 {missing_terms}")
c=json.load(open(f"{out}/{t}.claude.json")) if os.path.exists(f"{out}/{t}.claude.json") else {}
d=dict(task=t,title=re.search(r'^title:\s*(.*)$',fm,re.M).group(1),reasons=reasons,browser_runs=len(ran),run_commands=ran[:5],outputs=files,tools=tools,
       claude=dict(num_turns=c.get('num_turns'),cost_usd=c.get('total_cost_usd')),result_head=res[:600])
d['pass']=ok
json.dump(d,open(f"{out}/{t}.json","w"),ensure_ascii=False,indent=1)
print(f"   {'PASS' if ok else 'FAIL'} runs={len(ran)} outputs={len(files)} {reasons} turns={c.get('num_turns')} cost={c.get('total_cost_usd')}")
PY
