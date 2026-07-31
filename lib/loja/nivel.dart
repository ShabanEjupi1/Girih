/// Modeli i një niveli dhe kodimi i tij.
///
/// Vendimi qendror: **një nivel ruhet si zgjidhja e tij**, jo si çiftet e
/// nyjeve. Nga rrjeta e zgjidhur nxirren vetvetiu edhe muret, edhe çiftet —
/// sepse çdo shteg është një "gjarpër" i thjeshtë, pra qelizat e skajshme janë
/// pikërisht ato me VETËM një fqinj të të njëjtit shteg.
///
/// Kjo blen tri gjëra njëherësh:
///  * skedari i niveleve bie në ~1 bajt për qelizë (240 nivele ≈ 20 KB, gjë që
///    ka rëndësi kur loja hapet në shfletues para se dikush të vendosë ta luajë);
///  * ndihma është e saktë dhe e menjëhershme — nuk ka nevojë të zgjidhet asgjë
///    në pajisje, sepse zgjidhja është aty;
///  * është e pamundur të dërgohet një nivel i pazgjidhshëm, sepse zgjidhja
///    është vetë formati.
library;

/// Numri i qelizave është i vogël, ndaj indeksi i qelizës është `r * gjerësia + k`
/// kudo në kod. Asnjë `Point`; aritmetika mbi një `List` të sheshtë është edhe më
/// e shpejtë edhe më e lehtë për t'u serializuar.
typedef Qeliza = int;

const int mur = -1;

/// Alfabeti bazë-36 për id-në e shtegut. 36 shtigje janë shumë më tepër se
/// maksimumi real (12), ndaj një karakter për qelizë mjafton përgjithmonë.
const String _shifra = '0123456789abcdefghijklmnopqrstuvwxyz';
const String _shenjaMurit = '.';

int _nga36(String c) {
  final i = _shifra.indexOf(c);
  if (i < 0) throw FormatException('Karakter i panjohur në nivel: "$c"');
  return i;
}

class Nivel {
  Nivel({
    required this.id,
    required this.gjeresia,
    required this.lartesia,
    required this.qelizat,
  })  : sasiaEShtigjeve = _numeroShtigjet(qelizat),
        skajet = _nxirrSkajet(qelizat, gjeresia, lartesia);

  /// Identifikues i qëndrueshëm: `b<botë>-<numër>` ose `d-<datë>` për sfidën
  /// ditore. Përparimi ruhet nën këtë çelës, ndaj **nuk guxon të ndryshojë**
  /// pasi një nivel të jetë botuar.
  final String id;
  final int gjeresia;
  final int lartesia;

  /// Për çdo qelizë: id-ja e shtegut, ose [mur].
  final List<int> qelizat;

  final int sasiaEShtigjeve;

  /// `skajet[i]` = të dyja qelizat e skajshme të shtegut `i`.
  final List<(Qeliza, Qeliza)> skajet;

  int get sasiaEQelizave => gjeresia * lartesia;

  /// Qelizat që lojtari duhet t'i mbushë. Muret nuk numërohen.
  late final int sasiaELira =
      qelizat.where((v) => v != mur).length;

  /// "Par"-i i lojës: një gjest i vetëm për çdo çift. Yll i tretë jepet vetëm
  /// kur lojtari e mbyll nivelin me kaq lëvizje — pra kur asnjë shteg nuk është
  /// vizatuar dy herë.
  int get hapatIdeale => sasiaEShtigjeve;

  bool eshteMur(Qeliza q) => qelizat[q] == mur;

  int rreshti(Qeliza q) => q ~/ gjeresia;
  int kolona(Qeliza q) => q % gjeresia;

  /// Fqinjët ortogonalë brenda rrjetës, muret të përfshira (filtrimi bëhet nga
  /// thirrësi kur i duhet).
  Iterable<Qeliza> fqinjet(Qeliza q) sync* {
    final r = q ~/ gjeresia, k = q % gjeresia;
    if (r > 0) yield q - gjeresia;
    if (r < lartesia - 1) yield q + gjeresia;
    if (k > 0) yield q - 1;
    if (k < gjeresia - 1) yield q + 1;
  }

  /// Zgjidhja e shtegut `id`, e renditur nga njëri skaj te tjetri. Përdoret nga
  /// ndihma dhe nga animacioni i fitores.
  List<Qeliza> zgjidhjaEShtegut(int idShtegu) {
    final (nisja, _) = skajet[idShtegu];
    final rruga = <Qeliza>[nisja];
    final pare = <Qeliza>{nisja};
    while (true) {
      final tjetra = fqinjet(rruga.last).firstWhere(
        (f) => qelizat[f] == idShtegu && !pare.contains(f),
        orElse: () => -1,
      );
      if (tjetra < 0) return rruga;
      pare.add(tjetra);
      rruga.add(tjetra);
    }
  }

  // -------------------------------------------------------------------------
  // Kodimi
  // -------------------------------------------------------------------------

  /// `<gjerësia><lartësia><qelizat>` — dy karaktere bazë-36 dhe pastaj një
  /// karakter për qelizë.
  String kodo() {
    final b = StringBuffer()
      ..write(_shifra[gjeresia])
      ..write(_shifra[lartesia]);
    for (final v in qelizat) {
      b.write(v == mur ? _shenjaMurit : _shifra[v]);
    }
    return b.toString();
  }

  factory Nivel.dekodo(String id, String s) {
    final gjeresia = _nga36(s[0]);
    final lartesia = _nga36(s[1]);
    final trupi = s.substring(2);
    if (trupi.length != gjeresia * lartesia) {
      throw FormatException(
          'Niveli $id: prisja ${gjeresia * lartesia} qeliza, mora ${trupi.length}.');
    }
    return Nivel(
      id: id,
      gjeresia: gjeresia,
      lartesia: lartesia,
      qelizat: [
        for (final c in trupi.split('')) c == _shenjaMurit ? mur : _nga36(c),
      ],
    );
  }

  static int _numeroShtigjet(List<int> qelizat) {
    var maks = -1;
    for (final v in qelizat) {
      if (v > maks) maks = v;
    }
    return maks + 1;
  }

  /// Skajet nxirren nga forma: në një gjarpër të thjeshtë, qeliza e skajshme ka
  /// saktësisht një fqinj të të njëjtit shteg. Nëse një shteg do të prekte
  /// vetveten, kjo do të binte — prandaj gjeneruesi i hedh poshtë të tillët.
  static List<(Qeliza, Qeliza)> _nxirrSkajet(
      List<int> qelizat, int gjeresia, int lartesia) {
    final n = _numeroShtigjet(qelizat);
    final gjetur = List.generate(n, (_) => <Qeliza>[]);
    for (var q = 0; q < qelizat.length; q++) {
      final v = qelizat[q];
      if (v == mur) continue;
      final r = q ~/ gjeresia, k = q % gjeresia;
      var njesoj = 0;
      if (r > 0 && qelizat[q - gjeresia] == v) njesoj++;
      if (r < lartesia - 1 && qelizat[q + gjeresia] == v) njesoj++;
      if (k > 0 && qelizat[q - 1] == v) njesoj++;
      if (k < gjeresia - 1 && qelizat[q + 1] == v) njesoj++;
      if (njesoj == 1) gjetur[v].add(q);
    }
    return [
      for (var i = 0; i < n; i++)
        if (gjetur[i].length == 2)
          (gjetur[i][0], gjetur[i][1])
        else
          throw FormatException(
              'Shtegu $i nuk është gjarpër i thjeshtë (${gjetur[i].length} skaje).'),
    ];
  }
}
