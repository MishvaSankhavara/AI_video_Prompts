import 'package:flutter/material.dart';

import '../../main.dart';
import '../../utils/colors.dart';
import '../../utils/strings.dart';

/// A blocking, non-dismissible "loading" dialog (spinner + label) shown while
/// an ad is being fetched. Manages its own show/hide via the global
/// [navigatorKey] so services can call it without a [BuildContext].
class LoadingDialog extends StatelessWidget {
  final String text;

  const LoadingDialog({super.key, required this.text});

  static bool _isShowing = false;

  /// Shows the dialog with [text]. No-op if already showing or no navigator.
  static void show({String text = AppStrings.loadingAd}) {
    final context = navigatorKey.currentContext;
    if (context == null || _isShowing) return;

    _isShowing = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      builder: (_) => LoadingDialog(text: text),
    );
  }

  /// Dismisses the dialog if it's showing.
  static void hide() {
    final context = navigatorKey.currentContext;
    if (context == null || !_isShowing) return;

    _isShowing = false;
    Navigator.of(context, rootNavigator: true).pop();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Prevent dismissal via the back button.
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 38,
                height: 38,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  strokeWidth: 3.5,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                text,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.none,
                  fontFamily: 'Outfit',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
