import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../utils/common_utils.dart';

class AdManager {
  AdManager._internal();
  static final AdManager instance = AdManager._internal();

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

  // ─── INITIALIZATION ────────────────────────────────────────────────────────

  Future<void> initialize() async {
    await MobileAds.instance.initialize();
    // // // CommonUtils.printLog('AdManager: MobileAds SDK initialized.');
  }
}
