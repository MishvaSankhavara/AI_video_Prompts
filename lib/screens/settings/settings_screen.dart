import 'dart:io';
import 'package:aivideoprompt/utils/images.dart';
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
import '../../widgets/dialog/support_login_dialog.dart';
import '../../services/navigation_service.dart';
import '../pro/pro_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _appVersion = '1.0.0';

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
                  CommonUtils.showToast(AppStrings.settingsPlayStoreError);
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
        bottom: 90.h,
      ),
      children: [
        _buildHeaderCard(),
        SizedBox(height: 20.h),
        _buildSettingsGroup(
          items: [
            _buildSettingsTile(
              imagePath: ImageUtils.icShare,
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
              imagePath: ImageUtils.icRate,
              title: AppStrings.settingsRateApp,
              onTap: () => _showRatingDialog(context),
            ),
            _buildSettingsTile(
              imagePath: ImageUtils.icFeedback,
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
              imagePath: ImageUtils.icPrivacyPolicy,
              title: AppStrings.settingsPrivacyPolicy,
              onTap: () {
                NavigationService.push(context, const PrivacyPolicyScreen());
              },
            ),
            if (Platform.isIOS)
              _buildSettingsTile(
                imagePath: ImageUtils.icPrivacyPolicy,
                title: AppStrings.settingsTermsOfUse,
                onTap: () {
                  NavigationService.push(context, const TermsOfUseScreen());
                },
              ),
            _buildSettingsTile(
              imagePath: ImageUtils.icFeedback,
              title: AppStrings.settingsSupport,
              onTap: () {
                showDialog(
                  context: context,
                  barrierDismissible: true,
                  builder: (context) => const SupportLoginDialog(),
                );
              },
            ),
            _buildSettingsTile(
              imagePath: ImageUtils.icCrown,
              title: AppStrings.settingsCancelSubscription,
              // onTap:
              // () async {
              //   try {
              //     final packageInfo = await PackageInfo.fromPlatform();
              //     final String url = Platform.isAndroid
              //       ? 'https://play.google.com/store/account/subscriptions?package=${packageInfo.packageName}'
              //       : 'https://apps.apple.com/account/subscriptions';
              //     final uri = Uri.parse(url);
              //     if (await canLaunchUrl(uri)) {
              //       await launchUrl(uri, mode: LaunchMode.externalApplication);
              //     }
              //   } catch (e) {
              //     // Ignore
              //   }
              // },
            ),
            _buildSettingsTile(
              imagePath: ImageUtils.icAppVersion,
              title: AppStrings.settingsAppVersion,
              trailing: AppText(
                _appVersion,
                textColor: AppColors.textMuted,
                textWeight: FontWeight.bold,
                textSize: 14.sp,
              ),
              showDivider: false,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeaderCard() {
    return GestureDetector(
      onTap: () {
        NavigationService.push(context, const ProScreen());
      },
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.buttonGradientStart, AppColors.buttonGradientEnd],
          ),
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.4),
              blurRadius: 20.r,
              offset: Offset(0.w, 10.h),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Decorative background shapes
            Positioned(
              top: -30.h,
              right: -20.w,
              child: Container(
                width: 120.w,
                height: 120.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.white.withOpacity(0.08),
                ),
              ),
            ),
            Positioned(
              bottom: -40.h,
              right: 80.w,
              child: Container(
                width: 80.w,
                height: 80.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.white.withOpacity(0.05),
                ),
              ),
            ),
            // Card Content
            Padding(
              padding: EdgeInsets.all(24.w),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12.r),
                    decoration: BoxDecoration(
                      color: AppColors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.white.withOpacity(0.3),
                        width: 1.w,
                      ),
                    ),
                    child: Image.asset(
                      ImageUtils.icCrown,
                      width: 32.w,
                      height: 32.h,
                      color: AppColors.amber500, // Premium Gold
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(width: 20.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(
                          AppStrings.proUnlockPremium,
                          textColor: AppColors.amber500, // Premium Gold
                          textSize: 18.sp,
                          textWeight: FontWeight.w800,
                          lettersSpace: 0.5,
                        ),
                        SizedBox(height: 6.h),
                        AppText(
                          AppStrings.settingsProSubtitle,
                          textColor: AppColors.white.withOpacity(0.9),
                          textSize: 13.sp,
                          textWeight: FontWeight.w500,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(8.r),
                    decoration: BoxDecoration(
                      color: AppColors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: AppColors.white,
                      size: 16.sp,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
          contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 4.h),
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
          title: AppText(
            title,
            textColor: AppColors.textPrimary,
            textWeight: FontWeight.w600,
            textSize: 15.sp,
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
