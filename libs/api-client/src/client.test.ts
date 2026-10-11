import {beforeEach, describe, expect, it} from 'vitest';
import {addTask} from '@board/board-core';
import {loadBoard, saveBoard} from './client';

describe('api-client', () => {
    beforeEach(() => localStorage.clear());

    it('저장한 보드를 그대로 돌려준다', async () => {
        const board = addTask({tasks: []}, '글 쓰기', 'a');
        await saveBoard(board);
        expect(await loadBoard()).toEqual(board);
    });

    it('저장한 적 없으면 빈 보드다', async () => {
        expect(await loadBoard()).toEqual({tasks: []});
    });
});
