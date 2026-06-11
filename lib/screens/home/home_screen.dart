import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../adsmanager/ad_service.dart';
import '../../adsmanager/ad_ids.dart';
import '../../services/app_state.dart';
import '../../services/analytics_service.dart';
import '../../services/navigation_service.dart';
import '../../utils/colors.dart';
import '../../utils/common_utils.dart';
import '../../utils/strings.dart';
import '../../widgets/prompt_grid_card.dart';
import '../../widgets/shimmer_grid_card.dart';
import '../../widgets/dialog/custom_app_dialog.dart';
import '../category/category_details_screen.dart';
import '../../widgets/common_app_bar.dart';
import '../../utils/text_app.dart';
import 'home_bottom_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    AnalyticsService.instance.logScreenView(screenName: 'home_tab');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Provider.of<AppState>(context, listen: false).loadCategories();
      _checkForUpdates();
    });
    // Preload interstitial so it is ready when user taps a category item
    AdService.instance.loadInterstitialAd(
      highFloorId: AdIds.interHomelHF1,
      lowFloorId: AdIds.interHomeLF1,
    );
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
    AnalyticsService.instance.logEvent(name: 'app_update_dialog_viewed');
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
          AnalyticsService.instance.logEvent(
            name: 'app_update_action',
            parameters: {'action': 'update_now'},
          );
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
          AnalyticsService.instance.logEvent(
            name: 'app_update_action',
            parameters: {'action': 'remind_later'},
          );
          Navigator.pop(context);
        },
      ),
    );
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
    
    return Scaffold(
      backgroundColor: AppColors.mainBackground,
      extendBody: true,
      appBar: CommonAppBar(
        title: _getAppBarTitle(appState.currentTabIndex),
        showBackButton: false,
      ),
      body: CustomBottomBar.getBody(appState),
      bottomNavigationBar: const CustomBottomBar(),
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
            AdService.instance.showInterstitialAd(
              onAdDismissed: () {
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
