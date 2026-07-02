import 'package:aivideoprompt/widgets/text_app.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../adsmanager/app_open_ad_service.dart';
import '../../adsmanager/ad_ids.dart';
// import '../../services/analytics_service.dart';
import '../../services/navigation_service.dart';
import '../../utils/colors.dart';
import '../../utils/strings.dart';
import '../home/bottom_nav_bar_screen.dart';

class WelcomeBackScreen extends StatefulWidget {
  final bool isResume;
  const WelcomeBackScreen({super.key, this.isResume = false});

  @override
  State<WelcomeBackScreen> createState() => _WelcomeBackScreenState();
}

class _WelcomeBackScreenState extends State<WelcomeBackScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    _progressAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.6, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    _controller.forward();

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (!mounted) return;

        if (widget.isResume) {
          AppOpenAdService.showAd(
            context: context,
            customAdIds: [AdIds.appOpenAdUnitId],
            screenName: 'WelcomeBackScreen',
            onAdClosed: () {
              if (!mounted) return;
              NavigationService.pop(context);
            },
          );
        } else {
          AppOpenAdService.showAd(
            context: context,
            customAdIds: [AdIds.appOpenAdUnitId],
            screenName: 'WelcomeBackScreen',
            onAdClosed: () {
              if (!mounted) return;
              NavigationService.pushReplacement(
                context,
                const BottomNavBarScreen(),
              );
            },
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
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
              AppColors.white,
              AppColors.softPink, // Premium soft lavender-pink tint
            ],
          ),
        ),
        child: Stack(
          children: [
            // Soft Light Aurora Glow 1 (Top Left)
            Positioned(
              top: -100,
              left: -50,
              child: Container(
                width: 320.w,
                height: 320.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.08),
                      AppColors.primary.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),

            // Soft Light Aurora Glow 2 (Bottom Right)
            Positioned(
              bottom: -50,
              right: -50,
              child: Container(
                width: 280.w,
                height: 280.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.secondary.withValues(alpha: 0.06),
                      AppColors.secondary.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),

            // Main Layout Content
            SafeArea(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Glassmorphic Center Card
                      ScaleTransition(
                        scale: _scaleAnimation,
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(32.r),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                              child: Container(
                                padding: EdgeInsets.all(32.w),
                                decoration: BoxDecoration(
                                  color: AppColors.white.withValues(
                                    alpha: 0.45,
                                  ),
                                  borderRadius: BorderRadius.circular(32.r),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withValues(
                                        alpha: 0.03,
                                      ),
                                      blurRadius: 20.r,
                                      spreadRadius: 2.r,
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // App Logo with soft glowing shadow
                                    Container(
                                      decoration: BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.primary.withValues(
                                              alpha: 0.06,
                                            ),
                                            blurRadius: 30.r,
                                            spreadRadius: 2.r,
                                          ),
                                        ],
                                      ),
                                      child: Image.asset(
                                        'assets/images/logo.png',
                                        width: 130.w,
                                        height: 130.h,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                    SizedBox(height: 28.h),
                                    // Welcome Text
                                    AppText(
                                      AppStrings.welcomeBackTitle,
                                      textAlignment: TextAlign.center,
                                      textColor: AppColors.textPrimary,
                                      textSize: 28.sp,
                                      textWeight: FontWeight.bold,
                                      lettersSpace: 0.8,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 70.h),

                      // Sleek glowing progress indicator
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Container(
                          width: 200.w,
                          height: 4.h,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.08),
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
                                          AppColors.secondary,
                                          AppColors.primary,
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
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
