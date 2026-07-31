#!/usr/bin/env node
// Provë e drejtuar e Girih-it në një Chrome pa ekran.
//
// Loja vizatohet krejt në një canvas, ndaj asnjë selektor DOM nuk e gjen dot një
// buton: e vetmja rrugë janë koordinatat dhe fotoja e rezultatit.
//
//   node luaj.mjs <chrome-debug> <dosja> <url> [skedari-i-hapave]

import { readFileSync, writeFileSync } from 'node:fs';

const DEBUG = process.argv[2] || 'http://127.0.0.1:9222';
const OUT = process.argv[3] || '.';
const APP = process.argv[4] || 'https://girih.spacecode.tech/';
const HAPAT = process.argv[5];

const W = 390, H = 844, SCALE = 2;
const sleep = ms => new Promise(r => setTimeout(r, ms));

class Cdp {
  constructor(ws) { this.ws = ws; this.id = 0; this.waiting = new Map(); }

  static async open(wsUrl) {
    const ws = new WebSocket(wsUrl);
    await new Promise((ok, err) => { ws.onopen = ok; ws.onerror = err; });
    const cdp = new Cdp(ws);
    ws.onmessage = ev => {
      const msg = JSON.parse(ev.data);
      const p = cdp.waiting.get(msg.id);
      if (!p) return;
      cdp.waiting.delete(msg.id);
      msg.error ? p.err(new Error(msg.error.message)) : p.ok(msg.result);
    };
    return cdp;
  }

  send(method, params = {}) {
    const id = ++this.id;
    this.ws.send(JSON.stringify({ id, method, params }));
    return new Promise((ok, err) => this.waiting.set(id, { ok, err }));
  }

  async tap(x, y) {
    await this.send('Input.dispatchMouseEvent', { type: 'mousePressed', x, y, button: 'left', clickCount: 1, buttons: 1 });
    await sleep(70);
    await this.send('Input.dispatchMouseEvent', { type: 'mouseReleased', x, y, button: 'left', clickCount: 1, buttons: 0 });
    await sleep(700);
  }

  // Një tërheqje e vërtetë: shtypje, disa lëvizje të ndërmjetme, lëshim. Pikat e
  // ndërmjetme kanë rëndësi — pa to loja merr një kërcim të vetëm dhe pikërisht
  // ai është rasti që kodi i lojës duhet ta mbushë hap pas hapi.
  async drag(pikat) {
    const [x0, y0] = pikat[0];
    await this.send('Input.dispatchMouseEvent', { type: 'mousePressed', x: x0, y: y0, button: 'left', clickCount: 1, buttons: 1 });
    await sleep(40);
    for (let i = 1; i < pikat.length; i++) {
      const [xa, ya] = pikat[i - 1], [xb, yb] = pikat[i];
      for (let t = 1; t <= 3; t++) {
        await this.send('Input.dispatchMouseEvent', {
          type: 'mouseMoved', buttons: 1, button: 'left',
          x: xa + (xb - xa) * t / 3, y: ya + (yb - ya) * t / 3,
        });
        await sleep(12);
      }
    }
    const [xe, ye] = pikat[pikat.length - 1];
    await this.send('Input.dispatchMouseEvent', { type: 'mouseReleased', x: xe, y: ye, button: 'left', clickCount: 1, buttons: 0 });
    await sleep(220);
  }

  async shot(name) {
    await this.send('Page.bringToFront');
    const { data } = await this.send('Page.captureScreenshot', { format: 'png' });
    writeFileSync(`${OUT}/${name}.png`, Buffer.from(data, 'base64'));
    console.log(`✓ ${OUT}/${name}.png`);
  }
}

const tab = await (await fetch(`${DEBUG}/json/new?about:blank`, { method: 'PUT' })).json();
const cdp = await Cdp.open(tab.webSocketDebuggerUrl);
await cdp.send('Page.enable');
await cdp.send('Runtime.enable');
const gabimet = [];
cdp.ws.addEventListener('message', ev => {
  const m = JSON.parse(ev.data);
  if (m.method === 'Runtime.exceptionThrown') {
    gabimet.push(m.params.exceptionDetails.text + ' ' + (m.params.exceptionDetails.exception?.description || ''));
  }
});
await cdp.send('Emulation.setDeviceMetricsOverride', { width: W, height: H, deviceScaleFactor: SCALE, mobile: true });
await cdp.send('Emulation.setTouchEmulationEnabled', { enabled: true, maxTouchPoints: 5 });
await cdp.send('Page.navigate', { url: APP });
await sleep(14000);

const hapat = HAPAT ? JSON.parse(readFileSync(HAPAT, 'utf8')) : [{ shot: '00-fillimi' }];
for (const h of hapat) {
  if (h.tap) await cdp.tap(h.tap[0], h.tap[1]);
  if (h.drag) await cdp.drag(h.drag);
  if (h.wait) await sleep(h.wait);
  if (h.shot) await cdp.shot(h.shot);
}
if (gabimet.length) console.log('GABIME NË FAQE:\n' + gabimet.join('\n'));
else console.log('pa gabime në faqe');

await fetch(`${DEBUG}/json/close/${tab.id}`);
cdp.ws.close();
process.exitCode = 0;
