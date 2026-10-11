---
id: D-006
date: 2026-09-30
area: 디자인 토큰
status: active
supersedes: []
superseded_by: null
---
# 토큰은 CSS 변수가 아니라 TS 상수다

## 결정
`libs/ui/src/tokens.ts` 의 `as const` 객체가 단일 출처다.

## 이유
라이브러리에 CSS 파일이 없다.

## 이전
Card 가 `#ccc` 를 직접 들고 있던 것 / CSS 변수 계획
