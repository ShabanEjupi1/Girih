// Gjeneruesi jashtë-loje i niveleve.
//
//   dart run tool/gjenero.dart [--prova N] [--fara N] [--bote 1,2,3]
//
// Shkruan `lib/te_dhena/nivelet.g.dart`. Fara është e ngulur, ndaj i njëjti
// ekzekutim jep të njëjtat nivele — përndryshe çdo rindërtim do t'i zhbënte
// përparimet e ruajtura të lojtarëve, sepse përparimi lidhet me id-në e nivelit.

import 'dart:io';
import 'dart:math';

import 'package:girih/loja/gjeneruesi.dart';
import 'package:girih/loja/nivel.dart';
import 'package:girih/loja/zgjidhesi.dart';

const int nivelePerBote = 30;

/// Tetë botë, secila me rrjetën e vet dhe me formën e vet. Rritja e madhësisë
/// nuk mjafton si përparim vështirësie: nga bota 6 e tutje rrjeta merr edhe mure,
/// dhe një rrjetë me vrima luhet krejt ndryshe nga një katror i plotë.
final bote = <Bota>[
  Bota('Fillimi', 5, 5, 4, 6, muret: _paMure),
  Bota('Rrota', 6, 6, 5, 8, muret: _paMure),
  Bota('Ylli', 7, 7, 6, 10, muret: _paMure),
  Bota('Kupa', 8, 8, 8, 12, muret: _paMure),
  Bota('Harku', 9, 9, 9, 14, muret: _paMure),
  Bota('Oborri', 10, 10, 11, 16, muret: _muretRrotulluese),
  Bota('Kupola', 11, 11, 14, 20, muret: _muretRrotulluese),
  Bota('Nyja', 12, 12, 16, 24, muret: _muretRrotulluese),
];

class Bota {
  Bota(this.emri, this.gj, this.la, this.minC, this.maksC, {required this.muret});
  final String emri;
  final int gj, la, minC, maksC;
  final Set<int> Function(int gj, int la, int n) muret;
}

Set<int> _paMure(int gj, int la, int n) => const {};

// ---------------------------------------------------------------------------
// Format muresh. Të gjitha simetrike — një vrimë e vetme jashtë boshtit duket
// si gabim, jo si dizajn.
// ---------------------------------------------------------------------------

Set<int> _muretRrotulluese(int gj, int la, int n) {
  switch (n % 5) {
    case 0:
      return const {};
    case 1:
      return _qoshet(gj, la);
    case 2:
      return _kryqi(gj, la);
    case 3:
      return _qendra(gj, la);
    default:
      return _brinjet(gj, la);
  }
}

Set<int> _qoshet(int gj, int la) => {
      0, 1, gj,
      gj - 2, gj - 1, 2 * gj - 1,
      (la - 1) * gj, (la - 2) * gj, (la - 1) * gj + 1,
      la * gj - 1, la * gj - 2, (la - 1) * gj - 1,
    };

Set<int> _kryqi(int gj, int la) {
  final r = la ~/ 2, k = gj ~/ 2;
  return {r * gj + k, (r - 1) * gj + k, (r + 1) * gj + k, r * gj + k - 1, r * gj + k + 1};
}

Set<int> _qendra(int gj, int la) {
  final r = la ~/ 2 - 1, k = gj ~/ 2 - 1;
  return {r * gj + k, r * gj + k + 1, (r + 1) * gj + k, (r + 1) * gj + k + 1};
}

Set<int> _brinjet(int gj, int la) {
  final r = la ~/ 2, k = gj ~/ 2;
  return {r * gj, r * gj + gj - 1, k, (la - 1) * gj + k};
}

// ---------------------------------------------------------------------------

void main(List<String> args) {
  final prova = _flag(args, '--prova', 6000);
  final fara = _flag(args, '--fara', 20260731);
  final vetem = args
      .firstWhere((a) => a.startsWith('--bote='), orElse: () => '')
      .replaceFirst('--bote=', '')
      .split(',')
      .where((s) => s.isNotEmpty)
      .map(int.parse)
      .toSet();

  final dalja = StringBuffer()
    ..writeln('// GJENERUAR NGA `dart run tool/gjenero.dart` — mos e ndrysho me dorë.')
    ..writeln('//')
    ..writeln('// Çdo varg është vetë zgjidhja e nivelit: dy karaktere për përmasat,')
    ..writeln('// pastaj një karakter bazë-36 për qelizë (id-ja e shtegut) ose `.` për mur.')
    ..writeln('// Nyjet dhe muret nxirren prej saj nga `Nivel.dekodo`.')
    ..writeln('library;')
    ..writeln()
    ..writeln('class BotaTeDhena {')
    ..writeln('  const BotaTeDhena(this.emri, this.nivelet);')
    ..writeln('  final String emri;')
    ..writeln('  final List<String> nivelet;')
    ..writeln('}')
    ..writeln()
    ..writeln('const botet = <BotaTeDhena>[');

  final oraNisjes = DateTime.now();
  for (var b = 0; b < bote.length; b++) {
    if (vetem.isNotEmpty && !vetem.contains(b + 1)) continue;
    final w = bote[b];
    final gj = Gjeneruesi(Random(fara + b * 1000));
    final gjetur = <Kandidat>[];

    // Muret ndryshojnë brenda botës, ndaj gjenerohet grup pas grupi: një recetë
    // për çdo formë muri, dhe pastaj të gjitha renditen bashkë sipas vështirësisë.
    final format = <Set<int>>{};
    for (var n = 0; n < 5; n++) {
      format.add(w.muret(w.gj, w.la, n));
    }
    final perForme = (nivelePerBote / format.length).ceil();
    for (final muret in format) {
      if (!_iLidhur(w.gj, w.la, muret)) {
        stderr.writeln('  ! forma e murit u anashkalua (rrjeta ndahet më dysh)');
        continue;
      }
      final r = Recete(
        gjeresia: w.gj,
        lartesia: w.la,
        minCifte: w.minC,
        maksCifte: w.maksC,
        muret: muret,
        // Sa më e madhe rrjeta, aq më shpesh ecja lë një qelizë të vetmuar në
        // fund. Dy çifte ngjitur në një rrjetë 12×12 nuk vihen re; ndalimi i tyre
        // e ul prodhimin në zero.
        maksTeShkurtra: w.gj >= 9 ? 2 : 0,
      );
      gjetur.addAll(gj.prodho(r, sa: perForme * 4, provaMaksimale: prova));
    }

    // Renditja e vetme është sipas vështirësisë, dhe pastaj zgjidhet një ndarje e
    // BARABARTË nga i gjithë brezi. Marrja e 30 të parëve do të jepte një botë
    // krejt të lehtë dhe do ta linte vështirësinë t'i binte tërësisht ndarjes në
    // botë — kështu secila botë ka kurbën e vet, nga e para te e tridhjetta.
    gjetur.sort((a, b) => a.veshtiresia.compareTo(b.veshtiresia));
    final zgjedhur = <Kandidat>[];
    if (gjetur.length <= nivelePerBote) {
      zgjedhur.addAll(gjetur);
    } else {
      for (var i = 0; i < nivelePerBote; i++) {
        zgjedhur.add(gjetur[(i * (gjetur.length - 1) / (nivelePerBote - 1)).round()]);
      }
    }
    if (zgjedhur.length < nivelePerBote) {
      stderr.writeln('  ! bota ${b + 1} (${w.emri}): vetëm ${zgjedhur.length}/'
          '$nivelePerBote nivele — rrit --prova ose ngushto brezin e çifteve');
    }
    if (zgjedhur.isEmpty) {
      throw StateError('Bota ${b + 1} (${w.emri}) doli bosh — receta është e pamundur.');
    }

    // Kontroll i fundit, mbi vargun e koduar dhe jo mbi objektin në kujtesë: kjo
    // provon njëherësh gjeneruesin, kodimin DHE dekodimin.
    for (var i = 0; i < zgjedhur.length; i++) {
      final id = 'b${b + 1}-${i + 1}';
      final kodi = zgjedhur[i].nivel.kodo();
      final rikthyer = Nivel.dekodo(id, kodi);
      final rez = Zgjidhesi.ngaNiveli(rikthyer).numero(kufi: 2);
      if (!rez.eVetme) {
        throw StateError('Niveli $id nuk ka zgjidhje të vetme pas dekodimit!');
      }
    }

    stdout.writeln('bota ${b + 1} ${w.emri.padRight(8)} '
        '${w.gj}×${w.la}  ${zgjedhur.length} nivele  '
        'vështirësia ${zgjedhur.first.veshtiresia}..${zgjedhur.last.veshtiresia}');

    dalja
      ..writeln('  BotaTeDhena(${_cit(w.emri)}, <String>[')
      ..writeln(zgjedhur.map((k) => "    '${k.nivel.kodo()}',").join('\n'))
      ..writeln('  ]),');
  }
  dalja.writeln('];');

  File('lib/te_dhena/nivelet.g.dart').writeAsStringSync(dalja.toString());
  stdout.writeln('U shkrua lib/te_dhena/nivelet.g.dart për '
      '${DateTime.now().difference(oraNisjes).inSeconds}s');
}

String _cit(String s) => "'${s.replaceAll("'", r"\'")}'";

int _flag(List<String> args, String emri, int parazgjedhje) {
  final a = args.firstWhere((x) => x.startsWith('$emri='), orElse: () => '');
  return a.isEmpty ? parazgjedhje : int.parse(a.split('=')[1]);
}

/// Një formë muri që e ndan rrjetën më dysh do të prodhonte nivele ku dy gjysma
/// nuk komunikojnë — të ligjshme, por të shëmtuara. Kontrollohet një herë.
bool _iLidhur(int gj, int la, Set<int> muret) {
  final n = gj * la;
  var fillimi = -1;
  for (var q = 0; q < n; q++) {
    if (!muret.contains(q)) {
      fillimi = q;
      break;
    }
  }
  if (fillimi < 0) return false;
  final pare = <int>{fillimi};
  final radha = <int>[fillimi];
  while (radha.isNotEmpty) {
    final q = radha.removeLast();
    final r = q ~/ gj, k = q % gj;
    for (final f in [
      if (r > 0) q - gj,
      if (r < la - 1) q + gj,
      if (k > 0) q - 1,
      if (k < gj - 1) q + 1,
    ]) {
      if (muret.contains(f) || pare.contains(f)) continue;
      pare.add(f);
      radha.add(f);
    }
  }
  return pare.length == n - muret.length;
}
