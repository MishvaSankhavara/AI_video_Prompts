import 'dart:io';

import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../adsmanager/native ad/native_ad_service.dart';
import '../../adsmanager/native ad/native_ad_shimmer.dart';
import '../../adsmanager/ad_ids.dart';
import '../../services/navigation_service.dart';
import '../../utils/colors.dart';
import '../../utils/strings.dart';
import '../../widgets/text_app.dart';
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
                      bottom: 0,
                      left: 0,
                      right: 0,
                      height: 180, // Height of the fade effect
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.white,
                              Colors.white.withValues(alpha: 0.0),
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
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 12),
                    Text(
                      'Ready to create amazing videos with AI? Dive right back into the prompts.',
                      style: AppTextStyles.getStyle(
                        color: AppColors.textMuted,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),

                    // Start Exploring Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          NavigationService.pushReplacement(
                            context,
                            const BottomNavBarScreen(),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Start Exploring',
                          style: AppTextStyles.getStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
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
              customAdIds: [AdIds.nativeHF, AdIds.nativeLF],
              factoryId: Platform.isAndroid
                  ? AppStrings.nativeAdFactoryLargeAndroid
                  : AppStrings.nativeAdFactoryLargeIOS,
              height: 34.h,
              width: double.infinity,
              borderRadius: 16,
              backgroundColor: AppColors.cardBackground,
              margin: const EdgeInsets.only(bottom: 6, left: 6, right: 6),
              screenName: 'AiStartScreen_Large',
              shimmer: ShimmerNativeAd.largeNativeAdShimmer(),
            ),
          ],
        ),
      ),
    );
  }
}
