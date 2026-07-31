/// Lista e botëve dhe rrjeta e niveleve brenda njërës.
library;

import 'package:flutter/material.dart';

import '../te_dhena/katalogu.dart';
import '../te_dhena/perkthimi.dart';
import '../te_dhena/ruajtja.dart';
import 'faqja_lojes.dart';
import 'tema.dart';

class FaqjaEBoteve extends StatelessWidget {
  const FaqjaEBoteve({super.key, required this.ruajtja});
  final Ruajtja ruajtja;

  @override
  Widget build(BuildContext context) {
    final c = ruajtja.cilesimet;
    final n = Ngjyrat.per(c.pamja);
    final f = Fjalor(c.gjuha);
    return Scaffold(
      backgroundColor: n.sfondi,
      appBar: AppBar(
        backgroundColor: n.sfondi,
        foregroundColor: n.teksti,
        title: Text(f('botet')),
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: Katalogu.sasiaEBoteve,
        itemBuilder: (context, i) {
          final bota = i + 1;
          final sa = Katalogu.nivelaNe(bota);
          final bere = ruajtja.zgjidhurNeBote(bota, sa);
          final eHapur = ruajtja.botaEHapur(
              bota, bota > 1 ? Katalogu.nivelaNe(bota - 1) : 0);
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Material(
              color: n.fusha,
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: eHapur
                    ? () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) =>
                              FaqjaENiveleve(ruajtja: ruajtja, bota: bota),
                        ))
                    : null,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      _shenja(n, bota, eHapur),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${f('bota')} $bota · ${Katalogu.emriIBotes(bota)}',
                              style: TextStyle(
                                color: eHapur ? n.teksti : n.tekstiZbehte,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              eHapur
                                  ? '$bere/$sa'
                                  : f('zhbllokohet',
                                      vlera: {'n': pragUZhbllokimit}),
                              style: TextStyle(
                                  color: n.tekstiZbehte, fontSize: 12),
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(3),
                              child: LinearProgressIndicator(
                                value: sa == 0 ? 0 : bere / sa,
                                minHeight: 4,
                                backgroundColor: n.qeliza,
                                valueColor: AlwaysStoppedAnimation(n.theksi),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Icon(eHapur ? Icons.chevron_right : Icons.lock_outline,
                          color: n.tekstiZbehte),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _shenja(Ngjyrat n, int bota, bool eHapur) => Container(
        width: 44,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: eHapur ? n.theksi.withValues(alpha: 0.16) : n.qeliza,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text('$bota',
            style: TextStyle(
                color: eHapur ? n.theksi : n.tekstiZbehte,
                fontSize: 18,
                fontWeight: FontWeight.w800)),
      );
}

class FaqjaENiveleve extends StatefulWidget {
  const FaqjaENiveleve({super.key, required this.ruajtja, required this.bota});
  final Ruajtja ruajtja;
  final int bota;

  @override
  State<FaqjaENiveleve> createState() => _FaqjaENivelevState();
}

class _FaqjaENivelevState extends State<FaqjaENiveleve> {
  @override
  Widget build(BuildContext context) {
    final c = widget.ruajtja.cilesimet;
    final n = Ngjyrat.per(c.pamja);
    final f = Fjalor(c.gjuha);
    final sa = Katalogu.nivelaNe(widget.bota);

    return Scaffold(
      backgroundColor: n.sfondi,
      appBar: AppBar(
        backgroundColor: n.sfondi,
        foregroundColor: n.teksti,
        elevation: 0,
        title: Text('${f('bota')} ${widget.bota} · '
            '${Katalogu.emriIBotes(widget.bota)}'),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 92,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1,
        ),
        itemCount: sa,
        itemBuilder: (context, i) {
          final nr = i + 1;
          final yje = widget.ruajtja.yjetE('b${widget.bota}-$nr');
          return Material(
            color: yje > 0 ? n.theksi.withValues(alpha: 0.14) : n.fusha,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => _luaj(nr),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('$nr',
                      style: TextStyle(
                          color: n.teksti,
                          fontSize: 20,
                          fontWeight: FontWeight.w800)),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (var s = 0; s < 3; s++)
                        Icon(
                          s < yje
                              ? Icons.star_rounded
                              : Icons.star_border_rounded,
                          size: 12,
                          color: s < yje ? n.theksi : n.tekstiZbehte,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _luaj(int nr) async {
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => FaqjaELojes(
        nivel: Katalogu.merr(widget.bota, nr),
        ruajtja: widget.ruajtja,
        titulli: '${Katalogu.emriIBotes(widget.bota)} · $nr',
      ),
    ));
    // Yjet e sapofituar duhen parë kur lojtari kthehet, përndryshe rrjeta duket
    // e pandryshuar dhe fitorja ndihet e humbur.
    if (mounted) setState(() {});
  }
}
