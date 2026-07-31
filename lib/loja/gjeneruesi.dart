/// Gjeneruesi i niveleve. Ekzekutohet **jashtë lojës** (`tool/gjenero.dart`) dhe
/// dalja e tij futet e gatshme te `lib/te_dhena/nivelet.g.dart`.
///
/// Rendi është i kundërt me atë që pret njeriu: nuk vendosen nyjet e pastaj
/// kërkohet një zgjidhje, por **ndërtohet zgjidhja e parë** — një ndarje e
/// rastësishme e krejt rrjetës në gjarpërinj — dhe nyjet janë thjesht skajet e
/// tyre. Kështu asnjë nivel nuk del i pazgjidhshëm. E vetmja pyetje që mbetet,
/// dhe e vetmja që kushton, është nëse zgjidhja është e vetmja: atë e përgjigjet
/// [Zgjidhesi].
library;

import 'dart:math';

import 'nivel.dart';
import 'zgjidhesi.dart';

class Kandidat {
  const Kandidat(this.nivel, this.veshtiresia);
  final Nivel nivel;

  /// Nyjet që i deshën zgjidhësit për ta provuar unicitetin. Matës i papërsosur
  /// por i qëndrueshëm i asaj se sa "mendim" kërkon niveli.
  final int veshtiresia;
}

class Recete {
  const Recete({
    required this.gjeresia,
    required this.lartesia,
    required this.minCifte,
    required this.maksCifte,
    this.muret = const <int>{},
    this.minGjatesi = 3,
    this.maksTeShkurtra = 0,
  });

  final int gjeresia;
  final int lartesia;
  final int minCifte;
  final int maksCifte;

  /// Qelizat e bllokuara. Përdoren nga botët e vona për t'i dhënë rrjetës formë —
  /// një kornizë e vrimosur luhet krejt ndryshe nga një katror i plotë.
  final Set<int> muret;

  /// Gjarpërinjtë me dy qeliza janë dy nyje ngjitur: pa lojë fare.
  final int minGjatesi;

  /// Sa shtigje nën [minGjatesi] tolerohen. Zero do të thoshte hedhje e krejt
  /// mbulesës sa herë që ecja lë një qelizë të vetmuar në fund — dhe mbi një
  /// rrjetë 12×12 kjo ndodh pothuajse gjithmonë, ndaj prodhimi bie në zero.
  /// Një ose dy çifte ngjitur nuk e prishin nivelin; pesë po.
  final int maksTeShkurtra;

  int get qelizaTeLira => gjeresia * lartesia - muret.length;
}

class Gjeneruesi {
  Gjeneruesi(this.rastesi);
  final Random rastesi;

  /// Prodhon deri në [sa] nivele të ndryshme për recetën, të renditura nga më i
  /// lehti te më i vështiri.
  ///
  /// [provaMaksimale] e mban kohën e gjenerimit të kufizuar: në rrjetat e mëdha
  /// shumica e kandidatëve bien te uniciteti, dhe kjo është normale — një nivel
  /// i mirë është i rrallë, prandaj gjenerohet një herë dhe jo në pajisje.
  List<Kandidat> prodho(
    Recete r, {
    required int sa,
    int provaMaksimale = 4000,
    int buxhetiNyjeve = 250000,
  }) {
    final gjetur = <String, Kandidat>{};
    for (var prova = 0; prova < provaMaksimale && gjetur.length < sa; prova++) {
      final qelizat = _mbulesa(r);
      if (qelizat == null) continue;

      final nivel = Nivel(
        id: 'x',
        gjeresia: r.gjeresia,
        lartesia: r.lartesia,
        qelizat: qelizat,
      );
      if (nivel.sasiaEShtigjeve < r.minCifte ||
          nivel.sasiaEShtigjeve > r.maksCifte) {
        continue;
      }

      final kodi = nivel.kodo();
      if (gjetur.containsKey(kodi)) continue;

      final rez = Zgjidhesi.ngaNiveli(nivel)
          .numero(kufi: 2, buxhetiNyjeve: buxhetiNyjeve);
      if (!rez.eVetme) continue;

      gjetur[kodi] = Kandidat(nivel, rez.nyje);
    }
    final lista = gjetur.values.toList()
      ..sort((a, b) => a.veshtiresia.compareTo(b.veshtiresia));
    return lista;
  }

  // -------------------------------------------------------------------------
  // Ndarja e rrjetës në gjarpërinj
  // -------------------------------------------------------------------------

  /// Kthen `null` nëse prova dështoi — më lirë se çdo përpjekje për ta shpëtuar
  /// një mbulesë të keqe, sepse një provë e re kushton mikrosekonda.
  List<int>? _mbulesa(Recete r) {
    final n = r.gjeresia * r.lartesia;
    final qelizat = List<int>.filled(n, -2);
    for (final m in r.muret) {
      qelizat[m] = mur;
    }

    // Sa e gjatë të lejohet një gjarpër. Pa tavan, ecja e rastësishme e gëlltit
    // gjysmën e rrjetës në një shteg të vetëm dhe del një nivel me tri nyje.
    final mesatarja = r.qelizaTeLira / ((r.minCifte + r.maksCifte) / 2);
    final maksGjatesi = max(r.minGjatesi + 1, (mesatarja * 1.6).round());

    var id = 0;
    var mbetur = r.qelizaTeLira;
    var teShkurtra = 0;
    while (mbetur > 0) {
      if (id > 35) return null; // s'ka më shifra bazë-36 për id
      final fillimi = _mePakFqinje(qelizat, r);
      if (fillimi < 0) return null;

      final synimi = r.minGjatesi +
          rastesi.nextInt(max(1, maksGjatesi - r.minGjatesi + 1));
      var tani = fillimi;
      qelizat[tani] = id;
      var gjatesia = 1;
      mbetur--;

      while (gjatesia < synimi) {
        final tjetra = _fqinjaMePakFqinje(qelizat, r, tani, id);
        if (tjetra < 0) break;
        qelizat[tjetra] = id;
        tani = tjetra;
        gjatesia++;
        mbetur--;
      }

      if (gjatesia < 2) return null; // një qelizë e vetme s'është çift
      if (gjatesia < r.minGjatesi && ++teShkurtra > r.maksTeShkurtra) return null;
      id++;
    }

    // Një gjarpër që kalon ngjitur me vetveten nuk ka skaje të lexueshme, dhe
    // do të thoshte gjithashtu se lojtari mund ta vizatojë ndryshe: hidhet.
    return _pavetPrekje(qelizat, r) ? qelizat : null;
  }

  /// Qeliza e paprekur me më së paku fqinjë të paprekur. Duke nisur nga aty (dhe
  /// duke ecur po ashtu), ecja e rastësishme rrallë lë qeliza të vetmuara pas —
  /// e njëjta ide si rregulli i Warnsdorff-it te kali i shahut.
  int _mePakFqinje(List<int> qelizat, Recete r) {
    var meMire = -1, meMireShkalla = 99;
    final barabarte = <int>[];
    for (var q = 0; q < qelizat.length; q++) {
      if (qelizat[q] != -2) continue;
      final sh = _shkalla(qelizat, r, q);
      if (sh < meMireShkalla) {
        meMireShkalla = sh;
        barabarte
          ..clear()
          ..add(q);
        meMire = q;
      } else if (sh == meMireShkalla) {
        barabarte.add(q);
      }
    }
    if (meMire < 0) return -1;
    return barabarte[rastesi.nextInt(barabarte.length)];
  }

  /// Fqinji ku mund të vazhdojë shtegu [id].
  ///
  /// Kushti i dytë është ai që e bën gjenerimin të mundur mbi rrjeta të mëdha:
  /// një qelizë pranohet vetëm nëse ka **një të vetëm** fqinj të këtij shtegu —
  /// pikërisht qelizën ku ndodhemi. Kështu asnjë gjarpër nuk e prek dot vetveten
  /// **nga ndërtimi**. Më parë vetëprekja kontrollohej në fund dhe e hidhte krejt
  /// mbulesën; mbi 12×12 kjo do të thoshte se pothuajse çdo provë humbte.
  int _fqinjaMePakFqinje(List<int> qelizat, Recete r, int q, int id) {
    var meMireShkalla = 99;
    final barabarte = <int>[];
    for (final f in _fqinjet(r, q)) {
      if (qelizat[f] != -2) continue;
      var vetja = 0;
      for (final g in _fqinjet(r, f)) {
        if (qelizat[g] == id) vetja++;
      }
      if (vetja > 1) continue;
      final sh = _shkalla(qelizat, r, f);
      if (sh < meMireShkalla) {
        meMireShkalla = sh;
        barabarte
          ..clear()
          ..add(f);
      } else if (sh == meMireShkalla) {
        barabarte.add(f);
      }
    }
    if (barabarte.isEmpty) return -1;
    return barabarte[rastesi.nextInt(barabarte.length)];
  }

  int _shkalla(List<int> qelizat, Recete r, int q) {
    var n = 0;
    for (final f in _fqinjet(r, q)) {
      if (qelizat[f] == -2) n++;
    }
    return n;
  }

  bool _pavetPrekje(List<int> qelizat, Recete r) {
    for (var q = 0; q < qelizat.length; q++) {
      final v = qelizat[q];
      if (v == mur) continue;
      var njesoj = 0;
      for (final f in _fqinjet(r, q)) {
        if (qelizat[f] == v) njesoj++;
      }
      if (njesoj > 2) return false;
    }
    // Dhe secili shteg duhet të ketë saktësisht dy skaje.
    final skaje = <int, int>{};
    for (var q = 0; q < qelizat.length; q++) {
      final v = qelizat[q];
      if (v == mur) continue;
      var njesoj = 0;
      for (final f in _fqinjet(r, q)) {
        if (qelizat[f] == v) njesoj++;
      }
      if (njesoj == 1) skaje[v] = (skaje[v] ?? 0) + 1;
    }
    for (final n in skaje.values) {
      if (n != 2) return false;
    }
    return skaje.length ==
        qelizat.where((v) => v != mur).fold<int>(
              -1,
              (maks, v) => v > maks ? v : maks,
            ) +
            1;
  }

  Iterable<int> _fqinjet(Recete r, int q) sync* {
    final rr = q ~/ r.gjeresia, k = q % r.gjeresia;
    if (rr > 0) yield q - r.gjeresia;
    if (rr < r.lartesia - 1) yield q + r.gjeresia;
    if (k > 0) yield q - 1;
    if (k < r.gjeresia - 1) yield q + 1;
  }
}
