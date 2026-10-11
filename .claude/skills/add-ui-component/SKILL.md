---
name: add-ui-component
description: Use when creating or changing a shared UI component in libs/ui (@board/ui), including its tokens, test and export.
---

# UI 컴포넌트 추가 (`@board/ui`)

1. `libs/ui/src/<Name>.tsx` — 도메인을 모르는 props 만(`Task` 금지, `title: string`·`value: number` 처럼). 모양 분기 `variant` 금지(D-005) — 필요하면 props 로 토큰 값을 넘긴다.
2. 색·간격·모서리는 `./tokens` 에서. 인라인 숫자·`#hex` 금지. 새 값이 필요하면 `tokens.ts` 에 역할 이름으로 추가(`colorDanger`, `colorRed` 아님).
3. `libs/ui/src/<Name>.test.tsx` — 렌더 테스트 하나 이상(`Card.test.tsx` 모양).
4. `libs/ui/src/index.ts` 에 export. 여기 없으면 앱에서 못 쓴다.
5. 앱에서는 `import {Name} from '@board/ui'`.

## 체크
- [ ] props 에 도메인 타입 없음, `variant` 없음
- [ ] 파일 안에 `#`, `padding: 숫자` 없음
- [ ] index.ts export + .test.tsx
