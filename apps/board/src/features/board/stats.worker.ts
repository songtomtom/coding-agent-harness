import {COLUMNS, tasksIn, type Board} from '@board/board-core';

/**
 * 열별 개수를 메인 스레드 밖에서 센다. 개수 세기가 워커에 갈 일은 없지만,
 * 워커 번들이 라이브러리 별칭을 해석하는지 확인하는 가장 작은 예다.
 */
self.onmessage = (e: MessageEvent<Board>) => {
    const counts = Object.fromEntries(COLUMNS.map(c => [c, tasksIn(e.data, c).length]));
    self.postMessage(counts);
};
