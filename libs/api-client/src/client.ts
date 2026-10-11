import type {Board} from '@board/board-core';

/**
 * 서버 통신 계층. 이 예제는 서버가 없으므로 localStorage 를 원격 저장소처럼 쓴다.
 * 실제 앱이라면 fetch 로 바뀌는 자리이고, 그래서 도메인과 분리해 둔다.
 */
const KEY = 'board:v1';

export async function loadBoard(): Promise<Board> {
    const raw = localStorage.getItem(KEY);
    return raw ? (JSON.parse(raw) as Board) : {tasks: []};
}

export async function saveBoard(board: Board): Promise<void> {
    localStorage.setItem(KEY, JSON.stringify(board));
}
