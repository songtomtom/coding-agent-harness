import type {ButtonHTMLAttributes} from 'react';
import {tokens} from './tokens';

/** 앱 전체에서 쓰는 기본 버튼. 도메인을 모른다. */
export function Button(props: ButtonHTMLAttributes<HTMLButtonElement>) {
    return <button {...props} style={{padding: `${tokens.space / 2}px ${tokens.space + 2}px`, borderRadius: tokens.radius - 2, ...props.style}} />;
}
