import {describe, expect, it} from 'vitest';
import {addTask, moveTask, tasksIn, type Board} from './board';

describe('board', () => {
    const empty: Board = {tasks: []};

    it('빈 제목은 추가하지 않는다', () => {
        expect(addTask(empty, '   ')).toBe(empty);
    });

    it('추가한 작업은 todo 열에 들어간다', () => {
        const b = addTask(empty, '글 쓰기', 'a');
        expect(tasksIn(b, 'todo')).toEqual([{id: 'a', title: '글 쓰기', column: 'todo'}]);
    });

    it('이동하면 원래 열에서 빠지고 새 열에 들어간다', () => {
        const b = moveTask(addTask(empty, '글 쓰기', 'a'), 'a', 'done');
        expect(tasksIn(b, 'todo')).toHaveLength(0);
        expect(tasksIn(b, 'done')).toHaveLength(1);
    });
});
