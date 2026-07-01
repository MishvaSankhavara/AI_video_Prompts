import 'package:aivideoprompt/widgets/text_app.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../adsmanager/native ad/native_ad_service.dart';
import '../../adsmanager/native ad/native_ad_shimmer.dart';
import '../../adsmanager/ad_ids.dart';
import '../../services/navigation_service.dart';
import '../../utils/colors.dart';
import '../../utils/strings.dart';
import '../home/bottom_nav_bar_screen.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  final NativeAdService _nativeAdService = NativeAdService();

  @override
  void dispose() {
    _nativeAdService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainBackground,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // Top Half: App Related Image
            Expanded(
              flex: 7,
              child: Container(
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      'assets/images/start_screen_img.png', // Using an existing nice illustration
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      bottom: 0.h,
                      left: 0.w,
                      right: 0.w,
                      height: 180.h, // Height of the fade effect
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
            ),

            // Bottom Half: Text and Button
            Expanded(
              flex: 3,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 12.h),
                    Text(
                      AppStrings.startScreenSubtitle,
                      style: AppTextStyles.getStyle(
                        color: AppColors.textMuted,
                        fontSize: 16.sp,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20.h),

                    // Start Exploring Button
                    SizedBox(
                      width: double.infinity,
                      height: 46.h,
                      child: ElevatedButton(
                        onPressed: () {
                          NavigationService.pushReplacement(
                            context,
                            const BottomNavBarScreen(),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          AppStrings.startScreenButton,
                          style: AppTextStyles.getStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Native ad at the bottom (collapses to nothing when unavailable)
            _nativeAdService.buildNativeAdTile(
              0, // Index 0 for start screen single ad
              () => setState(() {}),
              customAdIds: [AdIds.nativeAd1, AdIds.nativeAd2],
              factoryId: Platform.isAndroid
                  ? AppStrings.nativeAdFactoryLargeAndroid
                  : AppStrings.nativeAdFactoryLargeIOS,
              height: 0.34.sh,
              width: double.infinity,
              borderRadius: 16,
              backgroundColor: AppColors.cardBackground,
              margin: EdgeInsets.only(bottom: 6.h, left: 6.w, right: 6.w),
              screenName: 'AiStartScreen_Large',
              shimmer: ShimmerNativeAd.largeNativeAdShimmer(),
            ),
          ],
        ),
      ),
    );
  }
}
