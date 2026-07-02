import 'package:aivideoprompt/widgets/text_app.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/app_update_service.dart';
import '../../services/navigation_service.dart';
import '../../utils/colors.dart';
import '../../utils/strings.dart';
import '../../viewmodel/fetch_video_category.dart';
import '../../widgets/common_app_bar.dart';
import '../../widgets/dialog/custom_app_dialog.dart';
import '../../services/fcm_service.dart';
import '../pro/pro_screen.dart';
import '../settings/settings_screen.dart';
import '../category/category_details_screen.dart';
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
    FcmService.instance.setupNotificationListener(context);

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
                padding: EdgeInsets.only(right: 16.w),
                child: Image.asset(
                  'assets/images/img_pro_btn.png',
                  width: 32.w,
                  height: 32.h,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ],
        ),
        body: _bodyForIndex(_currentIndex),
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
        padding: EdgeInsets.only(left: 20.w, right: 20.w, bottom: 16.h),
        child: Container(
          height: 64.h,
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(35.r),
            border: Border.all(color: AppColors.border, width: 1.w),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.05),
                blurRadius: 16.r,
                offset: Offset(0.w, 6.h),
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
                    top: 6.h,
                    bottom: 6.h,
                    width: tabWidth,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(30.r),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          width: 0.5.w,
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
          style: GoogleFonts.poppins(
            color: color,
            fontSize: isActive ? 12 : 11,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween<double>(
                  begin: isActive ? 1 : 0,
                  end: isActive ? 1 : 0,
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
                    height: 22.h + (2 * value),
                    width: 22.w + (2 * value),
                    fit: BoxFit.contain,
                  );
                },
              ),
              SizedBox(height: 4.h),
              AppText(text),
            ],
          ),
        ),
      ),
    );
  }
}
