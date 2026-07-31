#!/usr/bin/env bash
# Ndërto Girih-un për web dhe vendose te girih.spacecode.tech.
#
# Ekzekutohet MBI Ampere (aty është Flutter-i dhe aty është /mnt/data):
#   ssh ampere 'PATH=$PATH:/mnt/data/flutter/bin /mnt/data/workspace/girih/deploy/vendos.sh'
#
# 🚨 Tri gjërat që ky skript i bën PAS `flutter build` — dhe pa të cilat një
#    ndryshim i vendosur nuk e arrin lojtarin:
#
#    1. `--pwa-strategy=none` e ndalon regjistrimin e RI të një shërbëtori pune,
#       por NUK e heq atë që një ndërtim i mëparshëm e ka regjistruar tashmë te
#       telefoni. Prandaj mbi skedarin bosh vihet një shërbëtor vetëvrasës.
#    2. `main.dart.js` dhe `flutter_bootstrap.js` nuk e mbajnë hash-in te emri.
#       Cloudflare-i i kësaj zone e mbishkruan `no-cache` të nginx-it me
#       `max-age=14400`, pra pa një `?v=` shfletuesi rri KATËR ORË me kodin e
#       vjetër. I njëjti kurth u zgjidh njësoj te SpaceChess-i.
#    3. Cache-i i Cloudflare-it pastrohet, përndryshe skaji vazhdon të shërbejë
#       paketën e mëparshme edhe kur origjina është e re.
set -euo pipefail

DEPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DALJA=/mnt/data/girih-web
ZONA=3fc0dc3a63b9c3837be19199b7a56cfb

cd "$DEPO"

echo "→ testet"
flutter test

echo "→ ndërtimi"
flutter build web --release --pwa-strategy=none

W=build/web

echo "→ shërbëtori vetëvrasës"
cp deploy/sherbetori-vdes.js "$W/flutter_service_worker.js"

echo "→ URL me hash"
H=$(md5sum "$W/main.dart.js" | cut -c1-10)
sed -i "s|main\.dart\.js|main.dart.js?v=$H|g" "$W/flutter_bootstrap.js"
sed -i "s|flutter_bootstrap\.js|flutter_bootstrap.js?v=$H|" "$W/index.html"
echo "   v=$H"

echo "→ kopjimi te $DALJA"
mkdir -p "$DALJA"
rsync -a --delete "$W/" "$DALJA/"
cp web/privatesia.html "$DALJA/" 2>/dev/null || true

echo "→ pastrimi i Cloudflare-it"
: "${CF_TOKEN:?vendos CF_TOKEN (shih credentials.local.txt)}"
curl -s -X POST "https://api.cloudflare.com/client/v4/zones/$ZONA/purge_cache" \
  -H "Authorization: Bearer $CF_TOKEN" -H "Content-Type: application/json" \
  --data '{"hosts":["girih.spacecode.tech"]}' | head -c 200
echo

echo "→ gjendja live"
curl -s https://girih.spacecode.tech/ | grep -o 'flutter_bootstrap\.js?v=[a-f0-9]*'
echo "✅ u vendos"
