import 'dart:io';

import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../adsmanager/native ad/native_ad_service.dart';
import '../../adsmanager/native ad/native_ad_shimmer.dart';
import '../../adsmanager/ad_ids.dart';
// import '../../services/analytics_service.dart';
import '../../services/navigation_service.dart';
import '../../services/shareed_prefe.dart';
import '../../utils/colors.dart';
import '../../utils/common_utils.dart';
import '../../utils/strings.dart';
import '../../widgets/text_app.dart';
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
        top:
            !isAdPage, // Expand full screen (above status bar area) on ad slide
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
                      customAdIds: [AdIds.nativeHF, AdIds.nativeLF],
                      factoryId: Platform.isAndroid
                          ? AppStrings.nativeAdFactoryFullscreenAndroid
                          : AppStrings.nativeAdFactoryFullscreenIOS,
                      height: 100.h,
                      width: double.infinity,
                      backgroundColor: Colors.white,
                      screenName: 'AiOnboardingScreen_Fullscreen',
                      shimmer: ShimmerNativeAd.fullscreenNativeAdShimmer(),
                    );
                  }

                  // Resolve onboarding page data: index 0,1 -> 0,1; index 3 -> 2
                  final pageIndex = index > 2 ? index - 1 : index;
                  final page = _pages[pageIndex];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Full-width Image
                      Expanded(
                        flex: 6,
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage(page.imagePath),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      // Text details (Left-aligned)
                      Expanded(
                        flex: 5,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24.0,
                            vertical: 16.0,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 12),
                              Text(
                                page.title,
                                style: AppTextStyles.getStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 14),
                              Text(
                                page.subtitle,
                                style: AppTextStyles.getStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 14,
                                  height: 1.5,
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 16.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Dot Indicators
                    Row(
                      children: List.generate(4, (index) {
                        final isActive = index == _currentPage;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4.0),
                          height: 8.0,
                          width: isActive ? 24.0 : 8.0,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4.0),
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      child: Text(
                        _currentPage == 3 ? 'Start' : 'Next',
                        style: AppTextStyles.getStyle(
                          fontSize: 18,
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
                customAdIds: [AdIds.nativeHF, AdIds.nativeLF],
                factoryId: Platform.isAndroid
                    ? AppStrings.nativeAdFactoryLargeAndroid
                    : AppStrings.nativeAdFactoryLargeIOS,
                height: 34.h,
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
