import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../utils/common_utils.dart';
import '../utils/strings.dart';
import '../widgets/dialog/loading_dialog.dart';
import '../services/remote_config_service.dart';
import 'ad_ids.dart';

class InterstitialAdService {
  InterstitialAdService._();

  static void showAd({
    required BuildContext context,
    required List<String> customAdIds,
    String? screenName,
    VoidCallback? onAdClosed,
    VoidCallback? onAdFailedToShow,
  }) {
    // Ads disabled (e.g. via remote config) -> skip the ad, continue app flow.
    if (!RemoteConfigService.instance.showAdsEnabled) {
      onAdFailedToShow?.call();
      return;
    }

    if (customAdIds.isEmpty) {
      CommonUtils.printLog('InterstitialAdService: No IDs provided.');
      onAdFailedToShow?.call();
      return;
    }

    LoadingDialog.show(text: AppStrings.loadingAd);
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
      LoadingDialog.hide();
      // Ad couldn't be shown — let the caller continue the app flow.
      onAdFailedToShow?.call();
      return;
    }

    final adUnitId = adIds[index];
    CommonUtils.printLog(
      'InterstitialAdService: Attempting to load Interstitial Ad ID: $adUnitId',
    );

    InterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          CommonUtils.printLog(
            'InterstitialAdService: Interstitial loaded successfully ID: $adUnitId',
          );

          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              CommonUtils.printLog(
                'InterstitialAdService: Interstitial dismissed.',
              );
              onAdClosed?.call();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              CommonUtils.printLog(
                'InterstitialAdService: Interstitial failed to show: $error',
              );
              LoadingDialog.hide();
              onAdFailedToShow?.call();
            },
            onAdShowedFullScreenContent: (ad) {
              CommonUtils.printLog(
                'InterstitialAdService: Interstitial displayed.',
              );
              LoadingDialog.hide();
            },
          );

          ad.show();
        },
        onAdFailedToLoad: (error) {
          CommonUtils.printLog(
            'InterstitialAdService: Interstitial failed to load ID: $adUnitId ($error). Trying next...',
          );
          _loadAndShow(adIds, index + 1, onAdClosed, onAdFailedToShow);
        },
      ),
    );
  }
}
