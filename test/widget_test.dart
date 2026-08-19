/// Provë nisjeje: a ngrihet aplikacioni i vërtetë deri te faqja kryesore?
///
/// 🚨 Deri më 19-08-2026 këtu rrinte shablloni i Flutter-it — numëruesi me
/// `MyApp` dhe butonin `+`, që kjo lojë nuk i ka pasur kurrë. Skedari NUK
/// përpilohej («The name 'MyApp' isn't a class»), ndaj `flutter analyze` binte
/// dhe bashkë me të i gjithë zinxhiri i botimit te [[ndert-dhe-boto.sh]].
/// Dështonte i heshtur sepse asnjë ndërtim i mëparshëm nuk e kishte kaluar
/// analizën — 1.2.0 doli nga një rrugë tjetër.
///
/// 🔑 Prandaj nuk u fshi thjesht: një skedar i fshirë s'do të kishte kapur
/// asgjë. Kjo provë ngre `Girih`-un e vërtetë me `Ruajtja`-n e vërtetë, pra
/// kap një `main.dart` që s'ndërtohet dot — pikërisht ajo që shablloni s'e bënte.
///
/// ⚠️ `Ads.start()` NUK thirret: reklamat kërkojnë rrjet dhe formularin e
/// pëlqimit, dhe një provë që pret rrjetin nuk është më provë.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:girih/main.dart';
import 'package:girih/pamja/faqja_kryesore.dart';
import 'package:girih/te_dhena/ruajtja.dart';

void main() {
  testWidgets('aplikacioni ngrihet deri te faqja kryesore', (tester) async {
    // Pa këtë `Ruajtja.hap()` pret një kanal që te provat nuk ekziston.
    SharedPreferences.setMockInitialValues({});
    final ruajtja = await Ruajtja.hap();

    await tester.pumpWidget(Girih(ruajtja: ruajtja));
    await tester.pumpAndSettle();

    expect(find.byType(FaqjaKryesore), findsOneWidget);
  });
}
