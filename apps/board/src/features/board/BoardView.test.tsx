import {describe, expect, it} from 'vitest';
import {fireEvent, render, screen} from '@testing-library/react';
import {BoardView} from './BoardView';

describe('BoardView', () => {
    it('입력한 할 일이 todo 열에 나타난다', async () => {
        render(<BoardView />);
        fireEvent.change(screen.getByPlaceholderText('할 일'), {target: {value: '글 쓰기'}});
        fireEvent.click(screen.getByText('추가'));
        expect(await screen.findByText('글 쓰기')).toBeTruthy();
    });
});
