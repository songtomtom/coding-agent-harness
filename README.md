# nx-vite-pnpm-monorepo

단일 Vite React 앱을 Nx + pnpm workspace 모노레포로 쪼갠 예제입니다.

- `single-app` 태그: 전환 전. `src/` 하나에 UI, 도메인, API 계층이 폴더로만 나뉘어 있다.
- `main`: 전환 후. 앱 2개와 라이브러리 3개. 라이브러리는 빌드하지 않고 `tsconfig.base.json`의 `paths`로 소스째 참조한다.

```
apps/
  board/        할 일 보드 앱
  admin/        열별 개수만 보여 주는 두 번째 앱
libs/
  ui/           @board/ui          Button, Card
  board-core/   @board/board-core  도메인 순수 함수
  api-client/   @board/api-client  저장소 계층 (localStorage)
nx.json           추론 플러그인(@nx/vite, @nx/vitest, @nx/eslint) 설정
eslint.config.mjs 태그 기반 import 방향 규칙(@nx/enforce-module-boundaries)
tsconfig.base.json  @board/* 경로 별칭의 단일 진실
pnpm-workspace.yaml
```

의존 방향은 `apps → libs` 단방향이고 `api-client → board-core` 만 라이브러리 간 의존입니다.

## 실행

```bash
pnpm install
pnpm exec nx run-many -t lint typecheck test build   # 5개 프로젝트, 17개 타깃
pnpm exec nx affected -t lint typecheck test build   # 바뀐 프로젝트와 그 의존자만
pnpm exec nx serve board                        # dev 서버, 주소는 출력을 본다
pnpm exec nx graph                              # 의존 그래프
```

두 앱을 preview로 띄우면 포트가 달라 localStorage 원본이 분리되므로 admin 은 board 에서 넣은 데이터를 보지 못합니다. 실제 앱이라면 `api-client` 가 서버를 가리키는 자리입니다.

## 글

- [단일 앱을 Nx 모노레포로 쪼개기](https://songtomtom.github.io/blog/nx-monorepo-split-single-app)
- [tsconfig paths 하나로 Vite와 Nx를 같이 맞추기](https://songtomtom.github.io/blog/nx-tsconfig-paths-boundaries-affected)
