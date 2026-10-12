#!/usr/bin/env node
/**
 * 테스트 케이스 JSON 을 실제 브라우저(Chromium)에서 실행하고 결과를 JSON 으로 쓴다.
 * 사용: node tools/qa/run.mjs <tc.json> <out.json>
 * tc.json: { "baseURL": "http://localhost:4200", "cases": [ { "id": "TC-01", "title": "...", "steps": [ {"goto": "/"}, {"fill": ["input", "글 쓰기"]}, {"click": "text=추가"}, {"expectText": "글 쓰기"} ] } ] }
 * 안전: baseURL 호스트가 localhost/127.0.0.1 이 아니면 실행하지 않는다.
 */
import {chromium} from 'playwright';
import {readFileSync, writeFileSync} from 'node:fs';

const [tcPath, outPath] = process.argv.slice(2);
if (!tcPath || !outPath) { console.error('usage: run.mjs <tc.json> <out.json>'); process.exit(2); }
const tc = JSON.parse(readFileSync(tcPath, 'utf8'));
const host = new URL(tc.baseURL).hostname;
if (!['localhost', '127.0.0.1', '[::1]'].includes(host)) { console.error(`refused: ${host} is not a local host`); process.exit(3); }

const browser = await chromium.launch();
const results = [];
for (const c of tc.cases) {
    const page = await browser.newPage();
    const r = {id: c.id, title: c.title, status: 'Pass', step: null, error: null, console: []};
    page.on('console', m => { if (m.type() === 'error') r.console.push(m.text()); });
    try {
        for (const [i, s] of c.steps.entries()) {
            r.step = i;
            if (s.goto) await page.goto(new URL(s.goto, tc.baseURL).href, {waitUntil: 'networkidle'});
            else if (s.fill) await page.fill(s.fill[0], s.fill[1]);
            else if (s.click) await page.click(s.click);
            else if (s.expectText) await page.getByText(s.expectText, {exact: false}).first().waitFor({timeout: 3000});
            else if (s.expectCount) { const n = await page.locator(s.expectCount[0]).count(); if (n !== s.expectCount[1]) throw new Error(`count ${n} != ${s.expectCount[1]}`); }
            else throw new Error(`unknown step ${JSON.stringify(s)}`);
        }
    } catch (e) {
        r.status = 'Fail'; r.error = String(e.message || e).split('\n')[0];
        await page.screenshot({path: `${outPath}.${c.id}.png`}).catch(() => {});
    }
    await page.close(); results.push(r);
}
await browser.close();
const summary = {total: results.length, pass: results.filter(r => r.status === 'Pass').length, fail: results.filter(r => r.status === 'Fail').length};
writeFileSync(outPath, JSON.stringify({baseURL: tc.baseURL, ranAt: new Date().toISOString(), summary, results}, null, 2));
console.log(JSON.stringify(summary));
for (const r of results) console.log(`${r.status === 'Pass' ? '✓' : '✗'} ${r.id} ${r.title}${r.error ? ' — ' + r.error : ''}`);
