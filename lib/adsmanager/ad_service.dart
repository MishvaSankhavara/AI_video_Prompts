import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../utils/common_utils.dart';
import '../utils/colors.dart';
import '../main.dart';
import 'ad_ids.dart';

class AdService {
  AdService._internal();
  static final AdService instance = AdService._internal();

  /// Set to 'debug' to use test ad IDs, or 'release' to use production/real ad IDs.
  static const String adMode = 'debug'; // Options: 'debug' | 'release'

  /// Clean common helper to resolve the correct Ad ID based on mode and platform.
  static String getAdUnitId({
    required String androidDebug,
    required String androidRelease,
    required String iosDebug,
    required String iosRelease,
  }) {
    final bool isAndroid = Platform.isAndroid;
    final bool isRelease = adMode == 'release';

    if (isAndroid) {
      return isRelease ? androidRelease : androidDebug;
    } else {
      return isRelease ? iosRelease : iosDebug;
    }
  }

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

  // Global Dialog State
  bool _isDialogShowing = false;

  // Get current global context from navigatorKey
  BuildContext? get _globalContext => navigatorKey.currentContext;

  // ─── INITIALIZATION ────────────────────────────────────────────────────────

  Future<void> initialize() async {
    if (!AdIds.showAdsEnabled) {
      CommonUtils.printLog('AdService: Ads are disabled. Skipping MobileAds SDK initialization.');
      return;
    }
    await MobileAds.instance.initialize();
    CommonUtils.printLog('AdService: MobileAds SDK initialized.');
  }

  // ─── LOADING DIALOG UI ─────────────────────────────────────────────────────

  void _showLoadingDialog() {
    final context = _globalContext;
    if (context == null || _isDialogShowing) return;

    _isDialogShowing = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      builder: (BuildContext context) {
        return PopScope(
          canPop: false, // Prevent dismissal via back button
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 38,
                    height: 38,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                      strokeWidth: 3.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Loading Ad...',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.none,
                      fontFamily: 'Outfit',
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _dismissLoadingDialog() {
    final context = _globalContext;
    if (context == null || !_isDialogShowing) return;

    _isDialogShowing = false;
    Navigator.of(context, rootNavigator: true).pop();
  }

  // ─── APP OPEN AD ───────────────────────────────────────────────────────────

  // Preloads the App Open Ad.
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
      CommonUtils.printLog('showAppOpenAd: App Open Ad not ready, proceeding without ad.');
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

  // Pre-loads the interstitial ad.
  void loadInterstitialAd({String? highFloorId, String? lowFloorId}) {
    if (highFloorId != null) _lastInterstitialHighFloorId = highFloorId;
    if (lowFloorId != null) _lastInterstitialLowFloorId = lowFloorId;

    if (!AdIds.showAdsEnabled) {
      CommonUtils.printLog('AdService: Ads are disabled. Skipping loadInterstitialAd.');
      return;
    }

    if (_isInterstitialLoading || _interstitialAd != null) return;
    _isInterstitialLoading = true;

    final String highId = _lastInterstitialHighFloorId ?? AdIds.interHomelHF1;
    final String lowId = _lastInterstitialLowFloorId ?? AdIds.interHomeLF1;

    CommonUtils.printLog('AdService: Starting load for Interstitial Ad (high-floor) with ID: $highId');

    // Attempt high-floor first
    InterstitialAd.load(
      adUnitId: highId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialLoading = false;
          CommonUtils.printLog('AdService: Interstitial (high-floor) loaded successfully with ID: $highId');
        },
        onAdFailedToLoad: (error) {
          CommonUtils.printLog('AdService: Interstitial high-floor ($highId) failed ($error), trying low-floor fallback ($lowId)...');
          // Fallback to low-floor
          InterstitialAd.load(
            adUnitId: lowId,
            request: const AdRequest(),
            adLoadCallback: InterstitialAdLoadCallback(
              onAdLoaded: (ad) {
                _interstitialAd = ad;
                _isInterstitialLoading = false;
                CommonUtils.printLog('AdService: Interstitial (low-floor) loaded successfully with ID: $lowId');
              },
              onAdFailedToLoad: (err) {
                _interstitialAd = null;
                _isInterstitialLoading = false;
                CommonUtils.printLog('AdService: Interstitial low-floor ($lowId) also failed: $err');
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
      CommonUtils.printLog('AdService: Ads are disabled. Skipping Interstitial Ad show.');
      onAdDismissed();
      return;
    }

    _showLoadingDialog();

    // If ad is not ready yet, try loading on-the-fly and wait with a timeout
    if (_interstitialAd == null) {
      CommonUtils.printLog('AdService: Interstitial not ready. Attempting to load on-the-fly...');
      
      bool finished = false;
      Future.delayed(const Duration(seconds: 4), () {
        if (!finished) {
          finished = true;
          CommonUtils.printLog('AdService: Interstitial load timed out. Proceeding...');
          _dismissLoadingDialog();
          onAdDismissed();
        }
      });

      loadInterstitialAd();

      void checkAdReady() {
        if (finished) return;
        if (_interstitialAd != null) {
          finished = true;
          CommonUtils.printLog('AdService: Interstitial loaded on-the-fly. Displaying ad.');
          _showLoadedInterstitial(onAdDismissed);
        } else if (!_isInterstitialLoading) {
          finished = true;
          CommonUtils.printLog('AdService: Interstitial failed to load on-the-fly. Proceeding...');
          _dismissLoadingDialog();
          onAdDismissed();
        } else {
          Future.delayed(const Duration(milliseconds: 250), checkAdReady);
        }
      }

      checkAdReady();
      return;
    }

    _showLoadedInterstitial(onAdDismissed);
  }

  void _showLoadedInterstitial(VoidCallback onAdDismissed) {
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        final adId = ad.adUnitId;
        ad.dispose();
        _interstitialAd = null;
        CommonUtils.printLog('AdService: Interstitial dismissed. (Ad ID: $adId)');
        onAdDismissed();
        loadInterstitialAd(); // Preload next using the last active IDs
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        final adId = ad.adUnitId;
        ad.dispose();
        _interstitialAd = null;
        CommonUtils.printLog('AdService: Interstitial failed to show. Error: $error. (Ad ID: $adId)');
        _dismissLoadingDialog();
        onAdDismissed();
        loadInterstitialAd();
      },
      onAdShowedFullScreenContent: (ad) {
        CommonUtils.printLog('AdService: Interstitial successfully displayed. (Ad ID: ${ad.adUnitId})');
        _dismissLoadingDialog();
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
      CommonUtils.printLog('AdService: Ads are disabled. Skipping loadRewardedAd.');
      return;
    }

    if (_isRewardedAdLoading || _rewardedAd != null) return;
    _isRewardedAdLoading = true;

    final String highId = _lastRewardedHighFloorId ?? AdIds.rewardedHF;
    final String lowId = _lastRewardedLowFloorId ?? AdIds.rewardedLF;

    CommonUtils.printLog('AdService: Starting load for Rewarded Ad (high-floor) with ID: $highId');

    // Attempt high-floor first
    RewardedAd.load(
      adUnitId: highId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedAdLoading = false;
          CommonUtils.printLog('AdService: Rewarded Ad (high-floor) loaded successfully with ID: $highId');
        },
        onAdFailedToLoad: (error) {
          CommonUtils.printLog('AdService: Rewarded Ad high-floor ($highId) failed ($error), trying low-floor fallback ($lowId)...');
          // Fallback to low-floor
          RewardedAd.load(
            adUnitId: lowId,
            request: const AdRequest(),
            rewardedAdLoadCallback: RewardedAdLoadCallback(
              onAdLoaded: (ad) {
                _rewardedAd = ad;
                _isRewardedAdLoading = false;
                CommonUtils.printLog('AdService: Rewarded Ad (low-floor) loaded successfully with ID: $lowId');
              },
              onAdFailedToLoad: (err) {
                _rewardedAd = null;
                _isRewardedAdLoading = false;
                CommonUtils.printLog('AdService: Rewarded Ad low-floor ($lowId) also failed: $err');
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
        CommonUtils.printLog('AdService: Ads are disabled. Auto-rewarding user and skipping Rewarded Ad show.');
        onRewarded();
        onDismissed();
        return;
      }

      _showLoadingDialog();

      // If ad is not ready yet, try loading on-the-fly and wait with a timeout
      if (_rewardedAd == null) {
        CommonUtils.printLog('AdService: Rewarded Ad not ready. Attempting to load on-the-fly...');

        bool finished = false;
        Future.delayed(const Duration(seconds: 4), () {
          if (!finished) {
            finished = true;
            CommonUtils.printLog('AdService: Rewarded Ad load timed out. Proceeding...');
            _dismissLoadingDialog();
            onDismissed();
          }
        });

        loadRewardedAd();

        void checkAdReady() {
          if (finished) return;
          if (_rewardedAd != null) {
            finished = true;
            CommonUtils.printLog('AdService: Rewarded Ad loaded on-the-fly. Displaying ad.');
            _showLoadedRewarded(onRewarded, onDismissed);
          } else if (!_isRewardedAdLoading) {
            finished = true;
            CommonUtils.printLog('AdService: Rewarded Ad failed to load on-the-fly. Proceeding...');
            _dismissLoadingDialog();
            onDismissed();
          } else {
            Future.delayed(const Duration(milliseconds: 250), checkAdReady);
          }
        }

        checkAdReady();
        return;
      }

      _showLoadedRewarded(onRewarded, onDismissed);
  }

  void _showLoadedRewarded(VoidCallback onRewarded, VoidCallback onDismissed) {
    bool rewardEarned = false;

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        final adId = ad.adUnitId;
        ad.dispose();
        _rewardedAd = null;
        CommonUtils.printLog('AdService: Rewarded Ad dismissed. Reward earned: $rewardEarned. (Ad ID: $adId)');
        if (rewardEarned) onRewarded();
        onDismissed();
        loadRewardedAd(); // Preload next using the last active IDs
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        final adId = ad.adUnitId;
        ad.dispose();
        _rewardedAd = null;
        CommonUtils.printLog('AdService: Rewarded Ad failed to show. Error: $error. (Ad ID: $adId)');
        _dismissLoadingDialog();
        onDismissed();
        loadRewardedAd();
      },
      onAdShowedFullScreenContent: (ad) {
        CommonUtils.printLog('AdService: Rewarded Ad successfully displayed. (Ad ID: ${ad.adUnitId})');
        _dismissLoadingDialog();
      },
    );

    _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        rewardEarned = true;
        CommonUtils.printLog('AdService: User earned reward: ${reward.amount} ${reward.type} (Ad ID: ${ad.adUnitId})');
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
