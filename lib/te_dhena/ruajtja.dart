/// Përparimi dhe cilësimet — një dokument i vetëm JSON te `shared_preferences`.
///
/// Çelësi i çdo rekordi është id-ja e nivelit (`b3-17`), jo pozicioni i tij në
/// listë. Kjo do të thotë se nivelet mund të rirenditen ose të shtohen të reja
/// pa ia zhbërë askujt përparimin — përkundër faktit që një ndryshim i farës së
/// gjeneruesit do ta bënte pikërisht këtë, dhe prandaj fara rri e ngulur.
library;

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'perkthimi.dart';
import '../pamja/tema.dart';

const int ndihmaFillestare = 5;

/// Sa nivele duhen mbaruar në një botë që të hapet e ardhshmja. Nën gjysmën e
/// botës: pengesa duhet të ndalë kalimin me vrap, jo lojtarin që ngec te tre
/// nivele.
const int pragUZhbllokimit = 12;

class Cilesimet {
  Cilesimet({
    this.gjuha = Gjuha.shqip,
    this.pamja = Pamja.erret,
    this.daltonik = false,
    this.shenja = false,
    this.dridhje = true,
    this.animacione = true,
  });

  Gjuha gjuha;
  Pamja pamja;
  bool daltonik;

  /// Numri i çiftit i shkruar brenda nyjes. Ndizet vetvetiu bashkë me paletën
  /// daltonike, sepse aty ngjyra vetëm nuk mjafton.
  bool shenja;
  bool dridhje;
  bool animacione;

  Map<String, Object?> drejtJson() => {
        'gjuha': gjuha.index,
        'pamja': pamja.index,
        'daltonik': daltonik,
        'shenja': shenja,
        'dridhje': dridhje,
        'animacione': animacione,
      };

  static Cilesimet ngaJson(Map<String, Object?> j) => Cilesimet(
        gjuha: Gjuha.values[(j['gjuha'] as int?) ?? 0],
        pamja: Pamja.values[(j['pamja'] as int?) ?? 0],
        daltonik: (j['daltonik'] as bool?) ?? false,
        shenja: (j['shenja'] as bool?) ?? false,
        dridhje: (j['dridhje'] as bool?) ?? true,
        animacione: (j['animacione'] as bool?) ?? true,
      );
}

class Ruajtja extends ChangeNotifier {
  Ruajtja._(this._prefs, this._j);

  static const _celes = 'girih.v1';

  final SharedPreferences _prefs;
  Map<String, Object?> _j;

  static Future<Ruajtja> hap() async {
    final p = await SharedPreferences.getInstance();
    Map<String, Object?> j;
    try {
      j = jsonDecode(p.getString(_celes) ?? '{}') as Map<String, Object?>;
    } catch (_) {
      // Një dokument i prishur nuk guxon ta bllokojë nisjen: më mirë përparim i
      // humbur sesa një lojë që s'hapet më kurrë.
      j = <String, Object?>{};
    }
    return Ruajtja._(p, j);
  }

  Cilesimet get cilesimet => Cilesimet.ngaJson(
      (_j['cilesimet'] as Map?)?.cast<String, Object?>() ?? const {});

  Map<String, int> get _yjet =>
      ((_j['yjet'] as Map?)?.cast<String, Object?>() ?? const {})
          .map((k, v) => MapEntry(k, (v as num).toInt()));

  Map<String, int> get _levizjet =>
      ((_j['levizjet'] as Map?)?.cast<String, Object?>() ?? const {})
          .map((k, v) => MapEntry(k, (v as num).toInt()));

  int yjetE(String idNivelit) => _yjet[idNivelit] ?? 0;
  int? levizjetMeTeMira(String idNivelit) => _levizjet[idNivelit];
  bool zgjidhur(String idNivelit) => yjetE(idNivelit) > 0;

  int get yjetGjithsej => _yjet.values.fold(0, (a, b) => a + b);
  int get nivelaTeZgjidhur => _yjet.values.where((v) => v > 0).length;
  int get nivelaTePersosur => _yjet.values.where((v) => v >= 3).length;

  int get ndihma => (_j['ndihma'] as num?)?.toInt() ?? ndihmaFillestare;
  int get seria => (_j['seria'] as num?)?.toInt() ?? 0;
  String? get ditorjaEFundit => _j['ditorja'] as String?;
  int get kohaGjithsej => (_j['koha'] as num?)?.toInt() ?? 0;

  int zgjidhurNeBote(int bota, int sa) {
    var n = 0;
    for (var i = 1; i <= sa; i++) {
      if (zgjidhur('b$bota-$i')) n++;
    }
    return n;
  }

  /// Bota `b` (me bazë 1) hapet kur ajo para saj ka [pragUZhbllokimit] nivele të
  /// mbaruara. Bota e parë është gjithmonë e hapur.
  bool botaEHapur(int bota, int nivelaNeBotenEMeparshme) =>
      bota <= 1 || zgjidhurNeBote(bota - 1, nivelaNeBotenEMeparshme) >= pragUZhbllokimit;

  // -------------------------------------------------------------------------

  Future<void> ruajNivelin(String id, int yje, int levizje, int sekonda) async {
    final y = _yjet;
    final l = _levizjet;
    // Vetëm përmirësimi ruhet: një kalim i dytë më i dobët nuk ta heq yllin e
    // fituar një herë.
    if (yje > (y[id] ?? 0)) y[id] = yje;
    if (levizje < (l[id] ?? 1 << 30)) l[id] = levizje;
    _j['yjet'] = y;
    _j['levizjet'] = l;
    _j['koha'] = kohaGjithsej + sekonda;
    await _shkruaj();
  }

  /// Ndihmat fitohen duke luajtur, jo duke paguar: një për çdo nivel të ri të
  /// zgjidhur me tre yje. Nuk ka blerje brenda aplikacionit askund në këtë lojë.
  Future<void> shtoNdihme(int sa) async {
    _j['ndihma'] = (ndihma + sa).clamp(0, 99);
    await _shkruaj();
  }

  Future<void> perdorNdihme() async {
    _j['ndihma'] = (ndihma - 1).clamp(0, 99);
    await _shkruaj();
  }

  Future<void> shenoDitoren(String data) async {
    final iFundit = ditorjaEFundit;
    if (iFundit == data) return;
    final dje = DateTime.parse(data).subtract(const Duration(days: 1));
    final vargDje = dje.toIso8601String().substring(0, 10);
    _j['seria'] = iFundit == vargDje ? seria + 1 : 1;
    _j['ditorja'] = data;
    await _shkruaj();
  }

  Future<void> ruajCilesimet(Cilesimet c) async {
    _j['cilesimet'] = c.drejtJson();
    await _shkruaj();
  }

  Future<void> fshijGjithcka() async {
    _j = <String, Object?>{'cilesimet': ?_j['cilesimet']};
    await _shkruaj();
  }

  Future<void> _shkruaj() async {
    await _prefs.setString(_celes, jsonEncode(_j));
    notifyListeners();
  }
}
