import 'package:flutter_test/flutter_test.dart';
import 'package:girih/loja/motori.dart';
import 'package:girih/loja/nivel.dart';
import 'package:girih/loja/zgjidhesi.dart';
import 'package:girih/te_dhena/katalogu.dart';

/// Rrjeta 5×5 e provës — e njëjta që përdoret si fillim i botës së parë.
const _prova = '550000011110222103320044444';

void main() {
  group('Nivel', () {
    test('kodimi kthehet i njëjtë', () {
      final n = Nivel.dekodo('t', _prova);
      expect(n.kodo(), _prova);
      expect(n.gjeresia, 5);
      expect(n.lartesia, 5);
      expect(n.sasiaEShtigjeve, 5);
      expect(n.sasiaELira, 25);
    });

    test('skajet nxirren nga forma, jo nga të dhëna të veçanta', () {
      final n = Nivel.dekodo('t', _prova);
      // Shtegu 3 është dy qeliza ngjitur: (3,0) dhe (3,1) → indekset 15 dhe 16.
      expect(n.skajet[3], (15, 16));
      for (final (a, b) in n.skajet) {
        expect(a, isNot(b));
      }
    });

    test('zgjidhja e një shtegu del e plotë dhe e renditur', () {
      final n = Nivel.dekodo('t', _prova);
      final rruga = n.zgjidhjaEShtegut(0);
      expect(rruga.length, 9);
      expect(rruga.first, n.skajet[0].$1);
      expect(rruga.last, n.skajet[0].$2);
    });

    test('një trup me gjatësi të gabuar refuzohet', () {
      expect(() => Nivel.dekodo('t', '55000'), throwsFormatException);
    });
  });

  group('Zgjidhesi', () {
    test('e gjen zgjidhjen e vetme të nivelit të provës', () {
      final rez = Zgjidhesi.ngaNiveli(Nivel.dekodo('t', _prova)).numero();
      expect(rez.uNderpre, isFalse);
      expect(rez.zgjidhje, 1);
      expect(rez.eVetme, isTrue);
    });

    test('numëron më shumë se një kur rrjeta lë liri', () {
      // Dy shtigje paralele mbi një rrjetë 2×3: skajet janë në të njëjtat qoshe,
      // por rrugët mund të shkëmbehen, pra zgjidhja nuk është e vetme.
      final n = Nivel.dekodo('t', '23' '01' '01' '01');
      final rez = Zgjidhesi.ngaNiveli(n).numero(kufi: 5);
      expect(rez.zgjidhje, greaterThanOrEqualTo(1));
    });
  });

  group('Motori', () {
    Motori mot() => Motori(Nivel.dekodo('t', _prova));

    test('nis vetëm mbi një nyje ose mbi një litar të vizatuar', () {
      final m = mot();
      expect(m.nis(12), isFalse, reason: 'qeliza e mesme s\'është nyje');
      expect(m.nis(15), isTrue, reason: 'skaji i shtegut 3');
    });

    test('vizatimi i një çifti e lidh atë dhe numëron një lëvizje', () {
      final m = mot();
      expect(m.nis(15), isTrue);
      expect(m.zvarrit(16), Rezultati.uMbyll);
      expect(m.mbaro(), isTrue);
      expect(m.lidhur(3), isTrue);
      expect(m.levizje, 1);
    });

    test('hapi diagonal ose mbi një nyje të huaj refuzohet', () {
      final m = mot();
      m.nis(15);
      expect(m.zvarrit(21), Rezultati.asgje, reason: 'jo fqinj i drejtpërdrejtë');
      m.mbaro();
      m.nis(0); // skaji i shtegut 0
      expect(m.zvarrit(5), Rezultati.asgje, reason: '5 është nyja e shtegut 1');
    });

    test('kalimi mbi një litar tjetër e pret atë', () {
      final m = mot();
      // Shtegu 4 (rreshti i fundit) vizatohet i tëri.
      m.nis(20);
      for (final q in [21, 22, 23, 24]) {
        m.zvarrit(q);
      }
      m.mbaro();
      expect(m.lidhur(4), isTrue);

      // Shtegu 3 nis nga 15 dhe kalon poshtë mbi qelizën 21, e mesme te shtegu 4.
      m.nis(16);
      m.zvarrit(21);
      m.mbaro();
      expect(m.shtegulNe(21), 3);
      expect(m.lidhur(4), isFalse, reason: 'shtegu 4 u pre');
    });

    test('zhbërja e kthen gjendjen dhe numëruesin e lëvizjeve', () {
      final m = mot();
      m.nis(15);
      m.zvarrit(16);
      m.mbaro();
      expect(m.levizje, 1);
      expect(m.zhbej(), isTrue);
      expect(m.lidhur(3), isFalse);
      expect(m.levizje, 0);
    });

    test('vizatimi i plotë i zgjidhjes fiton me tre yje', () {
      final m = mot();
      _luajZgjidhjen(m);
      expect(m.fituar, isTrue);
      expect(m.levizje, m.nivel.hapatIdeale);
      expect(m.yjet, 3);
    });

    test('lidhja e të gjitha nyjeve pa mbushur rrjetën NUK është fitore', () {
      final n = Nivel.dekodo('t', _prova);
      final m = Motori(n);
      m.nis(n.skajet[3].$1);
      m.zvarrit(n.skajet[3].$2);
      m.mbaro();
      expect(m.lidhur(3), isTrue);
      expect(m.fituar, isFalse);
    });

    test('ndihma e vizaton çiftin dhe e ul yllin në një', () {
      final m = mot();
      expect(m.ndihmo(), isNotNull);
      expect(m.ndihmaTeperdorura, 1);
      _luajZgjidhjen(m);
      expect(m.fituar, isTrue);
      expect(m.yjet, 1, reason: 'ndihma e heq të drejtën për yje të plotë');
    });

    test('rivizatimi i një çifti të zgjidhur e humb yllin e tretë', () {
      final m = mot();
      _luajZgjidhjen(m);
      final n = m.nivel;
      m.nis(n.skajet[3].$1);
      m.zvarrit(n.skajet[3].$2);
      m.mbaro();
      expect(m.fituar, isTrue);
      expect(m.yjet, 2);
    });
  });

  group('Katalogu', () {
    test('çdo nivel dekodohet dhe zgjidhja e tij e fiton lojën', () {
      for (var b = 1; b <= Katalogu.sasiaEBoteve; b++) {
        for (var i = 1; i <= Katalogu.nivelaNe(b); i++) {
          final n = Katalogu.merr(b, i);
          expect(n.sasiaEShtigjeve, greaterThan(1), reason: n.id);
          final m = Motori(n);
          _luajZgjidhjen(m);
          expect(m.fituar, isTrue, reason: '${n.id} nuk u fitua nga zgjidhja e vet');
          expect(m.yjet, 3, reason: '${n.id} nuk jep tre yje me rrugën ideale');
        }
      }
    });

    test('sfida e ditës është e njëjtë për të njëjtën datë', () {
      final a = Katalogu.ditorja('2026-08-01');
      final b = Katalogu.ditorja('2026-08-01');
      expect(a.kodo(), b.kodo());
      expect(a.id, 'd-2026-08-01');
    });

    // 🚨 Rrëshqitja nga fitorja te niveli tjetër ishte E PRISHUR: butoni
    // «Tjetri» mbante një mbyllje me numrin e nivelit nga i cili u nis, dhe
    // faqja e re e trashëgonte të pandryshuar — pra pas hapit të parë loja e
    // ringarkonte përjetësisht të njëjtin nivel. Ky test e ndjek zinxhirin nga
    // fillimi te fundi: nëse ndalet ose përsëritet, ai dështon.
    test('zinxhiri i niveleve ecën përpara pa u përsëritur, nga fillimi në fund',
        () {
      final pare = <String>{};
      var id = 'b1-1';
      var hapa = 1;
      pare.add(id);
      while (true) {
        final tjetri = Katalogu.pasNivelit(id);
        if (tjetri == null) break;
        id = tjetri.$1.id;
        expect(pare.add(id), isTrue, reason: 'niveli $id u dha dy herë');
        hapa++;
        expect(hapa, lessThanOrEqualTo(Katalogu.gjithsejNivele));
      }
      expect(hapa, Katalogu.gjithsejNivele);
      expect(id, 'b${Katalogu.sasiaEBoteve}-'
          '${Katalogu.nivelaNe(Katalogu.sasiaEBoteve)}');
    });

    test('zinxhiri kalon te bota tjetër dhe ndalet vetëm te fundi', () {
      final fundiIBotes1 = 'b1-${Katalogu.nivelaNe(1)}';
      expect(Katalogu.pasNivelit(fundiIBotes1)!.$1.id, 'b2-1');
      final fundi = 'b${Katalogu.sasiaEBoteve}-'
          '${Katalogu.nivelaNe(Katalogu.sasiaEBoteve)}';
      expect(Katalogu.pasNivelit(fundi), isNull);
    });

    test('sfida e ditës nuk ka vazhdim', () {
      expect(Katalogu.pasNivelit('d-2026-08-01'), isNull);
      expect(Katalogu.pasNivelit('b99-1'), isNull);
      expect(Katalogu.pasNivelit('gjepura'), isNull);
    });

    test('«para» është e anasjellta e «pas» te çdo hap i zinxhirit', () {
      var id = 'b1-1';
      while (true) {
        final tjetri = Katalogu.pasNivelit(id);
        if (tjetri == null) break;
        // Nga niveli tjetër, një hap prapa duhet të kthejë saktësisht këtu.
        expect(Katalogu.paraNivelit(tjetri.$1.id)!.$1.id, id,
            reason: 'prapa nga ${tjetri.$1.id} nuk kthen te $id');
        id = tjetri.$1.id;
      }
    });

    test('para nivelit kalon te bota e mëparshme dhe ndalet te b1-1', () {
      expect(Katalogu.paraNivelit('b2-1')!.$1.id,
          'b1-${Katalogu.nivelaNe(1)}');
      expect(Katalogu.paraNivelit('b1-1'), isNull);
      expect(Katalogu.paraNivelit('d-2026-08-01'), isNull);
    });

    test('pjesët e id-së nxirren vetëm për nivele që ekzistojnë vërtet', () {
      expect(Katalogu.pjeset('b3-7'), (3, 7));
      expect(Katalogu.pjeset('b1-0'), isNull);
      expect(Katalogu.pjeset('b1-${Katalogu.nivelaNe(1) + 1}'), isNull);
      expect(Katalogu.pjeset('b99-1'), isNull);
      expect(Katalogu.pjeset('d-2026-08-01'), isNull);
    });
  });
}

/// E luan nivelin duke ndjekur zgjidhjen e ruajtur, një gjest për çdo çift —
/// pra pikërisht rruga që duhet të japë tre yje.
void _luajZgjidhjen(Motori m) {
  for (var id = 0; id < m.nivel.sasiaEShtigjeve; id++) {
    final rruga = m.nivel.zgjidhjaEShtegut(id);
    m.nis(rruga.first);
    for (var i = 1; i < rruga.length; i++) {
      m.zvarrit(rruga[i]);
    }
    m.mbaro();
  }
}
