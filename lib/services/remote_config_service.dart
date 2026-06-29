import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../utils/common_utils.dart';

class RemoteConfigService {
  static final RemoteConfigService instance = RemoteConfigService._internal();

  factory RemoteConfigService() {
    return instance;
  }

  RemoteConfigService._internal();

  Future<void> initialize() async {
    try {
      final remoteConfig = FirebaseRemoteConfig.instance;
      await remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        // Set to 0 to fetch fresh values every time the app starts. 
        // Note: In a large-scale production app, you might want to increase this to avoid Firebase throttling.
        minimumFetchInterval: Duration.zero, 
      ));

      await remoteConfig.setDefaults(const {
        'ads_disabled_versions': '',
      });

      await remoteConfig.fetchAndActivate();

      final String disabledVersionsStr = remoteConfig.getString('ads_disabled_versions');
      
      final packageInfo = await PackageInfo.fromPlatform();
      final String currentVersion = packageInfo.version;

      if (disabledVersionsStr.isNotEmpty) {
        // Split by comma and remove whitespace, handling multiple versions if needed
        final List<String> disabledVersions = disabledVersionsStr
            .split(',')
            .map((e) => e.trim())
            .toList();

        if (disabledVersions.contains(currentVersion)) {
          CommonUtils.printLog('Ads disabled via Remote Config for version $currentVersion');
          // AdIds.showAdsEnabled removed
        } else {
          CommonUtils.printLog('Ads enabled. Current version $currentVersion is not in disabled list.');
        }
      } else {
         CommonUtils.printLog('Remote Config: ads_disabled_versions is empty.');
      }
    } catch (e) {
      CommonUtils.printLog('Error initializing Remote Config: $e');
    }
  }
}
