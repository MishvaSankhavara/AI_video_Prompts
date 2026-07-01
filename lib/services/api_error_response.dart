import 'package:aivideoprompt/widgets/text_app.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../utils/colors.dart';
import '../utils/strings.dart';

/// Shared error state shown whenever an API call fails.
///
/// It distinguishes a "no internet" failure (inferred from the error text) from
/// a generic server/parse error, and offers a retry button. Use this everywhere
/// an API call can fail instead of duplicating an error column per screen.
class ApiErrorResponse extends StatelessWidget {
  /// The raw error message from the view model / service.
  final String message;

  /// Called when the user taps "Try Again".
  final VoidCallback onRetry;

  const ApiErrorResponse({
    super.key,
    required this.message,
    required this.onRetry,
  });

  /// Heuristic: did this failure come from a lost / missing connection?
  static bool isNoInternet(String message) {
    final m = message.toLowerCase();
    return m.contains('socketexception') ||
        m.contains('failed host lookup') ||
        m.contains('network is unreachable') ||
        m.contains('no address associated with hostname') ||
        m.contains('connection refused') ||
        m.contains('connection timed out') ||
        m.contains('connection closed') ||
        m.contains('os error');
  }

  @override
  Widget build(BuildContext context) {
    final bool noInternet = isNoInternet(message);

    final icon = noInternet
        ? FontAwesomeIcons.wifi
        : FontAwesomeIcons.triangleExclamation;
    final String title = noInternet
        ? AppStrings.noInternetTitle
        : AppStrings.apiErrorTitle;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.r),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(icon, size: 64.sp, color: AppColors.textMuted),
            SizedBox(height: 16.h),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.getStyle(
                color: AppColors.textPrimary,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 24.h),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
              ),
              child: Text(AppStrings.tryAgain),
            ),
          ],
        ),
      ),
    );
  }
}
