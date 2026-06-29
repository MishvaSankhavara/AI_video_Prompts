import 'dart:ui';
import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import '../../utils/text_app.dart';
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
                  const SizedBox(height: 16),
                  
                  // Top Section: Badge, Title, and Image in a Stack
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // 3D Design Image on the Right
                      Positioned(
                        right: -2,
                        top: 10,
                        bottom: -40, // Allows the image to overflow downwards nicely
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
                          left: 24,
                          top: 36,
                          bottom: 24,
                          right: size.width * 0.45, // Prevent text from overlapping the image too much
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Badge
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Image.asset(
                                    'assets/images/ic_crown.png',
                                    width: 16,
                                    height: 16,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    AppStrings.proUnlockPremium,
                                    style: AppTextStyles.getStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            // Title
                            Text(
                              AppStrings.proTitle,
                              style: AppTextStyles.getStyle(
                                color: AppColors.textPrimary,
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                height: 1.1,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 10), // Give extra space at the bottom of the stack
                            
                            // Subtitle placed below the image so it spans full width and doesn't overlap the 3D podium
                            Text(
                              AppStrings.proSubtitle,
                              style: AppTextStyles.getStyle(
                                color: AppColors.textMuted,
                                fontSize: 12,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // const SizedBox(height: 0),
                  
                  // Features Row
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
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

                  const SizedBox(height: 20),

                  // Subscription Plans
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
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
                                title: 'Weekly',
                                price: '\$4.99',
                                subtitle: 'per week',
                                isSelected: !isYearlySelected,
                                isBestValue: false,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          
                          // Yearly Plan
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  isYearlySelected = true;
                                });
                              },
                              child: _PlanCard(
                                title: 'Yearly',
                                price: '\$39.99',
                                subtitle: 'per year',
                                isSelected: isYearlySelected,
                                isBestValue: true,
                                badgeText: 'BEST DEAL',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                  
                  // Billing Text
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      isYearlySelected 
                          ? 'You will be charged \$39.99/Year, billed\nautomatically until cancelled.' 
                          : 'You will be charged \$4.99/Week, billed\nautomatically until cancelled.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.getStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        height: 1.5,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Continue Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, Color(0xFF6B48FF)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          // TODO: Implement purchase flow
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        child: Text(
                          'Continue',
                          style: AppTextStyles.getStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Legal Links
                  /*Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Terms of Service',
                        style: AppTextStyles.getStyle(
                          color: AppColors.textMuted,
                          fontSize: 12,
                        ).copyWith(decoration: TextDecoration.underline),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'Restore',
                        style: AppTextStyles.getStyle(
                          color: AppColors.textMuted,
                          fontSize: 12,
                        ).copyWith(decoration: TextDecoration.underline),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'Privacy Policy',
                        style: AppTextStyles.getStyle(
                          color: AppColors.textMuted,
                          fontSize: 12,
                        ).copyWith(decoration: TextDecoration.underline),
                      ),
                    ],
                  ),*/
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),

          // Fixed Top Right Glass Back Button
          Positioned(
            top: MediaQuery.of(context).padding.top + 6,
            right: 24,
            child: IgnorePointer(
              ignoring: !_isCloseButtonVisible,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 500),
                opacity: _isCloseButtonVisible ? 1.0 : 0.0,
                child: AnimatedScale(
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.elasticOut,
                  scale: _isCloseButtonVisible ? 1.0 : 0.0,
                  child: GestureDetector(
                    onTap: () => NavigationService.pop(context),
                    child: ClipRRect(
                borderRadius: BorderRadius.circular(40),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(40),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.6),
                        width: 1.5,
                      ),
                    ),
                    child: const Icon(
                      Icons.close,
                      color: AppColors.primary,
                      size: 24,
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
      height: 40,
      width: 1,
      color: AppColors.border.withValues(alpha: 0.5),
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
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
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary.withValues(alpha: 0.05) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.primary.withValues(alpha: 0.15),
              width: 2,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    )
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
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                price,
                style: AppTextStyles.getStyle(
                  color: AppColors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: AppTextStyles.getStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        
        // Best Value Badge
        if (isBestValue && badgeText != null)
          Positioned(
            top: -12,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, Color(0xFF6B48FF)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  badgeText!,
                  style: AppTextStyles.getStyle(
                    color: Colors.white,
                    fontSize: 10,
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

  const _FeatureItem({
    required this.iconPath,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Image.asset(
                iconPath,
                width: 24,
                height: 24,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTextStyles.getStyle(
              color: AppColors.textPrimary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}
