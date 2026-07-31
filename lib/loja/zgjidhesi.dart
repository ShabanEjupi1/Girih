/// Zgjidhësi i saktë — i vetmi gjykatës i cilësisë së një niveli.
///
/// Ai nuk përdoret kurrë gjatë lojës: niveli e mban tashmë zgjidhjen e vet
/// ([Nivel]). Detyra e tij është të thotë, gjatë gjenerimit, nëse zgjidhja është
/// **e VETMJA**. Pa këtë kontroll, një lojë "lidh nyjet" degjeneron menjëherë —
/// lojtari e mbush rrjetën në një mënyrë tjetër, loja ia refuzon, dhe ai ka të
/// drejtë e ne kemi gabim.
///
/// Prandaj numërimi këtu është i rreptë: numërohen **të gjitha** sistemet e
/// shtigjeve të thjeshta që mbulojnë çdo qelizë, edhe ato ku një shteg e prek
/// vetveten anash. Nëse dalin dy, niveli hidhet.
library;

import 'nivel.dart';

const int _bosh = -2;

class RezultatiZgjidhjes {
  const RezultatiZgjidhjes(this.zgjidhje, this.nyje, this.uNderpre);

  /// Sa zgjidhje u gjetën (numërimi ndalet te kufiri i kërkuar).
  final int zgjidhje;

  /// Sa nyje u vizituan. Përdoret si matës i vështirësisë: një nivel që zgjidhet
  /// pa asnjë prapakthim është i mërzitshëm, një që kërkon mijëra është i egër.
  final int nyje;

  /// E vërtetë nëse u kalua buxheti i nyjeve — atëherë numri i zgjidhjeve nuk
  /// do të thotë asgjë dhe kandidati duhet hedhur.
  final bool uNderpre;

  bool get eVetme => !uNderpre && zgjidhje == 1;
}

class Zgjidhesi {
  Zgjidhesi({
    required this.gjeresia,
    required this.lartesia,
    required List<bool> muret,
    required this.skajet,
  })  : _muret = muret,
        _rrjeta = List<int>.filled(gjeresia * lartesia, _bosh) {
    for (var q = 0; q < _rrjeta.length; q++) {
      if (_muret[q]) _rrjeta[q] = mur;
    }
    for (var i = 0; i < skajet.length; i++) {
      _rrjeta[skajet[i].$1] = i;
      _rrjeta[skajet[i].$2] = i;
    }
  }

  /// Ndërton zgjidhësin nga vetë niveli, duke harruar zgjidhjen e tij — pikërisht
  /// ajo është pyetja që i bëhet.
  factory Zgjidhesi.ngaNiveli(Nivel n) => Zgjidhesi(
        gjeresia: n.gjeresia,
        lartesia: n.lartesia,
        muret: [for (final v in n.qelizat) v == mur],
        skajet: n.skajet,
      );

  final int gjeresia;
  final int lartesia;
  final List<bool> _muret;
  final List<(int, int)> skajet;
  final List<int> _rrjeta;

  int _aktiv = 0;
  int _koka = -1;
  int _boshe = 0;
  int _gjetur = 0;
  int _nyje = 0;
  int _kufiZgjidhjesh = 2;
  int _buxhetiNyjeve = 1 << 22;
  int _kMbyllurDeri = 0;
  bool _kokaVlen = true;

  RezultatiZgjidhjes numero({int kufi = 2, int buxhetiNyjeve = 1 << 22}) {
    _kufiZgjidhjesh = kufi;
    _buxhetiNyjeve = buxhetiNyjeve;
    _gjetur = 0;
    _nyje = 0;
    _boshe = _rrjeta.where((v) => v == _bosh).length;
    _filloCiftin(0);
    return RezultatiZgjidhjes(_gjetur, _nyje, _nyje >= _buxhetiNyjeve);
  }

  // -------------------------------------------------------------------------

  void _filloCiftin(int k) {
    if (_gjetur >= _kufiZgjidhjesh || _nyje >= _buxhetiNyjeve) return;
    if (k == skajet.length) {
      // Mbulimi i plotë është pjesë e rregullit, jo bonus: një rrjetë me qeliza
      // të lira nuk është zgjidhje.
      if (_boshe == 0) _gjetur++;
      return;
    }
    _aktiv = k;
    _koka = skajet[k].$1;
    _zgjero();
  }

  void _zgjero() {
    _nyje++;
    if (_gjetur >= _kufiZgjidhjesh || _nyje >= _buxhetiNyjeve) return;

    final k = _aktiv;
    final koka = _koka;
    final synimi = skajet[k].$2;

    for (final f in _fqinjet(koka)) {
      if (f == synimi) {
        // Çifti mbyllet këtu. Gjendja e kokës rikthehet pas kthimit sepse degët
        // e tjera të kësaj kulme e presin kokën aty ku ishte.
        final ruajAktiv = _aktiv, ruajKoka = _koka;
        if (_premton(kMbyllurDeri: k + 1)) _filloCiftin(k + 1);
        _aktiv = ruajAktiv;
        _koka = ruajKoka;
        if (_gjetur >= _kufiZgjidhjesh || _nyje >= _buxhetiNyjeve) return;
      } else if (_rrjeta[f] == _bosh) {
        _rrjeta[f] = k;
        _boshe--;
        _koka = f;
        if (_premton(kMbyllurDeri: k)) _zgjero();
        _koka = koka;
        _boshe++;
        _rrjeta[f] = _bosh;
        if (_gjetur >= _kufiZgjidhjesh || _nyje >= _buxhetiNyjeve) return;
      }
    }
  }

  // -------------------------------------------------------------------------
  // Prerjet. Pa to kjo kërkim është e pafundme mbi një rrjetë 10×10.
  // -------------------------------------------------------------------------

  /// A mund të hyjë ende diçka në qelizën [q]? Kjo është e vetmja pyetje mbi të
  /// cilën ngrihen të tria prerjet, ndaj rri në një vend të vetëm.
  ///
  /// Qelizat e shtigjeve të mbyllura janë të vdekura. Nga shtegu në punë janë të
  /// gjalla vetëm koka dhe synimi — trupi i tij jo. Nga çiftet që s'kanë nisur
  /// ende janë të gjalla të dyja skajet.
  bool _lidhshme(int q) {
    final v = _rrjeta[q];
    if (v == _bosh) return true;
    if (v == mur) return false;
    if (v < _kMbyllurDeri) return false;
    if (_kokaVlen && v == _aktiv) return q == _koka || q == skajet[v].$2;
    return q == skajet[v].$1 || q == skajet[v].$2;
  }

  /// [kMbyllurDeri] = numri i çifteve tashmë të lidhura. Kur thirret pas mbylljes
  /// së një çifti është `k+1` dhe koka e vjetër nuk vlen më si zgjatuese.
  bool _premton({required int kMbyllurDeri}) {
    _kMbyllurDeri = kMbyllurDeri;
    _kokaVlen = kMbyllurDeri == _aktiv;

    // 1. Numërimi i shkallës. Një qelizë boshe do dy fqinjë (hyrje + dalje); një
    //    skaj i gjallë do të paktën një. Kjo e kap shumicën e qorrsokakëve
    //    menjëherë pas vendosjes, me një kalim të vetëm mbi rrjetën.
    for (var q = 0; q < _rrjeta.length; q++) {
      final v = _rrjeta[q];
      if (v == mur) continue;
      final duhen = v == _bosh ? 2 : (_lidhshme(q) ? 1 : 0);
      if (duhen == 0) continue;
      var n = 0;
      for (final f in _fqinjet(q)) {
        if (_lidhshme(f)) {
          n++;
          if (n >= duhen) break;
        }
      }
      if (n < duhen) return false;
    }

    // 2. Arritshmëria. Çdo çift i pambyllur duhet ta shohë ende partnerin e vet
    //    përmes qelizave boshe, përndryshe dega është e vdekur sado thellë të
    //    shkohet.
    if (_kokaVlen && !_arrin(_koka, skajet[_aktiv].$2)) return false;
    for (var i = kMbyllurDeri; i < skajet.length; i++) {
      if (i == _aktiv && _kokaVlen) continue;
      if (!_arrin(skajet[i].$1, skajet[i].$2)) return false;
    }

    // 3. Ishujt. Një copë qelizash boshe pa asnjë skaj të gjallë përreth nuk
    //    mbushet dot më kurrë — dhe mbulimi i plotë është i detyrueshëm.
    return _paIshuj();
  }

  /// BFS nga [nga] te [te] duke kaluar vetëm nëpër qeliza boshe.
  bool _arrin(int nga, int te) {
    if (nga == te) return true;
    final pare = List<bool>.filled(_rrjeta.length, false);
    final radha = <int>[nga];
    pare[nga] = true;
    while (radha.isNotEmpty) {
      final q = radha.removeLast();
      for (final f in _fqinjet(q)) {
        if (f == te) return true;
        if (pare[f] || _rrjeta[f] != _bosh) continue;
        pare[f] = true;
        radha.add(f);
      }
    }
    return false;
  }

  bool _paIshuj() {
    final pare = List<bool>.filled(_rrjeta.length, false);
    for (var fillim = 0; fillim < _rrjeta.length; fillim++) {
      if (_rrjeta[fillim] != _bosh || pare[fillim]) continue;
      final radha = <int>[fillim];
      pare[fillim] = true;
      var gjalle = false;
      while (radha.isNotEmpty) {
        final q = radha.removeLast();
        for (final f in _fqinjet(q)) {
          if (_rrjeta[f] == _bosh) {
            if (!pare[f]) {
              pare[f] = true;
              radha.add(f);
            }
          } else if (_lidhshme(f)) {
            gjalle = true;
          }
        }
      }
      if (!gjalle) return false;
    }
    return true;
  }

  Iterable<int> _fqinjet(int q) sync* {
    final r = q ~/ gjeresia, k = q % gjeresia;
    if (r > 0) yield q - gjeresia;
    if (r < lartesia - 1) yield q + gjeresia;
    if (k > 0) yield q - 1;
    if (k < gjeresia - 1) yield q + 1;
  }
}
