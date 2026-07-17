import 'package:aivideoprompt/widgets/text_app.dart';
import 'package:aivideoprompt/utils/images.dart';
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
import '../../services/firebase/remote_config_service.dart';

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
      imagePath: ImageUtils.onboarding1,
    ),
    OnboardingPageData(
      title: AppStrings.onboardingTitle2,
      subtitle: AppStrings.onboardingSubtitle2,
      imagePath: ImageUtils.onboarding2,
    ),
    OnboardingPageData(
      title: AppStrings.onboardingTitle3,
      subtitle: AppStrings.onboardingSubtitle3,
      imagePath: ImageUtils.onboarding3,
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
    final bool showAd = RemoteConfigService.instance.showNativeAdOnboardingFullScreen &&
                        !_fullscreenAd.hasAdFailed(0) &&
                        _fullscreenAd.canShowAds;
    final bool isAdPage = showAd && _currentPage == 2;

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
                itemCount: showAd ? 4 : 3, // 3 onboarding pages + 1 full-screen ad page if loaded
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  if (showAd && index == 2) {
                    return _fullscreenAd.buildNativeAdTile(
                      0, // Fullscreen ad index 0
                      () => setState(() {}),
                      customAdIds: [AdIds.nativeAd7, AdIds.nativeAd8],
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

                  // Resolve onboarding page data:
                  // If showAd is true: pageIndex is index for index < 2, and index - 1 for index > 2 (i.e. index 3 -> 2).
                  // If showAd is false: pageIndex is simply index (since there is no ad page).
                  final pageIndex = (showAd && index > 2) ? index - 1 : index;
                  final page = _pages[pageIndex];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top portion: App Related Image with fixed height to prevent vertical stretching
                      Container(
                        height: 0.38.sh,
                        width: double.infinity,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.asset(
                              page.imagePath,
                              fit: BoxFit.cover, // Preserves aspect ratio, prevents skewing
                            ),
                            // Gradient fade effect at the bottom of the image
                            Positioned(
                              bottom: 0.h,
                              left: 0.w,
                              right: 0.w,
                              height: 120.h, // Height of the fade effect
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: [
                                      AppColors.white,
                                      AppColors.white.withValues(alpha: 0),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(), // <--- Push the text details to the bottom when ad is not showing!
                      // Bottom portion: Text details
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 24.w,
                          vertical: 16.h,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AppText(
                              page.title,
                              textColor: AppColors.textPrimary,
                              textSize: 20.sp,
                              textWeight: FontWeight.bold,
                              lettersSpace: -0.5,
                            ),
                            SizedBox(height: 14.h),
                            AppText(
                              page.subtitle,
                              textColor: AppColors.textMuted,
                              textSize: 12.sp,
                              fontHeight: 1.5.h,
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

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
                        final activeDotIndex = (showAd && _currentPage > 2)
                            ? _currentPage - 1
                            : _currentPage;
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
                        final maxPages = showAd ? 3 : 2;
                        if (_currentPage < maxPages) {
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
                      child: AppText(
                        (showAd ? _currentPage == 3 : _currentPage == 2) ? 'Start' : 'Next',
                        textSize: 18.sp,
                        textWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

            if (_currentPage == 0 && RemoteConfigService.instance.showNativeAdOnboarding1)
              _pageAds[0].buildNativeAdTile(
                0,
                () => setState(() {}),
                customAdIds: [AdIds.nativeAd3, AdIds.nativeAd4],
                factoryId: Platform.isAndroid
                    ? AppStrings.nativeAdFactoryLargeAndroid
                    : AppStrings.nativeAdFactoryLargeIOS,
                height: 0.34.sh,
                width: double.infinity,
                backgroundColor: AppColors.mainBackground,
                screenName: 'AiOnboardingScreen_Large_0',
                shimmer: ShimmerNativeAd.largeNativeAdShimmer(),
              ),
            if (_currentPage == 1 && RemoteConfigService.instance.showNativeAdOnboarding2)
              _pageAds[1].buildNativeAdTile(
                0,
                () => setState(() {}),
                customAdIds: [AdIds.nativeAd5, AdIds.nativeAd6],
                factoryId: Platform.isAndroid
                    ? AppStrings.nativeAdFactoryLargeAndroid
                    : AppStrings.nativeAdFactoryLargeIOS,
                height: 0.34.sh,
                width: double.infinity,
                backgroundColor: AppColors.mainBackground,
                screenName: 'AiOnboardingScreen_Large_1',
                shimmer: ShimmerNativeAd.largeNativeAdShimmer(),
              ),
            if (_currentPage == 3 && RemoteConfigService.instance.showNativeAdOnboarding3)
              _pageAds[3].buildNativeAdTile(
                0,
                () => setState(() {}),
                customAdIds: [AdIds.nativeAd9, AdIds.nativeAd10],
                factoryId: Platform.isAndroid
                    ? AppStrings.nativeAdFactoryLargeAndroid
                    : AppStrings.nativeAdFactoryLargeIOS,
                height: 0.34.sh,
                width: double.infinity,
                backgroundColor: AppColors.mainBackground,
                screenName: 'AiOnboardingScreen_Large_3',
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
