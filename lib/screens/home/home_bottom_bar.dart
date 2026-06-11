import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:curved_navigation_bar_pro/curved_navigation_bar_pro.dart';

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

    // Soft light-purple color for inactive items to look premium on the dark purple bar
    const Color inactiveColor = Color(0xFFD6B5D0);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.only(
          left: 16.0,
          right: 16.0,
          bottom: 12.0,
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(24.0),
            bottomRight: Radius.circular(24.0),
          ),
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              // Solid white background bar to fill the transparent notch area
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: 80, // Matches the barHeight of CurvedNavigationBarPro
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24.0), // Matches cornerRadius: 24
                  ),
                ),
              ),
              CurvedNavigationBarPro(
                currentIndex: activeIndex,
                onTap: (index) {
                  appState.changeTab(index);
                },
                backgroundColor: AppColors.primary, // Purple bar background
                activeColor: Colors.white, // Active label text color
                activeIconColor: Colors.white, // Active icon inside FAB color
                inactiveColor: inactiveColor, // Inactive labels color
                fabColor: AppColors.primary, // Floating FAB color

                // Geometry
                barHeight: 80,
                fabRadius: 26,
                fabGap: 5,
                fabSink: 10,
                notchShoulderRadius: 12,
                cornerRadius: 24,
                contentPadding: 16,

                // Shadow
                elevation: 10,
                shadowColor: Colors.black12,

                items: [
                  CurvedNavigationItemPro(
                    inactiveWidget: const FaIcon(
                      FontAwesomeIcons.house,
                      size: 24,
                      color: inactiveColor,
                    ),
                    activeWidget: const Icon(
                      Icons.home_rounded,
                      size: 24,
                      color: Colors.white,
                    ),
                    label: AppStrings.tabHome,
                  ),
                  CurvedNavigationItemPro(
                    inactiveWidget: const FaIcon(
                      FontAwesomeIcons.heart,
                      size: 24,
                      color: inactiveColor,
                    ),
                    activeWidget: const FaIcon(
                      FontAwesomeIcons.solidHeart,
                      size: 24,
                      color: Colors.white,
                    ),
                    label: AppStrings.tabFavorite,
                  ),
                  CurvedNavigationItemPro(
                    inactiveWidget: const FaIcon(
                      FontAwesomeIcons.gear,
                      size: 24,
                      color: inactiveColor,
                    ),
                    activeWidget: const FaIcon(
                      FontAwesomeIcons.gear,
                      size: 24,
                      color: Colors.white,
                    ),
                    label: AppStrings.tabSettings,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
