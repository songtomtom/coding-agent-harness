import {useEffect, useState} from 'react';
import {Card, tokens} from '@board/ui';
import {t} from '@board/i18n';
import {COLUMNS, tasksIn, type Board} from '@board/board-core';
import {loadBoard} from '@board/api-client';

/** 두 번째 앱. 같은 도메인·저장소를 읽어 열별 개수만 보여 준다. */
export function App() {
    const [board, setBoard] = useState<Board>({tasks: []});
    useEffect(() => {
        loadBoard().then(setBoard);
    }, []);
    return (
        <main style={{fontFamily: 'sans-serif', padding: tokens.space * 2}}>
            <h1>{t('admin.title')}</h1>
            {COLUMNS.map(column => (
                <Card key={column} title={t(`column.${column}`)}>
                    <p>{t('admin.count', {n: tasksIn(board, column).length})}</p>
                </Card>
            ))}
        </main>
    );
}
