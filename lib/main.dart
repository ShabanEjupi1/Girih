/// Girih — lidh nyjet, zbulo yllin.
///
/// Lojë enigmash me 300 nivele: pa llogari, pa blerje brenda aplikacionit dhe
/// pa asnjë thirrje drejt një shërbimi me pagesë. **Vetë loja luhet e plotë pa
/// internet** — nivelet janë të ngulura në kod dhe përparimi rri në pajisje.
///
/// 🚨 Nga 1.2.0 aplikacioni ka reklama, pra nuk është më «pa rrjet fare». Ky
/// dallim është i rëndësishëm dhe nuk duhet zbutur askund: te listimi, te
/// politika e privatësisë dhe te «Siguria e të dhënave» duhet thënë
/// **«luhet pa internet»**, jo «nuk lidhet me internetin». E dyta do të ishte
/// e pavërtetë, dhe kundërshtia mes listimit dhe Data safety është nga shkaqet
/// më të shpeshta të pezullimit te Play.
library;

import 'dart:async';

import 'package:flutter/material.dart';

import 'app/ads.dart';
import 'app/analitika.dart';
import 'pamja/faqja_kryesore.dart';
import 'pamja/orientimi.dart';
import 'pamja/tema.dart';
import 'te_dhena/ruajtja.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final ruajtja = await Ruajtja.hap();
  // 🚨 Orientimi NUK kyçet më këtu. Kyçi pa kushte ishte shkaku pse loja del si
  // shirit i ngushtë te Google Play Games on PC. Vendimi merret tani sipas
  // madhësisë së dritares, te [OrientimiPershtatur].
  // Pa `await`: nisja e reklamave përfshin formularin e pëlqimit dhe një
  // udhëtim rrjeti. Loja nuk pret asgjë prej tyre — banderola thjesht shfaqet
  // pak çaste më vonë, ose kurrë.
  // Matja nis PARA reklamave: një hapje që dështon te formulari i pëlqimit
  // duhet numëruar prapë, përndryshe humbasin pikërisht hapjet problematike.
  unawaited(Analitika.nis());
  unawaited(Ads.start());
  runApp(Girih(ruajtja: ruajtja));
}

class Girih extends StatelessWidget {
  const Girih({super.key, required this.ruajtja});
  final Ruajtja ruajtja;

  @override
  Widget build(BuildContext context) {
    // Ruajtja është një `ChangeNotifier`: një ndryshim cilësimesh e rindërton
    // krejt aplikacionin, ndaj tema dhe gjuha ndërrohen menjëherë kudo pa e
    // bartur gjendjen dorë më dorë nëpër ekrane.
    return AnimatedBuilder(
      animation: ruajtja,
      builder: (context, _) => MaterialApp(
        title: 'Girih',
        debugShowCheckedModeBanner: false,
        theme: temaPer(ruajtja.cilesimet.pamja),
        // `builder` dhe jo një mbështjellës rreth `home`-it: kështu rregulli
        // vlen edhe për faqet e hapura me Navigator, jo vetëm për të parën.
        builder: (context, child) =>
            OrientimiPershtatur(child: child ?? const SizedBox.shrink()),
        home: FaqjaKryesore(ruajtja: ruajtja),
      ),
    );
  }
}
