import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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

  Widget _navItem({
    required FaIconData icon,
    required String title,
  }) {
    return Transform.translate(
      offset: const Offset(0, 5),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            FaIcon(
              icon,
              size: 22,
              color: AppColors.white,
            ),
            const SizedBox(height: 6),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.visible,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 10,
                fontWeight: FontWeight.w600,
                height: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final activeIndex = appState.currentTabIndex;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.only(
          left: 16.0,
          right: 16.0,
          bottom: 12.0,
        ),
        child: ClipPath(
          clipper: CustomBottomBarClipper(topRadius: 20.0, bottomRadius: 30.0),
          child: CurvedNavigationBar(
            index: activeIndex,
            height: 75.0,
            color: AppColors.homeBottomBar,
            buttonBackgroundColor: AppColors.homeBottomBar,
            backgroundColor: Colors.white,
            animationCurve: Curves.easeInOut,
            animationDuration: const Duration(milliseconds: 300),

            items: <Widget>[
              activeIndex == 0
                  ? const Icon(
                Icons.home_rounded,
                size: 28,
                color: AppColors.white,
              )
                  : _navItem(
                icon: FontAwesomeIcons.house,
                title: AppStrings.tabHome,
              ),

              activeIndex == 1
                  ? const FaIcon(
                FontAwesomeIcons.solidHeart,
                size: 28,
                color: AppColors.white,
              )
                  : _navItem(
                icon: FontAwesomeIcons.heart,
                title: AppStrings.tabFavorite,
              ),

              activeIndex == 2
                  ? const FaIcon(
                FontAwesomeIcons.gear,
                size: 28,
                color: AppColors.white,
              )
                  : _navItem(
                icon: FontAwesomeIcons.gear,
                title: AppStrings.tabSettings,
              ),
            ],

            onTap: (index) {
              appState.changeTab(index);
            },
          ),
        ),
      ),
    );
  }
}

class CustomBottomBarClipper extends CustomClipper<Path> {
  final double topRadius;
  final double bottomRadius;

  CustomBottomBarClipper({
    this.topRadius = 20.0,
    this.bottomRadius = 30.0,
  });

  @override
  Path getClip(Size size) {
    final path = Path();
    final tr = topRadius;
    final br = bottomRadius;
    final h = size.height;
    final w = size.width;

    // Start at left middle (below top-left corner)
    path.moveTo(0, tr);
    
    // Top-left corner
    path.quadraticBezierTo(0, 0, tr, 0);
    
    // Go straight up to clear the floating active button
    path.lineTo(tr, -55);
    
    // Go across to the right side
    path.lineTo(w - tr, -55);
    
    // Go straight down to the top-right corner start
    path.lineTo(w - tr, 0);
    
    // Top-right corner
    path.quadraticBezierTo(w, 0, w, tr);
    
    // Line to bottom-right corner start
    path.lineTo(w, h - br);
    
    // Bottom-right corner
    path.quadraticBezierTo(w, h, w - br, h);
    
    // Line to bottom-left corner start
    path.lineTo(br, h);
    
    // Bottom-left corner
    path.quadraticBezierTo(0, h, 0, h - br);
    
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
