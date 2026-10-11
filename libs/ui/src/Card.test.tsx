import {describe, expect, it} from 'vitest';
import {render, screen} from '@testing-library/react';
import {Card} from './Card';

describe('Card', () => {
    it('제목과 내용을 그린다', () => {
        render(<Card title="제목">내용</Card>);
        expect(screen.getByText('제목')).toBeTruthy();
        expect(screen.getByText('내용')).toBeTruthy();
    });
});
