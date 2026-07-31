/// I gjithë vizatimi i fushës. Asnjë aset, vetëm gjeometri.
///
/// Pamja synon **girih**-un — rrjetën me yje tetëcepësh të arkitekturës islame:
/// litarët e lojtarit vizatohen si rripa të endur, dhe nyjet si yje. Kjo nuk
/// është vetëm shije: një lojë ku e vetmja gjë që sheh janë vija me ngjyra ka
/// nevojë që ato vija të duken të bukura, përndryshe nuk ka çka ndahet me të
/// tjerët — dhe ndarja është e vetmja rrugë e vërtetë drejt përhapjes.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../loja/motori.dart';
import '../loja/nivel.dart';
import 'tema.dart';

/// Ku bie çdo qelizë brenda kanavacës. Njehsohet njësoj nga piktori dhe nga
/// prekja — po ta bënin veç e veç, gishti dhe vija do të binin ndryshe.
class Fusha {
  Fusha(this.gjeresia, this.lartesia, Size madhesia) {
    final an = math.min(madhesia.width / gjeresia, madhesia.height / lartesia);
    ana = an;
    dalja = Offset(
      (madhesia.width - an * gjeresia) / 2,
      (madhesia.height - an * lartesia) / 2,
    );
  }

  final int gjeresia;
  final int lartesia;
  late final double ana;
  late final Offset dalja;

  Offset qendra(int q) => Offset(
        dalja.dx + (q % gjeresia + 0.5) * ana,
        dalja.dy + (q ~/ gjeresia + 0.5) * ana,
      );

  Rect kutia(int q) => Rect.fromLTWH(
        dalja.dx + (q % gjeresia) * ana,
        dalja.dy + (q ~/ gjeresia) * ana,
        ana,
        ana,
      );

  /// Qeliza nën gisht, ose `null` jashtë rrjetës.
  int? qelizaNe(Offset p) {
    final k = ((p.dx - dalja.dx) / ana).floor();
    final r = ((p.dy - dalja.dy) / ana).floor();
    if (k < 0 || r < 0 || k >= gjeresia || r >= lartesia) return null;
    return r * gjeresia + k;
  }
}

class PiktoriFushes extends CustomPainter {
  PiktoriFushes({
    required this.motori,
    required this.ngjyrat,
    required this.paleta,
    required this.shenja,
    required this.fitorja,
    required this.pulsi,
  });

  final Motori motori;
  final Ngjyrat ngjyrat;
  final List<Color> paleta;
  final bool shenja;

  /// 0 → asnjë fitore; 1 → animacioni i mbaruar.
  final double fitorja;

  /// Rrahje e vazhdueshme 0..1 për kokën që lojtari po zvarrit.
  final double pulsi;

  Color _ngjyra(int id) => paleta[id % paleta.length];

  @override
  void paint(Canvas canvas, Size size) {
    final n = motori.nivel;
    final f = Fusha(n.gjeresia, n.lartesia, size);

    _sfondi(canvas, f, n);
    _qelizat(canvas, f, n);
    _litaret(canvas, f, n);
    _nyjet(canvas, f, n);
    if (fitorja > 0) _shkelqimiIFitores(canvas, f, n);
  }

  // -------------------------------------------------------------------------

  void _sfondi(Canvas canvas, Fusha f, Nivel n) {
    final r = RRect.fromRectAndRadius(
      Rect.fromLTWH(f.dalja.dx - f.ana * 0.18, f.dalja.dy - f.ana * 0.18,
          f.ana * n.gjeresia + f.ana * 0.36, f.ana * n.lartesia + f.ana * 0.36),
      Radius.circular(f.ana * 0.45),
    );
    canvas.drawRRect(r, Paint()..color = ngjyrat.fusha);
  }

  void _qelizat(Canvas canvas, Fusha f, Nivel n) {
    final bosh = Paint()..color = ngjyrat.qeliza;
    final muriBoje = Paint()..color = ngjyrat.muri;
    // Motivi girih: dy diagonale të zbehta për qelizë. Bashkë ato formojnë rrjetën
    // e yjeve tetëcepësh pa u vizatuar asnjëherë ylli si figurë më vete.
    final motivi = Paint()
      ..color = ngjyrat.vija.withValues(alpha: 0.5)
      ..strokeWidth = math.max(0.6, f.ana * 0.02)
      ..style = PaintingStyle.stroke;

    for (var q = 0; q < n.sasiaEQelizave; q++) {
      final kutia = f.kutia(q).deflate(f.ana * 0.045);
      final rr = RRect.fromRectAndRadius(kutia, Radius.circular(f.ana * 0.16));
      if (n.eshteMur(q)) {
        canvas.drawRRect(rr, muriBoje);
        continue;
      }
      canvas.drawRRect(rr, bosh);
      final c = f.qendra(q);
      final a = f.ana * 0.5;
      canvas.drawLine(c + Offset(-a * 0.55, 0), c + Offset(0, -a * 0.55), motivi);
      canvas.drawLine(c + Offset(0, -a * 0.55), c + Offset(a * 0.55, 0), motivi);
      canvas.drawLine(c + Offset(a * 0.55, 0), c + Offset(0, a * 0.55), motivi);
      canvas.drawLine(c + Offset(0, a * 0.55), c + Offset(-a * 0.55, 0), motivi);
    }
  }

  void _litaret(Canvas canvas, Fusha f, Nivel n) {
    final gjeresiaERripit = f.ana * 0.40;
    for (var id = 0; id < n.sasiaEShtigjeve; id++) {
      final qelizat = motori.shtegu(id);
      if (qelizat.length < 2) continue;
      final rruga = Path()..moveTo(f.qendra(qelizat.first).dx, f.qendra(qelizat.first).dy);
      for (var i = 1; i < qelizat.length; i++) {
        final p = f.qendra(qelizat[i]);
        rruga.lineTo(p.dx, p.dy);
      }
      final ngjyra = _ngjyra(id);
      final iLidhur = motori.lidhur(id);

      // Tri kalime: hija, rripi, dhe drita e brendshme. Kjo është ajo që e bën
      // vijën të duket e endur e jo një vijë e trashë.
      canvas.drawPath(
        rruga,
        Paint()
          ..color = Colors.black.withValues(alpha: 0.28)
          ..style = PaintingStyle.stroke
          ..strokeWidth = gjeresiaERripit * 1.16
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
      canvas.drawPath(
        rruga,
        Paint()
          ..color = iLidhur ? ngjyra : ngjyra.withValues(alpha: 0.85)
          ..style = PaintingStyle.stroke
          ..strokeWidth = gjeresiaERripit
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
      canvas.drawPath(
        rruga,
        Paint()
          ..color = Colors.white.withValues(alpha: iLidhur ? 0.34 : 0.16)
          ..style = PaintingStyle.stroke
          ..strokeWidth = gjeresiaERripit * 0.30
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );

      // Koka e shtegut që po vizatohet merr një unazë që rreh, që gishti ta dijë
      // ku ndodhet edhe kur e mbulon vetë ekranin.
      if (motori.shtegulAktiv == id && !iLidhur) {
        final koka = f.qendra(qelizat.last);
        canvas.drawCircle(
          koka,
          gjeresiaERripit * (0.62 + 0.22 * pulsi),
          Paint()
            ..color = ngjyra.withValues(alpha: 0.35 * (1 - pulsi))
            ..style = PaintingStyle.stroke
            ..strokeWidth = f.ana * 0.05,
        );
      }
    }
  }

  void _nyjet(Canvas canvas, Fusha f, Nivel n) {
    for (var id = 0; id < n.sasiaEShtigjeve; id++) {
      final ngjyra = _ngjyra(id);
      final iLidhur = motori.lidhur(id);
      for (final q in [n.skajet[id].$1, n.skajet[id].$2]) {
        final c = f.qendra(q);
        final rreze = f.ana * (iLidhur ? 0.33 : 0.30);
        canvas.drawPath(
          _yll(c, rreze, iLidhur ? 0.0 : math.pi / 8),
          Paint()..color = ngjyra,
        );
        canvas.drawPath(
          _yll(c, rreze, iLidhur ? 0.0 : math.pi / 8),
          Paint()
            ..color = Colors.black.withValues(alpha: 0.35)
            ..style = PaintingStyle.stroke
            ..strokeWidth = f.ana * 0.03,
        );
        canvas.drawCircle(
          c,
          rreze * 0.34,
          Paint()..color = ngjyrat.fusha.withValues(alpha: 0.9),
        );
        if (shenja) {
          _shkruajNumrin(canvas, c, id + 1, f.ana * 0.30, ngjyrat.teksti);
        }
      }
    }
  }

  /// Yll tetëcepësh — dy katrorë të rrotulluar, forma themelore e girih-ut.
  Path _yll(Offset c, double rreze, double rrotullim) {
    final p = Path();
    const cepa = 8;
    for (var i = 0; i < cepa * 2; i++) {
      final r = i.isEven ? rreze : rreze * 0.52;
      final kend = rrotullim - math.pi / 2 + i * math.pi / cepa;
      final pika = c + Offset(math.cos(kend) * r, math.sin(kend) * r);
      if (i == 0) {
        p.moveTo(pika.dx, pika.dy);
      } else {
        p.lineTo(pika.dx, pika.dy);
      }
    }
    return p..close();
  }

  void _shkruajNumrin(Canvas canvas, Offset c, int numri, double madhesia, Color ngjyra) {
    final tp = TextPainter(
      text: TextSpan(
        text: '$numri',
        style: TextStyle(
          fontSize: madhesia,
          fontWeight: FontWeight.w700,
          color: ngjyra,
          height: 1,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, c - Offset(tp.width / 2, tp.height / 2));
  }

  void _shkelqimiIFitores(Canvas canvas, Fusha f, Nivel n) {
    final qendra = Offset(
      f.dalja.dx + f.ana * n.gjeresia / 2,
      f.dalja.dy + f.ana * n.lartesia / 2,
    );
    final rrezeMaks = f.ana * math.max(n.gjeresia, n.lartesia) * 0.75;
    for (var unaza = 0; unaza < 3; unaza++) {
      final t = (fitorja - unaza * 0.15).clamp(0.0, 1.0);
      if (t <= 0) continue;
      canvas.drawPath(
        _yll(qendra, rrezeMaks * t, math.pi / 8 * t),
        Paint()
          ..color = ngjyrat.theksi.withValues(alpha: 0.20 * (1 - t))
          ..style = PaintingStyle.stroke
          ..strokeWidth = f.ana * 0.10,
      );
    }
  }

  @override
  bool shouldRepaint(covariant PiktoriFushes iVjeter) => true;
}
