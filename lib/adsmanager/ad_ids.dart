import 'dart:io';

class AdIds {
  static const bool showAdsEnabled = true;

  // App Open Ad ID
  static String get appOpenAdUnitId => Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/9257395921' // Android Test
      : 'ca-app-pub-3940256099942544/5575463023'; // iOS Test

  // Home Screen Interstitial Ads
  static String get interHomelHF1 => Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/1033173712' // Android Test
      : 'ca-app-pub-3940256099942544/4411468910'; // iOS Test

  static String get interHomeLF1 => Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/1033173712' // Android Test
      : 'ca-app-pub-3940256099942544/4411468910'; // iOS Test

  // Category Details Screen Interstitial Ads
  static String get interCategoryHF2 => Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/1033173712' // Android Test
      : 'ca-app-pub-3940256099942544/4411468910'; // iOS Test

  static String get interCategoryLF2 => Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/1033173712' // Android Test
      : 'ca-app-pub-3940256099942544/4411468910'; // iOS Test

  // Splash Screen Interstitial Ads
  static String get interSplashHF1 => Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/1033173712' // Android Test
      : 'ca-app-pub-3940256099942544/4411468910'; // iOS Test

  static String get interSplashLF2 => Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/1033173712' // Android Test
      : 'ca-app-pub-3940256099942544/4411468910'; // iOS Test

  // Rewarded Ad High-Floor (HF)
  static String get rewardedHF => Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/5224354917' // Android Test
      : 'ca-app-pub-3940256099942544/1712485313'; // iOS Test

  // Rewarded Ad Low-Floor (LF)
  static String get rewardedLF => Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/5224354917' // Android Test
      : 'ca-app-pub-3940256099942544/1712485313'; // iOS Test
}
