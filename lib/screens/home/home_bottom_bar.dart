import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../services/app_state.dart';
import '../../utils/colors.dart';
import '../../utils/strings.dart';
import '../../utils/text_app.dart';
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
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.mainBackground,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Container(
          height: isLandscape ? 56.0 : 66.0,
          padding: EdgeInsets.symmetric(
            horizontal: isLandscape ? 8.w : 5.w,
            vertical: isLandscape ? 4.0 : 6.0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildTabItem(
                icon: Icons.home_rounded,
                label: 'Home',
                isActive: activeIndex == 0,
                activeColor: const Color(0xFF0D9488), // Vibrant Teal
                onTap: () => appState.changeTab(0),
                isLandscape: isLandscape,
              ),
              _buildTabItem(
                icon: Icons.favorite_rounded,
                label: AppStrings.tabFavorite,
                isActive: activeIndex == 1,
                activeColor: const Color(0xFF232F72), // Vibrant Rose/Red
                onTap: () => appState.changeTab(1),
                isLandscape: isLandscape,
              ),
              _buildTabItem(
                icon: Icons.settings_rounded,
                label: AppStrings.tabSettings,
                isActive: activeIndex == 2,
                activeColor: const Color(0xFF4F46E5), // Vibrant Indigo
                onTap: () => appState.changeTab(2),
                isLandscape: isLandscape,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabItem({
    required IconData icon,
    required String label,
    required bool isActive,
    required Color activeColor,
    required VoidCallback onTap,
    required bool isLandscape,
  }) {
    final Color inactiveColor = AppColors.textMuted.withValues(alpha: 0.6);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      splashColor: activeColor.withValues(alpha: 0.1),
      highlightColor: activeColor.withValues(alpha: 0.05),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          horizontal: isActive ? 12.0 : 10.0,
          vertical: isLandscape ? 6.0 : 8.0,
        ),
        decoration: BoxDecoration(
          color: isActive ? activeColor.withValues(alpha: 0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? activeColor : inactiveColor,
              size: isLandscape ? 20.0 : 22.0,
            ),
            // Animate label width and display state smoothly
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: isActive
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(width: 6.0),
                        Text(
                          label,
                          style: AppTextStyles.getStyle(
                            color: activeColor,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
