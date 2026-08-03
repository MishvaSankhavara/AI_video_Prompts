import 'package:aivideoprompt/widgets/text_app.dart';
import 'package:aivideoprompt/utils/images.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

import 'package:flutter/material.dart';
import '../../adsmanager/native ad/native_ad_service.dart';
import '../../adsmanager/native ad/native_ad_shimmer.dart';
import '../../adsmanager/interstitial_ad_service.dart';
import '../../adsmanager/ad_ids.dart';
import '../../adsmanager/ad_manager.dart';
// import '../../services/analytics_service.dart';
import '../../services/navigation_service.dart';
import '../../services/shareed_prefe.dart';
import '../../services/asset_preloader.dart';
import '../../utils/colors.dart';
import '../../utils/common_utils.dart';
import '../../utils/constants.dart';
import '../../utils/strings.dart';
import '../onboarding/onboarding_screen.dart';
import '../settings/privacy_policy_screen.dart';
import '../start/start_screen.dart';
import '../../services/firebase/remote_config_service.dart';
import '../../services/subscription_service.dart';
import '../../services/device_id_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;
  late Animation<double> _fadeAnimation;

  final NativeAdService _nativeAdService = NativeAdService();
  bool _isAdManagerInitialized = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    _progressAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.4, curve: Curves.easeIn),
      ),
    );

    _controller.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Request tracking authorization on iOS devices before continuing
      try {
        if (Platform.isIOS) {
          final status = await AppTrackingTransparency.requestTrackingAuthorization();
          CommonUtils.printLog('>>> SPLASH SCREEN: ATT status: $status');

          final idfa = await AppTrackingTransparency.getAdvertisingIdentifier();
          CommonUtils.printLog('===================================================');
          CommonUtils.printLog('SPLASH SCREEN: IDFA: $idfa');
          CommonUtils.printLog('===================================================');

          final iosDeviceId = await DeviceInfoService.getDeviceId();
          CommonUtils.print('===================================================');
          CommonUtils.print('SPLASH SCREEN: iOS Device ID: $iosDeviceId');
          CommonUtils.print('===================================================');

          if (idfa.isNotEmpty && idfa != '00000000-0000-0000-0000-000000000000') {
            final String rawIdfaUpper = idfa.toUpperCase();
            final String rawIdfaLower = idfa.toLowerCase();

            // AdMob expects lowercase MD5 hash of raw IDFA string
            final String md5Upper = md5.convert(utf8.encode(rawIdfaUpper)).toString().toLowerCase();
            final String md5Lower = md5.convert(utf8.encode(rawIdfaLower)).toString().toLowerCase();

            CommonUtils.printLog('>>> REGISTERING TEST DEVICE MD5 (Upper): $md5Upper');
            CommonUtils.printLog('>>> REGISTERING TEST DEVICE MD5 (Lower): $md5Lower');

            // Apply configurations to Google Mobile Ads SDK dynamically
            final requestConfig = RequestConfiguration(
              testDeviceIds: [
                md5Upper,
                md5Lower,
                idfa,
              ],
            );
            await MobileAds.instance.updateRequestConfiguration(requestConfig);
            CommonUtils.printLog('>>> Dynamic AdMob Test Device Registration Completed!');
          }
        }
      } catch (e) {
        CommonUtils.printLog('>>> SPLASH SCREEN: ATT error: $e');
      }

      // Initialize AdManager after ATT authorization has been resolved so the Ad SDK has full device identification
      try {
        CommonUtils.printLog('>>> SPLASH SCREEN: Initializing AdManager...');
        await AdManager.instance.initialize();
        CommonUtils.printLog('>>> SPLASH SCREEN: AdManager Initialized successfully!');
        if (mounted) {
          setState(() {
            _isAdManagerInitialized = true;
          });
        }
      } catch (e) {
        // CommonUtils.printLog('>>> SPLASH SCREEN: AdManager Initialization Error: $e');
      }

      bool isSub = await SharedPrefs.isSubscribed();
      if (isSub) {
        String? expiryString = await SharedPrefs.getExpiryDate();
        if (expiryString != null) {
          try {
            DateTime expiryDate = DateTime.parse(expiryString);
            if (DateTime.now().isAfter(expiryDate)) {
              isSub = false;
              await SharedPrefs.setSubscribed(false);
            }
          } catch (e) {
            // Ignored
          }
        }
      }
      
      AppConstants.isSubscribed = isSub;
      // CommonUtils.printLog('>>> SPLASH SCREEN isSubscribed (cached): ${AppConstants.isSubscribed}');
      if (mounted) setState(() {});
      AssetPreloader.preloadAssets(context);
      await SubscriptionService.instance.init();
      // CommonUtils.printLog('>>> SPLASH SCREEN isSubscribed (after init): ${AppConstants.isSubscribed}');
      // CommonUtils.printLog('--- SPLASH LOG: Fetched Weekly Price: ${SubscriptionService.instance.weeklyPrice} ---');
      // CommonUtils.printLog('--- SPLASH LOG: Fetched Yearly Price: ${SubscriptionService.instance.yearlyPrice} ---');
      // CommonUtils.printLog('--- SPLASH LOG: isSubscribed is currently ${AppConstants.isSubscribed} ---');

      // Fetch and log FCM token after splash is fully running so it is guaranteed to show up in Android Studio console
      try {
        final fcmToken = await FirebaseMessaging.instance.getToken();
        CommonUtils.printLog('===================================================');
        CommonUtils.printLog('SPLASH FCM TOKEN: $fcmToken');
        // CommonUtils.printLog('===================================================');
        // CommonUtils.printLog('SPLASH FCM TOKEN: $fcmToken');
      } catch (e) {
        CommonUtils.printLog('SPLASH FCM TOKEN ERROR: $e');
      }
    });

    _controller.addStatusListener((status) async {
      if (status == AnimationStatus.completed) {
        bool hasSeenOnboarding = false;
        try {
          hasSeenOnboarding = await SharedPrefs.hasSeenOnboarding();
        } catch (e) {
          // // CommonUtils.printLog('Error reading onboarding status: $e');
        }

        if (!mounted) return;

        Widget targetScreen = hasSeenOnboarding
            ? const StartScreen()
            : const PrivacyPolicyScreen(isFirstTime: true);

        void navigateToTarget() {
          if (!mounted) return;
          NavigationService.pushReplacement(context, targetScreen);
        }

        if (_isAdManagerInitialized && RemoteConfigService.instance.showInterAdSplash && !AppConstants.isSubscribed) {
          InterstitialAdService.showAd(
            context: context,
            customAdIds: [AdIds.interstitialAd1, AdIds.interstitialAd2],
            onAdClosed: navigateToTarget,
            onAdFailedToShow: navigateToTarget,
          );
        } else {
          navigateToTarget();
        }
      }
    });
  }

  // Removed _loadNativeAd

  @override
  void dispose() {
    _controller.dispose();
    _nativeAdService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.splashBackgroundStart,
              AppColors.splashBackgroundEnd,
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Center Logo and App Name
              Align(
                alignment: const Alignment(0, -0.25),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Light-optimized Image Logo from assets
                      Image.asset(
                        ImageUtils.logoRounded,
                        width: 180.w,
                        height: 180.h,
                        fit: BoxFit.contain,
                      ),
                      SizedBox(height: 40.h),
                      // Text Title
                      AppText(
                        AppStrings.appName,
                        textColor: AppColors.textPrimary,
                        textSize: 26.sp,
                        textWeight: FontWeight.bold,
                        lettersSpace: 0.5,
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom Progress Bar
              Positioned(
                bottom: 180.h,
                left: 0.w,
                right: 0.w, //ad
                child: Center(
                  child: Container(
                    width: 240.w,
                    height: 6.h,
                    decoration: BoxDecoration(
                      color: AppColors.black.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: AnimatedBuilder(
                      animation: _progressAnimation,
                      builder: (context, child) {
                        return Align(
                          alignment: Alignment.centerLeft,
                          child: FractionallySizedBox(
                            widthFactor: _progressAnimation.value,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    AppColors.splashAccent,
                                    AppColors.textMuted,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),

              // Medium Native Ad at Bottom
              if (_isAdManagerInitialized && RemoteConfigService.instance.showNativeAdSplash && !AppConstants.isSubscribed)
                Positioned(
                  bottom: 6.h,
                  left: 6.w,
                  right: 6.w,
                  child: _nativeAdService.buildNativeAdTile(
                  0, // Index 0 for splash single ad
                  () => setState(() {}),
                  customAdIds: [AdIds.nativeAd1, AdIds.nativeAd2],
                  factoryId: Platform.isAndroid
                      ? AppStrings.nativeAdFactoryMediumAndroid
                      : AppStrings.nativeAdFactoryMediumIOS,
                  height: 0.16.sh,
                  width: double.infinity,
                  borderRadius: 12,
                  backgroundColor: AppColors.white,
                  screenName: 'AiSplashScreen_Medium',
                  shimmer: ShimmerNativeAd.mediumNativeAdShimmer(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
