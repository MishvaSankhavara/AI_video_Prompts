import 'dart:io';
import 'package:flutter/foundation.dart';
import 'ad_manager.dart';

class AdIds {

  static bool get showAdsEnabled => true;
  static bool useTestAds = kDebugMode; // keep it in debug mode only

  // -------------------------------
  // COMMON TEST IDS
  // -------------------------------
  static const String appOpenIosTestId = 'ca-app-pub-3940256099942544/5575463023';
  static const String interstitialIosTestId = 'ca-app-pub-3940256099942544/4411468910';
  static const String rewardedIosTestId = 'ca-app-pub-3940256099942544/1712485313';
  static const String nativeIosTestId = 'ca-app-pub-3940256099942544/3986624511';

  static const String appOpenAndroidTestId = 'ca-app-pub-3940256099942544/9257395921';
  static const String interstitialAndroidTestId = 'ca-app-pub-3940256099942544/1033173712';
  static const String rewardedAndroidTestId = 'ca-app-pub-3940256099942544/5224354917';
  static const String nativeAndroidTestId = 'ca-app-pub-3940256099942544/2247696110';

  // -------------------------------
  // LIVE IDS (Swap with real AdMob IDs)
  // -------------------------------

  /// App Open Ad ID
  static String get appOpenAdUnitId => useTestAds
      ? Platform.isAndroid
          ? appOpenAndroidTestId // Test Ad - Android
          : appOpenIosTestId // Test Ad - ios
      : Platform.isAndroid
          ? "ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX" // Live Ad - Android
          : "ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX"; // Live Ad - ios

  /// Home Screen Interstitial HF 1
  static String get interHomelHF1 => useTestAds
      ? Platform.isAndroid
          ? interstitialAndroidTestId // Test Ad - Android
          : interstitialIosTestId // Test Ad - ios
      : Platform.isAndroid
          ? "ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX" // Live Ad - Android
          : "ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX"; // Live Ad - ios

  /// Home Screen Interstitial LF 1
  static String get interHomeLF1 => useTestAds
      ? Platform.isAndroid
          ? interstitialAndroidTestId // Test Ad - Android
          : interstitialIosTestId // Test Ad - ios
      : Platform.isAndroid
          ? "ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX" // Live Ad - Android
          : "ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX"; // Live Ad - ios

  /// Category Screen Interstitial HF 2
  static String get interCategoryHF2 => useTestAds
      ? Platform.isAndroid
          ? interstitialAndroidTestId // Test Ad - Android
          : interstitialIosTestId // Test Ad - ios
      : Platform.isAndroid
          ? "ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX" // Live Ad - Android
          : "ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX"; // Live Ad - ios

  /// Category Screen Interstitial LF 2
  static String get interCategoryLF2 => useTestAds
      ? Platform.isAndroid
          ? interstitialAndroidTestId // Test Ad - Android
          : interstitialIosTestId // Test Ad - ios
      : Platform.isAndroid
          ? "ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX" // Live Ad - Android
          : "ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX"; // Live Ad - ios

  /// Splash Screen Interstitial HF 1
  static String get interSplashHF1 => useTestAds
      ? Platform.isAndroid
          ? interstitialAndroidTestId // Test Ad - Android
          : interstitialIosTestId // Test Ad - ios
      : Platform.isAndroid
          ? "ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX" // Live Ad - Android
          : "ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX"; // Live Ad - ios

  /// Splash Screen Interstitial LF 2
  static String get interSplashLF2 => useTestAds
      ? Platform.isAndroid
          ? interstitialAndroidTestId // Test Ad - Android
          : interstitialIosTestId // Test Ad - ios
      : Platform.isAndroid
          ? "ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX" // Live Ad - Android
          : "ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX"; // Live Ad - ios

  /// Rewarded Ad HF
  static String get rewardedHF => useTestAds
      ? Platform.isAndroid
          ? rewardedAndroidTestId // Test Ad - Android
          : rewardedIosTestId // Test Ad - ios
      : Platform.isAndroid
          ? "ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX" // Live Ad - Android
          : "ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX"; // Live Ad - ios

  /// Rewarded Ad LF
  static String get rewardedLF => useTestAds
      ? Platform.isAndroid
          ? rewardedAndroidTestId // Test Ad - Android
          : rewardedIosTestId // Test Ad - ios
      : Platform.isAndroid
          ? "ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX" // Live Ad - Android
          : "ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX"; // Live Ad - ios

  /// Native Ad
  static String get nativeAdUnitId => useTestAds
      ? Platform.isAndroid
          ? nativeAndroidTestId // Test Ad - Android
          : nativeIosTestId // Test Ad - ios
      : Platform.isAndroid
          ? "ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX" // Live Ad - Android
          : "ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX"; // Live Ad - ios
}
