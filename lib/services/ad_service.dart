import 'dart:async';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  static AdService? _instance;
  static AdService get instance => _instance ??= AdService._();
  AdService._();

  // ─── Ad Unit IDs ───────────────────────────────────────────────
  static const String _rewardedAdUnitId =
      'ca-app-pub-9755093615040362/7217622023';
  static const String _bannerAdUnitId =
      'ca-app-pub-9755093615040362/1069649094';
  static const String _interstitialAdUnitId =
      'ca-app-pub-9755093615040362/6720694934';

  RewardedAd? _rewardedAd;
  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  bool _isBannerAdLoaded = false;

  // ─── Init ──────────────────────────────────────────────────────
  Future<void> init() async {
    MobileAds.instance.updateRequestConfiguration(
      RequestConfiguration(
        testDeviceIds: ['AB1F3CFD8D78B06344825FC64B1F7285'],
      ),
    );
    await MobileAds.instance.initialize();
    loadRewardedAd();
    loadBannerAd();
    loadInterstitialAd();
  }

  // ─── Rewarded Ad ───────────────────────────────────────────────
  void loadRewardedAd() {
    RewardedAd.load(
      adUnitId: _rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) => _rewardedAd = ad,
        onAdFailedToLoad: (_) {
          _rewardedAd = null;
          Future.delayed(const Duration(seconds: 30), loadRewardedAd);
        },
      ),
    );
  }

  bool get isRewardedAdReady => _rewardedAd != null;

  Future<bool> showRewardedAd() async {
    if (_rewardedAd == null) return false;

    final ad = _rewardedAd!;
    _rewardedAd = null;

    final completer = Completer<bool>();
    bool rewarded = false;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        loadRewardedAd();
        if (!completer.isCompleted) completer.complete(rewarded);
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        loadRewardedAd();
        if (!completer.isCompleted) completer.complete(false);
      },
    );

    await ad.show(
      onUserEarnedReward: (_, __) => rewarded = true,
    );

    return completer.future;
  }

  // ─── Banner Ad ────────────────────────────────────────────────
  void loadBannerAd() {
    _bannerAd?.dispose();
    _bannerAd = BannerAd(
      adUnitId: _bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) => _isBannerAdLoaded = true,
        onAdFailedToLoad: (ad, _) {
          ad.dispose();
          _bannerAd = null;
          _isBannerAdLoaded = false;
        },
      ),
    )..load();
  }

  bool get isBannerAdReady => _isBannerAdLoaded && _bannerAd != null;
  BannerAd? get bannerAd => _bannerAd;

  // ─── Interstitial ─────────────────────────────────────────────
  void loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: _interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => _interstitialAd = ad,
        onAdFailedToLoad: (_) => _interstitialAd = null,
      ),
    );
  }

  Future<void> showInterstitialAd() async {
    if (_interstitialAd == null) return;

    final ad = _interstitialAd!;
    _interstitialAd = null;

    final completer = Completer<void>();

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        loadInterstitialAd();
        if (!completer.isCompleted) completer.complete();
      },
      onAdFailedToShowFullScreenContent: (ad, _) {
        ad.dispose();
        loadInterstitialAd();
        if (!completer.isCompleted) completer.complete();
      },
    );

    await ad.show();
    return completer.future;
  }

  // ─── Dispose ──────────────────────────────────────────────────
  void dispose() {
    _rewardedAd?.dispose();
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
  }
}