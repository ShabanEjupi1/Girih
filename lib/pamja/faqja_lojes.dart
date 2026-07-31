/// Ekrani i lojës.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../loja/motori.dart';
import '../loja/nivel.dart';
import '../te_dhena/katalogu.dart';
import '../te_dhena/perkthimi.dart';
import '../te_dhena/ruajtja.dart';
import 'piktori.dart';
import 'tema.dart';

class FaqjaELojes extends StatefulWidget {
  const FaqjaELojes({
    super.key,
    required this.nivel,
    required this.ruajtja,
    required this.titulli,
  });

  final Nivel nivel;
  final Ruajtja ruajtja;
  final String titulli;

  @override
  State<FaqjaELojes> createState() => _FaqjaELojesState();
}

class _FaqjaELojesState extends State<FaqjaELojes>
    with TickerProviderStateMixin {
  late Motori _motori;
  late AnimationController _pulsi;
  late AnimationController _fitorja;
  late DateTime _nisi;
  Fusha? _fusha;
  bool _uRuajt = false;

  @override
  void initState() {
    super.initState();
    _motori = Motori(widget.nivel);
    _nisi = DateTime.now();
    _pulsi = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
    _fitorja = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
  }

  @override
  void dispose() {
    _pulsi.dispose();
    _fitorja.dispose();
    super.dispose();
  }

  Cilesimet get _c => widget.ruajtja.cilesimet;
  Fjalor get _f => Fjalor(_c.gjuha);
  List<Color> get _paleta => _c.daltonik ? paletaDaltonike : paletaBaze;

  // -------------------------------------------------------------------------
  // Prekja
  // -------------------------------------------------------------------------

  void _prek(Offset p) {
    final q = _fusha?.qelizaNe(p);
    if (q == null) return;
    if (_motori.nis(q)) setState(() {});
  }

  /// 🚨 Një gisht i shpejtë kapërcen qeliza: mes dy kuadrove ai mund të kalojë
  /// tri prej tyre. Nëse pranohet vetëm qeliza ku ndodhet tani, vija këputet dhe
  /// loja "ka çrregullime". Prandaj hendeku mbushet hap pas hapi — dhe pikërisht
  /// sepse çdo hap kalon nga [Motori.zvarrit], asnjë mur dhe asnjë nyje e huaj
  /// nuk kapërcehet dot me shpejtësi.
  void _zvarrit(Offset p) {
    final fusha = _fusha;
    if (fusha == null) return;
    final synimi = fusha.qelizaNe(p);
    if (synimi == null) return;
    final id = _motori.shtegulAktiv;
    if (id == null) return;

    var ndryshoi = false;
    for (var hap = 0; hap < 64; hap++) {
      final rruga = _motori.shtegu(id);
      if (rruga.isEmpty) break;
      final koka = rruga.last;
      if (koka == synimi) break;

      final gj = widget.nivel.gjeresia;
      final dr = synimi ~/ gj - koka ~/ gj;
      final dk = synimi % gj - koka % gj;
      // Përparo në boshtin me mbetjen më të madhe; nëse ai bllokohet, provo tjetrin.
      final provat = (dk.abs() >= dr.abs())
          ? [if (dk != 0) koka + dk.sign, if (dr != 0) koka + dr.sign * gj]
          : [if (dr != 0) koka + dr.sign * gj, if (dk != 0) koka + dk.sign];
      var eci = false;
      for (final tjetra in provat) {
        if (_motori.zvarrit(tjetra) != Rezultati.asgje) {
          eci = true;
          ndryshoi = true;
          break;
        }
      }
      if (!eci) break;
    }
    if (ndryshoi) {
      if (_c.dridhje) unawaited(HapticFeedback.selectionClick());
      setState(() {});
    }
  }

  void _lesho() {
    _motori.mbaro();
    setState(() {});
    if (_motori.fituar && !_uRuajt) _fito();
  }

  // -------------------------------------------------------------------------

  Future<void> _fito() async {
    _uRuajt = true;
    if (_c.animacione) {
      unawaited(_fitorja.forward(from: 0));
    } else {
      _fitorja.value = 1;
    }
    if (_c.dridhje) unawaited(HapticFeedback.mediumImpact());

    final sekonda = DateTime.now().difference(_nisi).inSeconds;
    final yjet = _motori.yjet;
    final iPariMeTreYje =
        yjet >= 3 && widget.ruajtja.yjetE(widget.nivel.id) < 3;
    await widget.ruajtja.ruajNivelin(widget.nivel.id, yjet, _motori.levizje, sekonda);
    // Ndihmat fitohen duke luajtur mirë. Nuk shiten askund.
    if (iPariMeTreYje) await widget.ruajtja.shtoNdihme(1);
    if (widget.nivel.id.startsWith('d-')) {
      await widget.ruajtja.shenoDitoren(widget.nivel.id.substring(2));
    }
    if (mounted) setState(() {});
  }

  Future<void> _ndihmo() async {
    if (widget.ruajtja.ndihma <= 0) {
      _njofto(_f('pa_ndihma'));
      return;
    }
    final id = _motori.ndihmo();
    if (id == null) return;
    await widget.ruajtja.perdorNdihme();
    if (!mounted) return;
    setState(() {});
    if (_motori.fituar && !_uRuajt) await _fito();
  }

  void _njofto(String teksti) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(teksti)));
  }

  Future<void> _ndaj() async {
    final yje = '★' * _motori.yjet + '☆' * (3 - _motori.yjet);
    final teksti = 'Girih · ${widget.titulli}\n'
        '$yje  ${_motori.levizje} ${_f('levizje').toLowerCase()}\n'
        'girih.spacecode.tech';
    await Clipboard.setData(ClipboardData(text: teksti));
    if (mounted) _njofto(_f('kopjuar'));
  }

  // -------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final n = Ngjyrat.per(_c.pamja);
    final nivel = widget.nivel;
    return Scaffold(
      backgroundColor: n.sfondi,
      body: SafeArea(
        child: Column(
          children: [
            _koka(n),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: LayoutBuilder(
                  builder: (context, kufijte) {
                    final madhesia = Size(kufijte.maxWidth, kufijte.maxHeight);
                    _fusha = Fusha(nivel.gjeresia, nivel.lartesia, madhesia);
                    return Listener(
                      onPointerDown: (e) => _prek(e.localPosition),
                      onPointerMove: (e) => _zvarrit(e.localPosition),
                      onPointerUp: (_) => _lesho(),
                      onPointerCancel: (_) => _lesho(),
                      child: AnimatedBuilder(
                        animation: Listenable.merge([_pulsi, _fitorja]),
                        builder: (context, _) => CustomPaint(
                          size: madhesia,
                          painter: PiktoriFushes(
                            motori: _motori,
                            ngjyrat: n,
                            paleta: _paleta,
                            shenja: _c.shenja || _c.daltonik,
                            fitorja: _fitorja.value,
                            pulsi: _pulsi.value,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            _kembet(n),
            if (_motori.fituar) _fletaEFitores(n),
          ],
        ),
      ),
    );
  }

  Widget _koka(Ngjyrat n) {
    final nivel = widget.nivel;
    final perQind = nivel.sasiaELira == 0
        ? 0.0
        : _motori.qelizaTeMbushura / nivel.sasiaELira;
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
                tooltip: _f('dil'),
              ),
              Expanded(
                child: Text(
                  widget.titulli,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: n.teksti,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              _numer(n, '${_motori.sasiaELidhura}/${nivel.sasiaEShtigjeve}',
                  _f('nyje')),
              const SizedBox(width: 10),
              _numer(n, '${_motori.levizje}/${nivel.hapatIdeale}', _f('levizje')),
              const SizedBox(width: 6),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: perQind,
              minHeight: 5,
              backgroundColor: n.qeliza,
              valueColor: AlwaysStoppedAnimation(n.theksi),
            ),
          ),
        ],
      ),
    );
  }

  Widget _numer(Ngjyrat n, String vlera, String etiketa) => Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(vlera,
              style: TextStyle(
                  color: n.teksti, fontSize: 15, fontWeight: FontWeight.w700)),
          Text(etiketa,
              style: TextStyle(color: n.tekstiZbehte, fontSize: 10)),
        ],
      );

  Widget _kembet(Ngjyrat n) => Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buton(n, Icons.undo, _f('zhbej'),
                _motori.mundZhbehet ? () => setState(_motori.zhbej) : null),
            _buton(n, Icons.refresh, _f('rifillo'), () {
              setState(() {
                _motori.rifillo();
                _uRuajt = false;
                _fitorja.value = 0;
                _nisi = DateTime.now();
              });
            }),
            _buton(
              n,
              Icons.lightbulb_outline,
              '${_f('ndihme')} (${widget.ruajtja.ndihma})',
              _motori.fituar ? null : _ndihmo,
            ),
          ],
        ),
      );

  Widget _buton(Ngjyrat n, IconData ikona, String etiketa, VoidCallback? veprim) {
    final aktiv = veprim != null;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: FilledButton.tonalIcon(
          onPressed: veprim,
          icon: Icon(ikona, size: 18),
          label: Text(etiketa, overflow: TextOverflow.ellipsis),
          style: FilledButton.styleFrom(
            backgroundColor: n.qeliza,
            foregroundColor: aktiv ? n.teksti : n.tekstiZbehte,
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );
  }

  Widget _fletaEFitores(Ngjyrat n) {
    final yje = _motori.yjet;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
      decoration: BoxDecoration(
        color: n.fusha,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < 3; i++)
                Icon(
                  i < yje ? Icons.star_rounded : Icons.star_border_rounded,
                  color: i < yje ? n.theksi : n.tekstiZbehte,
                  size: 34,
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            yje >= 3 ? _f('perfekt') : _f('zgjidhur'),
            style: TextStyle(
                color: n.teksti, fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _ndaj,
                  icon: const Icon(Icons.ios_share, size: 18),
                  label: Text(_f('ndaj')),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton(
                  onPressed: () {
                    final tjetri = Katalogu.pasNivelit(widget.nivel.id);
                    if (tjetri == null) {
                      Navigator.of(context).pop();
                      return;
                    }
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (_) => FaqjaELojes(
                        nivel: tjetri.$1,
                        ruajtja: widget.ruajtja,
                        titulli: tjetri.$2,
                      ),
                    ));
                  },
                  child: Text(Katalogu.pasNivelit(widget.nivel.id) == null
                      ? _f('mbyll')
                      : _f('tjetri')),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
