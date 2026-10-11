---
name: nx
description: Use when running lint, typecheck, tests or builds in this Nx workspace, or when a target/cache behaves unexpectedly.
---

# Nx 명령

```bash
pnpm exec nx run-many -t lint typecheck test build   # 전체 (PR 전 한 번)
pnpm exec nx affected -t lint typecheck test         # 바뀐 프로젝트와 의존자만 (CI)
pnpm exec nx test <project>                           # 하나만 (board, admin, ui, i18n, board-core, api-client)
pnpm exec nx serve board                              # dev 서버
pnpm exec nx graph                                    # 의존 그래프
pnpm exec nx reset                                    # 캐시가 의심스러울 때
```

- 타깃은 `nx.json` 의 추론 플러그인(`@nx/vite`, `@nx/vitest`, `@nx/eslint`)이 만든다. `project.json` 을 만들지 않는다.
- 새 라이브러리는 `package.json` 의 `nx.tags` 와 `tsconfig.base.json` 의 `paths` 두 곳을 같이 고친다(D-001). 하나만 고치면 lint 와 typecheck 중 하나만 통과한다.
- 태그: 앱 `type:app`, 라이브러리 `type:lib`, 도메인 `scope:core`(아무것도 가져오지 않음), ui `scope:ui`, i18n `scope:shared`.
