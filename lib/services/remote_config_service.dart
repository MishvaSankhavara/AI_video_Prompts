import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../adsmanager/ad_ids.dart';

class RemoteConfigService {
  static final RemoteConfigService instance = RemoteConfigService._internal();

  factory RemoteConfigService() {
    return instance;
  }

  RemoteConfigService._internal();

  /// Whether ads may be shown. Defaults to true and is set to false
  /// when the installed version is listed in the `ads_disabled_versions` remote config value.
  bool showAdsEnabled = true;

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

      await remoteConfig.setDefaults(const {'ads_disabled_versions': ''});

      await remoteConfig.fetchAndActivate();

      final String disabledVersionsStr = remoteConfig.getString(
        'ads_disabled_versions',
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
