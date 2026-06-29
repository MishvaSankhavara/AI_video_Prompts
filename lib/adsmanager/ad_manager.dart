import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../utils/common_utils.dart';
import '../utils/colors.dart';
import '../main.dart';
import 'ad_ids.dart';

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

  // Global Dialog State
  bool _isDialogShowing = false;

  // Get current global context from navigatorKey
  BuildContext? get _globalContext => navigatorKey.currentContext;

  // ─── INITIALIZATION ────────────────────────────────────────────────────────

  Future<void> initialize() async {
    await MobileAds.instance.initialize();
    CommonUtils.printLog('AdManager: MobileAds SDK initialized.');
  }

  // ─── LOADING DIALOG UI ─────────────────────────────────────────────────────

  void showLoadingDialog() {
    final context = _globalContext;
    if (context == null || _isDialogShowing) return;

    _isDialogShowing = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      builder: (BuildContext context) {
        return PopScope(
          canPop: false, // Prevent dismissal via back button
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 38,
                    height: 38,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                      strokeWidth: 3.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Loading Ad...',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.none,
                      fontFamily: 'Outfit',
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void dismissLoadingDialog() {
    final context = _globalContext;
    if (context == null || !_isDialogShowing) return;

    _isDialogShowing = false;
    Navigator.of(context, rootNavigator: true).pop();
  }
}
