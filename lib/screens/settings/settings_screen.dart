import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/colors.dart';
import '../../widgets/dialog/custom_app_dialog.dart';
import '../../utils/strings.dart';
import '../../utils/text_app.dart';
import 'feedback_screen.dart';
import 'privacy_policy_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _appVersion = '1.0.0';

  // Common Play Store Base URL for sharing and rating (easy to modify in the future)
  static const String _playStoreBaseUrl = 'https://play.google.com/store/apps/details?id=';
  
  // Common Default Fallback Package ID (used if dynamic package info is unavailable)
  static const String _fallbackPackageId = 'com.aivideoprompt';
  
  // Common Default Fallback Full Play Store URL
  static const String _fallbackPlayStoreUrl = '$_playStoreBaseUrl$_fallbackPackageId';

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
      debugPrint('Error fetching app version: $e');
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
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => CustomAppDialog(
        title: AppStrings.ratingDialogTitle,
        subtitle: AppStrings.ratingDialogSubtitle,
        icon: Icons.star_rounded,
        primaryButtonText: AppStrings.ratingDialogSubmit,
        showCloseButton: true,
        showRatingStars: true,
        onRatingSubmit: (rating) async {
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
              debugPrint('Error opening Play Store from feedback: $e');
            }
          } else {
            // 1-3 stars → open Feedback screen
            if (context.mounted) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FeedbackScreen(rating: rating),
                ),
              );
            }
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0, bottom: 120.0),
      children: [
        _buildHeaderCard(),
        const SizedBox(height: 20),
        _buildSettingsGroup(
          items: [
            _buildSettingsTile(
              icon: Icons.share_rounded,
              title: AppStrings.settingsShareApp,
              onTap: () async {
                try {
                  final packageInfo = await PackageInfo.fromPlatform();
                  final appUrl = '$_playStoreBaseUrl${packageInfo.packageName}';
                  await SharePlus.instance.share(
                    ShareParams(
                      text: '${AppStrings.settingsShareMessage}$appUrl',
                    ),
                  );
                } catch (e) {
                  debugPrint('Error sharing app: $e');
                  // Fallback share logic if package info fails
                  await SharePlus.instance.share(
                    ShareParams(
                      text: '${AppStrings.settingsShareMessage}$_fallbackPlayStoreUrl',
                    ),
                  );
                }
              },
            ),
            _buildSettingsTile(
              icon: Icons.star_outline_rounded,
              title: AppStrings.settingsRateApp,
              onTap: () => _showRatingDialog(context),
            ),
            _buildSettingsTile(
              icon: Icons.feedback_outlined,
              title: AppStrings.settingsFeedback,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FeedbackScreen()),
                );
              },
              showDivider: false,
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildSettingsGroup(
          items: [
            _buildSettingsTile(
              icon: Icons.lock_outline_rounded,
              title: AppStrings.settingsPrivacyPolicy,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PrivacyPolicyScreen()),
                );
              },
            ),
            _buildSettingsTile(
              icon: Icons.info_outline_rounded,
              title: AppStrings.settingsAppVersion,
              trailing: Text(
                _appVersion,
                style: AppTextStyles.getStyle(
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
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
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.secondary,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.15),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.25),
              shape: BoxShape.circle,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(40),
              child: Image.asset(
                'assets/images/logo.png',
                width: 60,
                height: 60,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.appName,
                  style: AppTextStyles.getStyle(
                    color: AppColors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppStrings.settingsHeaderSubtitle,
                  style: AppTextStyles.getStyle(
                    color: AppColors.white.withValues(alpha: 0.75),
                    fontSize: 12,
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

  Widget _buildSettingsGroup({
    required List<Widget> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppColors.border.withValues(alpha: 0.45),
              width: 1,
            ),
          ),
          child: Column(
            children: items,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
    bool showDivider = true,
  }) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          title: Text(
            title,
            style: AppTextStyles.getStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          trailing: trailing ?? const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: 22),
          onTap: onTap,
        ),
        if (showDivider)
          Padding(
            padding: const EdgeInsets.only(left: 64.0, right: 20.0),
            child: Divider(
              height: 1,
              thickness: 0.8,
              color: AppColors.border.withValues(alpha: 0.4),
            ),
          ),
      ],
    );
  }
}
