#!/usr/bin/env python3
"""results/<run>/*.json → 마크다운 비교표. 사용: report.py results/a results/b"""
import json, sys, glob, os
runs = sys.argv[1:]; rows = {}; names = [os.path.basename(r.rstrip('/')) for r in runs]
for r, n in zip(runs, names):
    for f in sorted(glob.glob(os.path.join(r, 'T[0-9][0-9].json'))):
        d = json.load(open(f, encoding='utf-8')); rows.setdefault(d['task'], {})[n] = d
print('| 작업 | ' + ' | '.join(names) + ' |'); print('|---|' + '---|' * len(names))
for t in sorted(rows):
    cells = []
    for n in names:
        d = rows[t].get(n)
        if not d: cells.append('-'); continue
        c = d['claude']; h = d.get('hooks', {}); tl = d.get('tools', {})
        hk = f" · 훅차단 {h.get('pre_blocks',0)+h.get('diff_blocks',0)+h.get('stop_blocks',0)}" if any(h.get(k) for k in ('pre_checks','diff_blocks','stop_blocks')) else ''
        cells.append(f"{'✅' if d['pass'] else '❌'} tsc {d['tsc_errors']} · lint {d['lint_errors']} · test {d['test_failed']} · 규칙 {d['rule_violations']}{hk} · {c.get('num_turns')}턴 · ${(c.get('cost_usd') or 0):.2f} · 도구 Bash {tl.get('Bash',0)}/Edit {tl.get('Edit',0)+tl.get('Write',0)}")
    print(f"| {t} {rows[t][next(iter(rows[t]))]['title']} | " + ' | '.join(cells) + ' |')
print()
for n in names:
    ds = [rows[t][n] for t in rows if n in rows[t]]
    if ds: print(f"**{n}**: 통과 {sum(d['pass'] for d in ds)}/{len(ds)} · 규칙 위반 합 {sum(d['rule_violations'] for d in ds)} · 턴 합 {sum(d['claude'].get('num_turns') or 0 for d in ds)} · 비용 ${sum((d['claude'].get('cost_usd') or 0) for d in ds):.2f}")
