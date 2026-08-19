import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Reklamat e Girih-ut.
///
/// Të gjitha rregullat rrinë KËTU, në një skedar. Shpërndarja e tyre nëpër
/// ekrane e bën pyetjen «sa reklama ka kjo lojë» të papërgjigjshme — dhe
/// pikërisht ajo pyetje vendos nëse lojtari e mban ose e heq lojën.
///
/// **Politika: më e rreptë se te [[Mat!]].** Një enigmë zgjidhet për 40 sekonda,
/// pra një kufi «1 reklamë për 3 lojëra» do të nxirrte një reklamë çdo dy minuta
/// — pesëfishi i shahut për të njëjtën kohë loje. Kufijtë janë prandaj të
/// shprehur në **nivele DHE në minuta**, dhe kufiri i kohës është ai që bën punë:
///
/// | Ku | Çfarë |
/// |---|---|
/// | menyja kryesore | banderolë poshtë |
/// | gjatë zgjidhjes | **asgjë** — rrjeta nuk preket kurrë |
/// | pas fitores | interstitial, 1 në 5 nivele dhe s'ka dy brenda 4 minutash |
/// | sfida e ditës | **kurrë** — ajo luhet një herë në ditë, s'ka çka amortizohet |
/// | butoni «Ndihmë» kur ndihmat mbarojnë | reklamë me shpërblim, me dëshirë |
/// | hapja e aplikacionit | **e fikur** |
///
/// **Katër rregulla që nuk shkelen:**
///
/// 1. 🕌 **Filtrim halal në dy vende.** [MaxAdContentRating.g] këtu plus
///    bllokimi i kategorive te konsola e AdMob-it (bixhoz, alkool, takime,
///    kredi me kamatë). Të dyja duhen: kodi kufizon *klasifikimin*, konsola
///    kufizon *temën*, dhe një reklamë bixhozi mund të jetë fare mirë e
///    klasifikuar «G».
/// 2. **Asnjë reklamë mbi rrjetën.** Një enigmë e mbuluar gjysmë nga një
///    banderolë është pikërisht ajo që Play-i e quan «reklamë shkatërruese».
/// 3. 🚨 **Në debug përdoren GJITHMONË njësitë e provës së Google-it.** Një
///    klikim i vetëm mbi njësinë e vërtetë nga vetë zhvilluesi është «trafik i
///    pavlefshëm»: llogaria e AdMob-it mbyllet pa paralajmërim.
/// 4. 🚨 **Loja mbetet e plotë pa rrjet.** Reklamat janë e vetmja gjë në krejt
///    Girih-un që prek internetin; nivelet, përparimi dhe ndihmat janë vendëse.
///    Nëse rrjeti mungon, [supported] mbetet `true` por çdo ngarkim dështon —
///    dhe çdo rrugë këtu është shkruar që dështimi të mos i kushtojë lojtarit
///    asgjë: banderola zë zero hapësirë, interstitial-i anashkalohet, dhe
///    shpërblimi jepet gjithsesi.
class Ads {
  Ads._();

  /// Njësitë e vërteta të Girih-ut nga llogaria e AdMob-it
  /// (`credentials.local.txt`, ndarja «Girih»). Nuk janë sekret: një
  /// identifikues njësie del në çdo kërkesë reklame dhe lexohet nga APK-ja.
  ///
  /// ⚠️ Të tri aplikacionet rrinë nën të njëjtën llogari
  /// (`~1776059573171352`) por nën aplikacione të NDRYSHME te AdMob-i, ndaj
  /// identifikuesi i aplikacionit ndryshon: Girih `~4045126137`, Mat!
  /// `~3928973421`, Tokërrgjik `~3673667026`. Ai i Girih-ut rri te manifesti.
  /// Një identifikues i huaj nuk jep gabim — jep zero mbushje.
  static const String _bannerLive = 'ca-app-pub-8491001524308476/4903217121';
  static const String _interstitialLive = 'ca-app-pub-8491001524308476/7079572292';
  static const String _rewardedLive = 'ca-app-pub-8491001524308476/2888940647';

  // Të krijuara te AdMob-i por të PAPËRDORURA me qëllim. Rrinë të shënuara që
  // të mos rikrijohen, dhe që një njësi me zero kërkesa te konsola të ketë
  // shpjegim:
  //   app open           ca-app-pub-8491001524308476/1827245611
  //   native advanced    ca-app-pub-8491001524308476/4174102153
  //   rewarded interst.  ca-app-pub-8491001524308476/6800265494

  /// Njësitë e provës së Google-it. Kthejnë gjithmonë një reklamë, kudo, dhe
  /// klikimi mbi to nuk numërohet askund.
  static const String _bannerTest = 'ca-app-pub-3940256099942544/6300978111';
  static const String _interstitialTest = 'ca-app-pub-3940256099942544/1033173712';
  static const String _rewardedTest = 'ca-app-pub-3940256099942544/5224354917';

  static String get bannerUnit => kReleaseMode ? _bannerLive : _bannerTest;
  static String get interstitialUnit =>
      kReleaseMode ? _interstitialLive : _interstitialTest;
  static String get rewardedUnit => kReleaseMode ? _rewardedLive : _rewardedTest;

  /// Reklamat ekzistojnë vetëm në Android dhe iOS. I njëjti kod ndërtohet edhe
  /// për web (girih.spacecode.tech), dhe atje `MobileAds.instance` rrëzohet —
  /// ndaj çdo rrugë këtu kalon nga kjo pyetje e vetme. Versioni në internet
  /// mbetet pa asnjë reklamë.
  static bool get supported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  static bool _ready = false;

  /// A janë reklamat gati. Ekranet e pyesin që të mos lënë vend bosh për diçka
  /// që mund të mos vijë kurrë.
  static bool get ready => _ready;

  /// Nisja. Thirret një herë, para se të hapet ekrani i parë.
  ///
  /// Nuk hidhet kurrë përjashtim jashtë: një enigmë që nuk hapet sepse rrjeti i
  /// reklamave nuk u përgjigj është shkëmbim absurd.
  static Future<void> start() async {
    if (!supported || _ready) return;
    try {
      await _askConsent();
      await MobileAds.instance.initialize();
      await MobileAds.instance.updateRequestConfiguration(
        RequestConfiguration(
          // 🕌 «G» = e përshtatshme për të gjithë. Gjysma e filtrit; gjysma
          // tjetër janë kategoritë e ndjeshme te konsola e AdMob-it.
          maxAdContentRating: MaxAdContentRating.g,
          // Publiku i synuar te Play është 13+, pra jo fëmijë. Një «po» këtu do
          // të hiqte identifikuesin e reklamave, do të ulte mbushjen pa nevojë,
          // dhe mbi të gjitha do të ishte deklarim i pasaktë.
          tagForChildDirectedTreatment: TagForChildDirectedTreatment.unspecified,
        ),
      );
      _ready = true;
      preloadInterstitial();
    } catch (e) {
      debugPrint('reklamat nuk u nisën: $e');
    }
  }

  /// Pëlqimi sipas GDPR-së (UMP). Pa këtë, një lojtar në BE merr reklama pa bazë
  /// ligjore — dhe Google-i e ndalon mbushjen për atë pajisje.
  static Future<void> _askConsent() async {
    final Completer<void> done = Completer<void>();
    ConsentInformation.instance.requestConsentInfoUpdate(
      ConsentRequestParameters(),
      () {
        ConsentForm.loadAndShowConsentFormIfRequired((FormError? error) {
          if (error != null) debugPrint('formulari i pëlqimit: ${error.message}');
          if (!done.isCompleted) done.complete();
        });
      },
      (FormError error) {
        debugPrint('pëlqimi: ${error.message}');
        if (!done.isCompleted) done.complete();
      },
    );
    // Nëse UMP-ja nuk përgjigjet fare, aplikacioni vazhdon pa të: më mirë një
    // ekran fillestar pa reklama sesa një ekran fillestar që nuk mbaron kurrë.
    return done.future.timeout(const Duration(seconds: 6), onTimeout: () {});
  }

  // ── interstitial ───────────────────────────────────────────────────────────

  static InterstitialAd? _interstitial;
  static DateTime _lastInterstitial = DateTime.fromMillisecondsSinceEpoch(0);
  static int _levelsSinceAd = 0;

  /// Ngarkon paraprakisht reklamën e ndërmjetme. Ngarkimi zgjat sekonda; nëse
  /// nis vetëm në çastin kur duhet shfaqur, ose vonon lojtarin ose humbet.
  static void preloadInterstitial() {
    if (!_ready || _interstitial != null) return;
    InterstitialAd.load(
      adUnitId: interstitialUnit,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) => _interstitial = ad,
        onAdFailedToLoad: (LoadAdError e) => _interstitial = null,
      ),
    );
  }

  /// Shfaqet kur lojtari kalon te niveli tjetër — dhe jo pas çdo niveli.
  ///
  /// 🚨 Kufiri i **kohës** është ai që bën punë këtu, jo ai i niveleve. Nivelet
  /// e botës së parë zgjidhen për 20–40 sekonda; me kufi vetëm prej pesë
  /// nivelesh, një lojtar i shpejtë do të shihte një reklamë çdo dy minuta.
  /// Katër minuta e vendosin tavanin te ~15 reklama në orë loje edhe në rastin
  /// më të keq.
  static Future<void> maybeShowAfterLevel() async {
    if (!_ready) return;
    _levelsSinceAd++;
    final bool tooSoon =
        DateTime.now().difference(_lastInterstitial) < const Duration(minutes: 4);
    if (_levelsSinceAd < 5 || tooSoon) {
      preloadInterstitial();
      return;
    }

    final InterstitialAd? ad = _interstitial;
    if (ad == null) {
      preloadInterstitial();
      return;
    }
    _interstitial = null;
    _levelsSinceAd = 0;
    _lastInterstitial = DateTime.now();

    ad.fullScreenContentCallback = FullScreenContentCallback<InterstitialAd>(
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        ad.dispose();
        preloadInterstitial();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError e) {
        ad.dispose();
        preloadInterstitial();
      },
    );
    await ad.show();
  }

  // ── me shpërblim ───────────────────────────────────────────────────────────

  /// Shfaq një reklamë me shpërblim dhe kthen `true` vetëm nëse lojtari e pa
  /// deri në fund.
  ///
  /// Çdo dështim kthen `false`, dhe thirrësi vendos vetë: te ky aplikacion e jep
  /// ndihmën gjithsesi, sepse një lojtar që PRANOI të shohë një reklamë nuk
  /// duhet ndëshkuar për një rrjet që nuk u përgjigj.
  static Future<bool> showRewarded() async {
    if (!_ready) return false;
    final Completer<bool> done = Completer<bool>();

    unawaited(RewardedAd.load(
      adUnitId: rewardedUnit,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          bool earned = false;
          ad.fullScreenContentCallback = FullScreenContentCallback<RewardedAd>(
            onAdDismissedFullScreenContent: (RewardedAd ad) {
              ad.dispose();
              if (!done.isCompleted) done.complete(earned);
            },
            onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError e) {
              ad.dispose();
              if (!done.isCompleted) done.complete(false);
            },
          );
          unawaited(ad.show(onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
            earned = true;
          }));
        },
        onAdFailedToLoad: (LoadAdError e) {
          if (!done.isCompleted) done.complete(false);
        },
      ),
    ));

    return done.future.timeout(const Duration(seconds: 12), onTimeout: () => false);
  }
}

/// Banderola e poshtme e menysë kryesore.
///
/// E ndarë si widget me gjendjen e vet sepse një `BannerAd` duhet ngarkuar dhe
/// hedhur bashkë me ekranin që e mban; një banderolë e vetme e përbashkët do të
/// mbetej e lidhur me një `BuildContext` të vdekur pas rrotullimit të ekranit.
///
/// Sa kohë reklama nuk është gati, widget-i zë **zero** hapësirë. Një kuti bosh
/// me lartësi 50 pikselë nën menu është vend i mbajtur për diçka që mund të mos
/// vijë kurrë (pa internet, në web, ose me pëlqim të refuzuar).
class BannerSlot extends StatefulWidget {
  const BannerSlot({super.key});

  @override
  State<BannerSlot> createState() => _BannerSlotState();
}

class _BannerSlotState extends State<BannerSlot> {
  BannerAd? _ad;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    if (!Ads.ready) return;
    final BannerAd ad = BannerAd(
      adUnitId: Ads.bannerUnit,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad _) {
          if (mounted) setState(() => _loaded = true);
        },
        onAdFailedToLoad: (Ad ad, LoadAdError e) {
          ad.dispose();
          if (mounted) setState(() => _ad = null);
        },
      ),
    );
    _ad = ad;
    unawaited(ad.load());
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final BannerAd? ad = _ad;
    if (ad == null || !_loaded) return const SizedBox.shrink();
    return SizedBox(
      width: ad.size.width.toDouble(),
      height: ad.size.height.toDouble(),
      child: AdWidget(ad: ad),
    );
  }
}
