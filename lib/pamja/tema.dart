/// Ngjyrat, paleta e shtigjeve dhe tema e aplikacionit.
///
/// 🕌 Asnjë figurë qenieje të gjallë askund në këtë lojë: e gjithë pamja është
/// gjeometri — yje tetëcepësh dhe rrjeta girih — e vizatuar me kod. Kjo është
/// arsyeja pse depoja s'ka asnjë skedar pamjeje, dhe pse s'ka asnjë detyrim
/// licence mbi asetet.
library;

import 'package:flutter/material.dart';

enum Pamja { erret, ndritshem, pergamene }

/// Deri në 24 shtigje në një rrjetë 12×12, pra paleta duhet të mbajë 24 ngjyra
/// që dallohen edhe pranë njëra-tjetrës edhe në një ekran telefoni në diell.
/// Renditja nuk është rastësore: ngjyrat fqinje në listë janë sa më larg njëra
/// tjetrës, sepse nivelet e vegjël përdorin vetëm fillimin e saj.
const List<Color> paletaBaze = [
  Color(0xFFE4572E), // e kuqe tulle
  Color(0xFF17BEBB), // bruz
  Color(0xFFFFC914), // ar
  Color(0xFF6A4C93), // vjollcë
  Color(0xFF2E9E49), // gjelbër
  Color(0xFFF06AA4), // rozë
  Color(0xFF4A90D9), // kaltër
  Color(0xFFE87D1E), // portokalli
  Color(0xFF9BD40C), // limon
  Color(0xFFB5179E), // magenta
  Color(0xFF00A6A6), // gurkalitë
  Color(0xFFD62246), // vishnje
  Color(0xFF7FB3FF), // qiell
  Color(0xFFBF8A2E), // bronz
  Color(0xFF57C785), // mendër
  Color(0xFFAA6CFF), // lavandë
  Color(0xFFE8E337), // squfur
  Color(0xFF0E7C7B), // smerald i thellë
  Color(0xFFFF8A5C), // korall
  Color(0xFF8D99AE), // gri e kaltërt
  Color(0xFFC44536), // ndryshk
  Color(0xFF3AB795), // xhad
  Color(0xFFDD6E42), // qeramikë
  Color(0xFF6C91BF), // çeliku
];

/// Paletë për daltonizëm: e ndërtuar mbi grupin Okabe–Ito, i cili ruan dallimin
/// te të tria format e zakonshme. Ka më pak ngjyra të vërteta të dallueshme, ndaj
/// modaliteti i shenjave (numri brenda nyjes) ndizet bashkë me të.
const List<Color> paletaDaltonike = [
  Color(0xFF0072B2),
  Color(0xFFE69F00),
  Color(0xFF009E73),
  Color(0xFFCC79A7),
  Color(0xFF56B4E9),
  Color(0xFFD55E00),
  Color(0xFFF0E442),
  Color(0xFF7F7F7F),
  Color(0xFF004C6D),
  Color(0xFF9A6324),
  Color(0xFF46A06B),
  Color(0xFFA0508B),
  Color(0xFF8AC7E8),
  Color(0xFFB35A00),
  Color(0xFFCFC03A),
  Color(0xFF565656),
  Color(0xFF2B7BB9),
  Color(0xFFE8B14C),
  Color(0xFF6FBF9C),
  Color(0xFFD79CC0),
  Color(0xFF00344B),
  Color(0xFF6E4517),
  Color(0xFF2E7350),
  Color(0xFF733A63),
];

class Ngjyrat {
  const Ngjyrat({
    required this.sfondi,
    required this.fusha,
    required this.qeliza,
    required this.vija,
    required this.teksti,
    required this.tekstiZbehte,
    required this.theksi,
    required this.muri,
  });

  final Color sfondi;
  final Color fusha;
  final Color qeliza;
  final Color vija;
  final Color teksti;
  final Color tekstiZbehte;
  final Color theksi;
  final Color muri;

  static const errret = Ngjyrat(
    sfondi: Color(0xFF0E1116),
    fusha: Color(0xFF161B22),
    qeliza: Color(0xFF1C222B),
    vija: Color(0xFF2A323D),
    teksti: Color(0xFFECEFF4),
    tekstiZbehte: Color(0xFF8B949E),
    theksi: Color(0xFFFFC914),
    muri: Color(0xFF303945),
  );

  static const ndritshem = Ngjyrat(
    sfondi: Color(0xFFF5F7FA),
    fusha: Color(0xFFFFFFFF),
    qeliza: Color(0xFFEDF1F6),
    vija: Color(0xFFD3DAE3),
    teksti: Color(0xFF11161C),
    tekstiZbehte: Color(0xFF5B6672),
    theksi: Color(0xFFB88600),
    muri: Color(0xFFB9C2CD),
  );

  /// Letra e vjetër: paletë e ngrohtë, e menduar për lexim të gjatë natën pa
  /// dritën e bardhë të temës së ndritshme.
  static const pergamene = Ngjyrat(
    sfondi: Color(0xFFF3E9D2),
    fusha: Color(0xFFFBF5E6),
    qeliza: Color(0xFFEFE3C8),
    vija: Color(0xFFD8C7A2),
    teksti: Color(0xFF3B2F1C),
    tekstiZbehte: Color(0xFF7A6A4E),
    theksi: Color(0xFF9C6B1E),
    muri: Color(0xFFC3B08A),
  );

  static Ngjyrat per(Pamja p) => switch (p) {
        Pamja.erret => errret,
        Pamja.ndritshem => ndritshem,
        Pamja.pergamene => pergamene,
      };
}

ThemeData temaPer(Pamja p) {
  final n = Ngjyrat.per(p);
  final eErret = p == Pamja.erret;
  final baza = eErret ? ThemeData.dark() : ThemeData.light();
  return baza.copyWith(
    scaffoldBackgroundColor: n.sfondi,
    colorScheme: (eErret ? const ColorScheme.dark() : const ColorScheme.light())
        .copyWith(
      primary: n.theksi,
      surface: n.fusha,
      onSurface: n.teksti,
    ),
    textTheme: baza.textTheme.apply(
      bodyColor: n.teksti,
      displayColor: n.teksti,
    ),
    iconTheme: IconThemeData(color: n.teksti),
    dividerColor: n.vija,
  );
}
