/**
 * 보드 도메인. React도 fetch도 모른다. 순수 함수만 있다.
 */
export type Column = 'todo' | 'doing' | 'done';

export interface Task {
    id: string;
    title: string;
    column: Column;
}

export interface Board {
    tasks: Task[];
}

export const COLUMNS: Column[] = ['todo', 'doing', 'done'];

export function addTask(board: Board, title: string, id: string = crypto.randomUUID()): Board {
    const trimmed = title.trim();
    if (!trimmed) return board;
    return {tasks: [...board.tasks, {id, title: trimmed, column: 'todo'}]};
}

export function moveTask(board: Board, id: string, to: Column): Board {
    return {tasks: board.tasks.map(t => (t.id === id ? {...t, column: to} : t))};
}

export function tasksIn(board: Board, column: Column): Task[] {
    return board.tasks.filter(t => t.column === column);
}
