# coding-agent-harness

코딩 에이전트(Claude Code)를 위한 하네스를 한 층씩 쌓으면서 **같은 작업을 다시 돌려 효과를 재는** 예제입니다. 코드베이스는 [nx-vite-pnpm-monorepo](https://github.com/songtomtom/nx-vite-pnpm-monorepo)(할 일 보드, 앱 2개 + 라이브러리 4개)를 출발점으로 디자인 토큰과 i18n 을 더해, 지킬 규칙이 생기게 했습니다.

태그가 곧 층입니다.

| 태그 | 상태 |
|---|---|
| `before` | 규칙·절차·결정 이유가 섞인 123줄 CLAUDE.md 하나 |
| `after-rules` | CLAUDE.md 29줄(행동 규칙만) + `.claude/skills/` 4종(절차) + `docs/decisions/` 10건(이유·번복) |
| `after-qa` | + 절차형 Skill `/qa-session`(범위→TC→승인→실행→리포트) + `tools/qa/run.mjs`(localhost 만 허용) |
| `after-hooks-pre` | + Write/Edit 에 PreToolUse 금지 패턴 차단 |
| `after-hooks` | + Bash 뒤 변경 줄 검사, Stop 에서 typecheck+규칙 (쓰기 도구와 무관) |
| `after-agents` | + 서브에이전트 `rule-reviewer`(읽기 전용 리뷰), `decision-lookup` |

리뷰 시나리오용 브랜치 `seed-on-after-hooks`, `seed-on-after-agents` 는 규칙 위반 3개를 심은 커밋을 각 태그 위에 올린 것이다.

## 구조

```
apps/board, apps/admin           할 일 보드 · 열별 개수
libs/ui                          Button, Card, tokens(색·간격의 단일 출처)
libs/i18n                        t(), ko/en 사전, 대칭 테스트
libs/board-core                  도메인 순수 함수(COLUMNS 가 열의 단일 출처)
libs/api-client                  저장소(localStorage)
.claude/skills/                  add-column · add-ui-component · i18n · nx
docs/decisions/                  D-001 ~ D-010
harness/rules.py                 CLAUDE.md 규칙 중 기계 판정 가능한 것 (grep)
harness/rules_diff.py            추가한 줄만 검사 (쓰기 도구와 무관)
harness/eval/                    고정 작업 5개 · 격리 실행 · 자동 채점 · 비교표
```

## 실행

```bash
pnpm install
pnpm exec nx run-many -t lint typecheck test

# 같은 작업 9개를 태그마다 돌려 비교 (claude CLI 필요, 작업당 $0.1~0.3)
for ref in before after-rules after-hooks-pre after-hooks after-agents; do harness/eval/run.sh --ref $ref --run $ref; done
python3 harness/eval/report.py harness/eval/results/{before,after-rules,after-hooks-pre,after-hooks,after-agents}
# QA 게이트 시나리오 / 리뷰 시나리오
harness/eval/run.sh --ref after-qa --run qa-after --tasks-dir harness/eval/qa-tasks --scorer harness/eval/qa-score.sh
harness/eval/run.sh --ref seed-on-after-agents --run review-after --tasks-dir harness/eval/review-tasks --scorer harness/eval/review-score.sh
```

채점은 사람 판정 없이 `nx run-many -t typecheck lint test` 종료 코드, 추가한 줄의 규칙 위반(`harness/rules_diff.py`), 기대 파일 존재, 비용·턴·도구 사용만 기록합니다.

## 글

1. [규칙 문서는 길어질수록 안 지켜진다](https://songtomtom.github.io/blog/coding-agent-harness-rules-skills-decisions) — `before` → `after-rules`
2. [절차형 Skill: 승인 게이트와 안전 규칙](https://songtomtom.github.io/blog/coding-agent-harness-procedural-skill) — `after-qa`, `harness/eval/qa-tasks/`
3. [Hook은 어떻게 우회되는가](https://songtomtom.github.io/blog/coding-agent-harness-hooks-bypass) — `after-hooks-pre` → `after-hooks`
4. [역할이 다른 일은 다른 에이전트가](https://songtomtom.github.io/blog/coding-agent-harness-subagents) — `after-agents`, `harness/eval/review-tasks/`
5. [하네스가 맞는지 증명하기](https://songtomtom.github.io/blog/coding-agent-harness-evaluation) — `harness/eval/`
6. [616줄에서 배운 것](https://songtomtom.github.io/blog/coding-agent-harness-lessons)
