import 'package:aivideoprompt/widgets/text_app.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../adsmanager/native ad/native_ad_service.dart';
import '../../adsmanager/native ad/native_ad_shimmer.dart';
import '../../adsmanager/interstitial_ad_service.dart';
import '../../adsmanager/ad_ids.dart';
// import '../../services/analytics_service.dart';
import '../../services/navigation_service.dart';
import '../../services/shareed_prefe.dart';
import '../../services/asset_preloader.dart';
import '../../utils/colors.dart';
import '../../utils/common_utils.dart';
import '../../utils/strings.dart';
import '../onboarding/onboarding_screen.dart';
import '../start/start_screen.dart';

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      AssetPreloader.preloadAssets(context);
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
            : const OnboardingScreen();

        void navigateToTarget() {
          if (!mounted) return;
          NavigationService.pushReplacement(context, targetScreen);
        }

        InterstitialAdService.showAd(
          context: context,
          customAdIds: [AdIds.interstitialAd5, AdIds.interstitialAd6],
          onAdClosed: navigateToTarget,
          onAdFailedToShow: navigateToTarget,
        );
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
                        'assets/images/logo.png',
                        width: 180.w,
                        height: 180.h,
                        fit: BoxFit.contain,
                      ),
                      SizedBox(height: 1.h),
                      // Text Title
                      Text(
                        AppStrings.appName,
                        style: AppTextStyles.getStyle(
                          color: AppColors.textPrimary,
                          fontSize: 26.sp,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
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
