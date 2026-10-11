# 결정 기록

CLAUDE.md 에는 행동 규칙만 두고, **왜 그렇게 정했는지와 번복 이력**은 여기에 둔다. 결정 하나당 파일 하나.

## 추가 절차
1. 마지막 ID + 1 로 `D-0xx-<slug>.md` 를 만든다(frontmatter: id·date·area·status·supersedes·superseded_by).
2. 이전 결정을 번복하면 새 파일의 `supersedes` 에 이전 ID 를, 이전 파일의 `status: superseded`·`superseded_by` 를 적는다.
3. CLAUDE.md 에는 결정 사유를 쓰지 않는다. 규칙만 바꾸고 이유는 여기에.

| ID | 날짜 | 영역 | 제목 | 상태 |
|---|---|---|---|---|
| D-001 | 2026-09-29 | 모듈 경계 | [새 라이브러리는 tags 와 paths 두 곳을 같이 고친다](D-001-tags-and-paths.md) | active |
| D-002 | 2026-10-02 | i18n | [없는 키는 키를 그대로 돌려준다](D-002-missing-key-returns-key.md) | active |
| D-003 | 2026-10-03 | i18n / 테스트 | [setLang 을 바꾼 테스트는 ko 로 되돌린다](D-003-reset-lang-in-tests.md) | active |
| D-004 | 2026-10-05 | 도메인 | [열의 순서는 COLUMNS 하나다](D-004-single-columns-source.md) | active |
| D-005 | 2026-10-04 | ui | [ui 컴포넌트에 variant 를 두지 않는다](D-005-no-variant-prop.md) | active |
| D-006 | 2026-09-30 | 디자인 토큰 | [토큰은 CSS 변수가 아니라 TS 상수다](D-006-tokens-as-ts-const.md) | active |
| D-007 | 2026-10-01 | 디자인 토큰 | [격자 gap 은 tokens.space + 4 를 허용한다](D-007-grid-gap-exception.md) | active |
| D-008 | 2026-10-03 | 문구 | [열 이동 버튼의 기호는 → 로 고정](D-008-move-button-arrow.md) | active |
| D-009 | 2026-10-06 | 테스트 | [화면 테스트에서 Worker 를 mock 하지 않는다](D-009-no-worker-mock.md) | active |
| D-010 | 2026-09-28 | 저장소 | [preview 에서 두 앱의 데이터가 분리되는 것은 버그가 아니다](D-010-preview-storage-split.md) | active |
