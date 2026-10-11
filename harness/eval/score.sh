#!/usr/bin/env bash
# 사용: score.sh <worktree> <task-id> <out-dir> <task-md>  → <out-dir>/<task-id>.json
set -uo pipefail
WT="$1"; T="$2"; OUT="$(cd "$3" && pwd)"; TASK_MD="$(cd "$(dirname "$4")" && pwd)/$(basename "$4")"
EVAL="$(cd "$(dirname "$0")" && pwd)"; cd "$WT"
CHANGED=$( (git diff --name-only; git ls-files --others --exclude-standard) | grep -v -E '__pycache__|node_modules' | sort -u )
CODE=$(echo "$CHANGED" | grep -E '\.(ts|tsx)$' || true)
ADD=$(git diff --numstat | awk '{a+=$1} END{print a+0}'); DEL=$(git diff --numstat | awk '{d+=$2} END{print d+0}')
NEWL=$(git ls-files --others --exclude-standard | xargs -I{} cat {} 2>/dev/null | wc -l | tr -d ' ')
# nx: lint · typecheck · test (전체, 캐시 끔)
pnpm exec nx run-many -t typecheck --skip-nx-cache --output-style=static > "$OUT/$T.typecheck.txt" 2>&1; TC_EXIT=$?
TSC_ERRORS=$(grep -c "error TS" "$OUT/$T.typecheck.txt" || true)
pnpm exec nx run-many -t lint --skip-nx-cache --output-style=static > "$OUT/$T.lint.txt" 2>&1; LINT_EXIT=$?
LINT_ERRORS=$(grep -cE "^\s+[0-9]+:[0-9]+\s+error" "$OUT/$T.lint.txt" || true)
pnpm exec nx run-many -t test --skip-nx-cache --output-style=static > "$OUT/$T.test.txt" 2>&1; TEST_EXIT=$?
TEST_FAILED=$(grep -oE "Tests\s+[0-9]+ failed" "$OUT/$T.test.txt" | awk '{s+=$2} END{print s+0}')
# 규칙: 추가한 줄만
python3 "$EVAL/../rules_diff.py" --root "$WT" > "$OUT/$T.rules.txt" 2>/dev/null || true
RULES=$(grep -c '^R-' "$OUT/$T.rules.txt" || true)
python3 - "$TASK_MD" "$OUT/$T.claude.json" "$OUT/$T.json" "$OUT/$T.stream.jsonl" "$OUT/$T.rules.txt" "$WT/.claude/logs/hook-blocks.jsonl" <<PY
import json,sys,re,os,collections
task_md, cj, oj, stream, rules_txt, hooklog = sys.argv[1:7]
fm = re.search(r'^---\n(.*?)\n---', open(task_md,encoding='utf-8').read(), re.S).group(1)
lst = lambda k: [x.strip().strip('"') for x in (re.search(rf'^{k}:\s*\[(.*?)\]', fm, re.M).group(1).split(',') if re.search(rf'^{k}:\s*\[(.*?)\]', fm, re.M) else []) if x.strip()]
ef, et = lst('expect_files'), lst('expect_terms'); changed = """$CHANGED""".split()
try: c = json.load(open(cj))
except Exception: c = {}
res_text = c.get('result') or ''
tools = collections.Counter()
if os.path.exists(stream):
    for line in open(stream, encoding='utf-8', errors='ignore'):
        try: e = json.loads(line)
        except Exception: continue
        if e.get('type') == 'assistant':
            for b in (e.get('message') or {}).get('content') or []:
                if b.get('type') == 'tool_use': tools[b.get('name')] += 1
hooks = dict(pre_checks=0, pre_blocks=0, diff_blocks=0, stop_blocks=0, rules={})
if os.path.exists(hooklog):
    for line in open(hooklog, encoding='utf-8'):
        try: e = json.loads(line)
        except Exception: continue
        if e.get('hook') == 'PreToolUse':
            hooks['pre_checks'] += 1
            if e.get('blocked'): hooks['pre_blocks'] += 1
        elif e.get('hook') == 'PostToolUse' and e.get('blocked'): hooks['diff_blocks'] += 1
        elif e.get('hook') == 'Stop' and e.get('blocked'): hooks['stop_blocks'] += 1
        for r in (e.get('rules') or []) if e.get('blocked') else []: hooks['rules'][r] = hooks['rules'].get(r, 0) + 1
missing_f = [f for f in ef if f not in changed]; missing_t = [t for t in et if t not in res_text]
res = dict(task="$T", title=re.search(r'^title:\s*(.*)$', fm, re.M).group(1), changed_files=changed,
  lines_added=$ADD+$NEWL, lines_deleted=$DEL, typecheck_exit=$TC_EXIT, tsc_errors=$TSC_ERRORS, lint_exit=$LINT_EXIT, lint_errors=$LINT_ERRORS,
  test_exit=$TEST_EXIT, test_failed=$TEST_FAILED, rule_violations=$RULES, rule_lines=[l.strip() for l in open(rules_txt,encoding='utf-8') if l.startswith('R-')],
  expect_files=ef, missing_expect_files=missing_f, expect_terms=et, missing_expect_terms=missing_t, tools=dict(tools), hooks=hooks,
  claude=dict(is_error=c.get('is_error'), num_turns=c.get('num_turns'), cost_usd=c.get('total_cost_usd'), duration_ms=c.get('duration_ms')))
res['pass'] = ($TC_EXIT==0 and $LINT_EXIT==0 and $TEST_EXIT==0 and $RULES==0 and not missing_f and not missing_t and bool(len(changed)>0 or et))
json.dump(res, open(oj,'w',encoding='utf-8'), ensure_ascii=False, indent=1)
print(f"   {'PASS' if res['pass'] else 'FAIL'} tsc={res['tsc_errors']} lint={res['lint_errors']} test_fail={res['test_failed']} rules={res['rule_violations']} files={len(changed)} missing={missing_f+missing_t} turns={res['claude']['num_turns']} cost={res['claude']['cost_usd']} tools={dict(tools)}")
PY
