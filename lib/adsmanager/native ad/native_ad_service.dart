import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../utils/common_utils.dart';
import '../ad_ids.dart';

/// Native ad service.
///
/// Instance-per-screen: create one in a screen's [State.initState] and call
/// [dispose] in [State.dispose]. Each ad slot on the screen is identified by an
/// [adIndex]; the service caches loaded/loading/failed state per index so an ad
/// is only requested once and reused across rebuilds.
///
/// Ported from prompt_app_v2 and refactored to use this app's [AdIds] gating,
/// ad-unit waterfall and logging.
class NativeAdService {
  final Map<int, NativeAd?> _nativeAds = {};
  final Set<int> _loadedAdIndices = {};
  final Set<int> _loadingAdIndices = {};
  final Set<int> _failedAdIndices = {};
  bool _disposed = false;

  /// Whether native ads may be shown at all.
  bool get canShowAds => AdIds.showAdsEnabled;

  /// Disposes every ad held by this service. Call from the host screen's
  /// [State.dispose] so the loaded `NativeAd` platform views are released.
  void dispose() {
    _disposed = true;
    for (final ad in _nativeAds.values) {
      ad?.dispose();
    }
    _nativeAds.clear();
    _loadedAdIndices.clear();
    _loadingAdIndices.clear();
    _failedAdIndices.clear();
  }

  /// Triggers a load for [adIndex] if it isn't already loaded/loading/failed.
  void loadNativeAd(
    int adIndex,
    VoidCallback refreshUI,
    String factoryId, {
    required List<String> customAdIds,
    String? screenName,
  }) {
    // Never load when ads are disabled (e.g. via remote config).
    if (!canShowAds) return;

    if (_disposed ||
        _loadedAdIndices.contains(adIndex) ||
        _loadingAdIndices.contains(adIndex) ||
        _failedAdIndices.contains(adIndex)) {
      return;
    }

    _loadingAdIndices.add(adIndex);
    _tryLoadAd(adIndex, 0, refreshUI, factoryId, customAdIds, screenName);
  }

  /// Walks [adIds] in order, falling back to the next id whenever one fails.
  void _tryLoadAd(
    int adIndex,
    int listIndex,
    VoidCallback refreshUI,
    String factoryId,
    List<String> adIds,
    String? screenName,
  ) {
    if (adIds.isEmpty || listIndex >= adIds.length) {
      _loadingAdIndices.remove(adIndex);
      _failedAdIndices.add(adIndex);
      // CommonUtils.printLog(
      //   'NativeAdService: all ad ids failed'
      //   '${screenName != null ? ' | Screen: $screenName' : ''}'
      //   ' | AdIndex: $adIndex',
      // );
      if (!_disposed) refreshUI();
      return;
    }

    _nativeAds[adIndex]?.dispose();

    final adUnitId = adIds[listIndex];

    final ad = NativeAd(
      adUnitId: adUnitId,
      request: const AdRequest(),
      factoryId: factoryId,
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          if (_disposed) {
            ad.dispose();
            return;
          }
          _nativeAds[adIndex] = ad as NativeAd;
          _loadedAdIndices.add(adIndex);
          _loadingAdIndices.remove(adIndex);
          // CommonUtils.printLog(
          //   'NativeAdService: loaded'
          //   '${screenName != null ? ' | Screen: $screenName' : ''}'
          //   ' | AdIndex: $adIndex | AdUnitId: $adUnitId | Factory: $factoryId',
          // );
          refreshUI();
        },
        onAdFailedToLoad: (ad, error) {
          // CommonUtils.printLog(
          //   'NativeAdService: failed'
          //   '${screenName != null ? ' | Screen: $screenName' : ''}'
          //   ' | AdIndex: $adIndex | AdUnitId: $adUnitId | Error: ${error.message}.'
          //   ' Trying next...',
          // );
          ad.dispose();
          if (_disposed) return;
          _tryLoadAd(
            adIndex,
            listIndex + 1,
            refreshUI,
            factoryId,
            adIds,
            screenName,
          );
        },
      ),
    );

    ad.load();
  }

  /// Builds the full, self-contained widget for the ad slot at [adIndex] —
  /// including the styled container (background, corner radius, shadow, clip) so
  /// screens don't have to wrap it in any ad UI of their own.
  ///
  /// While loading it shows [shimmer]; once loaded it shows the [AdWidget]. When
  /// ads are disabled or every ad id failed it returns [SizedBox.shrink] — taking
  /// ZERO space, so there is never a blank gap reserved for an ad that isn't shown.
  Widget buildNativeAdTile(
    int adIndex,
    VoidCallback refreshUI, {
    required String factoryId,
    required List<String> customAdIds,
    double? height,
    double? width,
    double borderRadius = 0,
    Color? backgroundColor,
    EdgeInsetsGeometry margin = EdgeInsets.zero,
    String? screenName,
    Widget? shimmer,
  }) {
    // Absolute block: no ad, no shimmer, no space.
    if (!canShowAds) return const SizedBox.shrink();

    // Kick off loading on first build for this slot.
    if (!_loadedAdIndices.contains(adIndex) &&
        !_loadingAdIndices.contains(adIndex) &&
        !_failedAdIndices.contains(adIndex)) {
      loadNativeAd(
        adIndex,
        refreshUI,
        factoryId,
        customAdIds: customAdIds,
        screenName: screenName,
      );
    }

    // Every ad id failed -> collapse entirely, no blank space.
    if (_failedAdIndices.contains(adIndex)) {
      return const SizedBox.shrink();
    }

    final ad = _nativeAds[adIndex];
    final Widget content = (_loadedAdIndices.contains(adIndex) && ad != null)
        ? AdWidget(ad: ad)
        : (shimmer ?? const SizedBox.shrink());

    // Styled, sized container owned by the service so screens stay UI-free.
    return Container(
      height: height,
      width: width,
      margin: margin,
      clipBehavior: borderRadius > 0 ? Clip.antiAlias : Clip.none,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: content,
    );
  }
}
