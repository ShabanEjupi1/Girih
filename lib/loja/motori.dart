/// Gjendja e luajtshme e një niveli — pa asnjë referencë te Flutter-i.
///
/// Kjo ndarje nuk është pedanteri: e gjithë logjika e lojës provohet me
/// `flutter test` pa nisur asnjë dritare, dhe ankesa e vjetër ("loja ka
/// çrregullime") lind pikërisht atje ku rregullat rrinë të përziera me
/// vizatimin. Këtu rregullat janë të vetme dhe të plota.
library;

import 'nivel.dart';

enum Rezultati { asgje, ndryshoi, uMbyll }

class Motori {
  Motori(this.nivel)
      : _rrjeta = List<int>.filled(nivel.sasiaEQelizave, bosh),
        _shtigjet = List.generate(nivel.sasiaEShtigjeve, (_) => <int>[]) {
    for (var q = 0; q < nivel.sasiaEQelizave; q++) {
      if (nivel.eshteMur(q)) _rrjeta[q] = mur;
    }
    for (var i = 0; i < nivel.skajet.length; i++) {
      _nyjet[nivel.skajet[i].$1] = i;
      _nyjet[nivel.skajet[i].$2] = i;
    }
  }

  static const int bosh = -2;

  final Nivel nivel;

  /// Për çdo qelizë: id-ja e shtegut të vizatuar nga lojtari, [bosh] ose [mur].
  final List<int> _rrjeta;
  final List<List<int>> _shtigjet;

  /// Qeliza → çifti së cilit i përket nyja fikse aty. Ndërtohet një herë; pa të,
  /// çdo prekje do të kërkonte një kalim mbi të gjitha skajet.
  final Map<int, int> _nyjet = {};

  final List<_Gjendje> _historia = [];
  final Set<int> _meNdihme = {};

  int _levizje = 0;
  int? _duke;
  bool _uNdryshua = false;

  // -------------------------------------------------------------------------
  // Lexim
  // -------------------------------------------------------------------------

  int get levizje => _levizje;
  int get ndihmaTeperdorura => _meNdihme.length;
  bool ndihmuar(int id) => _meNdihme.contains(id);
  int? get shtegulAktiv => _duke;
  bool get mundZhbehet => _historia.isNotEmpty;

  /// Shtegu i vizatuar për çiftin [id], nga njëri skaj drejt tjetrit.
  List<int> shtegu(int id) => List.unmodifiable(_shtigjet[id]);

  /// Cili shteg e zë qelizën, ose `null`.
  int? shtegulNe(int q) {
    final v = _rrjeta[q];
    return v == bosh || v == mur ? null : v;
  }

  /// Nyja fikse në këtë qelizë, ose `null`.
  int? nyjaNe(int q) => _nyjet[q];

  bool lidhur(int id) {
    final s = _shtigjet[id];
    if (s.length < 2) return false;
    final (a, b) = nivel.skajet[id];
    return (s.first == a && s.last == b) || (s.first == b && s.last == a);
  }

  int get sasiaELidhura {
    var n = 0;
    for (var i = 0; i < nivel.sasiaEShtigjeve; i++) {
      if (lidhur(i)) n++;
    }
    return n;
  }

  int get qelizaTeMbushura {
    var n = 0;
    for (var q = 0; q < _rrjeta.length; q++) {
      if (_rrjeta[q] >= 0) n++;
    }
    return n;
  }

  /// Fitorja kërkon të dyja: çdo çift i lidhur **dhe** çdo qelizë e mbushur.
  /// Vetëm e para do ta bënte lojën të lehtë dhe zgjidhjen jo të vetme.
  bool get fituar =>
      sasiaELidhura == nivel.sasiaEShtigjeve &&
      qelizaTeMbushura == nivel.sasiaELira;

  /// Yjet: një për zgjidhjen, dy nëse pa ndihmë, tre nëse edhe pa lëvizje të
  /// tepërta — pra çdo çift i vizatuar një herë të vetme dhe saktë.
  int get yjet {
    if (!fituar) return 0;
    if (_meNdihme.isNotEmpty) return 1;
    return _levizje <= nivel.hapatIdeale ? 3 : 2;
  }

  // -------------------------------------------------------------------------
  // Shkrim — gjesti i lojtarit
  // -------------------------------------------------------------------------

  /// Prekja fillestare. Kthen `true` nëse nisi vërtet një vizatim.
  bool nis(int q) {
    if (q < 0 || q >= _rrjeta.length || _rrjeta[q] == mur) return false;

    final nyja = _nyjet[q];
    if (nyja != null) {
      _ruaj();
      // Prekja e një nyjeje e nis çiftin nga e para. Kjo është arsyeja pse
      // "lëvizjet" numërojnë gjeste e jo qeliza: rivizatimi i një shtegu të
      // zgjidhur ta prish yllin e tretë, dhe kështu duhet.
      _fshij(nyja);
      _shtigjet[nyja].add(q);
      _rrjeta[q] = nyja;
      _duke = nyja;
      _uNdryshua = true;
      return true;
    }

    final mbi = shtegulNe(q);
    if (mbi != null) {
      _ruaj();
      // Prekja në mes të një shtegu e shkurton atje dhe vazhdon prej andej —
      // pa këtë, korrigjimi i një gabimi do të kërkonte rivizatim nga nyja.
      _pritTe(mbi, q);
      _duke = mbi;
      _uNdryshua = true;
      return true;
    }
    return false;
  }

  /// Zvarritja mbi qelizën [q]. Pranohet vetëm një hap ortogonal nga koka —
  /// një gisht i shpejtë mbi ekran kapërcen qeliza, dhe pranimi i kërcimeve do
  /// të lejonte vizatim përmes mureve.
  Rezultati zvarrit(int q) {
    final id = _duke;
    if (id == null || q < 0 || q >= _rrjeta.length) return Rezultati.asgje;
    final s = _shtigjet[id];
    if (s.isEmpty) return Rezultati.asgje;

    final koka = s.last;
    if (q == koka) return Rezultati.asgje;
    if (!_fqinje(koka, q)) return Rezultati.asgje;
    if (_rrjeta[q] == mur) return Rezultati.asgje;

    // Kthimi prapa mbi vetveten: shkurtohet, nuk shtohet.
    if (s.contains(q)) {
      _pritTe(id, q);
      _uNdryshua = true;
      return Rezultati.ndryshoi;
    }

    final nyja = _nyjet[q];
    if (nyja != null && nyja != id) return Rezultati.asgje; // nyjet janë të huaja

    // Kalimi mbi një shteg tjetër e pret atë. Zgjedhja alternative — ta ndalosh
    // gishtin — ndihet si defekt: lojtari e sheh qelizën të lirë nën gisht.
    final zenaNga = shtegulNe(q);
    if (zenaNga != null && zenaNga != id) _pritPara(zenaNga, q);

    s.add(q);
    _rrjeta[q] = id;
    _uNdryshua = true;

    if (nyja == id && s.length > 1) {
      final (a, b) = nivel.skajet[id];
      if ((s.first == a && q == b) || (s.first == b && q == a)) {
        _duke = null;
        return Rezultati.uMbyll;
      }
    }
    return Rezultati.ndryshoi;
  }

  /// Ngritja e gishtit. Kthen `true` nëse gjesti u numërua si lëvizje.
  bool mbaro() {
    final numeroi = _uNdryshua;
    _duke = null;
    if (_uNdryshua) _levizje++;
    _uNdryshua = false;
    return numeroi;
  }

  bool zhbej() {
    if (_historia.isEmpty) return false;
    final g = _historia.removeLast();
    for (var i = 0; i < _rrjeta.length; i++) {
      _rrjeta[i] = g.rrjeta[i];
    }
    for (var i = 0; i < _shtigjet.length; i++) {
      _shtigjet[i]
        ..clear()
        ..addAll(g.shtigjet[i]);
    }
    _levizje = g.levizje;
    _duke = null;
    _uNdryshua = false;
    return true;
  }

  void rifillo() {
    _historia.clear();
    _meNdihme.clear();
    for (var i = 0; i < _rrjeta.length; i++) {
      if (_rrjeta[i] != mur) _rrjeta[i] = bosh;
    }
    for (final s in _shtigjet) {
      s.clear();
    }
    _levizje = 0;
    _duke = null;
    _uNdryshua = false;
  }

  /// Vizaton të plotë një çift të pazgjidhur, nga zgjidhja e ruajtur te niveli.
  /// Kthen id-në e tij, ose `null` nëse s'kishte çfarë të ndihmohej.
  int? ndihmo() {
    final kandidate = [
      for (var i = 0; i < nivel.sasiaEShtigjeve; i++)
        if (!lidhur(i) && !_meNdihme.contains(i)) i,
    ];
    if (kandidate.isEmpty) return null;
    _ruaj();
    final id = kandidate.first;
    final rruga = nivel.zgjidhjaEShtegut(id);
    // Çdo shteg tjetër që e zë këtë rrugë duhet hequr nga aty tutje, përndryshe
    // dy shtigje do të mbanin të njëjtën qelizë.
    for (final q in rruga) {
      final tjeter = shtegulNe(q);
      if (tjeter != null && tjeter != id) _pritPara(tjeter, q);
    }
    _fshij(id);
    for (final q in rruga) {
      _shtigjet[id].add(q);
      _rrjeta[q] = id;
    }
    _meNdihme.add(id);
    _levizje++;
    _duke = null;
    return id;
  }

  // -------------------------------------------------------------------------

  void _ruaj() {
    _historia.add(_Gjendje(
      List<int>.from(_rrjeta),
      [for (final s in _shtigjet) List<int>.from(s)],
      _levizje,
    ));
    // Historia e plotë e një niveli 12×12 është e vogël, por e pakufizuar do të
    // rritej pa nevojë gjatë provave të gjata.
    if (_historia.length > 200) _historia.removeAt(0);
  }

  void _fshij(int id) {
    for (final q in _shtigjet[id]) {
      if (_rrjeta[q] == id) _rrjeta[q] = bosh;
    }
    _shtigjet[id].clear();
  }

  /// Mban qelizat deri te [q] përfshirë.
  void _pritTe(int id, int q) {
    final s = _shtigjet[id];
    final i = s.indexOf(q);
    if (i < 0) return;
    for (var j = i + 1; j < s.length; j++) {
      if (_rrjeta[s[j]] == id) _rrjeta[s[j]] = bosh;
    }
    s.removeRange(i + 1, s.length);
  }

  /// Mban qelizat para [q]; vetë [q] lirohet.
  void _pritPara(int id, int q) {
    final s = _shtigjet[id];
    final i = s.indexOf(q);
    if (i < 0) return;
    for (var j = i; j < s.length; j++) {
      if (_rrjeta[s[j]] == id) _rrjeta[s[j]] = bosh;
    }
    s.removeRange(i, s.length);
  }

  bool _fqinje(int a, int b) {
    final ra = a ~/ nivel.gjeresia, ka = a % nivel.gjeresia;
    final rb = b ~/ nivel.gjeresia, kb = b % nivel.gjeresia;
    return (ra - rb).abs() + (ka - kb).abs() == 1;
  }
}

class _Gjendje {
  _Gjendje(this.rrjeta, this.shtigjet, this.levizje);
  final List<int> rrjeta;
  final List<List<int>> shtigjet;
  final int levizje;
}
