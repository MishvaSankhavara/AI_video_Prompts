import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../utils/common_utils.dart';

class NativeAdService {
  NativeAdService._();
  static final NativeAdService instance = NativeAdService._();

  // Cache: screenName -> (adIndex -> NativeAd)
  final Map<String, Map<int, NativeAd>> _loadedAds = {};
  final Map<String, Map<int, bool>> _isLoading = {};
  final Map<String, Map<int, bool>> _hasFailed = {};

  void _initCacheForScreen(String screenName) {
    _loadedAds[screenName] ??= {};
    _isLoading[screenName] ??= {};
    _hasFailed[screenName] ??= {};
  }

  /// Builds a native ad tile, loading it if necessary.
  Widget showAd(
    int adIndex,
    VoidCallback refreshUI, {
    required String factoryId,
    Widget? shimmer,
    required List<String> customAdIds,
    required String screenName,
  }) {
    _initCacheForScreen(screenName);

    // If already loaded, show it
    if (_loadedAds[screenName]![adIndex] != null) {
      return AdWidget(ad: _loadedAds[screenName]![adIndex]!);
    }

    // If failed, return empty to not take up space
    if (_hasFailed[screenName]![adIndex] == true) {
      return const SizedBox.shrink();
    }

    // If currently loading, return shimmer
    if (_isLoading[screenName]![adIndex] == true) {
      return shimmer ?? const SizedBox.shrink();
    }

    // Otherwise, start loading
    _isLoading[screenName]![adIndex] = true;
    _loadWaterfall(
      customAdIds,
      0,
      factoryId,
      (ad) {
        _loadedAds[screenName]![adIndex] = ad;
        _isLoading[screenName]![adIndex] = false;
        refreshUI();
      },
      () {
        _hasFailed[screenName]![adIndex] = true;
        _isLoading[screenName]![adIndex] = false;
        refreshUI();
      },
    );

    return shimmer ?? const SizedBox.shrink();
  }

  // Alias for backward compatibility if user snippet referred to buildNativeAdTile
  Widget buildNativeAdTile(
    int adIndex,
    VoidCallback refreshUI, {
    required String factoryId,
    Widget? shimmer,
    required List<String> customAdIds,
    required String screenName,
  }) {
    return showAd(
      adIndex,
      refreshUI,
      factoryId: factoryId,
      shimmer: shimmer,
      customAdIds: customAdIds,
      screenName: screenName,
    );
  }

  /// Disposes all loaded ads for a specific screen to free memory
  void disposeAdsForScreen(String screenName) {
    final ads = _loadedAds[screenName];
    if (ads != null) {
      for (var ad in ads.values) {
        ad.dispose();
      }
      _loadedAds.remove(screenName);
      _isLoading.remove(screenName);
      _hasFailed.remove(screenName);
    }
  }

  void _loadWaterfall(
    List<String> adIds,
    int index,
    String factoryId,
    void Function(NativeAd ad) onAdLoaded,
    void Function() onAdFailedToLoad,
  ) {
    if (adIds.isEmpty || index >= adIds.length) {
      CommonUtils.printLog('NativeAdService: All Ad IDs failed or empty list.');
      onAdFailedToLoad();
      return;
    }

    final adUnitId = adIds[index];
    CommonUtils.printLog('NativeAdService: Attempting to load Native Ad ID: $adUnitId (Factory: $factoryId)');

    final nativeAd = NativeAd(
      adUnitId: adUnitId,
      factoryId: factoryId,
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          CommonUtils.printLog('NativeAdService: Native Ad loaded successfully ID: $adUnitId (Factory: $factoryId)');
          onAdLoaded(ad as NativeAd);
        },
        onAdFailedToLoad: (ad, error) {
          CommonUtils.printLog('NativeAdService: Native Ad failed to load ID: $adUnitId (Factory: $factoryId): $error. Trying next...');
          ad.dispose();
          _loadWaterfall(adIds, index + 1, factoryId, onAdLoaded, onAdFailedToLoad);
        },
      ),
    );

    nativeAd.load();
  }
}
