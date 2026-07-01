import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utils/common_utils.dart';
import '../utils/strings.dart';
import '../widgets/dialog/custom_app_dialog.dart';

/// Checks whether a newer build is live on the store and, if so, shows the
/// update dialog. The "latest" version is read from the actual store (Play
/// Store on Android, App Store on iOS) — never hardcoded — so the prompt only
/// appears when an update genuinely exists.
class AppUpdateService {
  AppUpdateService._();

  static Future<void> checkForUpdate(BuildContext context) async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      String? storeVersion;
      String? storeUrl;

      if (Platform.isAndroid) {
        storeVersion = await _getPlayStoreVersion(packageInfo.packageName);
        storeUrl = '${AppStrings.playStoreBaseUrl}${packageInfo.packageName}';
      } else if (Platform.isIOS && AppStrings.appStoreId.isNotEmpty) {
        final result = await _getAppStoreVersion(AppStrings.appStoreId);
        storeVersion = result['version'];
        storeUrl = result['url'];
      }

      if (!context.mounted) return;

      if (storeVersion != null &&
          storeUrl != null &&
          _shouldUpdate(currentVersion, storeVersion)) {
        // CommonUtils.printLog(
        //   'AppUpdateService: update available ($currentVersion -> $storeVersion)',
        // );
        _showUpdateDialog(context, storeUrl);
      }
    } catch (e) {
      // CommonUtils.printLog('AppUpdateService: update check failed: $e');
    }
  }

  /// Scrapes the Play Store listing HTML for the current version.
  static Future<String?> _getPlayStoreVersion(String packageId) async {
    try {
      final url =
          'https://play.google.com/store/apps/details?id=$packageId&hl=en&gl=US';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent':
              'Mozilla/5 (Windows NT 10; Win64; x64) AppleWebKit/537.36',
        },
      );

      if (response.statusCode != 200) return null;
      final body = response.body;

      final patterns = [
        RegExp(r'\[\["([0-9.]+)"\]\]'),
        RegExp(r'Current Version.*?>([\d.]+)<'),
        RegExp(r'"softwareVersion":"([\d.]+)"'),
        RegExp(r'htlgb">\s*([\d.]+)\s*<'),
      ];

      for (final pattern in patterns) {
        final match = pattern.firstMatch(body);
        if (match != null && match.groupCount > 0) {
          return match.group(1);
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Looks up the App Store version via the iTunes lookup API.
  static Future<Map<String, String?>> _getAppStoreVersion(String appId) async {
    try {
      final url = 'https://itunes.apple.com/lookup?id=$appId';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final json = response.body;
        final versionMatch = RegExp(r'"version":"([^"]+)"').firstMatch(json);
        final urlMatch = RegExp(r'"trackViewUrl":"([^"]+)"').firstMatch(json);
        return {'version': versionMatch?.group(1), 'url': urlMatch?.group(1)};
      }
      return {'version': null, 'url': null};
    } catch (e) {
      return {'version': null, 'url': null};
    }
  }

  /// Returns true only when [storeVersion] is strictly newer than [current].
  static bool _shouldUpdate(String current, String storeVersion) {
    try {
      final currentParts = current.split('.').map(int.parse).toList();
      final storeParts = storeVersion.split('.').map(int.parse).toList();

      while (currentParts.length < storeParts.length) {
        currentParts.add(0);
      }
      while (storeParts.length < currentParts.length) {
        storeParts.add(0);
      }

      for (int i = 0; i < currentParts.length; i++) {
        if (storeParts[i] > currentParts[i]) return true;
        if (storeParts[i] < currentParts[i]) return false;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  static void _showUpdateDialog(BuildContext context, String storeUrl) {
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
        onPrimaryPressed: () {
          Navigator.pop(context);
          _launchStore(storeUrl);
        },
        onSecondaryPressed: () => Navigator.pop(context),
      ),
    );
  }

  static Future<void> _launchStore(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      // CommonUtils.printLog('AppUpdateService: could not launch store: $e');
    }
  }
}
