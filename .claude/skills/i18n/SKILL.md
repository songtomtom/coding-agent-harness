---
name: i18n
description: Use when adding or changing any user-visible text so ko.json and en.json stay symmetric and t() is used.
---

# 문구 (ko/en)

파일: `libs/i18n/src/ko.json`, `en.json`. 키는 `<영역>.<이름>` — `board.*`, `admin.*`, `column.*`(두 앱 공용).

1. 같은 뜻의 키가 있는지 `grep -n '"문구"' libs/i18n/src/ko.json` 으로 먼저 찾는다.
2. ko 와 en 을 **같은 자리에 같이** 넣는다. 한쪽만 넣으면 `i18n.test.ts` 가 실패한다.
3. 코드에서는 `t("키")`. 변수는 `{n}` 자리에 `t("admin.count", {n})`. 문자열 이어붙이기 금지.
4. 없는 키는 키가 그대로 화면에 보인다. 의도된 동작이다(D-002) — 빈 문자열로 바꾸지 않는다.
5. 테스트는 ko 값으로 찾는다. `setLang('en')` 을 쓴 테스트는 끝에 `setLang('ko')`(D-003).
6. `pnpm exec nx test i18n`.
