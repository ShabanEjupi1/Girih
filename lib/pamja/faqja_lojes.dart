/// Ekrani i lojës.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app/ads.dart';
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
      // Ndihmat fitohen duke luajtur mirë; nga 1.2.0 mund të fitohet një edhe
      // duke parë një reklamë — me dëshirë, kurrë e detyruar. Pa reklama të
      // disponueshme (web, pa rrjet) sillet saktësisht si më parë.
      if (!Ads.ready) {
        _njofto(_f('pa_ndihma'));
        return;
      }
      final pranoi = await _kerkoNdihmeMeReklame();
      if (!pranoi || !mounted) return;
      // 🔑 `showRewarded` kthen `false` edhe kur rrjeti nuk u përgjigj. Lojtari
      // që PRANOI ta shohë reklamën nuk ndëshkohet për një rrjet të ngadaltë:
      // ndihma jepet gjithsesi. Humbja e mundshme është një ndihmë; humbja
      // tjetër do të ishte lojtari.
      await Ads.showRewarded();
      await widget.ruajtja.shtoNdihme(1);
      if (!mounted) return;
      setState(() {});
    }
    final id = _motori.ndihmo();
    if (id == null) return;
    await widget.ruajtja.perdorNdihme();
    if (!mounted) return;
    setState(() {});
    if (_motori.fituar && !_uRuajt) await _fito();
  }

  /// Ndërron nivelin në vend. `pushReplacement` do të thotë se një varg i gjatë
  /// nivelesh nuk e rrit stivën, dhe se «prapa» kthen te lista e niveleve e jo
  /// te secili nivel i luajtur para tij.
  ///
  /// 🚨 Synimi llogaritet nga id-ja e nivelit të tanishëm sa herë shtypet
  /// butoni, kurrë nga një vlerë e kapur kur u ndërtua faqja — pikërisht ai
  /// gabim e mbante lojtarin përjetësisht te i njëjti nivel.
  Future<void> _kalo((Nivel, String)? synimi) async {
    if (synimi == null) return;
    // 🚨 Reklama vjen PARA kalimit, jo pas fitores: kështu lojtari e sheh
    // rezultatin e vet, yjet dhe animacionin pa i ndërprerë askush. Vetë
    // `maybeShowAfterLevel` vendos nëse ka ardhur radha — shumica e kalimeve
    // nuk shfaqin asgjë.
    await Ads.maybeShowAfterLevel();
    if (!mounted) return;
    unawaited(Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (_) => FaqjaELojes(
        nivel: synimi.$1,
        ruajtja: widget.ruajtja,
        titulli: synimi.$2,
      ),
    )));
  }

  void _njofto(String teksti) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(teksti)));
  }

  /// Pyetja para reklamës me shpërblim. Play-i e kërkon këtë hap: një reklamë
  /// me shpërblim që niset pa e pyetur lojtarin numërohet si reklamë e
  /// papritur, jo me dëshirë.
  Future<bool> _kerkoNdihmeMeReklame() async {
    final n = Ngjyrat.per(_c.pamja);
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: n.fusha,
            title: Text(_f('pa_ndihma_titull'),
                style: TextStyle(color: n.teksti, fontSize: 18)),
            content: Text(_f('ndihme_me_reklame'),
                style: TextStyle(color: n.tekstiZbehte)),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(_f('jo_faleminderit')),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(_f('shih_reklamen')),
              ),
            ],
          ),
        ) ??
        false;
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
              // Një hap prapa në zinxhir. I fshehur — jo i fikur — te `b1-1`
              // dhe te sfida e ditës, që rreshti të mos mbajë një buton që nuk
              // bën kurrë asgjë.
              if (Katalogu.paraNivelit(widget.nivel.id) != null)
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () => _kalo(Katalogu.paraNivelit(widget.nivel.id)),
                  tooltip: _f('paraardhesi'),
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
          // 🚨 «E mbarova nivelin dhe nuk ka buton për të vazhduar.»
          //
          // Kjo ishte ankesa e Shabanit te «Rrota 8» (`b2-8`), dhe kodi nuk
          // kishte faj: fitorja kërkon TË DYJA — çdo çift i lidhur DHE çdo
          // qelizë e mbushur. Kur lidhen të gjitha nyjet por mbeten qeliza
          // boshe, loja nuk ishte fituar, ndaj fleta e fitores — dhe me të
          // butoni «Niveli tjetër» — nuk shfaqej fare. Lojtari e lexon këtë si
          // buton që mungon, jo si nivel të pambaruar, sepse pamja nuk i thotë
          // asgjë: të gjitha nyjet duken të lidhura.
          //
          // Rregulli i lojës nuk ndryshon (pa të, zgjidhja nuk do të ishte e
          // vetme — shih `Motori.fituar`). Ndryshon vetëm ajo që i thuhet
          // lojtarit, dhe vetëm në atë çast të vetëm ku ngatërrimi është i
          // pashmangshëm.
          if (_motori.sasiaELidhura == nivel.sasiaEShtigjeve && !_motori.fituar)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                _f('mbeten_qeliza', vlera: {
                  'n': '${nivel.sasiaELira - _motori.qelizaTeMbushura}'
                }),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: n.theksi,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
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
            // Kalimi mes niveleve pa u kthyer te menyja. I fikur te sfida e
            // ditës, e vetmja që nuk i përket asnjë bote.
            _buton(
              n,
              Icons.grid_view_rounded,
              _f('nivelet'),
              Katalogu.pjeset(widget.nivel.id) == null ? null : _zgjidhNivel,
            ),
          ],
        ),
      );

  /// Fleta e kalimit të shpejtë: rrjeta e kësaj bote, me yjet e fituar dhe
  /// rekordin e lëvizjeve. Kalimi bëhet me `pushReplacement`, ndaj stiva nuk
  /// rritet sado nivele të kalohen njëri pas tjetrit.
  Future<void> _zgjidhNivel() async {
    final pj = Katalogu.pjeset(widget.nivel.id);
    if (pj == null) return;
    final (bota, tanishmi) = pj;
    final n = Ngjyrat.per(_c.pamja);

    final zgjedhur = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: n.fusha,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${_f('bota')} $bota · ${Katalogu.emriIBotes(bota)}',
                style: TextStyle(
                    color: n.teksti, fontSize: 17, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              Flexible(
                child: GridView.builder(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  gridDelegate:
                      const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 78,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                  ),
                  itemCount: Katalogu.nivelaNe(bota),
                  itemBuilder: (context, i) {
                    final nr = i + 1;
                    final yje = widget.ruajtja.yjetE('b$bota-$nr');
                    final rekordi =
                        widget.ruajtja.levizjetMeTeMira('b$bota-$nr');
                    final ky = nr == tanishmi;
                    return Material(
                      color: ky
                          ? n.theksi.withValues(alpha: 0.30)
                          : yje > 0
                              ? n.theksi.withValues(alpha: 0.14)
                              : n.qeliza,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: ky ? null : () => Navigator.of(context).pop(nr),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('$nr',
                                style: TextStyle(
                                    color: n.teksti,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800)),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                for (var s = 0; s < 3; s++)
                                  Icon(
                                    s < yje
                                        ? Icons.star_rounded
                                        : Icons.star_border_rounded,
                                    size: 10,
                                    color:
                                        s < yje ? n.theksi : n.tekstiZbehte,
                                  ),
                              ],
                            ),
                            Text(
                              rekordi == null ? '·' : '$rekordi',
                              style: TextStyle(
                                  color: n.tekstiZbehte, fontSize: 10),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (zgjedhur == null || !mounted) return;
    unawaited(_kalo((
      Katalogu.merr(bota, zgjedhur),
      '${Katalogu.emriIBotes(bota)} · $zgjedhur',
    )));
  }

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
                    _kalo(tjetri);
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
