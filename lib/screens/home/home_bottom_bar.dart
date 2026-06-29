import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/app_state.dart';
import '../../utils/colors.dart';
import '../../utils/strings.dart';
import 'favorite_screen.dart';
import '../settings/settings_screen.dart';
import 'home_screen.dart';

class CustomBottomBar extends StatelessWidget {
  const CustomBottomBar({super.key});

  static Widget getBody(AppState appState) {
    switch (appState.currentTabIndex) {
      case 0:
        return const HomeTabBody();
      case 1:
        return const FavoriteScreen();
      case 2:
        return const SettingsScreen();
      default:
        return const HomeTabBody();
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final activeIndex = appState.currentTabIndex;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.only(
          left: 20.0,
          right: 20.0,
          bottom: 16.0,
        ),
        child: Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(35.0),
            border: Border.all(
              color: AppColors.border,
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.05),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final tabWidth = constraints.maxWidth / 3;
              return Stack(
                children: [
                  // Amazing Sliding Indicator
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.fastOutSlowIn,
                    left: tabWidth * activeIndex,
                    top: 6,
                    bottom: 6,
                    width: tabWidth,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          width: 0.5,
                        ),
                      ),
                    ),
                  ),
                  // The 3 Tabs
                  Row(
                    children: [
                      _buildTab(
                        index: 0,
                        activeIndex: activeIndex,
                        imagePath: 'assets/images/ic_home.png',
                        text: AppStrings.tabHome,
                        width: tabWidth,
                        appState: appState,
                      ),
                      _buildTab(
                        index: 1,
                        activeIndex: activeIndex,
                        imagePath: 'assets/images/ic_like.png',
                        text: AppStrings.tabFavorite,
                        width: tabWidth,
                        appState: appState,
                      ),
                      _buildTab(
                        index: 2,
                        activeIndex: activeIndex,
                        imagePath: 'assets/images/ic_settings.png',
                        text: AppStrings.tabSettings,
                        width: tabWidth,
                        appState: appState,
                      ),
                    ],
                  ),
                ],
              );
            }
          ),
        ),
      ),
    );
  }

  Widget _buildTab({
    required int index,
    required int activeIndex,
    required String imagePath,
    required String text,
    required double width,
    required AppState appState,
  }) {
    final isActive = index == activeIndex;
    final color = isActive ? AppColors.primary : AppColors.textMuted;
    
    return GestureDetector(
      onTap: () => appState.changeTab(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: width,
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 300),
          curve: Curves.fastOutSlowIn,
          style: TextStyle(
            color: color,
            fontSize: isActive ? 12 : 11,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: isActive ? 1.0 : 0.0, end: isActive ? 1.0 : 0.0),
                duration: const Duration(milliseconds: 300),
                curve: Curves.fastOutSlowIn,
                builder: (context, value, child) {
                  return Image.asset(
                    imagePath,
                    color: Color.lerp(AppColors.textMuted, AppColors.primary, value),
                    height: 22 + (2 * value),
                    width: 22 + (2 * value),
                    fit: BoxFit.contain,
                  );
                },
              ),
              const SizedBox(height: 4),
              Text(text),
            ],
          ),
        ),
      ),
    );
  }
}

