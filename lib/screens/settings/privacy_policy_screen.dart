import 'package:aivideoprompt/utils/strings.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
// import '../../services/analytics_service.dart';
import '../../utils/colors.dart';
import '../../utils/common_utils.dart';
import '../../widgets/text_app.dart';
import '../../widgets/common_app_bar.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  late final WebViewController _webViewController;
  bool _useWebView = false;
  bool _isLoading = true;

  static const String _privacyPolicyUrl = 'https://www.google.com';

  @override
  void initState() {
    super.initState();
    // If no URL is set yet, skip WebView entirely
    if (_privacyPolicyUrl.isEmpty) {
      _isLoading = false;
      return;
    }

    // Safely check if webview platform is registered (e.g. mobile platforms)
    try {
      if (WebViewPlatform.instance != null) {
        _useWebView = true;
      }
    } catch (e) {
      _useWebView = false;
    }

    if (_useWebView) {
      _webViewController = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(AppColors.mainBackground)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (String url) {
              if (mounted) {
                setState(() {
                  _isLoading = true;
                });
              }
            },
            onPageFinished: (String url) {
              if (mounted) {
                setState(() {
                  _isLoading = false;
                });
              }
            },
            onWebResourceError: (WebResourceError error) {
              // CommonUtils.printLog('WebView Error: ${error.description}');
            },
          ),
        )
        ..loadRequest(Uri.parse(_privacyPolicyUrl));
    } else {
      _isLoading = false;
    }
  }

  Future<void> _launchUrl() async {
    final uri = Uri.parse(_privacyPolicyUrl);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        // CommonUtils.printLog('Could not launch $_privacyPolicyUrl');
      }
    } catch (e) {
      // CommonUtils.printLog('Error launching url: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainBackground,
      appBar: const CommonAppBar(title: AppStrings.settingsPrivacyPolicy),
      body: _privacyPolicyUrl.isEmpty
          // No URL set yet — show coming soon placeholder
          ? Center(
              child: Padding(
                padding: EdgeInsets.all(32.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80.w,
                      height: 80.h,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.cardBackground,
                      ),
                      child: FaIcon(
                        FontAwesomeIcons.lock,
                        size: 40.sp,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(height: 24.h),
                    Text(
                      AppStrings.settingsPrivacyPolicy,
                      style: AppTextStyles.getStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      AppStrings.privacyPolicyComingSoon,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.getStyle(
                        color: AppColors.textMuted,
                        fontSize: 14.sp,
                        height: 1.5.h,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : _useWebView
          ? Stack(
              children: [
                WebViewWidget(controller: _webViewController),
                if (_isLoading)
                  Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                    ),
                  ),
              ],
            )
          : Center(
              child: Padding(
                padding: EdgeInsets.all(32.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FaIcon(
                      FontAwesomeIcons.globe,
                      size: 72.sp,
                      color: AppColors.textMuted,
                    ),
                    SizedBox(height: 24.h),
                    Text(
                      AppStrings.privacyPolicyViewOnline,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.getStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      AppStrings.privacyPolicyNoWebView,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.getStyle(
                        color: AppColors.textMuted,
                        fontSize: 14.sp,
                        height: 1.5.h,
                      ),
                    ),
                    SizedBox(height: 32.h),
                    ElevatedButton.icon(
                      onPressed: _launchUrl,
                      icon: const FaIcon(
                        FontAwesomeIcons.arrowUpRightFromSquare,
                        color: AppColors.white,
                      ),
                      label: Text(
                        AppStrings.privacyPolicyOpenWeb,
                        style: AppTextStyles.getStyle(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15.sp,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: EdgeInsets.symmetric(
                          horizontal: 24.w,
                          vertical: 14.h,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
