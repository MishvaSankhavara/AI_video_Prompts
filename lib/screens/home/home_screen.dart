import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../adsmanager/interstitial_ad_service.dart';
import '../../adsmanager/ad_ids.dart';
import '../../services/app_state.dart';
// import '../../services/analytics_service.dart';
import '../../services/navigation_service.dart';
import '../../utils/colors.dart';
import '../../utils/common_utils.dart';
import '../../utils/strings.dart';
import '../../widgets/prompt_grid_card.dart';
import '../../widgets/shimmer_grid_card.dart';
import '../../widgets/dialog/custom_app_dialog.dart';
import '../category/category_details_screen.dart';
import '../../widgets/common_app_bar.dart';
import '../pro/pro_screen.dart';
import '../../utils/text_app.dart';
import 'home_bottom_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  int _previousIndex = 0;

  @override
  void initState() {
    super.initState();
WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Provider.of<AppState>(context, listen: false).loadCategories();
      _checkForUpdates();
    });
  }

  Future<void> _checkForUpdates() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;
      
      // Let's assume the latest version is '1.1.0' (or a remote value).
      // Since local version will usually be '1.0.0' or '1.0.0+1', this will trigger the dialog.
      // This is perfect for demonstration and testing of update flow!
      const String latestVersion = '1.1.0';
      
      if (_isVersionOlder(currentVersion, latestVersion)) {
        if (!mounted) return;
        _showUpdateDialog();
      }
    } catch (e) {
      CommonUtils.printLog('Error checking for app updates: $e');
    }
  }

  bool _isVersionOlder(String current, String latest) {
    try {
      final currentParts = current.split('.').map(int.parse).toList();
      final latestParts = latest.split('.').map(int.parse).toList();
      
      for (int i = 0; i < latestParts.length; i++) {
        final currentVal = i < currentParts.length ? currentParts[i] : 0;
        final latestVal = latestParts[i];
        if (latestVal > currentVal) return true;
        if (latestVal < currentVal) return false;
      }
    } catch (_) {
      return current != latest;
    }
    return false;
  }

  void _showUpdateDialog() {
    /* AnalyticsService.instance.logEvent(name: 'app_update_dialog_viewed'); */
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => CustomAppDialog(
        title: AppStrings.updateDialogTitle,
        subtitle: AppStrings.updateDialogSubtitle,
        icon: FontAwesomeIcons.cloudArrowDown,
        primaryButtonText: AppStrings.updateDialogPrimary,
        secondaryButtonText: AppStrings.updateDialogSecondary,
        showCloseButton: true,
        onPrimaryPressed: () async {
          /* AnalyticsService.instance.logEvent(
            name: 'app_update_action',
            parameters: {'action': 'update_now'},
          ); */
          Navigator.pop(context);
          try {
            final packageInfo = await PackageInfo.fromPlatform();
            final uri = Uri.parse('${AppStrings.playStoreBaseUrl}${packageInfo.packageName}');
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            }
          } catch (e) {
            CommonUtils.printLog('Error launching play store: $e');
          }
        },
        onSecondaryPressed: () {
          /* AnalyticsService.instance.logEvent(
            name: 'app_update_action',
            parameters: {'action': 'remind_later'},
          ); */
          Navigator.pop(context);
        },
      ),
    );
  }

  Future<bool> _showExitDialog() async {
    /* AnalyticsService.instance.logEvent(name: 'exit_dialog_viewed'); */
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) => CustomAppDialog(
        title: AppStrings.exitDialogTitle ?? 'Exit App',
        subtitle: AppStrings.exitDialogSubtitle ?? 'Are you sure you want to exit?',
        icon: FontAwesomeIcons.doorOpen,
        primaryButtonText: AppStrings.exitDialogPrimary ?? 'Exit',
        secondaryButtonText: AppStrings.exitDialogSecondary ?? 'Cancel',
        showCloseButton: false,
        onPrimaryPressed: () {
          /* AnalyticsService.instance.logEvent(
            name: 'exit_app_action',
            parameters: {'action': 'exit'},
          ); */
          Navigator.pop(context, true);
        },
        onSecondaryPressed: () {
          /* AnalyticsService.instance.logEvent(
            name: 'exit_app_action',
            parameters: {'action': 'cancel'},
          ); */
          Navigator.pop(context, false);
        },
      ),
    );
    return result ?? false;
  }

  String _getAppBarTitle(int tabIndex) {
    switch (tabIndex) {
      case 0:
        return AppStrings.homeTitle;
      case 1:
        return AppStrings.tabFavorite;
      case 2:
        return AppStrings.tabSettings;
      default:
        return AppStrings.homeTitle;
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    
    if (appState.currentTabIndex != _currentIndex) {
      _previousIndex = _currentIndex;
      _currentIndex = appState.currentTabIndex;
    }

    return WillPopScope(
      onWillPop: () async {
        final state = Provider.of<AppState>(context, listen: false);
        // If not on Home tab, go back to Home tab first
        if (state.currentTabIndex != 0) {
          state.changeTab(0);
          return false;
        }
        // If on Home tab, show exit dialog
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
            child: SlideTransition(
              position: offsetAnimation,
              child: child,
            ),
          );
        },
        child: KeyedSubtree(
          key: ValueKey<int>(_currentIndex),
          child: CustomBottomBar.getBody(appState),
        ),
      ),
      bottomNavigationBar: const CustomBottomBar(),
    ),
    );
  }
}

class HomeTabBody extends StatelessWidget {
  const HomeTabBody({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    if (appState.isLoadingCategories) {
      return GridView.builder(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 150),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.70, // Matches 9:16 layout ratio
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: 6,
        itemBuilder: (context, index) => const ShimmerGridCard(),
      );
    }

    if (appState.apiError.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const FaIcon(FontAwesomeIcons.triangleExclamation, size: 64, color: AppColors.textMuted),
              const SizedBox(height: 16),
              Text(
                appState.apiError,
                textAlign: TextAlign.center,
                style: AppTextStyles.getStyle(color: AppColors.textPrimary, fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => appState.loadCategories(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    if (appState.categories.isEmpty) {
      return Center(
        child: Text(
          'No categories available.',
          style: AppTextStyles.getStyle(color: AppColors.textMuted),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 150),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.70, // Matches 9:16 layout ratio
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: appState.categories.length,
      itemBuilder: (context, index) {
        final category = appState.categories[index];
        if (category.items.isEmpty) {
          return const SizedBox.shrink();
        }
        final firstItem = category.items.first;
        final isPremium = index == 0 || index == 1; // Mark some as premium

        return PromptGridCard(
          item: firstItem,
          categoryName: category.categoryName,
          isPremium: isPremium,
          onTap: () {
            // Show interstitial ad then navigate to category details
            InterstitialAdService.showAd(
              context: context,
              customAdIds: [AdIds.interHomelHF1, AdIds.interHomeLF1],
              screenName: 'HomeScreen',
              onAdClosed: () {
                NavigationService.push(
                  context,
                  CategoryDetailsScreen(
                    categoryId: category.categoryId,
                    categoryName: category.categoryName,
                  ),
                );
              },
              onAdFailedToShow: () {
                NavigationService.push(
                  context,
                  CategoryDetailsScreen(
                    categoryId: category.categoryId,
                    categoryName: category.categoryName,
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
