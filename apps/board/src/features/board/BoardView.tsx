import {useEffect, useMemo, useState, type FormEvent} from 'react';
import {Button, Card, tokens} from '@board/ui';
import {t} from '@board/i18n';
import {COLUMNS, addTask, moveTask, tasksIn, type Board, type Column} from '@board/board-core';
import {loadBoard, saveBoard} from '@board/api-client';

export function BoardView() {
    const [board, setBoard] = useState<Board>({tasks: []});
    const [title, setTitle] = useState('');
    const [counts, setCounts] = useState<Record<string, number>>({});
    // jsdom(vitest)에는 Worker가 없다. 없으면 메인 스레드에서 센다.
    const worker = useMemo(
        () =>
            typeof Worker === 'undefined'
                ? null
                : new Worker(new URL('./stats.worker.ts', import.meta.url), {type: 'module'}),
        []
    );

    useEffect(() => {
        if (!worker) {
            setCounts(Object.fromEntries(COLUMNS.map(c => [c, tasksIn(board, c).length])));
            return;
        }
        worker.onmessage = (e: MessageEvent<Record<string, number>>) => setCounts(e.data);
        worker.postMessage(board);
    }, [board, worker]);

    useEffect(() => {
        loadBoard().then(setBoard);
    }, []);

    const update = (next: Board) => {
        setBoard(next);
        void saveBoard(next);
    };

    const onSubmit = (e: FormEvent) => {
        e.preventDefault();
        update(addTask(board, title));
        setTitle('');
    };

    return (
        <div>
            <form onSubmit={onSubmit} style={{marginBottom: tokens.space + 4}}>
                <input value={title} onChange={e => setTitle(e.target.value)} placeholder={t('board.placeholder')} />
                <Button type="submit">추가하기</Button>
            </form>
            <div style={{display: 'grid', gridTemplateColumns: `repeat(${COLUMNS.length}, 1fr)`, gap: tokens.space + 4}}>
                {COLUMNS.map(column => (
                    <Card key={column} title={`${t(`column.${column}`)} (${counts[column] ?? 0})`}>
                        {tasksIn(board, column).map(task => (
                            <div key={task.id} style={{margin: `${tokens.space - 2}px 0`}}>
                                {task.title}{' '}
                                {COLUMNS.filter(c => c !== column).map((to: Column) => (
                                    <Button key={to} onClick={() => update(moveTask(board, task.id, to))}>
                                        {t('board.moveTo', {column: t(`column.${to}`)})}
                                    </Button>
                                ))}
                            </div>
                        ))}
                    </Card>
                ))}
            </div>
        </div>
    );
}
