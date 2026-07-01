import 'dart:io';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
// import '../../services/analytics_service.dart';
import '../../utils/colors.dart';
import '../../utils/common_utils.dart';
import '../../widgets/dialog/custom_app_dialog.dart';
import '../../utils/strings.dart';
import '../../widgets/text_app.dart';
import 'feedback_screen.dart';
import 'privacy_policy_screen.dart';
import 'terms_of_use_screen.dart';
import '../../services/navigation_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _appVersion = '1.00';

  // Common Play Store Base URL for sharing and rating (easy to modify in the future)
  static const String _playStoreBaseUrl =
      'https://play.google.com/store/apps/details?id=';

  // Common Default Fallback Package ID (used if dynamic package info is unavailable)
  static const String _fallbackPackageId = 'com.aivideoprompt';

  // Common Default Fallback Full Play Store URL
  static const String _fallbackPlayStoreUrl =
      '$_playStoreBaseUrl$_fallbackPackageId';

  @override
  void initState() {
    super.initState();
    _initAppVersion();
  }

  Future<void> _initAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() {
          _appVersion = packageInfo.version;
        });
      }
    } catch (e) {
      // CommonUtils.printLog('Error fetching app version: $e');
    }
  }

  void _showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showRatingDialog(BuildContext context) {
    /* AnalyticsService.instance.logEvent(name: 'rate_app_dialog_viewed'); */
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => CustomAppDialog(
        title: AppStrings.ratingDialogTitle,
        subtitle: AppStrings.ratingDialogSubtitle,
        icon: FontAwesomeIcons.solidStar,
        primaryButtonText: AppStrings.ratingDialogSubmit,
        showCloseButton: true,
        showRatingStars: true,
        onRatingSubmit: (rating) async {
          /* AnalyticsService.instance.logEvent(
            name: 'rate_app_submit',
            parameters: {'rating': rating},
          ); */
          if (rating >= 4) {
            // 4 or 5 stars → open Play Store
            try {
              final packageInfo = await PackageInfo.fromPlatform();
              final appUrl = '$_playStoreBaseUrl${packageInfo.packageName}';
              final uri = Uri.parse(appUrl);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              } else {
                if (context.mounted) {
                  _showSnackbar(context, AppStrings.settingsPlayStoreError);
                }
              }
            } catch (e) {
              // CommonUtils.printLog(
              //   'Error opening Play Store from feedback: $e',
              // );
            }
          } else {
            // 1-3 stars → open Feedback screen
            if (context.mounted) {
              NavigationService.push(context, FeedbackScreen(rating: rating));
            }
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.only(
        left: 20.w,
        right: 20.w,
        top: 20.h,
        bottom: 120.h,
      ),
      children: [
        _buildHeaderCard(),
        SizedBox(height: 20.h),
        _buildSettingsGroup(
          items: [
            _buildSettingsTile(
              imagePath: 'assets/images/ic_share.png',
              title: AppStrings.settingsShareApp,
              onTap: () async {
                /* AnalyticsService.instance.logEvent(name: 'share_app_tapped'); */
                try {
                  final packageInfo = await PackageInfo.fromPlatform();
                  final appUrl = '$_playStoreBaseUrl${packageInfo.packageName}';
                  await SharePlus.instance.share(
                    ShareParams(
                      text: '${AppStrings.settingsShareMessage}$appUrl',
                    ),
                  );
                } catch (e) {
                  // CommonUtils.printLog('Error sharing app: $e');
                  // Fallback share logic if package info fails
                  await SharePlus.instance.share(
                    ShareParams(
                      text:
                          '${AppStrings.settingsShareMessage}$_fallbackPlayStoreUrl',
                    ),
                  );
                }
              },
            ),
            _buildSettingsTile(
              imagePath: 'assets/images/ic_rate.png',
              title: AppStrings.settingsRateApp,
              onTap: () => _showRatingDialog(context),
            ),
            _buildSettingsTile(
              imagePath: 'assets/images/ic_feedback.png',
              title: AppStrings.settingsFeedback,
              onTap: () {
                NavigationService.push(context, const FeedbackScreen());
              },
              showDivider: false,
            ),
          ],
        ),
        SizedBox(height: 16.h),
        _buildSettingsGroup(
          items: [
            _buildSettingsTile(
              imagePath: 'assets/images/ic_privacy_policy.png',
              title: AppStrings.settingsPrivacyPolicy,
              onTap: () {
                NavigationService.push(context, const PrivacyPolicyScreen());
              },
            ),
            if (Platform.isIOS)
              _buildSettingsTile(
                imagePath: 'assets/images/ic_privacy_policy.png',
                title: AppStrings.settingsTermsOfUse,
                onTap: () {
                  NavigationService.push(context, const TermsOfUseScreen());
                },
              ),
            _buildSettingsTile(
              imagePath: 'assets/images/ic_app_version.png',
              title: AppStrings.settingsAppVersion,
              trailing: Text(
                _appVersion,
                style: AppTextStyles.getStyle(
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.bold,
                  fontSize: 14.sp,
                ),
              ),
              showDivider: false,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.secondary],
        ),
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.15),
            blurRadius: 15.r,
            offset: Offset(0.w, 8.h),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(4.r),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.25),
              shape: BoxShape.circle,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(40.r),
              child: Image.asset(
                'assets/images/logo.png',
                width: 60.w,
                height: 60.h,
                fit: BoxFit.contain,
              ),
            ),
          ),
          SizedBox(width: 20.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.appName,
                  style: AppTextStyles.getStyle(
                    color: AppColors.white,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.3,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  AppStrings.settingsHeaderSubtitle,
                  style: AppTextStyles.getStyle(
                    color: AppColors.white.withValues(alpha: 0.75),
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsGroup({required List<Widget> items}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(
              color: AppColors.border.withValues(alpha: 0.45),
              width: 1.w,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          // Material carries the background so the ListTiles paint their
          // ink/splashes on it (a colored DecoratedBox here would hide them).
          child: Material(
            color: AppColors.cardBackground,
            child: Column(children: items),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsTile({
    required String imagePath,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
    bool showDivider = true,
  }) {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.symmetric(
            horizontal: 20.w,
            vertical: 4.h,
          ),
          leading: Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Image.asset(
              imagePath,
              color: AppColors.primary,
              width: 20.w,
              height: 20.h,
              fit: BoxFit.contain,
            ),
          ),
          title: Text(
            title,
            style: AppTextStyles.getStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 15.sp,
            ),
          ),
          trailing:
              trailing ??
              FaIcon(
                FontAwesomeIcons.chevronRight,
                color: AppColors.textMuted,
                size: 18.sp,
              ),
          onTap: onTap,
        ),
        if (showDivider)
          Padding(
            padding: EdgeInsets.only(left: 64.w, right: 20.w),
            child: Divider(
              height: 1.h,
              thickness: 0.8,
              color: AppColors.border.withValues(alpha: 0.4),
            ),
          ),
      ],
    );
  }
}
