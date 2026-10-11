---
name: add-column
description: Use when adding, renaming or reordering a board column (todo/doing/done) in this workspace.
---

# 열(Column) 추가

열은 `libs/board-core` 가 먼저다. 화면은 `COLUMNS` 를 돌며 그리므로 화면 코드는 고칠 것이 없어야 한다(D-004).

1. `libs/board-core/src/board.ts` — `Column` 유니온에 값 추가, `COLUMNS` 에 **순서대로** 추가.
2. `libs/i18n/src/ko.json`, `en.json` — `column.<값>` 키를 둘 다 추가(`/i18n`).
3. `libs/board-core/src/board.test.ts` — 새 열로 `moveTask` 하는 케이스 하나. id 를 넘겨 결정적으로.
4. `pnpm exec nx run-many -t typecheck test` — 화면을 고쳐야 통과한다면 어딘가에 열이 하드코딩된 것이다. 그것을 고친다(`repeat(N, 1fr)`, 열 배열 복사본).

## 체크
- [ ] `COLUMNS` 한 곳만 바뀌었다(앱에 열 배열 복사본 없음)
- [ ] ko/en 둘 다, 키 이름은 `column.<값>`
- [ ] 두 앱(board, admin)에 새 열이 보인다
