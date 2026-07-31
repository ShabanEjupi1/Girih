/// Girih — lidh nyjet, zbulo yllin.
///
/// Lojë enigmash me 240 nivele, plotësisht jashtë linje: pa llogari, pa rrjet,
/// pa reklama, pa blerje brenda aplikacionit dhe pa asnjë thirrje drejt një
/// shërbimi me pagesë. Kjo është edhe zgjedhje produkti edhe zgjedhje kostoje —
/// një lojë që nuk flet me askënd nuk mund të shpenzojë asgjë sado shumë të
/// luhet.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'pamja/faqja_kryesore.dart';
import 'pamja/tema.dart';
import 'te_dhena/ruajtja.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final ruajtja = await Ruajtja.hap();
  await SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
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
        home: FaqjaKryesore(ruajtja: ruajtja),
      ),
    );
  }
}
