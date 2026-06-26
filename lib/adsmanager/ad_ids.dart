import 'ad_service.dart';

class AdIds {
  static bool showAdsEnabled = true;

  // ─── PORTION 1: DEBUG / TEST ADS (Google Test IDs) ────────────────────────

  static const String appOpenDebugAndroid = 'ca-app-pub-3940256099942544/9257395921';
  static const String appOpenDebugIos = 'ca-app-pub-3940256099942544/5575463023';

  // Home Screen Interstitial (High Floor & Low Floor fallback)
  static const String interHomeHF1DebugAndroid = 'ca-app-pub-3940256099942544/1033173712';
  static const String interHomeHF1DebugIos = 'ca-app-pub-3940256099942544/4411468910';
  static const String interHomeLF2DebugAndroid = 'ca-app-pub-3940256099942544/1033173712';
  static const String interHomeLF2DebugIos = 'ca-app-pub-3940256099942544/4411468910';

  // Category Screen Interstitial (High Floor & Low Floor fallback)
  static const String interCategoryHF2DebugAndroid = 'ca-app-pub-3940256099942544/1033173712';
  static const String interCategoryHF2DebugIos = 'ca-app-pub-3940256099942544/4411468910';
  static const String interCategoryLF2DebugAndroid = 'ca-app-pub-3940256099942544/1033173712';
  static const String interCategoryLF2DebugIos = 'ca-app-pub-3940256099942544/4411468910';

  // Splash Screen Interstitial (High Floor & Low Floor fallback)
  static const String interSplashHF1DebugAndroid = 'ca-app-pub-3940256099942544/1033173712';
  static const String interSplashHF1DebugIos = 'ca-app-pub-3940256099942544/4411468910';
  static const String interSplashLF2DebugAndroid = 'ca-app-pub-3940256099942544/1033173712';
  static const String interSplashLF2DebugIos = 'ca-app-pub-3940256099942544/4411468910';

  // Rewarded Ad (High Floor & Low Floor fallback)
  static const String rewardedHFDebugAndroid = 'ca-app-pub-3940256099942544/5224354917';
  static const String rewardedHFDebugIos = 'ca-app-pub-3940256099942544/1712485313';
  static const String rewardedLFDebugAndroid = 'ca-app-pub-3940256099942544/5224354917';
  static const String rewardedLFDebugIos = 'ca-app-pub-3940256099942544/1712485313';



  // ─── PORTION 2: RELEASE / PRODUCTION ADS (Swap with real AdMob IDs) ────────

  static const String appOpenReleaseAndroid = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';
  static const String appOpenReleaseIos = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';

  // Home Screen Interstitial (High Floor & Low Floor fallback)
  static const String interHomeHF1ReleaseAndroid = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';
  static const String interHomeHF1ReleaseIos = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';
  static const String interHomeLF1ReleaseAndroid = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';
  static const String interHomeLF1ReleaseIos = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';

  // Category Screen Interstitial (High Floor & Low Floor fallback)
  static const String interCategoryHF2ReleaseAndroid = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';
  static const String interCategoryHF2ReleaseIos = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';
  static const String interCategoryLF2ReleaseAndroid = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';
  static const String interCategoryLF2ReleaseIos = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';

  // Splash Screen Interstitial (High Floor & Low Floor fallback)
  static const String interSplashHF1ReleaseAndroid = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';
  static const String interSplashHF1ReleaseIos = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';
  static const String interSplashLF2ReleaseAndroid = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';
  static const String interSplashLF2ReleaseIos = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';

  // Rewarded Ad (High Floor & Low Floor fallback)
  static const String rewardedHFReleaseAndroid = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';
  static const String rewardedHFReleaseIos = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';
  static const String rewardedLFReleaseAndroid = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';
  static const String rewardedLFReleaseIos = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';

  // ─── DYNAMIC RESOLUTION GETTERS ────────────────────────────────────────────

  // App Open Ad ID
  static String get appOpenAdUnitId => AdService.getAdUnitId(
        androidDebug: appOpenDebugAndroid,
        androidRelease: appOpenReleaseAndroid,
        iosDebug: appOpenDebugIos,
        iosRelease: appOpenReleaseIos,
      );

  // Home Screen Interstitial Ads
  static String get interHomelHF1 => AdService.getAdUnitId(
        androidDebug: interHomeHF1DebugAndroid,
        androidRelease: interHomeHF1ReleaseAndroid,
        iosDebug: interHomeHF1DebugIos,
        iosRelease: interHomeHF1ReleaseIos,
      );

  static String get interHomeLF1 => AdService.getAdUnitId(
        androidDebug: interHomeLF2DebugAndroid,
        androidRelease: interHomeLF1ReleaseAndroid,
        iosDebug: interHomeLF2DebugIos,
        iosRelease: interHomeLF1ReleaseIos,
      );

  // Category Details Screen Interstitial Ads
  static String get interCategoryHF2 => AdService.getAdUnitId(
        androidDebug: interCategoryHF2DebugAndroid,
        androidRelease: interCategoryHF2ReleaseAndroid,
        iosDebug: interCategoryHF2DebugIos,
        iosRelease: interCategoryHF2ReleaseIos,
      );

  static String get interCategoryLF2 => AdService.getAdUnitId(
        androidDebug: interCategoryLF2DebugAndroid,
        androidRelease: interCategoryLF2ReleaseAndroid,
        iosDebug: interCategoryLF2DebugIos,
        iosRelease: interCategoryLF2ReleaseIos,
      );

  // Splash Screen Interstitial Ads
  static String get interSplashHF1 => AdService.getAdUnitId(
        androidDebug: interSplashHF1DebugAndroid,
        androidRelease: interSplashHF1ReleaseAndroid,
        iosDebug: interSplashHF1DebugIos,
        iosRelease: interSplashHF1ReleaseIos,
      );

  static String get interSplashLF2 => AdService.getAdUnitId(
        androidDebug: interSplashLF2DebugAndroid,
        androidRelease: interSplashLF2ReleaseAndroid,
        iosDebug: interSplashLF2DebugIos,
        iosRelease: interSplashLF2ReleaseIos,
      );

  // Rewarded Ad High-Floor (HF)
  static String get rewardedHF => AdService.getAdUnitId(
        androidDebug: rewardedHFDebugAndroid,
        androidRelease: rewardedHFReleaseAndroid,
        iosDebug: rewardedHFDebugIos,
        iosRelease: rewardedHFReleaseIos,
      );

  // Rewarded Ad Low-Floor (LF)
  static String get rewardedLF => AdService.getAdUnitId(
        androidDebug: rewardedLFDebugAndroid,
        androidRelease: rewardedLFReleaseAndroid,
        iosDebug: rewardedLFDebugIos,
        iosRelease: rewardedLFReleaseIos,
      );

  // Native Ad IDs (Google demo / production)
  static const String nativeDebugAndroid = 'ca-app-pub-3940256099942544/2247696110';
  static const String nativeDebugIos = 'ca-app-pub-3940256099942544/3986624511';
  static const String nativeReleaseAndroid = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';
  static const String nativeReleaseIos = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';

  static String get nativeAdUnitId => AdService.getAdUnitId(
        androidDebug: nativeDebugAndroid,
        androidRelease: nativeReleaseAndroid,
        iosDebug: nativeDebugIos,
        iosRelease: nativeReleaseIos,
      );
}
