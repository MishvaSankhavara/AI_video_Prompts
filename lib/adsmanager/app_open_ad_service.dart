import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../utils/common_utils.dart';
import '../services/remote_config_service.dart';
import 'ad_ids.dart';

class AppOpenAdService {
  AppOpenAdService._();

  static void showAd({
    required BuildContext context,
    required List<String> customAdIds,
    String? screenName,
    VoidCallback? onAdClosed,
    VoidCallback? onAdFailedToShow,
  }) {
    // Ads disabled (e.g. via remote config) -> skip the ad, continue app flow.
    if (!RemoteConfigService.instance.showAdsEnabled) {
      onAdClosed?.call();
      return;
    }

    if (customAdIds.isEmpty) {
      // CommonUtils.printLog('AppOpenAdService: No IDs provided.');
      onAdClosed?.call();
      return;
    }

    _loadAndShow(customAdIds, 0, onAdClosed, onAdFailedToShow);
  }

  static void _loadAndShow(
    List<String> adIds,
    int index,
    VoidCallback? onAdClosed,
    VoidCallback? onAdFailedToShow,
  ) {
    if (index >= adIds.length) {
      // CommonUtils.printLog('AppOpenAdService: All Ad IDs failed.');
      onAdFailedToShow?.call();
      onAdClosed?.call();
      return;
    }

    final adUnitId = adIds[index];
    // CommonUtils.printLog('AppOpenAdService: Attempting to load App Open Ad ID: $adUnitId');

    AppOpenAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          // CommonUtils.printLog('AppOpenAdService: App Open Ad loaded successfully ID: $adUnitId');

          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              // CommonUtils.printLog('AppOpenAdService: App Open Ad dismissed.');
              onAdClosed?.call();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              // CommonUtils.printLog('AppOpenAdService: App Open Ad failed to show: $error');
              onAdFailedToShow?.call();
              onAdClosed?.call();
            },
            onAdShowedFullScreenContent: (ad) {
              // CommonUtils.printLog('AppOpenAdService: App Open Ad displayed.');
            },
          );

          ad.show();
        },
        onAdFailedToLoad: (error) {
          // CommonUtils.printLog('AppOpenAdService: App Open Ad failed to load ID: $adUnitId ($error). Trying next...');
          _loadAndShow(adIds, index + 1, onAdClosed, onAdFailedToShow);
        },
      ),
    );
  }
}
