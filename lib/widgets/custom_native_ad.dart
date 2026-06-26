import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../adsmanager/ad_ids.dart';
import '../utils/common_utils.dart';

class CustomNativeAd extends StatefulWidget {
  /// The Factory ID defined in MainActivity.kt
  /// Options: 'grid_ad_factory', 'fullscreen_ad_factory', 'large_ad_factory', 'medium_ad_factory'
  final String factoryId;
  final double height;
  final String? adUnitId;

  const CustomNativeAd({
    super.key,
    required this.factoryId,
    required this.height,
    this.adUnitId,
  });

  @override
  State<CustomNativeAd> createState() => _CustomNativeAdState();
}

class _CustomNativeAdState extends State<CustomNativeAd> {
  NativeAd? _nativeAd;
  bool _isAdLoaded = false;
  bool _isAdFailed = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    if (!AdIds.showAdsEnabled) {
      setState(() {
        _isAdFailed = true;
      });
      return;
    }

    // Determine the ad unit ID (fallback to standard Native Ad ID if not provided)
    final String targetAdUnitId = widget.adUnitId ?? AdIds.nativeAdUnitId;

    _nativeAd = NativeAd(
      adUnitId: targetAdUnitId,
      factoryId: widget.factoryId,
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          CommonUtils.printLog('CustomNativeAd loaded successfully: ${widget.factoryId}');
          if (mounted) {
            setState(() {
              _isAdLoaded = true;
            });
          }
        },
        onAdFailedToLoad: (ad, error) {
          CommonUtils.printLog('CustomNativeAd failed to load: $error');
          ad.dispose();
          if (mounted) {
            setState(() {
              _isAdFailed = true;
            });
          }
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isAdFailed) {
      return const SizedBox.shrink(); // Hide seamlessly if failed or disabled
    }

    if (!_isAdLoaded || _nativeAd == null) {
      return SizedBox(
        height: widget.height,
        child: const Center(
          child: CircularProgressIndicator(), // Loading state
        ),
      );
    }

    return SizedBox(
      height: widget.height,
      child: AdWidget(ad: _nativeAd!),
    );
  }
}
