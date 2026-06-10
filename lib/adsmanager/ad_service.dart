import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../utils/common_utils.dart';
import 'ad_ids.dart';

class AdService {
  AdService._internal();
  static final AdService instance = AdService._internal();

  // ─── INTERNAL STATE ──────────────
  AppOpenAd? _appOpenAd;
  bool _isAppOpenAdLoading = false;
  bool _isShowingAppOpenAd = false;
  String? _lastAppOpenAdUnitId;

  InterstitialAd? _interstitialAd;
  bool _isInterstitialLoading = false;
  String? _lastInterstitialHighFloorId;
  String? _lastInterstitialLowFloorId;

  RewardedAd? _rewardedAd;
  bool _isRewardedAdLoading = false;
  String? _lastRewardedHighFloorId;
  String? _lastRewardedLowFloorId;

  // ─── INITIALIZATION ────────────────────────────────────────────────────────

  Future<void> initialize() async {
    if (!AdIds.showAdsEnabled) {
      CommonUtils.printLog('AdService: Ads are disabled. Skipping MobileAds SDK initialization.');
      return;
    }
    await MobileAds.instance.initialize();
    CommonUtils.printLog('AdService: MobileAds SDK initialized.');
  }

  // ─── APP OPEN AD ───────────────────────────────────────────────────────────

  /// Preloads the App Open Ad.
  void loadAppOpenAd({String? adUnitId}) {
    if (adUnitId != null) {
      _lastAppOpenAdUnitId = adUnitId;
    }

    if (!AdIds.showAdsEnabled) {
      CommonUtils.printLog('loadAppOpenAd: Ads are disabled. Skipping loadAppOpenAd.');
      return;
    }

    if (_isAppOpenAdLoading || _appOpenAd != null) return;
    _isAppOpenAdLoading = true;

    final String targetId = _lastAppOpenAdUnitId ?? AdIds.appOpenAdUnitId;
    CommonUtils.printLog('loadAppOpenAd: Starting load for App Open Ad with ID: $targetId');

    AppOpenAd.load(
      adUnitId: targetId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpenAd = ad;
          _isAppOpenAdLoading = false;
          CommonUtils.printLog('loadAppOpenAd: App Open Ad loaded successfully with ID: $targetId');
        },
        onAdFailedToLoad: (error) {
          _appOpenAd = null;
          _isAppOpenAdLoading = false;
          CommonUtils.printLog('loadAppOpenAd: App Open Ad failed to load (ID: $targetId): $error');
        },
      ),
    );
  }

  // Shows the App Open Ad
  void showAppOpenAd({required VoidCallback onAdDismissed}) {
    if (!AdIds.showAdsEnabled) {
      CommonUtils.printLog('showAppOpenAd: Ads are disabled. Skipping App Open Ad show.');
      onAdDismissed();
      return;
    }

    if (_appOpenAd == null || _isShowingAppOpenAd) {
      CommonUtils.printLog('AdSeshowAppOpenAdrvice: App Open Ad not ready (is null or already showing), proceeding without ad.');
      onAdDismissed();
      return;
    }

    _isShowingAppOpenAd = true;

    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        final adId = ad.adUnitId;
        ad.dispose();
        _appOpenAd = null;
        _isShowingAppOpenAd = false;
        CommonUtils.printLog('showAppOpenAd: App Open Ad dismissed. (Ad ID: $adId)');
        onAdDismissed();
        loadAppOpenAd(); // Preload next using the last active ID
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        final adId = ad.adUnitId;
        ad.dispose();
        _appOpenAd = null;
        _isShowingAppOpenAd = false;
        CommonUtils.printLog('showAppOpenAd: App Open Ad failed to show. Error: $error. (Ad ID: $adId)');
        onAdDismissed();
        loadAppOpenAd();
      },
      onAdShowedFullScreenContent: (ad) {
        CommonUtils.printLog('showAppOpenAd: App Open Ad successfully displayed. (Ad ID: ${ad.adUnitId})');
      },
    );

    _appOpenAd!.show();
  }

  // ─── INTERSTITIAL AD ───────────────────────────────────────────────────────

  /// Pre-loads the interstitial ad.
  void loadInterstitialAd({String? highFloorId, String? lowFloorId}) {
    if (highFloorId != null) _lastInterstitialHighFloorId = highFloorId;
    if (lowFloorId != null) _lastInterstitialLowFloorId = lowFloorId;

    if (!AdIds.showAdsEnabled) {
      CommonUtils.printLog('loadInterstitialAd: Ads are disabled. Skipping loadInterstitialAd.');
      return;
    }

    if (_isInterstitialLoading || _interstitialAd != null) return;
    _isInterstitialLoading = true;

    final String highId = _lastInterstitialHighFloorId ?? AdIds.interHomelHF1;
    final String lowId = _lastInterstitialLowFloorId ?? AdIds.interHomeLF1;

    CommonUtils.printLog('loadInterstitialAd: Starting load for Interstitial Ad (high-floor) with ID: $highId');

    // Attempt high-floor first
    InterstitialAd.load(
      adUnitId: highId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialLoading = false;
          CommonUtils.printLog('loadInterstitialAd: Interstitial (high-floor) loaded successfully with ID: $highId');
        },
        onAdFailedToLoad: (error) {
          CommonUtils.printLog('loadInterstitialAd: Interstitial high-floor ($highId) failed ($error), trying low-floor fallback ($lowId)...');
          // Fallback to low-floor
          InterstitialAd.load(
            adUnitId: lowId,
            request: const AdRequest(),
            adLoadCallback: InterstitialAdLoadCallback(
              onAdLoaded: (ad) {
                _interstitialAd = ad;
                _isInterstitialLoading = false;
                CommonUtils.printLog('loadInterstitialAd: Interstitial (low-floor) loaded successfully with ID: $lowId');
              },
              onAdFailedToLoad: (err) {
                _interstitialAd = null;
                _isInterstitialLoading = false;
                CommonUtils.printLog('loadInterstitialAd: Interstitial low-floor ($lowId) also failed: $err');
              },
            ),
          );
        },
      ),
    );
  }

  // Shows the interstitial ad
  void showInterstitialAd({required VoidCallback onAdDismissed}) {
    if (!AdIds.showAdsEnabled) {
      CommonUtils.printLog('showInterstitialAd: Ads are disabled. Skipping Interstitial Ad show.');
      onAdDismissed();
      return;
    }

    if (_interstitialAd == null) {
      CommonUtils.printLog('showInterstitialAd: Interstitial not ready, proceeding without ad.');
      onAdDismissed();
      return;
    }

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        final adId = ad.adUnitId;
        ad.dispose();
        _interstitialAd = null;
        CommonUtils.printLog('showInterstitialAd: Interstitial dismissed. (Ad ID: $adId)');
        onAdDismissed();
        loadInterstitialAd(); // Preload next using the last active IDs
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        final adId = ad.adUnitId;
        ad.dispose();
        _interstitialAd = null;
        CommonUtils.printLog('showInterstitialAd: Interstitial failed to show. Error: $error. (Ad ID: $adId)');
        onAdDismissed();
        loadInterstitialAd();
      },
      onAdShowedFullScreenContent: (ad) {
        CommonUtils.printLog('showInterstitialAd: Interstitial successfully displayed. (Ad ID: ${ad.adUnitId})');
      },
    );

    _interstitialAd!.show();
  }

  // ─── REWARDED AD ───────────────────────────────────────────────────────────

  /// Pre-loads the Rewarded Ad with High-Floor / Low-Floor support.
  void loadRewardedAd({String? highFloorId, String? lowFloorId}) {
    if (highFloorId != null) _lastRewardedHighFloorId = highFloorId;
    if (lowFloorId != null) _lastRewardedLowFloorId = lowFloorId;

    if (!AdIds.showAdsEnabled) {
      CommonUtils.printLog('loadRewardedAd: Ads are disabled. Skipping loadRewardedAd.');
      return;
    }

    if (_isRewardedAdLoading || _rewardedAd != null) return;
    _isRewardedAdLoading = true;

    final String highId = _lastRewardedHighFloorId ?? AdIds.rewardedHF;
    final String lowId = _lastRewardedLowFloorId ?? AdIds.rewardedLF;

    CommonUtils.printLog('loadRewardedAd: Starting load for Rewarded Ad (high-floor) with ID: $highId');

    // Attempt high-floor first
    RewardedAd.load(
      adUnitId: highId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedAdLoading = false;
          CommonUtils.printLog('loadRewardedAd: Rewarded Ad (high-floor) loaded successfully with ID: $highId');
        },
        onAdFailedToLoad: (error) {
          CommonUtils.printLog('loadRewardedAd: Rewarded Ad high-floor ($highId) failed ($error), trying low-floor fallback ($lowId)...');
          // Fallback to low-floor
          RewardedAd.load(
            adUnitId: lowId,
            request: const AdRequest(),
            rewardedAdLoadCallback: RewardedAdLoadCallback(
              onAdLoaded: (ad) {
                _rewardedAd = ad;
                _isRewardedAdLoading = false;
                CommonUtils.printLog('loadRewardedAd: Rewarded Ad (low-floor) loaded successfully with ID: $lowId');
              },
              onAdFailedToLoad: (err) {
                _rewardedAd = null;
                _isRewardedAdLoading = false;
                CommonUtils.printLog('loadRewardedAd: Rewarded Ad low-floor ($lowId) also failed: $err');
              },
            ),
          );
        },
      ),
    );
  }

  // Shows the Rewarded Ad.
  void showRewardedAd({
    required VoidCallback onRewarded,
    required VoidCallback onDismissed,
  }) {
    if (!AdIds.showAdsEnabled) {
      CommonUtils.printLog('showRewardedAd: Ads are disabled. Skipping Rewarded Ad show.');
      onDismissed();
      return;
    }

    if (_rewardedAd == null) {
      CommonUtils.printLog('showRewardedAd: Rewarded Ad not ready, proceeding without ad.');
      onDismissed();
      return;
    }

    bool rewardEarned = false;

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        final adId = ad.adUnitId;
        ad.dispose();
        _rewardedAd = null;
        CommonUtils.printLog('showRewardedAd: Rewarded Ad dismissed. Reward earned: $rewardEarned. (Ad ID: $adId)');
        if (rewardEarned) onRewarded();
        onDismissed();
        loadRewardedAd(); // Preload next using the last active IDs
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        final adId = ad.adUnitId;
        ad.dispose();
        _rewardedAd = null;
        CommonUtils.printLog('showRewardedAd: Rewarded Ad failed to show. Error: $error. (Ad ID: $adId)');
        onDismissed();
        loadRewardedAd();
      },
      onAdShowedFullScreenContent: (ad) {
        CommonUtils.printLog('showRewardedAd: Rewarded Ad successfully displayed. (Ad ID: ${ad.adUnitId})');
      },
    );

    _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        rewardEarned = true;
        CommonUtils.printLog('showRewardedAd: User earned reward: ${reward.amount} ${reward.type} (Ad ID: ${ad.adUnitId})');
      },
    );
  }

  // ─── CLEANUP ───────────────────────────────────────────────────────────────

  void dispose() {
    _appOpenAd?.dispose();
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
  }
}
