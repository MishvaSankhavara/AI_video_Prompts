import 'dart:ui';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import '../../widgets/text_app.dart';
import '../../utils/strings.dart';
import '../../services/navigation_service.dart';

class ProScreen extends StatefulWidget {
  const ProScreen({super.key});

  @override
  State<ProScreen> createState() => _ProScreenState();
}

class _ProScreenState extends State<ProScreen> {
  // true = Yearly, false = Weekly
  bool isYearlySelected = true;
  bool _isCloseButtonVisible = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _isCloseButtonVisible = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.mainBackground,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Fixed Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/img_pro_screen_bg.png',
              fit: BoxFit.cover,
            ),
          ),

          // Scrollable Content
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 16.h),

                  // Top Section: Badge, Title, and Image in a Stack
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // 3D Design Image on the Right
                      Positioned(
                        right: -2,
                        top: 10.h,
                        bottom:
                            -40, // Allows the image to overflow downwards nicely
                        width: size.width * 0.45,
                        child: Image.asset(
                          'assets/images/img_pro_screen_design.png',
                          fit: BoxFit.contain,
                          alignment: Alignment.centerRight,
                        ),
                      ),

                      // Text Content on the Left
                      Padding(
                        padding: EdgeInsets.only(
                          left: 24.w,
                          top: 36.h,
                          bottom: 24.h,
                          right:
                              size.width *
                              0.45, // Prevent text from overlapping the image too much
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Badge
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 14.w,
                                vertical: 8.h,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Image.asset(
                                    'assets/images/ic_crown.png',
                                    width: 16.w,
                                    height: 16.h,
                                    color: AppColors.white,
                                  ),
                                  SizedBox(width: 8.w),
                                  Text(
                                    AppStrings.proUnlockPremium,
                                    style: AppTextStyles.getStyle(
                                      color: AppColors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10.sp,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 16.h),

                            // Title
                            Text(
                              AppStrings.proTitle,
                              style: AppTextStyles.getStyle(
                                color: AppColors.textPrimary,
                                fontSize: 20.sp,
                                fontWeight: FontWeight.w900,
                                height: 1.1.h,
                                letterSpacing: -0.5,
                              ),
                            ),
                            SizedBox(
                              height: 10.h,
                            ), // Give extra space at the bottom of the stack
                            // Subtitle placed below the image so it spans full width and doesn't overlap the 3D podium
                            Text(
                              AppStrings.proSubtitle,
                              style: AppTextStyles.getStyle(
                                color: AppColors.textMuted,
                                fontSize: 12.sp,
                                height: 1.5.h,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // SizedBox(height: 0.h),

                  // Features Row
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 24.w),
                    padding: EdgeInsets.symmetric(
                      vertical: 24.h,
                      horizontal: 8.w,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(24.r),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.05),
                          blurRadius: 20.r,
                          offset: Offset(0.w, 10.h),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _FeatureItem(
                          iconPath: 'assets/images/ic_sparkle.png',
                          title: AppStrings.proFeature1,
                        ),
                        _buildDivider(),
                        _FeatureItem(
                          iconPath: 'assets/images/ic_remove_ad.png',
                          title: AppStrings.proFeature2,
                        ),
                        _buildDivider(),
                        _FeatureItem(
                          iconPath: 'assets/images/ic_crown.png',
                          title: AppStrings.proFeature3,
                        ),
                        _buildDivider(),
                        _FeatureItem(
                          iconPath: 'assets/images/ic_infinite.png',
                          title: AppStrings.proFeature4,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20.h),

                  // Subscription Plans
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Weekly Plan
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  isYearlySelected = false;
                                });
                              },
                              child: _PlanCard(
                                title: AppStrings.proPlanWeekly,
                                price: AppStrings.proPriceWeekly,
                                subtitle: AppStrings.proSubtitleWeekly,
                                isSelected: !isYearlySelected,
                                isBestValue: false,
                              ),
                            ),
                          ),
                          SizedBox(width: 8.w),

                          // Yearly Plan
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  isYearlySelected = true;
                                });
                              },
                              child: _PlanCard(
                                title: AppStrings.proPlanYearly,
                                price: AppStrings.proPriceYearly,
                                subtitle: AppStrings.proSubtitleYearly,
                                isSelected: isYearlySelected,
                                isBestValue: true,
                                badgeText: AppStrings.proBestDealBadge,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 16.h),

                  // Billing Text
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Text(
                      isYearlySelected
                          ? AppStrings.proBillingYearly
                          : AppStrings.proBillingWeekly,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.getStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        height: 1.5.h,
                      ),
                    ),
                  ),

                  SizedBox(height: 16.h),

                  // Continue Button
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Container(
                      width: double.infinity,
                      height: 56.h,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.purpleAccent],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(28.r),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 20.r,
                            offset: Offset(0.w, 8.h),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          // TODO: Implement purchase flow
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.transparent,
                          shadowColor: AppColors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28.r),
                          ),
                        ),
                        child: Text(
                          AppStrings.proContinueBtn,
                          style: AppTextStyles.getStyle(
                            color: AppColors.white,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 16.h),

                  // Legal Links
                  /*Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppStrings.proTermsOfService,
                        style: AppTextStyles.getStyle(
                          color: AppColors.textMuted,
                          fontSize: 12.sp,
                        ).copyWith(decoration: TextDecoration.underline),
                      ),
                      SizedBox(width: 16.w),
                      Text(
                        AppStrings.proRestore,
                        style: AppTextStyles.getStyle(
                          color: AppColors.textMuted,
                          fontSize: 12.sp,
                        ).copyWith(decoration: TextDecoration.underline),
                      ),
                      SizedBox(width: 16.w),
                      Text(
                        AppStrings.proPrivacyPolicy,
                        style: AppTextStyles.getStyle(
                          color: AppColors.textMuted,
                          fontSize: 12.sp,
                        ).copyWith(decoration: TextDecoration.underline),
                      ),
                    ],
                  ),*/
                  SizedBox(height: 40.h),
                ],
              ),
            ),
          ),

          // Fixed Top Right Glass Back Button
          Positioned(
            top: MediaQuery.of(context).padding.top + 6,
            right: 24.w,
            child: IgnorePointer(
              ignoring: !_isCloseButtonVisible,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 500),
                opacity: _isCloseButtonVisible ? 1 : 0,
                child: AnimatedScale(
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.elasticOut,
                  scale: _isCloseButtonVisible ? 1 : 0,
                  child: GestureDetector(
                    onTap: () => NavigationService.pop(context),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(40.r),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          padding: EdgeInsets.all(6.r),
                          decoration: BoxDecoration(
                            color: AppColors.white.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(40.r),
                            border: Border.all(
                              color: AppColors.white.withValues(alpha: 0.6),
                              width: 1.5.w,
                            ),
                          ),
                          child: Icon(
                            Icons.close,
                            color: AppColors.primary,
                            size: 24.sp,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 40.h,
      width: 1.w,
      color: AppColors.border.withValues(alpha: 0.5),
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 8.h),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final String title;
  final String price;
  final String subtitle;
  final bool isSelected;
  final bool isBestValue;
  final String? badgeText;

  const _PlanCard({
    required this.title,
    required this.price,
    required this.subtitle,
    required this.isSelected,
    this.isBestValue = false,
    this.badgeText,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      fit: StackFit.expand,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 16.w),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.05)
                : AppColors.white,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: isSelected
                  ? AppColors.primary
                  : AppColors.primary.withValues(alpha: 0.15),
              width: 2.w,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      blurRadius: 15.r,
                      offset: Offset(0.w, 5.h),
                    ),
                  ]
                : [],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                title,
                style: AppTextStyles.getStyle(
                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                price,
                style: AppTextStyles.getStyle(
                  color: AppColors.textPrimary,
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                subtitle,
                style: AppTextStyles.getStyle(
                  color: AppColors.textMuted,
                  fontSize: 12.sp,
                ),
              ),
            ],
          ),
        ),

        // Best Value Badge
        if (isBestValue && badgeText != null)
          Positioned(
            top: -12,
            left: 0.w,
            right: 0.w,
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 12.w,
                  vertical: 4.h,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.purpleAccent],
                  ),
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 8.r,
                      offset: Offset(0.w, 2.h),
                    ),
                  ],
                ),
                child: Text(
                  badgeText!,
                  style: AppTextStyles.getStyle(
                    color: AppColors.white,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final String iconPath;
  final String title;

  const _FeatureItem({required this.iconPath, required this.title});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44.w,
            height: 44.h,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Image.asset(
                iconPath,
                width: 24.w,
                height: 24.h,
                color: AppColors.primary,
              ),
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTextStyles.getStyle(
              color: AppColors.textPrimary,
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              height: 1.3.h,
            ),
          ),
        ],
      ),
    );
  }
}
