import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../utils/colors.dart';

class CustomBottomBar extends StatelessWidget {
  const CustomBottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final activeIndex = appState.currentTabIndex;

    return BottomAppBar(
      color: AppColors.mainBackground,
      surfaceTintColor: AppColors.mainBackground,
      elevation: 12,
      shadowColor: Colors.black.withOpacity(0.4),
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      clipBehavior: Clip.antiAlias,
      child: Container(
        height: 60.0,
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Left Side: Home & Latest
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildTabItem(
                    icon: Icons.home_rounded,
                    label: 'Home',
                    isActive: activeIndex == 0,
                    onTap: () => appState.changeTab(0),
                  ),
                  _buildTabItem(
                    icon: Icons.auto_awesome_rounded,
                    label: 'Latest',
                    isActive: activeIndex == 1,
                    onTap: () => appState.changeTab(1),
                  ),
                ],
              ),
            ),

            // Spacer in the middle for center FAB
            const SizedBox(width: 60.0),

            // Right Side: Favorites & Settings
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildTabItem(
                    icon: Icons.favorite_rounded,
                    label: 'Favorites',
                    isActive: activeIndex == 3,
                    onTap: () => appState.changeTab(3),
                  ),
                  _buildTabItem(
                    icon: Icons.settings_rounded,
                    label: 'Settings',
                    isActive: activeIndex == 4,
                    onTap: () => appState.changeTab(4),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    final Color activeColor = AppColors.primary;
    final Color inactiveColor = AppColors.textMuted.withOpacity(0.6);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isActive ? activeColor : inactiveColor,
              size: 24,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: isActive ? activeColor : inactiveColor,
                fontSize: 10,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
