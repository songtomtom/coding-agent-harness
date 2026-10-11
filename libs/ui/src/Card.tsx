import type {ReactNode} from 'react';
import {tokens} from './tokens';

export function Card({title, children}: {title: string; children?: ReactNode}) {
    return (
        <section
            style={{border: `1px solid ${tokens.colorBorder}`, borderRadius: tokens.radius, padding: tokens.space, marginBottom: tokens.space}}
        >
            <strong>{title}</strong>
            {children}
        </section>
    );
}
