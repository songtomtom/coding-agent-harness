# board workspace

할 일 보드. 앱 2개(board, admin)와 라이브러리 4개(ui, i18n, board-core, api-client)로 된 Nx + pnpm 모노레포.

## 프로젝트 개요

- **board**: 할 일을 추가하고 열(todo → doing → done) 사이로 옮기는 앱. `apps/board`.
- **admin**: 같은 데이터를 읽어 열별 개수만 보여 주는 앱. `apps/admin`.
- **@board/ui**: Button, Card, 디자인 토큰. 도메인을 모른다. `libs/ui`.
- **@board/i18n**: `t()`, ko/en 사전. `libs/i18n`.
- **@board/board-core**: 보드 도메인 순수 함수. React도 fetch도 모른다. `libs/board-core`.
- **@board/api-client**: 저장소 계층(localStorage). board-core 에만 의존. `libs/api-client`.
- 라이브러리는 빌드하지 않고 `tsconfig.base.json` 의 `paths` 로 소스째 참조한다.

## 디자인 토큰

### 원칙

1. 색·간격·모서리는 `libs/ui/src/tokens.ts` 의 `tokens` 가 단일 출처다.
2. 컴포넌트와 앱은 `#2563eb`, `12px`, `borderRadius: 4` 같은 값을 직접 쓰지 않고 `tokens.colorAccent`, `tokens.space`, `tokens.radius` 를 쓴다.
3. 새 값이 필요하면 tokens 에 이름을 붙여 추가한 뒤 쓴다. 이름은 역할(`colorDanger`)이지 값(`colorRed`)이 아니다.
4. 토큰 값은 `as const` 라 바꾸면 쓰는 곳 전부에 반영된다. 색 변경은 이 파일만 수정한다.

> 2026-09-30 사용자 결정: 처음엔 CSS 변수로 가려 했는데 CSS 파일이 없는 라이브러리라 TS 상수로 했다. CSS 변수로 바꾸지 말 것. 이전엔 Card 가 `#ccc` 를 직접 들고 있었다.

### 간격 체계

| 용도 | 값 | 비고 |
|------|----|------|
| 기본 간격 | `tokens.space` (8) | 패딩, 카드 사이 |
| 작은 간격 | `tokens.space / 2` | 버튼 안쪽 세로 |
| 큰 간격 | `tokens.space * 2` | 페이지 패딩 |
| 격자 gap | `tokens.space + 4` | 열 사이 |

**원칙**: 12, 16 같은 숫자를 직접 쓰지 않는다. 표에 없는 간격이 필요하면 `tokens.space` 의 배수로 만든다. `tokens.space + 4` 처럼 더하기는 격자 gap 한 곳만 허용(2026-10-01 사용자 결정 — 열 사이가 너무 좁다는 피드백으로 12 를 쓰되 토큰에서 파생).

**예외**: `fontFamily: 'sans-serif'` 는 토큰이 아니다. 두 앱의 `<main>` 에만 있고 늘리지 않는다.

## 문구 (i18n)

- 사용자에게 보이는 모든 문구는 `@board/i18n` 의 `t("...")` 로 쓴다. JSX 텍스트·`placeholder`·`title` 속성에 한국어·영어 리터럴을 두지 않는다.
- 키는 `<영역>.<이름>`: `board.*`(보드 앱), `admin.*`(관리 앱), `column.*`(열 이름, 두 앱 공용).
- **ko.json 과 en.json 은 키가 완전히 같아야 한다.** `libs/i18n/src/i18n.test.ts` 가 대칭을 검사한다. 한쪽만 넣고 끝내지 않는다.
- 변수는 `{n}` 꼴로 넣고 `t("admin.count", {n: 3})` 처럼 채운다. 문자열 이어붙이기(`count + "개"`)로 문구를 만들지 않는다.
- 없는 키를 `t()` 로 부르면 키가 그대로 화면에 보인다. 이것은 의도다 — 누락이 숨지 않게(2026-10-02 사용자 결정, 이전엔 빈 문자열을 돌려줬다).
- 열 이름(`column.todo` 등)은 사전에만 있다. `Column` 타입 값(`'todo'`)을 화면에 직접 찍지 않는다.

> 테스트에서 문구를 찾을 때는 ko 값으로 찾는다(`screen.getByText('추가')`). `setLang('en')` 을 부른 테스트는 끝나기 전에 `setLang('ko')` 로 되돌린다(2026-10-03 사용자 피드백 — 순서에 따라 다른 테스트가 깨졌다).

## 모듈 경계

- 의존 방향은 `apps → libs` 단방향. 라이브러리 간에는 `api-client → board-core` 만 있다. `eslint.config.mjs` 의 `@nx/enforce-module-boundaries` 가 태그로 강제한다.
- 태그: 앱은 `type:app`, 라이브러리는 `type:lib`, 도메인은 추가로 `scope:core`(아무것도 가져오지 않는다), ui 는 `scope:ui`, i18n 은 `scope:shared`.
- 라이브러리는 **`@board/*` 별칭으로만** 가져온다. `../../libs/ui/src/Button` 같은 상대 경로로 라이브러리 안으로 들어가지 않는다. 별칭의 단일 진실은 `tsconfig.base.json` 의 `paths` 다.
- 라이브러리의 공개 API 는 `src/index.ts` 다. 거기서 export 하지 않은 것은 밖에서 쓸 수 없다.
- 새 라이브러리를 만들면 `package.json` 의 `nx.tags`, `tsconfig.base.json` 의 `paths` 두 곳을 같이 고친다. 하나만 고치면 lint 는 통과하는데 typecheck 가 깨지거나 그 반대가 된다(2026-09-29 — i18n 라이브러리를 넣을 때 겪음).

## 도메인 (board-core)

- `libs/board-core/src/board.ts` 는 순수 함수만 있다. `window`, `document`, `localStorage`, `fetch`, React 를 쓰지 않는다. `crypto.randomUUID` 는 기본 인자에서만 쓴다(테스트가 id 를 넘길 수 있게).
- 상태를 바꾸는 함수는 새 `Board` 를 돌려준다. 입력을 변경하지 않는다.
- `COLUMNS` 배열이 열의 순서다. 화면은 이 배열을 돌며 그린다 — 열 수를 숫자로 박지 않는다(`repeat(3, 1fr)` 금지, `repeat(${COLUMNS.length}, 1fr)`).

## 열(Column) 추가 절차

열을 하나 더하면 다음 네 곳을 같이 고친다. 하나라도 빠지면 typecheck 나 i18n 테스트가 잡는다.

1. `libs/board-core/src/board.ts` — `Column` 유니온에 값 추가, `COLUMNS` 에 순서대로 추가.
2. `libs/i18n/src/ko.json`, `en.json` — `column.<값>` 키 둘 다.
3. `libs/board-core/src/board.test.ts` — 새 열로 `moveTask` 하는 케이스 하나.
4. 화면은 `COLUMNS` 를 돌므로 고칠 것이 없어야 한다. 고쳐야 한다면 어딘가에 열이 하드코딩된 것이다 — 그걸 고친다.

> 2026-10-05 사용자 결정: 열 추가는 board-core 가 먼저다. 화면에서 열 배열을 따로 들고 있던 적이 있었는데(admin 이 `['todo','doing','done']` 을 복사) 두 앱이 어긋났다. 지금은 `COLUMNS` 하나다.

## UI 컴포넌트 추가 절차

1. `libs/ui/src/<Name>.tsx` — 도메인을 모르는 props 만 받는다(`Task` 를 받지 않는다. `title: string` 처럼).
2. 색·간격은 `tokens` 에서. 인라인 숫자 금지.
3. `libs/ui/src/<Name>.test.tsx` — 렌더 테스트 하나 이상.
4. `libs/ui/src/index.ts` 에 export. 여기 없으면 앱에서 못 쓴다.
5. 앱에서는 `import {Name} from '@board/ui'`.

> 2026-10-04 사용자 결정: 컴포넌트에 `variant` 같은 모양 분기를 두지 않는다. 필요하면 props 로 토큰 값을 넘긴다. 이전엔 `Button` 에 `variant="danger"` 를 넣었다가 뺐다 — 라이브러리가 앱의 의미(danger)를 알게 되기 때문.

## 저장소 (api-client)

- `loadBoard`/`saveBoard` 가 전부다. 지금은 localStorage, 실제라면 서버.
- 두 앱을 preview 로 띄우면 포트가 달라 localStorage 가 분리된다. admin 이 board 의 데이터를 못 보는 것은 버그가 아니다(2026-09-28 — 이슈로 두 번 올라왔다).
- 저장 실패는 조용히 삼키지 않는다. `console.error` 로 남긴다. **`console.log` 는 어디에도 두지 않는다**(디버그 흔적이 커밋된 적이 있다, 2026-10-02).

## Nx 명령

```bash
pnpm exec nx run-many -t lint typecheck test build   # 전체
pnpm exec nx affected -t lint typecheck test         # 바뀐 프로젝트와 의존자만
pnpm exec nx serve board                              # dev 서버
pnpm exec nx graph                                    # 의존 그래프
```

- 타깃은 `nx.json` 의 추론 플러그인(`@nx/vite`, `@nx/vitest`, `@nx/eslint`)이 만든다. `project.json` 을 만들지 않는다.
- CI 는 `affected` 만 돈다. 로컬에서 PR 전엔 `run-many` 로 전체를 한 번 돈다.
- 캐시가 의심스러우면 `pnpm exec nx reset`.

## 테스트

- 테스트 파일은 대상 옆에 `<이름>.test.ts(x)`. `__tests__` 폴더를 만들지 않는다.
- 도메인 테스트는 id 를 넘겨 결정적으로 만든다(`addTask(board, '제목', 'id-1')`).
- 화면 테스트는 `@testing-library/react`. `BoardView.test.tsx` 가 기준이다.
- jsdom 에는 `Worker` 가 없다. `BoardView` 는 없으면 메인 스레드에서 센다 — 테스트에서 Worker 를 mock 하지 않는다(2026-10-06 사용자 결정, 이전엔 mock 이 있었는데 실제 동작과 달랐다).
- `pnpm exec nx test <project>` 로 하나만 돌릴 수 있다.

## 글자·접근성

- 버튼 텍스트는 동사 하나("추가")다. "추가하기", "추가 버튼" 같은 꼬리를 붙이지 않는다.
- 열 이동 버튼은 `→ {열 이름}` 꼴로 `board.moveTo` 키를 쓴다. 화살표를 다른 기호로 바꾸지 않는다(2026-10-03 사용자 결정 — `>` 로 바꿨다가 되돌림).
- `<h1>` 은 앱마다 하나, `t("board.title")`/`t("admin.title")`.
- 입력 칸은 `placeholder` 로 라벨을 대신한다(지금 폼이 하나뿐이라). 폼이 늘면 `<label>` 로 바꾼다.

## 메모

- `dist/` 는 빌드 산출물, `.nx/` 는 캐시. 둘 다 gitignore.
- 두 앱의 `vite.config.ts` 는 같은 모양이다. 한쪽만 고치지 않는다.
- 관련 글: 단일 앱을 Nx 모노레포로 쪼갠 과정은 블로그 시리즈 nx-vite-pnpm-monorepo 에 있다.
