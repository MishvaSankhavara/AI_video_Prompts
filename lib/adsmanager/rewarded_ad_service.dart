import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../utils/common_utils.dart';
import '../utils/strings.dart';
import '../widgets/dialog/loading_dialog.dart';
import '../services/remote_config_service.dart';
import 'ad_ids.dart';

class RewardedAdService {
  RewardedAdService._();

  static void showAd({
    required BuildContext context,
    required List<String> customAdIds,
    String? screenName,
    VoidCallback? onAdClosed,
    VoidCallback? onAdFailedToShow,
    required VoidCallback onUserEarnedReward,
  }) {
    // Ads disabled (e.g. via remote config) -> skip the ad, continue app flow.
    if (!RemoteConfigService.instance.showAdsEnabled) {
      onAdFailedToShow?.call();
      return;
    }

    if (customAdIds.isEmpty) {
      CommonUtils.printLog('RewardedAdService: No IDs provided.');
      onAdFailedToShow?.call();
      return;
    }

    LoadingDialog.show(text: AppStrings.loadingAd);
    _loadAndShow(
      customAdIds,
      0,
      onAdClosed,
      onAdFailedToShow,
      onUserEarnedReward,
    );
  }

  static void _loadAndShow(
    List<String> adIds,
    int index,
    VoidCallback? onAdClosed,
    VoidCallback? onAdFailedToShow,
    VoidCallback onUserEarnedReward,
  ) {
    if (index >= adIds.length) {
      CommonUtils.printLog('RewardedAdService: All Ad IDs failed.');
      LoadingDialog.hide();
      // Ad couldn't be shown — let the caller continue the app flow.
      onAdFailedToShow?.call();
      return;
    }

    final adUnitId = adIds[index];
    CommonUtils.printLog(
      'RewardedAdService: Attempting to load Rewarded Ad ID: $adUnitId',
    );

    RewardedAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          CommonUtils.printLog(
            'RewardedAdService: Rewarded Ad loaded successfully ID: $adUnitId',
          );

          bool rewardEarned = false;

          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              CommonUtils.printLog(
                'RewardedAdService: Rewarded Ad dismissed. Reward earned: $rewardEarned',
              );
              if (rewardEarned) onUserEarnedReward();
              onAdClosed?.call();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              CommonUtils.printLog(
                'RewardedAdService: Rewarded Ad failed to show: $error',
              );
              LoadingDialog.hide();
              onAdFailedToShow?.call();
            },
            onAdShowedFullScreenContent: (ad) {
              CommonUtils.printLog('RewardedAdService: Rewarded Ad displayed.');
              LoadingDialog.hide();
            },
          );

          ad.show(
            onUserEarnedReward: (ad, reward) {
              rewardEarned = true;
              CommonUtils.printLog('RewardedAdService: User earned reward.');
            },
          );
        },
        onAdFailedToLoad: (error) {
          CommonUtils.printLog(
            'RewardedAdService: Rewarded Ad failed to load ID: $adUnitId ($error). Trying next...',
          );
          _loadAndShow(
            adIds,
            index + 1,
            onAdClosed,
            onAdFailedToShow,
            onUserEarnedReward,
          );
        },
      ),
    );
  }
}
