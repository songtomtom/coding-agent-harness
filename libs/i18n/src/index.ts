import ko from './ko.json';
import en from './en.json';

export type Lang = 'ko' | 'en';
const dict: Record<Lang, unknown> = {ko, en};
let current: Lang = 'ko';

export function setLang(lang: Lang) {
    current = lang;
}

/** "a.b.c" 키를 현재 언어 사전에서 찾는다. 없으면 키 그대로 돌려준다(누락이 화면에 보이게). */
export function t(key: string, vars: Record<string, string | number> = {}): string {
    const value = key.split('.').reduce<unknown>((node, k) => (node as Record<string, unknown>)?.[k], dict[current]);
    const text = typeof value === 'string' ? value : key;
    return text.replace(/\{(\w+)\}/g, (_, name) => String(vars[name] ?? `{${name}}`));
}

/** 중첩 사전을 "a.b.c" 키 목록으로 편다. 대칭 테스트가 쓴다. */
export function flatKeys(node: unknown, prefix = ''): string[] {
    if (node && typeof node === 'object' && !Array.isArray(node)) {
        return Object.entries(node as Record<string, unknown>).flatMap(([k, v]) => flatKeys(v, prefix ? `${prefix}.${k}` : k));
    }
    return [prefix];
}
