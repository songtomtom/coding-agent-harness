---
id: D-001
date: 2026-09-29
area: 모듈 경계
status: active
supersedes: []
superseded_by: null
---
# 새 라이브러리는 tags 와 paths 두 곳을 같이 고친다

## 결정
`package.json` 의 `nx.tags` 와 `tsconfig.base.json` 의 `paths` 를 함께 수정한다.

## 이유
i18n 라이브러리를 넣을 때 한 곳만 고쳐 lint 는 통과하고 typecheck 가 깨졌다.
