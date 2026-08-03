import 'dart:io';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../api/api_const.dart';
import '../../utils/common_utils.dart';

class RemoteConfigService {
  static final RemoteConfigService instance = RemoteConfigService._internal();

  factory RemoteConfigService() {
    return instance;
  }

  RemoteConfigService._internal();

  /// Whether ads may be shown. Defaults to true and is set to false
  /// when the installed version is listed in the `ads_disabled_versions` remote config value.
  bool showAdsEnabled = true;

  /// Whether the rewarded ad button is shown on the prompt details screen.
  bool showRewardedAdPromptDetails = true;

  /// Interstitial ad controls
  bool showInterAdCategoryDetails = true;
  bool showInterAdHome = true;
  bool showInterAdSplash = true;

  /// Native ad controls
  bool showNativeAdOnboarding1 = true;
  bool showNativeAdOnboarding2 = true;
  bool showNativeAdOnboarding3 = true;
  bool showNativeAdOnboardingFullScreen = true;
  bool showNativeAdSplash = true;

  bool showNativeAdCategoryDetails = true;
  bool showNativeAdPromptDetailsGrid = true;
  bool showNativeAdPromptDetailsMedium = true;
  bool showNativeAdStartScreen = true;

  bool loginDemo = true;
  String nameAccountDemo = "";
  String passwordDemo = "";

  Future<void> initialize() async {
    try {
      final remoteConfig = FirebaseRemoteConfig.instance;
      await remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(minutes: 1),
          // Set to 0 to fetch fresh values every time the app starts.
          // Note: In a large-scale production app, you might want to increase this to avoid Firebase throttling.
          minimumFetchInterval: Duration.zero,
        ),
      );

      await remoteConfig.setDefaults(const {
        'ads_disabled_versions': '',
        'ads_disabled_versions_ios': '',
        'rewarded_ad_prompt_details_screen': true,
        'inter_ad_category_details_screen': true,
        'inter_ad_home_screen': true,
        'inter_ad_splash_screen': true,
        'native_ad_onboarding_1': true,
        'native_ad_onboarding_2': true,
        'native_ad_onboarding_3': true,
        'native_ad_onboarding_full_screen': true,
        'native_ad_splash_screen': true,
        'native_ad_category_details_screen': true,
        'native_ad_prompt_details_screen_grid': true,
        'native_ad_prompt_details_screen_medium': true,
        'native_ad_start_screen': true,
        'login_demo': true,
        'name_account_demo': '123456',
        'password_demo': '123456',
      });

      await remoteConfig.fetchAndActivate();

      final allConfig = remoteConfig.getAll();
      CommonUtils.printLog('=== Firebase Remote Config Values ===');
      allConfig.forEach((key, value) {
        CommonUtils.printLog('RemoteConfig -> $key: ${value.asString()}');
      });
      CommonUtils.printLog('====================================');

      await ApiConst.applyServerConfig(remoteConfig);

      showRewardedAdPromptDetails = remoteConfig.getBool('rewarded_ad_prompt_details_screen');
      showInterAdCategoryDetails = remoteConfig.getBool('inter_ad_category_details_screen');
      showInterAdHome = remoteConfig.getBool('inter_ad_home_screen');
      showInterAdSplash = remoteConfig.getBool('inter_ad_splash_screen');

      showNativeAdOnboarding1 = remoteConfig.getBool('native_ad_onboarding_1');
      showNativeAdOnboarding2 = remoteConfig.getBool('native_ad_onboarding_2');
      showNativeAdOnboarding3 = remoteConfig.getBool('native_ad_onboarding_3');
      showNativeAdOnboardingFullScreen = remoteConfig.getBool('native_ad_onboarding_full_screen');
      showNativeAdSplash = remoteConfig.getBool('native_ad_splash_screen');

      showNativeAdCategoryDetails = remoteConfig.getBool('native_ad_category_details_screen');
      showNativeAdPromptDetailsGrid = remoteConfig.getBool('native_ad_prompt_details_screen_grid');
      showNativeAdPromptDetailsMedium = remoteConfig.getBool('native_ad_prompt_details_screen_medium');
      showNativeAdStartScreen = remoteConfig.getBool('native_ad_start_screen');

      loginDemo = remoteConfig.getBool('login_demo');
      nameAccountDemo = remoteConfig.getString('name_account_demo');
      passwordDemo = remoteConfig.getString('password_demo');

      final String disabledVersionsStr = remoteConfig.getString(
        Platform.isIOS ? 'ads_disabled_versions_ios' : 'ads_disabled_versions',
      );

      final packageInfo = await PackageInfo.fromPlatform();
      final String currentVersion = packageInfo.version;

      if (disabledVersionsStr.isNotEmpty) {
        // Split by comma and remove whitespace, handling multiple versions if needed
        final List<String> disabledVersions = disabledVersionsStr
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();

        // Disable ads when this build's version is in the remote list.
        showAdsEnabled = !disabledVersions.contains(currentVersion);
      } else {
        // No versions listed -> ads stay enabled.
        showAdsEnabled = true;
      }
    } catch (e) {
      // On any failure, keep ads enabled (safe default).
      showAdsEnabled = true;
    }
  }
}
