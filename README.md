# coding-agent-harness

코딩 에이전트(Claude Code)를 위한 하네스를 한 층씩 쌓으면서 **같은 작업을 다시 돌려 효과를 재는** 예제입니다. 코드베이스는 [nx-vite-pnpm-monorepo](https://github.com/songtomtom/nx-vite-pnpm-monorepo)(할 일 보드, 앱 2개 + 라이브러리 4개)를 출발점으로 디자인 토큰과 i18n 을 더해, 지킬 규칙이 생기게 했습니다.

태그가 곧 층입니다.

| 태그 | 상태 |
|---|---|
| `before` | 규칙·절차·결정 이유가 섞인 123줄 CLAUDE.md 하나 |
| `after-rules` | CLAUDE.md 29줄(행동 규칙만) + `.claude/skills/` 4종(절차) + `docs/decisions/` 10건(이유·번복) |

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

# 같은 작업 5개를 두 태그에서 돌려 비교 (claude CLI 필요, 작업당 $0.1~0.2)
harness/eval/run.sh --ref before --run before
harness/eval/run.sh --ref after-rules --run after-rules
python3 harness/eval/report.py harness/eval/results/before harness/eval/results/after-rules
```

채점은 사람 판정 없이 `nx run-many -t typecheck lint test` 종료 코드, 추가한 줄의 규칙 위반(`harness/rules_diff.py`), 기대 파일 존재, 비용·턴·도구 사용만 기록합니다.

## 글

1. [규칙 문서는 길어질수록 안 지켜진다](https://songtomtom.github.io/blog/coding-agent-harness-rules-skills-decisions) — `before` → `after-rules`
