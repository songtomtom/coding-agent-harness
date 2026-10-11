---
id: D-004
date: 2026-10-05
area: 도메인
status: active
supersedes: []
superseded_by: null
---
# 열의 순서는 COLUMNS 하나다

## 결정
열 배열은 `libs/board-core` 의 `COLUMNS` 한 곳에만 있고, 화면은 이 배열을 돈다.

## 이유
admin 이 열 배열을 복사해 들고 있다가 두 앱이 어긋났다.

## 이전
admin 에 `['todo','doing','done']` 복사본
