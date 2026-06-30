import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../../services/app_update_service.dart';
import '../../services/navigation_service.dart';
import '../../utils/colors.dart';
import '../../utils/strings.dart';
import '../../viewmodel/fetch_video_category.dart';
import '../../widgets/common_app_bar.dart';
import '../../widgets/dialog/custom_app_dialog.dart';
import '../pro/pro_screen.dart';
import '../settings/settings_screen.dart';
import 'favorite_screen.dart';
import 'home_screen.dart';

/// App shell: hosts the bottom navigation bar (Home, Favorites, Settings),
/// shows the screen for the selected tab, and runs the once-per-open startup
/// work (load categories, check for app updates).
class BottomNavBarScreen extends StatefulWidget {
  const BottomNavBarScreen({super.key});

  @override
  State<BottomNavBarScreen> createState() => _BottomNavBarScreenState();
}

class _BottomNavBarScreenState extends State<BottomNavBarScreen> {
  int _currentIndex = 0;
  int _previousIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Provider.of<FetchVideoCategoryViewModel>(
        context,
        listen: false,
      ).loadCategories();
      AppUpdateService.checkForUpdate(context);
    });
  }

  // ── Tab selection ────────────────────────────────────────────────────────
  void _onTabSelected(int index) {
    if (index == _currentIndex) return;
    setState(() {
      _previousIndex = _currentIndex;
      _currentIndex = index;
    });
  }

  Widget _bodyForIndex(int index) {
    switch (index) {
      case 1:
        return const FavoriteScreen();
      case 2:
        return const SettingsScreen();
      case 0:
      default:
        return const HomeScreen();
    }
  }

  String _getAppBarTitle(int tabIndex) {
    switch (tabIndex) {
      case 1:
        return AppStrings.tabFavorite;
      case 2:
        return AppStrings.tabSettings;
      case 0:
      default:
        return AppStrings.homeTitle;
    }
  }

  Future<bool> _showExitDialog() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) => CustomAppDialog(
        title: AppStrings.exitDialogTitle,
        subtitle: AppStrings.exitDialogSubtitle,
        icon: FontAwesomeIcons.doorOpen,
        primaryButtonText: AppStrings.exitDialogPrimary,
        secondaryButtonText: AppStrings.exitDialogSecondary,
        showCloseButton: false,
        onPrimaryPressed: () => Navigator.pop(context, true),
        onSecondaryPressed: () => Navigator.pop(context, false),
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // If not on Home tab, go back to Home tab first.
        if (_currentIndex != 0) {
          _onTabSelected(0);
          return false;
        }
        // If on Home tab, show exit dialog.
        return await _showExitDialog();
      },
      child: Scaffold(
        backgroundColor: AppColors.mainBackground,
        extendBody: true,
        appBar: CommonAppBar(
          title: _getAppBarTitle(_currentIndex),
          showBackButton: false,
          actions: [
            GestureDetector(
              onTap: () {
                NavigationService.push(context, const ProScreen());
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Image.asset(
                  'assets/images/img_crown.png',
                  width: 32,
                  height: 32,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ],
        ),
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeOutCubic,
          layoutBuilder: (Widget? currentChild, List<Widget> previousChildren) {
            return Stack(
              children: <Widget>[
                ...previousChildren,
                if (currentChild != null) currentChild,
              ],
            );
          },
          transitionBuilder: (Widget child, Animation<double> animation) {
            final key = child.key as ValueKey<int>?;
            final childIndex = key?.value ?? 0;
            final isIncoming = childIndex == _currentIndex;
            final isMovingRight = _currentIndex > _previousIndex;

            Offset beginOffset;
            if (isIncoming) {
              beginOffset = Offset(isMovingRight ? 0.3 : -0.3, 0.0);
            } else {
              beginOffset = Offset(isMovingRight ? -0.3 : 0.3, 0.0);
            }

            final offsetAnimation = Tween<Offset>(
              begin: beginOffset,
              end: Offset.zero,
            ).animate(animation);

            return FadeTransition(
              opacity: animation,
              child: SlideTransition(position: offsetAnimation, child: child),
            );
          },
          child: KeyedSubtree(
            key: ValueKey<int>(_currentIndex),
            child: _bodyForIndex(_currentIndex),
          ),
        ),
        bottomNavigationBar: _buildBottomBar(),
      ),
    );
  }

  // ── Bottom navigation bar ────────────────────────────────────────────────
  Widget _buildBottomBar() {
    final activeIndex = _currentIndex;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 16.0),
        child: Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(35.0),
            border: Border.all(color: AppColors.border, width: 1.0),
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
                  // Sliding indicator
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
                      ),
                      _buildTab(
                        index: 1,
                        activeIndex: activeIndex,
                        imagePath: 'assets/images/ic_like.png',
                        text: AppStrings.tabFavorite,
                        width: tabWidth,
                      ),
                      _buildTab(
                        index: 2,
                        activeIndex: activeIndex,
                        imagePath: 'assets/images/ic_settings.png',
                        text: AppStrings.tabSettings,
                        width: tabWidth,
                      ),
                    ],
                  ),
                ],
              );
            },
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
  }) {
    final isActive = index == activeIndex;
    final color = isActive ? AppColors.primary : AppColors.textMuted;

    return GestureDetector(
      onTap: () => _onTabSelected(index),
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
                tween: Tween<double>(
                  begin: isActive ? 1.0 : 0.0,
                  end: isActive ? 1.0 : 0.0,
                ),
                duration: const Duration(milliseconds: 300),
                curve: Curves.fastOutSlowIn,
                builder: (context, value, child) {
                  return Image.asset(
                    imagePath,
                    color: Color.lerp(
                      AppColors.textMuted,
                      AppColors.primary,
                      value,
                    ),
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
