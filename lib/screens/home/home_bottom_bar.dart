import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
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
        padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 12.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(50),
          child: CurvedNavigationBar(
            index: activeIndex,
            height: 70.0,
            items: <Widget>[
              activeIndex == 0
                  ? const Icon(
                      Icons.home_rounded,
                      size: 28,
                      color: AppColors.primary,
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.home_rounded,
                          size: 28,
                          color: AppColors.white,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          AppStrings.tabHome,
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
              activeIndex == 1
                  ? const Icon(
                      Icons.favorite_rounded,
                      size: 28,
                      color: AppColors.primary,
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.favorite_rounded,
                          size: 28,
                          color: AppColors.white,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          AppStrings.tabFavorite,
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
              activeIndex == 2
                  ? const Icon(
                      Icons.settings_rounded,
                      size: 28,
                      color: AppColors.primary,
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.settings_rounded,
                          size: 28,
                          color: AppColors.white,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          AppStrings.tabSettings,
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
            ],
            color: AppColors.homeBottomBar,
            buttonBackgroundColor: Colors.transparent,
            backgroundColor: Colors.white,
            animationCurve: Curves.easeInOut,
            animationDuration: const Duration(milliseconds: 300),
            onTap: (index) {
              appState.changeTab(index);
            },
          ),
        ),
      ),
    );
  }
}
