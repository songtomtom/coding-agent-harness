---
id: D-005
date: 2026-10-04
area: ui
status: active
supersedes: []
superseded_by: null
---
# ui 컴포넌트에 variant 를 두지 않는다

## 결정
모양 분기는 props 로 토큰 값을 넘겨 해결하고 `variant` 같은 의미 분기를 두지 않는다.

## 이유
라이브러리가 앱의 의미(danger)를 알게 된다.

## 이전
`Button` 에 `variant="danger"` 를 넣었던 것
