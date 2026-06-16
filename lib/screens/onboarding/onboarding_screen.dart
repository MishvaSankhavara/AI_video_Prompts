import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../adsmanager/ad_ids.dart';
import '../../services/analytics_service.dart';
import '../../services/navigation_service.dart';
import '../../utils/colors.dart';
import '../../utils/common_utils.dart';
import '../../utils/strings.dart';
import '../../utils/text_app.dart';
import '../home/home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  
  NativeAd? _bottomNativeAd;
  bool _isBottomAdLoaded = false;
  NativeAd? _fullScreenNativeAd;
  bool _isFullScreenAdLoaded = false;

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
    AnalyticsService.instance.logEvent(name: 'onboarding_started');
    AnalyticsService.instance.logScreenView(screenName: 'onboarding_slide_1');
    _loadBottomNativeAd();
    _loadFullScreenNativeAd();
  }

  void _loadBottomNativeAd() {
    if (!AdIds.showAdsEnabled) return;

    _bottomNativeAd = NativeAd(
      adUnitId: AdIds.nativeAdUnitId,
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          if (mounted) {
            setState(() {
              _isBottomAdLoaded = true;
            });
          }
          CommonUtils.printLog('Onboarding Bottom NativeAd loaded successfully.');
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          CommonUtils.printLog('Onboarding Bottom NativeAd failed to load: $error');
        },
      ),
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: TemplateType.medium,
        mainBackgroundColor: Colors.white,
        cornerRadius: 12.0,
        callToActionTextStyle: NativeTemplateTextStyle(
          textColor: Colors.white,
          backgroundColor: AppColors.primary,
          size: 15.0,
        ),
        primaryTextStyle: NativeTemplateTextStyle(
          textColor: AppColors.textPrimary,
          size: 15.0,
        ),
        secondaryTextStyle: NativeTemplateTextStyle(
          textColor: AppColors.textMuted,
          size: 13.0,
        ),
        tertiaryTextStyle: NativeTemplateTextStyle(
          textColor: AppColors.textMuted,
          size: 13.0,
        ),
      ),
    );
    _bottomNativeAd!.load();
  }

  void _loadFullScreenNativeAd() {
    if (!AdIds.showAdsEnabled) return;

    _fullScreenNativeAd = NativeAd(
      adUnitId: AdIds.nativeAdUnitId,
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          if (mounted) {
            setState(() {
              _isFullScreenAdLoaded = true;
            });
          }
          CommonUtils.printLog('Onboarding FullScreen NativeAd loaded successfully.');
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          CommonUtils.printLog('Onboarding FullScreen NativeAd failed to load: $error');
        },
      ),
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: TemplateType.medium,
        mainBackgroundColor: Colors.white,
        cornerRadius: 0.0, // Seamless full-width screen edge alignment
        callToActionTextStyle: NativeTemplateTextStyle(
          textColor: Colors.white,
          backgroundColor: AppColors.primary,
          size: 16.0,
        ),
        primaryTextStyle: NativeTemplateTextStyle(
          textColor: AppColors.textPrimary,
          size: 16.0,
        ),
        secondaryTextStyle: NativeTemplateTextStyle(
          textColor: AppColors.textMuted,
          size: 14.0,
        ),
        tertiaryTextStyle: NativeTemplateTextStyle(
          textColor: AppColors.textMuted,
          size: 14.0,
        ),
      ),
    );
    _fullScreenNativeAd!.load();
  }

  Future<void> _completeOnboarding() async {
    AnalyticsService.instance.logEvent(name: 'onboarding_completed');
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('has_seen_onboarding', true);
    } catch (e) {
      CommonUtils.printLog('Error writing onboarding flag to shared preferences: $e');
    }
    
    if (mounted) {
      NavigationService.pushReplacement(context, const HomeScreen());
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _bottomNativeAd?.dispose();
    _fullScreenNativeAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isAdPage = _currentPage == 2;

    return Scaffold(
      backgroundColor: AppColors.mainBackground, // White background matching app theme
      body: SafeArea(
        top: !isAdPage, // Expand full screen (above status bar area) on ad slide
        bottom: !isAdPage, // Expand full screen (below navigation bar area) on ad slide
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
                  AnalyticsService.instance.logScreenView(screenName: 'onboarding_slide_${index + 1}');
                },
                itemBuilder: (context, index) {
                  if (index == 2) {
                    return Container(
                      color: Colors.white,
                      width: double.infinity,
                      height: double.infinity,
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: SizedBox(
                          height: 500,
                          width: double.infinity,
                          child: _isFullScreenAdLoaded && _fullScreenNativeAd != null
                              ? AdWidget(ad: _fullScreenNativeAd!)
                              : const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      ),
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
                          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
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
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
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
                                ? AppColors.primary // Matches app theme primary color
                                : AppColors.border, // Muted purple-grey inactive
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
                        foregroundColor: AppColors.primary, // Matches app theme primary color
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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

            // Large Native Ad at bottom (only show on onboarding slides, not on the ad slide itself)
            if (AdIds.showAdsEnabled && !isAdPage)
              Container(
                height: 300,
                width: double.infinity,
                color: AppColors.mainBackground, // White background for the ad container
                child: _isBottomAdLoaded && _bottomNativeAd != null
                    ? AdWidget(ad: _bottomNativeAd!)
                    : const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                        ),
                      ),
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
