/// Faqja e parë: një ekran, pesë rrugë, asnjë njoftim.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../loja/nivel.dart';
import '../te_dhena/katalogu.dart';
import '../te_dhena/perkthimi.dart';
import '../te_dhena/ruajtja.dart';
import 'faqja_botes.dart';
import 'faqja_cilesimeve.dart';
import 'faqja_lojes.dart';
import 'faqja_statistikave.dart';
import 'tema.dart';

class FaqjaKryesore extends StatelessWidget {
  const FaqjaKryesore({super.key, required this.ruajtja});
  final Ruajtja ruajtja;

  @override
  Widget build(BuildContext context) {
    final c = ruajtja.cilesimet;
    final n = Ngjyrat.per(c.pamja);
    final f = Fjalor(c.gjuha);
    final tjetri = Katalogu.iPari(ruajtja.zgjidhur);
    final ditorjaEBere = ruajtja.ditorjaEFundit == Katalogu.dataESotme();

    return Scaffold(
      backgroundColor: n.sfondi,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 12),
                  _stema(n),
                  const SizedBox(height: 16),
                  Text(
                    f('titulli'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: n.teksti,
                      fontSize: 44,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 6,
                    ),
                  ),
                  Text(
                    f('moto'),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: n.tekstiZbehte, fontSize: 14),
                  ),
                  const SizedBox(height: 28),
                  _kryesor(
                    context,
                    n,
                    tjetri == null ? f('perserit') : f('vazhdo'),
                    tjetri == null
                        ? '${f('e_perfunduar')} · ${ruajtja.yjetGjithsej} ${f('yje')}'
                        : '${f('bota')} ${tjetri.$1} · ${f('niveli')} ${tjetri.$2}',
                    () => _luaj(context, tjetri ?? (1, 1)),
                  ),
                  const SizedBox(height: 10),
                  _rresht(context, n, Icons.grid_view_rounded, f('botet'),
                      '${ruajtja.nivelaTeZgjidhur}/${Katalogu.gjithsejNivele}', () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => FaqjaEBoteve(ruajtja: ruajtja),
                    ));
                  }),
                  _rresht(
                    context,
                    n,
                    Icons.today_rounded,
                    f('ditorja'),
                    ditorjaEBere
                        ? '✓ ${ruajtja.seria} ${f('dite')}'
                        : Katalogu.dataESotme(),
                    () => _ditorja(context),
                  ),
                  _rresht(context, n, Icons.insights_rounded, f('statistika'),
                      '${ruajtja.yjetGjithsej} ★', () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => FaqjaEStatistikave(ruajtja: ruajtja),
                    ));
                  }),
                  _rresht(context, n, Icons.tune_rounded, f('cilesimet'), '', () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => FaqjaECilesimeve(ruajtja: ruajtja),
                    ));
                  }),
                  const SizedBox(height: 18),
                  _udhezimet(n, f),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _luaj(BuildContext context, (int, int) ku) {
    final (b, nr) = ku;
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => FaqjaELojes(
        nivel: Katalogu.merr(b, nr),
        ruajtja: ruajtja,
        titulli: '${Katalogu.emriIBotes(b)} · $nr',
        tjetri: () => _pasKetij(b, nr),
      ),
    ));
  }

  /// Zinxhiri i niveleve nuk ndalet te fundi i botës: kalon te e ardhshmja, dhe
  /// vetëm te fundi i lojës kthen `null`. Një lojtar në vrull nuk duhet nxjerrë
  /// nga vrulli për ta shtypur dy herë «prapa».
  (Nivel, String)? _pasKetij(int bota, int numri) {
    var b = bota, nr = numri + 1;
    if (nr > Katalogu.nivelaNe(b)) {
      b++;
      nr = 1;
    }
    if (b > Katalogu.sasiaEBoteve) return null;
    return (Katalogu.merr(b, nr), '${Katalogu.emriIBotes(b)} · $nr');
  }

  void _ditorja(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => FaqjaELojes(
        nivel: Katalogu.ditorja(),
        ruajtja: ruajtja,
        titulli: Fjalor(ruajtja.cilesimet.gjuha)('ditorja'),
      ),
    ));
  }

  Widget _stema(Ngjyrat n) => SizedBox(
        height: 92,
        child: CustomPaint(painter: _PiktoriIStemes(n)),
      );

  Widget _kryesor(BuildContext context, Ngjyrat n, String titulli,
          String nen, VoidCallback veprim) =>
      FilledButton(
        onPressed: veprim,
        style: FilledButton.styleFrom(
          backgroundColor: n.theksi,
          foregroundColor: const Color(0xFF11161C),
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
        ),
        child: Column(
          children: [
            Text(titulli,
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.w800)),
            Text(nen,
                style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w500)),
          ],
        ),
      );

  Widget _rresht(BuildContext context, Ngjyrat n, IconData ikona,
          String titulli, String djathtas, VoidCallback veprim) =>
      Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Material(
          color: n.fusha,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            onTap: veprim,
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
              child: Row(
                children: [
                  Icon(ikona, color: n.theksi, size: 22),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(titulli,
                        style: TextStyle(
                            color: n.teksti,
                            fontSize: 16,
                            fontWeight: FontWeight.w600)),
                  ),
                  Text(djathtas,
                      style:
                          TextStyle(color: n.tekstiZbehte, fontSize: 13)),
                  const SizedBox(width: 6),
                  Icon(Icons.chevron_right, color: n.tekstiZbehte, size: 20),
                ],
              ),
            ),
          ),
        ),
      );

  Widget _udhezimet(Ngjyrat n, Fjalor f) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: n.fusha,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(f('si_luhet'),
                style: TextStyle(
                    color: n.teksti,
                    fontSize: 14,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            for (final k in ['ndihmesa_1', 'ndihmesa_2', 'ndihmesa_3', 'ndihmesa_4'])
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text('· ${f(k)}',
                    style: TextStyle(color: n.tekstiZbehte, fontSize: 13)),
              ),
          ],
        ),
      );
}

/// Stema: tri yje tetëcepësh të mbivendosur, të njëjtat forma që përdor fusha.
class _PiktoriIStemes extends CustomPainter {
  _PiktoriIStemes(this.n);
  final Ngjyrat n;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.height / 2;
    for (var i = 0; i < 3; i++) {
      final boja = Paint()
        ..color = [n.theksi, const Color(0xFF17BEBB), const Color(0xFF6A4C93)][i]
            .withValues(alpha: 0.85 - i * 0.22)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0
        ..strokeJoin = StrokeJoin.round;
      canvas.drawPath(_yll(c, r * (1 - i * 0.22), i * 0.26), boja);
    }
  }

  Path _yll(Offset c, double rreze, double rrotullim) {
    final p = Path();
    const cepa = 8;
    for (var i = 0; i < cepa * 2; i++) {
      final rr = i.isEven ? rreze : rreze * 0.52;
      final kend = rrotullim - 1.5707963 + i * 3.1415926 / cepa;
      final pika = Offset(c.dx + rr * math.cos(kend), c.dy + rr * math.sin(kend));
      i == 0 ? p.moveTo(pika.dx, pika.dy) : p.lineTo(pika.dx, pika.dy);
    }
    return p..close();
  }


  @override
  bool shouldRepaint(covariant _PiktoriIStemes iVjeter) => iVjeter.n != n;
}
