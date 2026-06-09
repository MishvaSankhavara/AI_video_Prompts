import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../utils/colors.dart';
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

  final List<OnboardingPageData> _pages = [
    OnboardingPageData(
      title: AppStrings.onboardingTitle1,
      subtitle: AppStrings.onboardingSubtitle1,
      icon: Icons.auto_awesome_rounded,
      gradientColors: [const Color(0xFF6366F1), const Color(0xFF4F46E5)], // Indigo/Blue
      visualWidget: const OnboardingVisualOne(),
    ),
    OnboardingPageData(
      title: AppStrings.onboardingTitle2,
      subtitle: AppStrings.onboardingSubtitle2,
      icon: Icons.copy_all_rounded,
      gradientColors: [const Color(0xFF06B6D4), const Color(0xFF0891B2)], // Teal/Cyan
      visualWidget: const OnboardingVisualTwo(),
    ),
    OnboardingPageData(
      title: AppStrings.onboardingTitle3,
      subtitle: AppStrings.onboardingSubtitle3,
      icon: Icons.workspace_premium_rounded,
      gradientColors: [const Color(0xFFF59E0B), const Color(0xFFD97706)], // Amber/Orange
      visualWidget: const OnboardingVisualThree(),
    ),
  ];

  Future<void> _completeOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('has_seen_onboarding', true);
    } catch (e) {
      debugPrint('Error writing onboarding flag to shared preferences: $e');
    }
    
    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 400),
        ),
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      backgroundColor: AppColors.mainBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar (Skip Button)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: isLandscape ? 0.5.h : 1.h),
              child: Align(
                alignment: Alignment.centerRight,
                child: _currentPage < 2
                    ? TextButton(
                        onPressed: () {
                          _pageController.animateToPage(
                            2,
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOutCubic,
                          );
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.textMuted,
                          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: isLandscape ? 0.5.h : 1.h),
                        ),
                        child: Text(
                          AppStrings.onboardingSkip,
                          style: AppTextStyles.getStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    : SizedBox(height: isLandscape ? 20.0 : 4.5.h), // placeholder to maintain layout stability
              ),
            ),

            // Content PageView
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  
                  if (isLandscape) {
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5.w),
                      child: Row(
                        children: [
                          // Left side: Visual Graphics Container
                          Expanded(
                            flex: 5,
                            child: Center(
                              child: page.visualWidget,
                            ),
                          ),
                          SizedBox(width: 4.w),
                          // Right side: Text Content
                          Expanded(
                            flex: 5,
                            child: Center(
                              child: SingleChildScrollView(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      page.title,
                                      textAlign: TextAlign.center,
                                      style: AppTextStyles.getStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 21,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                    SizedBox(height: 1.h),
                                    Text(
                                      page.subtitle,
                                      textAlign: TextAlign.center,
                                      style: AppTextStyles.getStyle(
                                        color: AppColors.textMuted,
                                        fontSize: 14,
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // Portrait mode layout
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 7.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Visual Graphics Container
                        Expanded(
                          flex: 5,
                          child: Center(
                            child: page.visualWidget,
                          ),
                        ),
                        
                        // Text Content
                        Expanded(
                          flex: 4,
                          child: Center(
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  SizedBox(height: 1.h),
                                  Text(
                                    page.title,
                                    textAlign: TextAlign.center,
                                    style: AppTextStyles.getStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 21,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  SizedBox(height: 1.5.h),
                                  Text(
                                    page.subtitle,
                                    textAlign: TextAlign.center,
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
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Bottom Navigation (Dots and Buttons)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: isLandscape ? 1.h : 3.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Dot Indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_pages.length, (index) {
                      final isActive = index == _currentPage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: EdgeInsets.symmetric(horizontal: 1.w),
                        height: isLandscape ? 6.0 : 1.h,
                        width: isActive ? 6.w : 2.w,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4.0),
                          gradient: isActive
                              ? LinearGradient(
                                  colors: _pages[index].gradientColors,
                                )
                              : const LinearGradient(
                                  colors: [AppColors.border, AppColors.border],
                                ),
                        ),
                      );
                    }),
                  ),
                  SizedBox(height: isLandscape ? 12.0 : 3.h),

                  // Action Button
                  SizedBox(
                    width: double.infinity,
                    height: isLandscape ? 44.0 : 7.h,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_currentPage < 2) {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOutCubic,
                          );
                        } else {
                          _completeOnboarding();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: Text(
                          _currentPage == 2 ? AppStrings.onboardingGetStarted : AppStrings.onboardingContinue,
                          key: ValueKey<int>(_currentPage),
                          style: AppTextStyles.getStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
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
  final IconData icon;
  final List<Color> gradientColors;
  final Widget visualWidget;

  OnboardingPageData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradientColors,
    required this.visualWidget,
  });
}

// ==========================================
// PROGRAMMATIC VISUAL GRAPHICS FOR SLIDE 1
// ==========================================
class OnboardingVisualOne extends StatelessWidget {
  const OnboardingVisualOne({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 28.h,
      width: 28.h,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background soft glowing blob 1
          Positioned(
            right: 2.3.h,
            bottom: 2.3.h,
            child: Container(
              width: 16.5.h,
              height: 16.5.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6366F1).withValues(alpha: 0.2),
                    blurRadius: 40,
                    spreadRadius: 15,
                  ),
                ],
              ),
            ),
          ),
          // Background soft glowing blob 2
          Positioned(
            left: 2.3.h,
            top: 2.3.h,
            child: Container(
              width: 14.h,
              height: 14.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4F46E5).withValues(alpha: 0.15),
                    blurRadius: 35,
                    spreadRadius: 10,
                  ),
                ],
              ),
            ),
          ),
          
          // Outer revolving-looking dotted circle
          Container(
            width: 23.h,
            height: 23.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF6366F1).withValues(alpha: 0.2),
                width: 2,
                style: BorderStyle.solid,
              ),
            ),
          ),

          // Middle decorative circle
          Container(
            width: 17.5.h,
            height: 17.5.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF4F46E5).withValues(alpha: 0.3),
                width: 1,
              ),
            ),
          ),

          // Central Glassmorphic Hexagonal / Rounded Card
          Container(
            width: 13.h,
            height: 13.h,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(3.3.h),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.6),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4F46E5).withValues(alpha: 0.15),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                Icons.auto_awesome_rounded,
                color: const Color(0xFF4F46E5),
                size: 6.h,
              ),
            ),
          ),

          // Tiny Floating Planet/Stars around the center
          Positioned(
            top: 4.7.h,
            right: 4.7.h,
            child: _buildFloatingParticle(1.8.h, const Color(0xFF818CF8)),
          ),
          Positioned(
            bottom: 5.8.h,
            left: 5.3.h,
            child: _buildFloatingParticle(1.2.h, const Color(0xFF312E81)),
          ),
          Positioned(
            top: 15.h,
            left: 2.9.h,
            child: _buildFloatingParticle(1.6.h, const Color(0xFFC7D2FE)),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingParticle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.4),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// PROGRAMMATIC VISUAL GRAPHICS FOR SLIDE 2
// ==========================================
class OnboardingVisualTwo extends StatelessWidget {
  const OnboardingVisualTwo({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 28.h,
      width: 28.h,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background soft glowing blob
          Container(
            width: 17.5.h,
            height: 17.5.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF06B6D4).withValues(alpha: 0.25),
                  blurRadius: 45,
                  spreadRadius: 15,
                ),
              ],
            ),
          ),

          // Cascading Cards Mocking prompt lists and copy action
          // Under card
          Positioned(
            top: 6.4.h,
            left: 4.7.h,
            child: Transform.rotate(
              angle: -0.1,
              child: Container(
                width: 15.h,
                height: 10.5.h,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(1.8.h),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
              ),
            ),
          ),

          // Main top card showing prompt details
          Positioned(
            top: 8.2.h,
            child: Container(
              width: 18.5.h,
              height: 11.6.h,
              padding: EdgeInsets.all(1.4.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(2.3.h),
                border: Border.all(
                  color: const Color(0xFFE2E8F0),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Fake prompt text lines
                  Container(
                    width: 12.8.h,
                    height: 0.9.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0891B2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  SizedBox(height: 0.7.h),
                  Container(
                    width: 15.h,
                    height: 0.9.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  SizedBox(height: 0.7.h),
                  Container(
                    width: 9.3.h,
                    height: 0.9.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Floating Clipboard Icon with Check mark/Success indicator
          Positioned(
            bottom: 5.3.h,
            right: 4.h,
            child: Container(
              width: 6.h,
              height: 6.h,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF06B6D4), Color(0xFF0891B2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0891B2).withValues(alpha: 0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: 3.2.h,
              ),
            ),
          ),

          // Dotted connection line representations
          Positioned(
            top: 4.7.h,
            right: 5.3.h,
            child: Icon(
              Icons.content_paste_rounded,
              color: const Color(0xFF0891B2),
              size: 3.h,
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// PROGRAMMATIC VISUAL GRAPHICS FOR SLIDE 3
// ==========================================
class OnboardingVisualThree extends StatelessWidget {
  const OnboardingVisualThree({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 28.h,
      width: 28.h,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background soft glowing blob (Amber/Orange)
          Container(
            width: 18.5.h,
            height: 18.5.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.25),
                  blurRadius: 50,
                  spreadRadius: 18,
                ),
              ],
            ),
          ),

          // Multi-layer rotating star background design
          Container(
            width: 20.h,
            height: 20.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.25),
                width: 1.5,
              ),
            ),
          ),

          // Premium Shield/Card
          Container(
            width: 11.6.h,
            height: 14.h,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(2.3.h),
                topRight: Radius.circular(2.3.h),
                bottomLeft: Radius.circular(100.w),
                bottomRight: Radius.circular(100.w),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFD97706).withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                Icons.workspace_premium_rounded,
                color: Colors.white,
                size: 6.3.h,
              ),
            ),
          ),

          // Floating Sparkles/Crown details
          Positioned(
            top: 4.h,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 1.2.h, vertical: 0.5.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(1.4.h),
                border: Border.all(
                  color: const Color(0xFFF59E0B),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.star_rounded, color: const Color(0xFFF59E0B), size: 1.6.h),
                  SizedBox(width: 0.5.h),
                  Text(
                    AppStrings.onboardingProBadge,
                    style: AppTextStyles.getStyle(
                      color: const Color(0xFFD97706),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Little floating items
          Positioned(
            top: 9.3.h,
            left: 3.5.h,
            child: Icon(Icons.star_rounded, color: const Color(0xFFF59E0B), size: 2.3.h),
          ),
          Positioned(
            bottom: 9.3.h,
            right: 3.5.h,
            child: Icon(Icons.star_rounded, color: const Color(0xFFF59E0B), size: 1.8.h),
          ),
        ],
      ),
    );
  }
}
