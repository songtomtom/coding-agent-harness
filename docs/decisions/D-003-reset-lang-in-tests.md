---
id: D-003
date: 2026-10-03
area: i18n / 테스트
status: active
supersedes: []
superseded_by: null
---
# setLang 을 바꾼 테스트는 ko 로 되돌린다

## 결정
테스트에서 `setLang('en')` 을 썼으면 끝나기 전에 `setLang('ko')`.

## 이유
언어 상태가 모듈 전역이라 테스트 순서에 따라 다른 테스트가 깨졌다.
