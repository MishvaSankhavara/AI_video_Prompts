import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/colors.dart';
import '../../widgets/dialog/custom_app_dialog.dart';
import '../../utils/strings.dart';
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
                  _showSnackbar(context, 'Could not open Play Store.');
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
      padding: const EdgeInsets.all(24.0),
      children: [
        _buildSettingsItem(
          context: context,
          icon: Icons.share_rounded,
          title: 'Share App',
          onTap: () async {
            try {
              final packageInfo = await PackageInfo.fromPlatform();
              final appUrl = '$_playStoreBaseUrl${packageInfo.packageName}';
              await SharePlus.instance.share(
                ShareParams(
                  text: 'Check out this amazing AI Video Prompt app: $appUrl',
                ),
              );
            } catch (e) {
              debugPrint('Error sharing app: $e');
              // Fallback share logic if package info fails
              await SharePlus.instance.share(
                ShareParams(
                  text: 'Check out this amazing AI Video Prompt app: $_fallbackPlayStoreUrl',
                ),
              );
            }
          },
        ),
        _buildSettingsItem(
          context: context,
          icon: Icons.star_outline_rounded,
          title: 'Rate App',
          onTap: () => _showRatingDialog(context),
        ),
        _buildSettingsItem(
          context: context,
          icon: Icons.lock_outline_rounded,
          title: 'Privacy Policy',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PrivacyPolicyScreen()),
            );
          },
        ),
        _buildSettingsItem(
          context: context,
          icon: Icons.feedback_outlined,
          title: 'Feedback',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FeedbackScreen()),
            );
          },
        ),
        _buildSettingsItem(
          context: context,
          icon: Icons.info_outline_rounded,
          title: 'App Version',
          subtitle: _appVersion,
          onTap: () {
            _showSnackbar(context, 'You are on the latest version!');
          },
        ),
      ],
    );
  }

  Widget _buildSettingsItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      color: AppColors.cardBackground,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: subtitle != null ? Text(subtitle, style: const TextStyle(color: AppColors.textMuted)) : null,
        trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
        onTap: onTap,
      ),
    );
  }
}
