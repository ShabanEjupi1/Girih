# Girih — lidh nyjet, zbulo yllin

Lojë enigmash: tërhiq nga çdo nyje te binjakja e saj dhe mbush krejt rrjetën.
**240 nivele** në 8 botë, nga 5×5 te 12×12, plus një sfidë e re çdo ditë.

Live: <https://girih.spacecode.tech>

## Çka e mban këtë lojë të drejtë

* **Çdo nivel ka një zgjidhje të VETME.** Kjo nuk është premtim, është kusht
  gjenerimi: `tool/gjenero.dart` e hedh poshtë çdo kandidat për të cilin
  `Zgjidhesi` gjen dy zgjidhje. Pa këtë, lojtari e mbush rrjetën ndryshe, loja
  ia refuzon, dhe ai ka të drejtë.
* **Niveli ruhet si zgjidhja e vet** — nyjet dhe muret nxirren nga forma. Prandaj
  një nivel i pazgjidhshëm nuk shprehet dot fare, dhe ndihma është e menjëhershme.
* **Pa rrjet, pa llogari, pa reklama, pa blerje.** Loja nuk bën asnjë kërkesë
  jashtë pajisjes. Kjo do të thotë gjithashtu se sado shumë të luhet, nuk kushton
  asnjë cent — asgjë s'varet nga një shërbim me faturë.
* 🕌 Pa qenie të gjalla dhe pa fat: e gjithë grafika është gjeometri girih e
  vizatuar me kod. Zero skedarë pamjeje në depo, pra zero detyrime licence.

## Ndërtimi

```bash
export PATH=$PATH:/mnt/data/flutter/bin
flutter test
flutter build web --release --pwa-strategy=none    # 🚨 --pwa-strategy=none
rsync -a --delete build/web/ /mnt/data/girih-web/
```

`--pwa-strategy=none` nuk është zgjedhje: shërbëtori i punës i Flutter-it vazhdon
të shërbejë ndërtimin e vjetër edhe pas rsync-ut edhe pas pastrimit të Cloudflare-it.

## Rigjenerimi i niveleve

```bash
dart run tool/gjenero.dart --prova=25000
```

⚠️ Fara është e ngulur me qëllim. Përparimi i lojtarit ruhet nën id-në e nivelit
(`b3-17`), ndaj një farë e re i zhbën yjet e fituar te çdo pajisje.
