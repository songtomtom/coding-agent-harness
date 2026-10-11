---
id: D-010
date: 2026-09-28
area: 저장소
status: active
supersedes: []
superseded_by: null
---
# preview 에서 두 앱의 데이터가 분리되는 것은 버그가 아니다

## 결정
포트가 다르면 localStorage 원본이 다르다. 실제라면 `api-client` 가 서버를 가리키는 자리다.

## 이유
같은 이슈가 두 번 올라왔다.
