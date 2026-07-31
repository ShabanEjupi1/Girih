/// Statistikat dhe arritjet.
///
/// Arritjet janë të gjitha të matshme nga ajo që tashmë ruhet — asnjë numërues i
/// ri, asnjë ngjarje e regjistruar veç. Kjo do të thotë se ato vlejnë edhe
/// prapa në kohë për një lojtar që luan që nga dita e parë.
library;

import 'package:flutter/material.dart';

import '../te_dhena/katalogu.dart';
import '../te_dhena/perkthimi.dart';
import '../te_dhena/ruajtja.dart';
import 'tema.dart';

class Arritje {
  const Arritje(this.emriSq, this.emriEn, this.ikona, this.arritur, this.ecuria);
  final String emriSq;
  final String emriEn;
  final IconData ikona;
  final bool arritur;
  final String ecuria;
}

class FaqjaEStatistikave extends StatelessWidget {
  const FaqjaEStatistikave({super.key, required this.ruajtja});
  final Ruajtja ruajtja;

  List<Arritje> _arritjet() {
    final zgjidhur = ruajtja.nivelaTeZgjidhur;
    final persosur = ruajtja.nivelaTePersosur;
    final yje = ruajtja.yjetGjithsej;
    final seria = ruajtja.seria;
    final boteTeMbaruara = [
      for (var b = 1; b <= Katalogu.sasiaEBoteve; b++)
        if (ruajtja.zgjidhurNeBote(b, Katalogu.nivelaNe(b)) ==
            Katalogu.nivelaNe(b))
          b
    ].length;
    return [
      Arritje('Nyja e parë', 'First knot', Icons.looks_one_rounded,
          zgjidhur >= 1, '$zgjidhur/1'),
      Arritje('Dhjetë nyje', 'Ten knots', Icons.filter_9_plus_rounded,
          zgjidhur >= 10, '$zgjidhur/10'),
      Arritje('Gjysma e rrugës', 'Halfway', Icons.timeline_rounded,
          zgjidhur >= Katalogu.gjithsejNivele ~/ 2,
          '$zgjidhur/${Katalogu.gjithsejNivele ~/ 2}'),
      Arritje('Të gjitha nivelet', 'Every level', Icons.emoji_events_rounded,
          zgjidhur >= Katalogu.gjithsejNivele,
          '$zgjidhur/${Katalogu.gjithsejNivele}'),
      Arritje('Dora e sigurt', 'Steady hand', Icons.star_rounded,
          persosur >= 25, '$persosur/25'),
      Arritje('Mjeshtër i yjeve', 'Star master', Icons.auto_awesome_rounded,
          yje >= 500, '$yje/500'),
      Arritje('Një botë e tërë', 'A whole world', Icons.public_rounded,
          boteTeMbaruara >= 1, '$boteTeMbaruara/1'),
      Arritje('Shtatë ditë rresht', 'Seven days', Icons.local_fire_department_rounded,
          seria >= 7, '$seria/7'),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final c = ruajtja.cilesimet;
    final n = Ngjyrat.per(c.pamja);
    final f = Fjalor(c.gjuha);
    final koha = Duration(seconds: ruajtja.kohaGjithsej);

    return Scaffold(
      backgroundColor: n.sfondi,
      appBar: AppBar(
        backgroundColor: n.sfondi,
        foregroundColor: n.teksti,
        elevation: 0,
        title: Text(f('statistika')),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              _kuti(n, '${ruajtja.nivelaTeZgjidhur}', f('gjithsej_zgjidhur')),
              const SizedBox(width: 10),
              _kuti(n, '${ruajtja.yjetGjithsej}', f('gjithsej_yje')),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _kuti(n, '${ruajtja.nivelaTePersosur}', f('perfekte')),
              const SizedBox(width: 10),
              _kuti(n, '${ruajtja.seria}', '${f('seria')} (${f('dite')})'),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _kuti(n, '${koha.inHours}h ${koha.inMinutes % 60}m', 'Koha'),
              const SizedBox(width: 10),
              _kuti(n, '${ruajtja.ndihma}', f('ndihma_mbetur')),
            ],
          ),
          const SizedBox(height: 24),
          Text(f('arritjet'),
              style: TextStyle(
                  color: n.tekstiZbehte,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1)),
          const SizedBox(height: 8),
          for (final a in _arritjet())
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: n.fusha,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(a.ikona,
                        color: a.arritur ? n.theksi : n.tekstiZbehte, size: 22),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        c.gjuha == Gjuha.shqip ? a.emriSq : a.emriEn,
                        style: TextStyle(
                          color: a.arritur ? n.teksti : n.tekstiZbehte,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(a.ecuria,
                        style: TextStyle(color: n.tekstiZbehte, fontSize: 12)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _kuti(Ngjyrat n, String vlera, String etiketa) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
          decoration: BoxDecoration(
            color: n.fusha,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              Text(vlera,
                  style: TextStyle(
                      color: n.teksti,
                      fontSize: 26,
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: 2),
              Text(etiketa,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: n.tekstiZbehte, fontSize: 11)),
            ],
          ),
        ),
      );
}
