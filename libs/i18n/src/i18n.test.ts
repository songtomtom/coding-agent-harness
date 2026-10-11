import {describe, expect, it} from 'vitest';
import {flatKeys, setLang, t} from './index';
import ko from './ko.json';
import en from './en.json';

describe('ko/en 키 대칭', () => {
    it('ko 에만 있는 키가 없다', () => {
        const enKeys = new Set(flatKeys(en));
        expect(flatKeys(ko).filter(k => !enKeys.has(k))).toEqual([]);
    });
    it('en 에만 있는 키가 없다', () => {
        const koKeys = new Set(flatKeys(ko));
        expect(flatKeys(en).filter(k => !koKeys.has(k))).toEqual([]);
    });
});

describe('t', () => {
    it('변수를 채운다', () => {
        setLang('ko');
        expect(t('admin.count', {n: 3})).toBe('3개');
    });
    it('없는 키는 키를 돌려준다', () => {
        expect(t('nope.key')).toBe('nope.key');
    });
});
