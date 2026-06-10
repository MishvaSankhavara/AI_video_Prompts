import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/analytics_service.dart';
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

  @override
  void initState() {
    super.initState();
    AnalyticsService.instance.logEvent(name: 'onboarding_started');
    AnalyticsService.instance.logScreenView(screenName: 'onboarding_slide_1');
  }

  final List<OnboardingPageData> _pages = [
    OnboardingPageData(
      title: AppStrings.onboardingTitle1,
      subtitle: AppStrings.onboardingSubtitle1,
      icon: FontAwesomeIcons.wandMagicSparkles,
      gradientColors: [const Color(0xFF6366F1), const Color(0xFF4F46E5)], // Indigo/Blue
      visualWidget: const OnboardingVisualOne(),
    ),
    OnboardingPageData(
      title: AppStrings.onboardingTitle2,
      subtitle: AppStrings.onboardingSubtitle2,
      icon: FontAwesomeIcons.solidCopy,
      gradientColors: [const Color(0xFF06B6D4), const Color(0xFF0891B2)], // Teal/Cyan
      visualWidget: const OnboardingVisualTwo(),
    ),
    OnboardingPageData(
      title: AppStrings.onboardingTitle3,
      subtitle: AppStrings.onboardingSubtitle3,
      icon: FontAwesomeIcons.crown,
      gradientColors: [const Color(0xFFF59E0B), const Color(0xFFD97706)], // Amber/Orange
      visualWidget: const OnboardingVisualThree(),
    ),
  ];

  Future<void> _completeOnboarding() async {
    AnalyticsService.instance.logEvent(name: 'onboarding_completed');
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
    return Scaffold(
      backgroundColor: AppColors.mainBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar (Skip Button)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Align(
                alignment: Alignment.centerRight,
                child: _currentPage < 2
                    ? TextButton(
                        onPressed: () {
                          AnalyticsService.instance.logEvent(name: 'onboarding_skip_tapped');
                          _pageController.animateToPage(
                            2,
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOutCubic,
                          );
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.textMuted,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                        child: Text(
                          AppStrings.onboardingSkip,
                          style: AppTextStyles.getStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    : const SizedBox(height: 38), // placeholder to maintain layout stability
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
                  AnalyticsService.instance.logScreenView(screenName: 'onboarding_slide_${index + 1}');
                },
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28.0),
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
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const SizedBox(height: 16),
                              Text(
                                page.title,
                                textAlign: TextAlign.center,
                                style: AppTextStyles.getStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 14),
                              Text(
                                page.subtitle,
                                textAlign: TextAlign.center,
                                style: AppTextStyles.getStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 15,
                                  height: 1.5,
                                ),
                              ),
                            ],
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
              padding: const EdgeInsets.all(28.0),
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
                        margin: const EdgeInsets.symmetric(horizontal: 4.0),
                        height: 8.0,
                        width: isActive ? 24.0 : 8.0,
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
                  const SizedBox(height: 36),

                  // Action Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
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
  final FaIconData icon;
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
      height: 240,
      width: 240,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background soft glowing blob 1
          Positioned(
            right: 20,
            bottom: 20,
            child: Container(
              width: 140,
              height: 140,
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
            left: 20,
            top: 20,
            child: Container(
              width: 120,
              height: 120,
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
            width: 200,
            height: 200,
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
            width: 150,
            height: 150,
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
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(28),
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
            child: const Center(
              child: FaIcon(
                FontAwesomeIcons.wandMagicSparkles,
                color: Color(0xFF4F46E5),
                size: 52,
              ),
            ),
          ),

          // Tiny Floating Planet/Stars around the center
          Positioned(
            top: 40,
            right: 40,
            child: _buildFloatingParticle(16, const Color(0xFF818CF8)),
          ),
          Positioned(
            bottom: 50,
            left: 45,
            child: _buildFloatingParticle(10, const Color(0xFF312E81)),
          ),
          Positioned(
            top: 130,
            left: 25,
            child: _buildFloatingParticle(14, const Color(0xFFC7D2FE)),
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
      height: 240,
      width: 240,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background soft glowing blob
          Container(
            width: 150,
            height: 150,
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
            top: 55,
            left: 40,
            child: Transform.rotate(
              angle: -0.1,
              child: Container(
                width: 130,
                height: 90,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(16),
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
            top: 70,
            child: Container(
              width: 160,
              height: 100,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
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
                    width: 110,
                    height: 8,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0891B2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 130,
                    height: 8,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 80,
                    height: 8,
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
            bottom: 45,
            right: 35,
            child: Container(
              width: 52,
              height: 52,
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
              child: const FaIcon(
                FontAwesomeIcons.check,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),

          // Dotted connection line representations
          Positioned(
            top: 40,
            right: 45,
            child: const FaIcon(
              FontAwesomeIcons.clipboard,
              color: Color(0xFF0891B2),
              size: 26,
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
      height: 240,
      width: 240,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background soft glowing blob (Amber/Orange)
          Container(
            width: 160,
            height: 160,
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
            width: 170,
            height: 170,
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
            width: 100,
            height: 120,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(20),
                topRight: const Radius.circular(20),
                bottomLeft: Radius.circular(MediaQuery.of(context).size.width),
                bottomRight: Radius.circular(MediaQuery.of(context).size.width),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFD97706).withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Center(
              child: FaIcon(
                FontAwesomeIcons.crown,
                color: Colors.white,
                size: 54,
              ),
            ),
          ),

          // Floating Sparkles/Crown details
          Positioned(
            top: 35,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
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
                  const FaIcon(FontAwesomeIcons.solidStar, color: Color(0xFFF59E0B), size: 14),
                  const SizedBox(width: 4),
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
            top: 80,
            left: 30,
            child: const FaIcon(FontAwesomeIcons.solidStar, color: Color(0xFFF59E0B), size: 20),
          ),
          Positioned(
            bottom: 80,
            right: 30,
            child: const FaIcon(FontAwesomeIcons.solidStar, color: Color(0xFFF59E0B), size: 16),
          ),
        ],
      ),
    );
  }
}
