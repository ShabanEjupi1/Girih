/// Cilësimet. Çdo ndryshim ruhet menjëherë — nuk ka buton «Ruaj».
library;

import 'package:flutter/material.dart';

import '../te_dhena/perkthimi.dart';
import '../te_dhena/ruajtja.dart';
import 'tema.dart';

class FaqjaECilesimeve extends StatefulWidget {
  const FaqjaECilesimeve({super.key, required this.ruajtja});
  final Ruajtja ruajtja;

  @override
  State<FaqjaECilesimeve> createState() => _FaqjaECilesimeveState();
}

class _FaqjaECilesimeveState extends State<FaqjaECilesimeve> {
  Future<void> _ndrysho(void Function(Cilesimet) veprim) async {
    final c = widget.ruajtja.cilesimet;
    veprim(c);
    await widget.ruajtja.ruajCilesimet(c);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.ruajtja.cilesimet;
    final n = Ngjyrat.per(c.pamja);
    final f = Fjalor(c.gjuha);

    return Scaffold(
      backgroundColor: n.sfondi,
      appBar: AppBar(
        backgroundColor: n.sfondi,
        foregroundColor: n.teksti,
        elevation: 0,
        title: Text(f('cilesimet')),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _grup(n, f('gjuha'), [
            _zgjedhje(n, 'Shqip', c.gjuha == Gjuha.shqip,
                () => _ndrysho((x) => x.gjuha = Gjuha.shqip)),
            _zgjedhje(n, 'English', c.gjuha == Gjuha.anglisht,
                () => _ndrysho((x) => x.gjuha = Gjuha.anglisht)),
          ]),
          _grup(n, f('pamja'), [
            _zgjedhje(n, f('erret'), c.pamja == Pamja.erret,
                () => _ndrysho((x) => x.pamja = Pamja.erret)),
            _zgjedhje(n, f('ndritshem'), c.pamja == Pamja.ndritshem,
                () => _ndrysho((x) => x.pamja = Pamja.ndritshem)),
            _zgjedhje(n, f('pergamene'), c.pamja == Pamja.pergamene,
                () => _ndrysho((x) => x.pamja = Pamja.pergamene)),
          ]),
          _celes(n, f('daltonik'), c.daltonik,
              (v) => _ndrysho((x) => x.daltonik = v)),
          _celes(n, f('shenja'), c.shenja || c.daltonik,
              (v) => _ndrysho((x) => x.shenja = v)),
          _celes(n, f('dridhje'), c.dridhje,
              (v) => _ndrysho((x) => x.dridhje = v)),
          _celes(n, f('animacione'), c.animacione,
              (v) => _ndrysho((x) => x.animacione = v)),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () => _fshij(f),
            icon: const Icon(Icons.delete_outline),
            style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFFE4572E)),
            label: Text(f('rifillo_gjithcka')),
          ),
          const SizedBox(height: 24),
          Text(
            'Girih 1.0 · girih.spacecode.tech',
            textAlign: TextAlign.center,
            style: TextStyle(color: n.tekstiZbehte, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Future<void> _fshij(Fjalor f) async {
    final po = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(f('rifillo_gjithcka')),
        content: Text(f('je_i_sigurt')),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(f('jo'))),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(f('po'))),
        ],
      ),
    );
    if (po ?? false) {
      await widget.ruajtja.fshijGjithcka();
      if (mounted) setState(() {});
    }
  }

  Widget _grup(Ngjyrat n, String titulli, List<Widget> femijet) => Padding(
        padding: const EdgeInsets.only(bottom: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(titulli,
                style: TextStyle(
                    color: n.tekstiZbehte,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1)),
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 8, children: femijet),
          ],
        ),
      );

  Widget _zgjedhje(Ngjyrat n, String etiketa, bool zgjedhur, VoidCallback veprim) =>
      ChoiceChip(
        label: Text(etiketa),
        selected: zgjedhur,
        onSelected: (_) => veprim(),
        backgroundColor: n.fusha,
        selectedColor: n.theksi.withValues(alpha: 0.25),
        labelStyle: TextStyle(color: n.teksti),
        side: BorderSide(color: zgjedhur ? n.theksi : n.vija),
      );

  Widget _celes(Ngjyrat n, String etiketa, bool vlera, ValueChanged<bool> ndrysho) =>
      SwitchListTile(
        value: vlera,
        onChanged: ndrysho,
        title: Text(etiketa, style: TextStyle(color: n.teksti, fontSize: 15)),
        contentPadding: EdgeInsets.zero,
        activeThumbColor: n.theksi,
      );
}
