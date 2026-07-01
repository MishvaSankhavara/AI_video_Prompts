import 'package:aivideoprompt/widgets/text_app.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../adsmanager/native ad/native_ad_service.dart';
import '../../adsmanager/native ad/native_ad_shimmer.dart';
import '../../adsmanager/ad_ids.dart';
// import '../../services/analytics_service.dart';
import '../../services/navigation_service.dart';
import '../../services/shareed_prefe.dart';
import '../../utils/colors.dart';
import '../../utils/common_utils.dart';
import '../../utils/strings.dart';
import '../home/bottom_nav_bar_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Fullscreen ad slide gets its own service; each onboarding page gets its
  // own so a fresh native ad is loaded whenever the page changes.
  final NativeAdService _fullscreenAd = NativeAdService();
  final List<NativeAdService> _pageAds = List.generate(
    4, // matches PageView itemCount
    (_) => NativeAdService(),
  );

  final List<OnboardingPageData> _pages = [
    OnboardingPageData(
      title: AppStrings.onboardingTitle1,
      subtitle: AppStrings.onboardingSubtitle1,
      imagePath: 'assets/images/onboarding_1.png',
    ),
    OnboardingPageData(
      title: AppStrings.onboardingTitle2,
      subtitle: AppStrings.onboardingSubtitle2,
      imagePath: 'assets/images/onboarding_2.png',
    ),
    OnboardingPageData(
      title: AppStrings.onboardingTitle3,
      subtitle: AppStrings.onboardingSubtitle3,
      imagePath: 'assets/images/onboarding_3.png',
    ),
  ];

  @override
  void initState() {
    super.initState();
  }

  // Removed manual NativeAd load methods

  Future<void> _completeOnboarding() async {
    try {
      await SharedPrefs.setOnboardingSeen();
    } catch (e) {
      // CommonUtils.printLog(
      //   'Error writing onboarding flag to shared preferences: $e',
      // );
    }

    if (mounted) {
      NavigationService.pushReplacement(context, const BottomNavBarScreen());
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fullscreenAd.dispose();
    for (final ad in _pageAds) {
      ad.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isAdPage = _currentPage == 2;

    return Scaffold(
      backgroundColor:
          AppColors.mainBackground, // White background matching app theme
      body: SafeArea(
        top: false,
        bottom:
            !isAdPage, // Expand full screen (below navigation bar area) on ad slide
        child: Column(
          children: [
            // Page Content (Image and Text inside PageView)
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: 4, // 3 onboarding pages + 1 full-screen ad page
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  if (index == 2) {
                    return _fullscreenAd.buildNativeAdTile(
                      0, // Fullscreen ad index 0
                      () => setState(() {}),
                      customAdIds: [AdIds.nativeAd1, AdIds.nativeAd2],
                      factoryId: Platform.isAndroid
                          ? AppStrings.nativeAdFactoryFullscreenAndroid
                          : AppStrings.nativeAdFactoryFullscreenIOS,
                      height: 1.sh,
                      width: double.infinity,
                      backgroundColor: AppColors.white,
                      screenName: 'AiOnboardingScreen_Fullscreen',
                      shimmer: ShimmerNativeAd.fullscreenNativeAdShimmer(),
                    );
                  }

                  // Resolve onboarding page data: index 0,1 -> 0,1; index 3 -> 2
                  final pageIndex = index > 2 ? index - 1 : index;
                  final page = _pages[pageIndex];
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      // Image taking full space
                      Image.asset(
                        page.imagePath,
                        fit: BoxFit.fill,
                      ),
                      // Gradient fade effect at the bottom
                      Positioned(
                        bottom: 0.h,
                        left: 0.w,
                        right: 0.w,
                        height: 250.h, // Height of the fade effect
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                AppColors.white,
                                AppColors.white.withValues(alpha: 0.8),
                                AppColors.white.withValues(alpha: 0),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Text details positioned at the bottom on top of the gradient
                      Positioned(
                        bottom: 0.h,
                        left: 0.w,
                        right: 0.w,
                        child: Padding(
                          padding: EdgeInsets.only(
                            left: 24.w,
                            right: 24.w,
                            top: 16.h,
                            bottom: 0.h,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                page.title,
                                style: AppTextStyles.getStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              SizedBox(height: 14.h),
                              Text(
                                page.subtitle,
                                style: AppTextStyles.getStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 12.sp,
                                  height: 1.5.h,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            // Navigation Row (Dots on Left, Next/Start on Right) - Hidden on Ad Slide
            if (!isAdPage)
              Padding(
                padding: EdgeInsets.only(
                  left: 24.w,
                  right: 24.w,
                  top: 0.h,
                  bottom: 0.h,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Dot Indicators
                    Row(
                      children: List.generate(3, (index) {
                        final activeDotIndex = _currentPage > 2 ? _currentPage - 1 : _currentPage;
                        final isActive = index == activeDotIndex;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: EdgeInsets.symmetric(horizontal: 4.w),
                          height: 8.h,
                          width: isActive ? 24 : 8,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4.r),
                            color: isActive
                                ? AppColors
                                      .primary // Matches app theme primary color
                                : AppColors
                                      .border, // Muted purple-grey inactive
                          ),
                        );
                      }),
                    ),

                    // Next / Start Button
                    TextButton(
                      onPressed: () {
                        if (_currentPage < 3) {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOutCubic,
                          );
                        } else {
                          _completeOnboarding();
                        }
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors
                            .primary, // Matches app theme primary color
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 8.h,
                        ),
                      ),
                      child: Text(
                        _currentPage == 3 ? 'Start' : 'Next',
                        style: AppTextStyles.getStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Large Native Ad at bottom (only on onboarding slides, not the ad slide itself).
            // A separate service per page loads a fresh ad whenever the page changes.
            if (!isAdPage)
              _pageAds[_currentPage].buildNativeAdTile(
                0,
                () => setState(() {}),
                customAdIds: [AdIds.nativeAd1, AdIds.nativeAd2],
                factoryId: Platform.isAndroid
                    ? AppStrings.nativeAdFactoryLargeAndroid
                    : AppStrings.nativeAdFactoryLargeIOS,
                height: 0.34.sh,
                width: double.infinity,
                backgroundColor: AppColors.mainBackground,
                screenName: 'AiOnboardingScreen_Large_$_currentPage',
                shimmer: ShimmerNativeAd.largeNativeAdShimmer(),
              ),
          ],
        ),
      ),
    );
  }
}

class OnboardingPageData {
  final String title;
  final String subtitle;
  final String imagePath;

  OnboardingPageData({
    required this.title,
    required this.subtitle,
    required this.imagePath,
  });
}
