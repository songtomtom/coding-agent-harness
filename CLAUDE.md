# board workspace

할 일 보드. 앱 2개(board, admin)와 라이브러리 4개(ui, i18n, board-core, api-client)로 된 Nx + pnpm 모노레포. 라이브러리는 빌드하지 않고 `tsconfig.base.json` 의 `paths` 로 소스째 참조한다.

이 파일은 **항상 지켜야 할 규칙만** 담는다. 절차는 `.claude/skills/`, 결정의 이유와 번복 이력은 `docs/decisions/` 에 있다.

| 하려는 일 | 읽을 것 |
|---|---|
| 열(Column) 추가 | `/add-column` |
| UI 컴포넌트 추가 | `/add-ui-component` |
| 문구 추가·변경 | `/i18n` |
| Nx 명령·테스트 실행 | `/nx` |
| 브라우저 수동 테스트 | `/qa-session` |
| "왜 이렇게 했나" | `docs/decisions/` |

Hook 이 쓰기 전에 금지 패턴을 막는다(규칙은 `harness/rules.py`). 막히면 우회하지 말고 규칙대로 고친다.

## 규칙

- **색·간격·모서리는 `@board/ui` 의 `tokens` 만.** `#2563eb`, `padding: 12` 같은 값을 직접 쓰지 않는다. 표에 없는 간격은 `tokens.space` 의 배수로 만든다. 예외는 두 앱 `<main>` 의 `fontFamily` 하나.
- **사용자에게 보이는 문구는 `t("영역.이름")`.** JSX 텍스트·`placeholder`·`title` 에 한국어·영어 리터럴을 두지 않는다. ko.json 과 en.json 은 키가 완전히 같아야 한다(`i18n.test.ts` 가 검사). 변수는 `{n}` 으로 넣고 문자열을 이어붙이지 않는다.
- **의존 방향은 `apps → libs` 단방향, 라이브러리 간은 `api-client → board-core` 만.** 라이브러리는 `@board/*` 별칭으로만 가져온다(상대 경로로 `libs/` 진입 금지). 공개 API 는 각 `src/index.ts`.
- **board-core 는 순수 함수만.** `window`·`document`·`localStorage`·`fetch`·React 를 모른다. 상태를 바꾸는 함수는 새 `Board` 를 돌려준다. 열의 순서는 `COLUMNS` 하나이고 화면은 이 배열을 돈다(`repeat(3, 1fr)` 처럼 열 수를 박지 않는다).
- **ui 컴포넌트는 도메인을 모르고(`Task` 를 받지 않는다), `variant` 같은 모양 분기를 두지 않는다.** 새 컴포넌트는 `index.ts` export 와 `.test.tsx` 가 있어야 한다.
- **`console.log` 금지.** 저장 실패는 `console.error`.
- **테스트는 대상 옆 `<이름>.test.ts(x)`.** `__tests__` 폴더 없음. 도메인 테스트는 id 를 넘겨 결정적으로. 화면 테스트에서 Worker 를 mock 하지 않는다(jsdom 에 없으면 메인 스레드에서 센다).
- **버튼 텍스트는 동사 하나("추가").** 열 이동 버튼은 `board.moveTo`(`→ {열}`) 키.

## 메모

- `dist/`·`.nx/` 는 산출물·캐시(gitignore). 두 앱의 `vite.config.ts` 는 같은 모양을 유지한다.
- 두 앱을 preview 로 띄우면 포트가 달라 localStorage 가 분리된다. admin 이 board 의 데이터를 못 보는 것은 버그가 아니다.
