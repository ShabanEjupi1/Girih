/// Katalogu: botët, nivelet dhe sfida e ditës.
///
/// Nivelet janë të ngulura në kod (`nivelet.g.dart`) dhe jo të gjeneruara në
/// pajisje. Kjo është zgjedhje: gjenerimi kërkon një kontroll uniciteti që merr
/// sekonda për një rrjetë 12×12, dhe një lojë që ngrin kur shtyp «Luaj» është
/// një lojë e vdekur. Gjenerimi bëhet një herë, këtu vetëm lexohen.
library;

import 'dart:math';

import '../loja/nivel.dart';
import 'nivelet.g.dart';

class Katalogu {
  static int get sasiaEBoteve => botet.length;

  static int nivelaNe(int bota) => botet[bota - 1].nivelet.length;

  static String emriIBotes(int bota) => botet[bota - 1].emri;

  static Nivel merr(int bota, int numri) =>
      Nivel.dekodo('b$bota-$numri', botet[bota - 1].nivelet[numri - 1]);

  static int get gjithsejNivele =>
      botet.fold(0, (a, b) => a + b.nivelet.length);

  /// Niveli që vjen pas atij me id-në [id] (`b3-17`), bashkë me titullin e tij.
  ///
  /// 🚨 Llogaritet nga id-ja e nivelit që sapo u mbarua, JO nga një numër i
  /// kapur kur u hap loja. Varianti i vjetër ia kalonte faqes së re të njëjtën
  /// mbyllje, ndaj «Tjetri» e ringarkonte përjetësisht të njëjtin nivel dhe
  /// lojtari ngecte. Nga id-ja, çdo faqe e di vetë ku ndodhet.
  ///
  /// Zinxhiri nuk ndalet te fundi i botës: kalon te e ardhshmja, dhe vetëm te
  /// fundi i lojës kthen `null`. Sfida e ditës (`d-…`) nuk përputhet me formën,
  /// pra kthen `null` vetvetiu — ajo s'ka vazhdim.
  static (Nivel, String)? pasNivelit(String id) {
    final pj = pjeset(id);
    if (pj == null) return null;
    var (b, nr) = pj;
    nr++;
    if (nr > nivelaNe(b)) {
      b++;
      nr = 1;
    }
    if (b > sasiaEBoteve) return null;
    return (merr(b, nr), '${emriIBotes(b)} · $nr');
  }

  /// Bota dhe numri brenda saj, nxjerrë nga id-ja (`b3-17` → `(3, 17)`).
  /// Kthen `null` për çdo id që nuk është e një niveli të katalogut — sfida e
  /// ditës (`d-2026-07-31`) është pikërisht ai rast.
  static (int, int)? pjeset(String id) {
    final m = RegExp(r'^b(\d+)-(\d+)$').firstMatch(id);
    if (m == null) return null;
    final b = int.parse(m.group(1)!);
    final nr = int.parse(m.group(2)!);
    if (b < 1 || b > sasiaEBoteve) return null;
    if (nr < 1 || nr > nivelaNe(b)) return null;
    return (b, nr);
  }

  /// Niveli para atij me id-në [id] — pasqyra e [pasNivelit], që lojtari të
  /// kthehet një hap prapa pa kaluar nga menyja. Te niveli i parë i një bote
  /// kalon te i fundit i asaj para saj; te `b1-1` kthen `null`.
  static (Nivel, String)? paraNivelit(String id) {
    final pj = pjeset(id);
    if (pj == null) return null;
    var (b, nr) = pj;
    nr--;
    if (nr < 1) {
      b--;
      if (b < 1) return null;
      nr = nivelaNe(b);
    }
    return (merr(b, nr), '${emriIBotes(b)} · $nr');
  }

  /// Niveli i parë i pazgjidhur, për butonin «Vazhdo».
  static (int, int)? iPari(bool Function(String) zgjidhur) {
    for (var b = 1; b <= sasiaEBoteve; b++) {
      for (var n = 1; n <= nivelaNe(b); n++) {
        if (!zgjidhur('b$b-$n')) return (b, n);
      }
    }
    return null;
  }

  // -------------------------------------------------------------------------

  static String dataESotme() => DateTime.now().toIso8601String().substring(0, 10);

  /// Sfida e ditës është një nivel i vërtetë i zgjedhur nga fundi i katalogut,
  /// jo një i gjeneruar aty për aty: kështu të gjithë lojtarët e botës marrin
  /// saktësisht të njëjtën enigmë në të njëjtën ditë, dhe rezultati krahasohet.
  ///
  /// Zgjedhja bëhet vetëm nga botët 3 e tutje — një 5×5 nuk është sfidë.
  static Nivel ditorja([String? data]) {
    final d = data ?? dataESotme();
    final fara = d.codeUnits.fold<int>(7, (a, c) => (a * 131 + c) & 0x7fffffff);
    final r = Random(fara);
    // Kufiri i poshtëm bie vetvetiu nëse katalogu është më i vogël se katër botë —
    // përndryshe një katalog i cunguar (p.sh. gjatë provave) do ta rrëzonte lojën.
    final mePara = sasiaEBoteve >= 4 ? 3 : 1;
    final bota = mePara + r.nextInt(sasiaEBoteve - mePara + 1);
    final numri = 1 + r.nextInt(nivelaNe(bota));
    // Id-ja mban datën, jo pozicionin: sfida e sotme ruhet veç nga i njëjti nivel
    // i luajtur normalisht, ndaj asnjëra nuk ia jep tjetrës yjet falas.
    return Nivel.dekodo('d-$d', botet[bota - 1].nivelet[numri - 1]);
  }
}
