---
id: D-009
date: 2026-10-06
area: 테스트
status: active
supersedes: []
superseded_by: null
---
# 화면 테스트에서 Worker 를 mock 하지 않는다

## 결정
jsdom 에 Worker 가 없으면 `BoardView` 가 메인 스레드에서 센다. 테스트는 그 경로를 그대로 쓴다.

## 이유
mock 이 실제 동작과 달라 테스트가 통과해도 화면이 틀렸다.

## 이전
Worker mock
