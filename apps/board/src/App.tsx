import {t} from '@board/i18n';
import {tokens} from '@board/ui';
import {BoardView} from './features/board/BoardView';

export function App() {
    return (
        <main style={{fontFamily: 'sans-serif', padding: tokens.space * 2}}>
            <h1>{t('board.title')}</h1>
            <BoardView />
        </main>
    );
}
