#!/usr/bin/env bash
# 고정 작업을 격리된 worktree 에서 claude -p 로 실행하고 채점한다.
# 사용: harness/eval/run.sh --ref <git-ref> --run <run-id> [--tasks T01,T02] [--model <m>] [--max-turns N] [--budget USD]
set -euo pipefail
ROOT="$(git rev-parse --show-toplevel)"; EVAL="$ROOT/harness/eval"
REF=main; RUN=""; TASKS=""; MODEL=""; MAX_TURNS=60; BUDGET=5
while [[ $# -gt 0 ]]; do case "$1" in
  --ref) REF="$2"; shift 2;; --run) RUN="$2"; shift 2;; --tasks) TASKS="$2"; shift 2;;
  --model) MODEL="$2"; shift 2;; --max-turns) MAX_TURNS="$2"; shift 2;; --budget) BUDGET="$2"; shift 2;;
  *) echo "unknown arg $1"; exit 2;; esac; done
[[ -n "$RUN" ]] || { echo "--run <id> 필요"; exit 2; }
OUT="$EVAL/results/$RUN"; mkdir -p "$OUT"
WT_BASE="${HARNESS_WT:-/tmp/harness-eval-cah}/$RUN"; mkdir -p "$WT_BASE"
SHA="$(git rev-parse "$REF")"
echo "{\"run\":\"$RUN\",\"ref\":\"$REF\",\"sha\":\"$SHA\",\"model\":\"${MODEL:-default}\",\"max_turns\":$MAX_TURNS,\"budget_usd\":$BUDGET,\"started\":\"$(date -Iseconds)\",\"claude\":\"$(claude --version | head -1)\"}" > "$OUT/run.json"
[[ -z "$TASKS" ]] && LIST=$(ls "$EVAL/tasks" | sed 's/\.md$//' | tr '\n' ' ') || LIST=$(echo "$TASKS" | tr ',' ' ')
for T in $LIST; do
  WT="$WT_BASE/$T"; echo "== $T ($REF) → $WT"
  rm -rf "$WT"; git worktree prune; git worktree add --detach -q "$WT" "$SHA"
  # pnpm workspace 의 node_modules 를 전부 심링크 (루트 + 각 프로젝트)
  for nm in $(cd "$ROOT" && find . -maxdepth 3 -name node_modules -type d -not -path '*/node_modules/*'); do
    mkdir -p "$WT/$(dirname "$nm")"; ln -s "$ROOT/$nm" "$WT/$nm"; done
  PROMPT="$(awk 'BEGIN{fm=0} /^---$/{fm++; next} fm>=2{print}' "$EVAL/tasks/$T.md")"
  START=$(date +%s)
  (cd "$WT" && claude -p "$PROMPT" --output-format stream-json --verbose --dangerously-skip-permissions \
      --max-turns "$MAX_TURNS" --max-budget-usd "$BUDGET" ${MODEL:+--model "$MODEL"} \
      > "$OUT/$T.stream.jsonl" 2> "$OUT/$T.stderr") || echo "   claude 비정상 종료 (exit $?)"
  grep '"type":"result"' "$OUT/$T.stream.jsonl" | tail -1 > "$OUT/$T.claude.json" || true
  echo "   claude $(( $(date +%s) - START ))s"
  "$EVAL/score.sh" "$WT" "$T" "$OUT" "$EVAL/tasks/$T.md"
  (cd "$WT" && git add -A -- . ":(exclude)**/node_modules" ":(exclude)node_modules" >/dev/null 2>&1; git diff --cached > "$OUT/$T.patch") || true
  [[ -f "$WT/.claude/logs/hook-blocks.jsonl" ]] && cp "$WT/.claude/logs/hook-blocks.jsonl" "$OUT/$T.hooks.jsonl"
  git worktree remove --force "$WT"
done
echo "done → $OUT"
