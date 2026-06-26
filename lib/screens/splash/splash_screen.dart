import 'package:flutter/material.dart';
import '../../widgets/custom_native_ad.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../adsmanager/ad_service.dart';
import '../../adsmanager/ad_ids.dart';
import '../../services/analytics_service.dart';
import '../../services/navigation_service.dart';
import '../../utils/colors.dart';
import '../../utils/common_utils.dart';
import '../../utils/strings.dart';
import '../../utils/text_app.dart';
import '../home/home_screen.dart';
import '../onboarding/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;
  late Animation<double> _fadeAnimation;

  // Removed manual native ad state

  @override
  void initState() {
    super.initState();
    AnalyticsService.instance.logScreenView(screenName: 'splash_screen');
    // Preload interstitial early so it is ready by the time splash finishes
    AdService.instance.loadInterstitialAd(
      highFloorId: AdIds.interSplashHF1,
      lowFloorId: AdIds.interSplashLF2,
    );

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );

    _controller.forward();

    _controller.addStatusListener((status) async {
      if (status == AnimationStatus.completed) {
        bool hasSeenOnboarding = false;
        try {
          final prefs = await SharedPreferences.getInstance();
          hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;
        } catch (e) {
          CommonUtils.printLog('Error reading onboarding status: $e');
        }

        if (!mounted) return;

        Widget targetScreen = hasSeenOnboarding ? const HomeScreen() : const OnboardingScreen();

        void navigateToTarget() {
          if (!mounted) return;
          NavigationService.pushReplacement(context, targetScreen);
        }

        AdService.instance.showInterstitialAd(
          onAdDismissed: navigateToTarget,
        );
      }
    });
  }

  // Removed _loadNativeAd

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
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
                alignment: const Alignment(0.0, -0.25),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Light-optimized Image Logo from assets
                      Image.asset(
                        'assets/images/logo_light.png',
                        width: 180,
                        height: 180,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 1),
                      // Text Title
                      Text(
                        AppStrings.appName,
                        style: AppTextStyles.getStyle(
                          color: AppColors.textPrimary,
                          fontSize: 26,
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
                bottom: 180,
                left: 0,
                right: 0,//ad
                child: Center(
                  child: Container(
                    width: 240,
                    height: 6,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(10),
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
                                    Color(0xFF86687F),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(10),
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
              if (AdIds.showAdsEnabled)
                Positioned(
                  bottom: 6,
                  left: 6,
                  right: 6,
                  height: 150,
                  child: Container(
                    width: MediaQuery.of(context).size.width - 32,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: const CustomNativeAd(
                      factoryId: 'medium_ad_factory',
                      height: 150,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
