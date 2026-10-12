---
name: qa-session
description: Use when asked to QA, manually test, smoke-test or verify a screen or flow of this app in a real browser (/qa), including producing a test-case list and a report.
---

# /qa — 브라우저 수동 테스트 세션

사람 테스터 역할을 대신한다. vitest 테스트 코드를 쓰지 않는다 — 목표는 실제 브라우저에서 동작을 점검하는 것이다.
**순서를 건너뛰지 않는다: 범위 → TC 작성 → TC 승인 → 실행 → 리포트.**

## 0. 환경
- 대상 URL 을 확인한다. 기본은 `pnpm exec nx serve board`(출력된 localhost 주소). 서버가 안 떠 있으면 백그라운드로 띄우고 `curl` 로 확인한다.
- **localhost 가 아니면 실행하지 않는다.** 호스트가 외부(배포 주소로 보이는 것)면 즉시 중단하고 알린다. `tools/qa/run.mjs` 도 외부 호스트를 거부한다.
- 데이터는 브라우저 localStorage 뿐이라 변경해도 된다. 단 TC 가 만든 데이터는 TC 안에서 정리한다.

## 1. 범위
사용자가 범위를 말하지 않았으면 **질문하고 멈춘다**: 어느 앱(board/admin), 어느 흐름(추가·이동·개수), 깊이(화면만 / 저장까지). 이미 말했으면 다시 묻지 않는다.

## 2. TC 작성
- 대상 코드(`apps/<app>/src`, `libs/board-core`, `libs/i18n/src/ko.json`)를 읽고 기대 결과를 **코드에서 근거를 찾아** 쓴다. 근거 없는 기대는 "확인 필요"로 표시한다.
- 표로 보여 준다: `| ID | 절차 | 기대결과 | 근거 |`. 정상 흐름 + 경계(빈 입력, 공백만 입력)를 포함한다.
- 같은 내용을 `tools/qa/run.mjs` 가 읽는 JSON(`qa/tc-<범위>.json`)으로도 만든다. 셀렉터는 `text=`·`placeholder` 같은 사용자 관점 셀렉터를 쓴다.
- **여기서 멈춘다. 사용자가 TC 를 승인하기 전에는 브라우저를 열지 않는다(`run.mjs` 를 실행하지 않는다).** 수정 요청이 오면 고쳐서 다시 승인받는다.

## 3. 실행 (승인 후)
- `node tools/qa/run.mjs qa/tc-<범위>.json qa/result-<범위>.json`
- Fail 은 스크린샷(`result-*.png`)과 콘솔 오류를 근거로 재현 절차를 정확히 적는다.
- **버그를 발견해도 코드를 고치지 않는다.** 기록만 한다(요청 시에만 수정).
- 같은 조작이 2~3회 실패하거나 페이지가 안 뜨면 멈추고 알린다.

## 4. 리포트
`qa/report-<범위>-<날짜>.md`: 환경(URL·커밋) → 집계(총/Pass/Fail) → TC 결과 표 → 결함(심각도·재현·근거) → 관찰(실패는 아니지만 확인이 필요한 것). 끝에 파일 경로와 집계를 한 줄로 알린다.

## 흔한 실수
| 실수 | 대응 |
|---|---|
| 범위를 묻지 않고 TC 작성 | 1단계부터 |
| TC 승인 전에 run.mjs 실행 | 승인 게이트 |
| 외부 호스트에 실행 | 0단계 호스트 확인, run.mjs 가 거부 |
| 기대결과를 추측으로 | 코드 근거 없으면 "확인 필요" |
| vitest 테스트 작성 | 하지 않는다 — 브라우저 점검이 목표 |
| 발견한 버그를 고침 | 기록만 |
