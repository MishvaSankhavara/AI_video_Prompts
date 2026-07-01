import 'dart:io';
import 'package:flutter/foundation.dart';
import 'ad_manager.dart';

class AdIds {
  static bool useTestAds = kDebugMode; // Set to true to test ads in release mode. Change to false or kDebugMode when using live keys!
  // -------------------------------
  // COMMON TEST IDS
  // -------------------------------
  static const String appOpenIosTestId =
      'ca-app-pub-3940256099942544/5575463023';
  static const String interstitialIosTestId =
      'ca-app-pub-3940256099942544/4411468910';
  static const String rewardedIosTestId =
      'ca-app-pub-3940256099942544/1712485313';
  static const String nativeIosTestId =
      'ca-app-pub-3940256099942544/3986624511';

  static const String appOpenAndroidTestId =
      'ca-app-pub-3940256099942544/9257395921';
  static const String interstitialAndroidTestId =
      'ca-app-pub-3940256099942544/1033173712';
  static const String rewardedAndroidTestId =
      'ca-app-pub-3940256099942544/5224354917';
  static const String nativeAndroidTestId =
      'ca-app-pub-3940256099942544/2247696110';

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

  /// Interstitial 1
  static String get interstitialAd1 => useTestAds
      ? Platform.isAndroid
            ? interstitialAndroidTestId // Test Ad - Android
            : interstitialIosTestId // Test Ad - ios
      : Platform.isAndroid
      ? "ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX" // Live Ad - Android
      : "ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX"; // Live Ad - ios

  /// Interstitial 2
  static String get interstitialAd2 => useTestAds
      ? Platform.isAndroid
            ? interstitialAndroidTestId // Test Ad - Android
            : interstitialIosTestId // Test Ad - ios
      : Platform.isAndroid
      ? "ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX" // Live Ad - Android
      : "ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX"; // Live Ad - ios

  /// Interstitial 3
  static String get interstitialAd3 => useTestAds
      ? Platform.isAndroid
            ? interstitialAndroidTestId // Test Ad - Android
            : interstitialIosTestId // Test Ad - ios
      : Platform.isAndroid
      ? "ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX" // Live Ad - Android
      : "ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX"; // Live Ad - ios

  /// Interstitial 4
  static String get interstitialAd4 => useTestAds
      ? Platform.isAndroid
            ? interstitialAndroidTestId // Test Ad - Android
            : interstitialIosTestId // Test Ad - ios
      : Platform.isAndroid
      ? "ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX" // Live Ad - Android
      : "ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX"; // Live Ad - ios

  /// Interstitial 5
  static String get interstitialAd5 => useTestAds
      ? Platform.isAndroid
            ? interstitialAndroidTestId // Test Ad - Android
            : interstitialIosTestId // Test Ad - ios
      : Platform.isAndroid
      ? "ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX" // Live Ad - Android
      : "ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX"; // Live Ad - ios

  /// Interstitial 6
  static String get interstitialAd6 => useTestAds
      ? Platform.isAndroid
            ? interstitialAndroidTestId // Test Ad - Android
            : interstitialIosTestId // Test Ad - ios
      : Platform.isAndroid
      ? "ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX" // Live Ad - Android
      : "ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX"; // Live Ad - ios

  /// Rewarded 1
  static String get rewardedAds1 => useTestAds
      ? Platform.isAndroid
            ? rewardedAndroidTestId // Test Ad - Android
            : rewardedIosTestId // Test Ad - ios
      : Platform.isAndroid
      ? "ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX" // Live Ad - Android
      : "ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX"; // Live Ad - ios

  /// Rewarded 2
  static String get rewardedAds2 => useTestAds
      ? Platform.isAndroid
            ? rewardedAndroidTestId // Test Ad - Android
            : rewardedIosTestId // Test Ad - ios
      : Platform.isAndroid
      ? "ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX" // Live Ad - Android
      : "ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX"; // Live Ad - ios

  /// Native Ad 1
  static String get nativeAd1 => useTestAds
      ? Platform.isAndroid
            ? nativeAndroidTestId // Test Ad - Android
            : nativeIosTestId // Test Ad - ios
      : Platform.isAndroid
      ? "ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX" // Live Ad - Android
      : "ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX"; // Live Ad - ios

  /// Native Ad 2
  static String get nativeAd2 => useTestAds
      ? Platform.isAndroid
            ? nativeAndroidTestId // Test Ad - Android
            : nativeIosTestId // Test Ad - ios
      : Platform.isAndroid
      ? "ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX" // Live Ad - Android
      : "ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX"; // Live Ad - ios
}
