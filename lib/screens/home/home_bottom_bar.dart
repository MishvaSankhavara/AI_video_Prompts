import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/app_state.dart';
import '../../utils/colors.dart';
import '../favorite/favorite_screen.dart';
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

    return BottomAppBar(
      color: AppColors.mainBackground,
      surfaceTintColor: AppColors.mainBackground,
      elevation: 12,
      shadowColor: Colors.black.withValues(alpha: 0.15),
      child: Container(
        height: 60.0,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildTabItem(
              icon: Icons.home_rounded,
              label: 'Home',
              isActive: activeIndex == 0,
              onTap: () => appState.changeTab(0),
            ),
            _buildTabItem(
              icon: Icons.favorite_rounded,
              label: 'Favorites',
              isActive: activeIndex == 1,
              onTap: () => appState.changeTab(1),
            ),
            _buildTabItem(
              icon: Icons.settings_rounded,
              label: 'Settings',
              isActive: activeIndex == 2,
              onTap: () => appState.changeTab(2),
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
    final Color inactiveColor = AppColors.textMuted.withValues(alpha: 0.6);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
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
