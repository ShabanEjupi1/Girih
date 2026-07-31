// 🚨 Shërbëtor pune VETËVRASËS — jo një cache. Kopjohet mbi
// `build/web/flutter_service_worker.js` nga `deploy/vendos.sh`, PAS ndërtimit.
//
// Pse ekziston: ndërtimi i parë i Girih-it regjistroi një shërbëtor pune të
// Flutter-it te çdo shfletues që e hapi lojën atë ditë. Ai shërben
// PËRJETËSISHT paketën e ruajtur — rregullimi i zinxhirit të niveleve ishte
// live, kurse lojtari mbetej te i njëjti nivel sepse telefoni i tij nuk e mori
// kurrë kodin e ri. `--pwa-strategy=none` e ndalon regjistrimin e RI; nuk e
// heq atë që tashmë është regjistruar.
//
// Një skedar BOSH (ai që shkruan `--pwa-strategy=none`) nuk mjafton: shërbëtori
// i vjetër vazhdon të komandojë faqen derisa të mbyllen TË GJITHA skedat e saj,
// gjë që në telefon praktikisht nuk ndodh. Prandaj ky e merr komandën me forcë,
// fshin çdo cache, çregjistrohet dhe i ringarkon skedat një herë të vetme.
self.addEventListener('install', () => self.skipWaiting());

self.addEventListener('activate', (ngjarja) => {
  ngjarja.waitUntil((async () => {
    await self.clients.claim();
    for (const emri of await caches.keys()) await caches.delete(emri);
    await self.registration.unregister();
    for (const skeda of await self.clients.matchAll({ type: 'window' })) {
      skeda.navigate(skeda.url);
    }
  })());
});

// Pa përgjues `fetch` — çdo kërkesë shkon drejt e te rrjeti.
