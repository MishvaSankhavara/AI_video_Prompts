import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../utils/common_utils.dart';
import 'ad_ids.dart';
import 'ad_manager.dart';

class InterstitialAdService {
  InterstitialAdService._();

  static void showAd({
    required BuildContext context,
    required List<String> customAdIds,
    String? screenName,
    VoidCallback? onAdClosed,
    VoidCallback? onAdFailedToShow,
  }) {
    if (customAdIds.isEmpty) {
      CommonUtils.printLog('InterstitialAdService: No IDs provided.');
      onAdClosed?.call();
      return;
    }

    AdManager.instance.showLoadingDialog();
    _loadAndShow(customAdIds, 0, onAdClosed, onAdFailedToShow);
  }

  static void _loadAndShow(
    List<String> adIds,
    int index,
    VoidCallback? onAdClosed,
    VoidCallback? onAdFailedToShow,
  ) {
    if (index >= adIds.length) {
      CommonUtils.printLog('InterstitialAdService: All Ad IDs failed.');
      AdManager.instance.dismissLoadingDialog();
      onAdFailedToShow?.call();
      // Even if ad fails to show, we often want to proceed with the app flow
      onAdClosed?.call();
      return;
    }

    final adUnitId = adIds[index];
    CommonUtils.printLog('InterstitialAdService: Attempting to load Interstitial Ad ID: $adUnitId');

    InterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          CommonUtils.printLog('InterstitialAdService: Interstitial loaded successfully ID: $adUnitId');

          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              CommonUtils.printLog('InterstitialAdService: Interstitial dismissed.');
              onAdClosed?.call();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              CommonUtils.printLog('InterstitialAdService: Interstitial failed to show: $error');
              AdManager.instance.dismissLoadingDialog();
              onAdFailedToShow?.call();
              onAdClosed?.call();
            },
            onAdShowedFullScreenContent: (ad) {
              CommonUtils.printLog('InterstitialAdService: Interstitial displayed.');
              AdManager.instance.dismissLoadingDialog();
            },
          );

          ad.show();
        },
        onAdFailedToLoad: (error) {
          CommonUtils.printLog('InterstitialAdService: Interstitial failed to load ID: $adUnitId ($error). Trying next...');
          _loadAndShow(adIds, index + 1, onAdClosed, onAdFailedToShow);
        },
      ),
    );
  }
}
