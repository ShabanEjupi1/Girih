import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Kufiri i njëjtë që Android e përdor për `sw600dp`: nën të është telefon,
/// mbi të tablet, dritare desktopi ose Google Play Games on PC.
const double kGjeresiaEMadhe = 600;

/// Gjerësia më e madhe që i jepet përmbajtjes së një faqeje.
///
/// Fusha e lojës e mban vetë raportin (shih `Fusha` te `piktori.dart`: ana e
/// qelizës është minimumi mes dy përmasave), ndaj rrjeta nuk shtrembërohet
/// kurrë. Ajo që shtrembërohet pa këtë kufi është KOKA dhe KËMBËT: në një
/// dritare 1920px të gjera, numrat dhe butonat tërhiqen deri te të dy skajet
/// dhe faqja duket bosh në mes.
const double kGjeresiaMaks = 900;

/// A e ka kjo dritare hapësirën e një tableti a të një PC-je?
bool eshteEGjere(BuildContext context) =>
    MediaQuery.sizeOf(context).shortestSide >= kGjeresiaEMadhe;

/// Qendërzon dhe kufizon përmbajtjen te ekranet e gjera; te telefoni s'bën gjë.
class Kufizuar extends StatelessWidget {
  const Kufizuar({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: kGjeresiaMaks),
          child: child,
        ),
      );
}

/// Lejon peizazhin VETËM aty ku gjerësia sjell diçka; te telefoni mban portretin.
///
/// 🚨 Deri më 05-08-2026 orientimi kyçej pa kushte te `main()`, dhe **pikërisht
/// ai kyç — jo manifesti — është shkaku pse loja del si shirit i ngushtë te
/// Google Play Games on PC.** Manifesti nuk e ka kurrë `screenOrientation`,
/// ndaj kontrolli i tij nuk zbulon asgjë: kërkesa bëhet gjatë ekzekutimit me
/// [SystemChrome.setPreferredOrientations], dhe dritarja e PC-së e respekton.
class OrientimiPershtatur extends StatefulWidget {
  const OrientimiPershtatur({super.key, required this.child});

  final Widget child;

  @override
  State<OrientimiPershtatur> createState() => _OrientimiPershtaturState();
}

class _OrientimiPershtaturState extends State<OrientimiPershtatur> {
  bool? _eGjere;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // 🚨 Matja bëhet KËTU, nga MediaQuery, jo te `main()`. Atje
    // `PlatformDispatcher.views.first.physicalSize` mund të jetë ende zero para
    // kuadrit të parë, dhe kushti do të vendosej gabim njëherë e përgjithmonë.
    final eGjere = eshteEGjere(context);
    if (eGjere == _eGjere) return;
    _eGjere = eGjere;

    unawaited(SystemChrome.setPreferredOrientations(
      eGjere
          // Listë bosh = pa kufizim, pra sistemi vendos.
          ? const <DeviceOrientation>[]
          : const <DeviceOrientation>[
              DeviceOrientation.portraitUp,
              DeviceOrientation.portraitDown,
            ],
    ));
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
