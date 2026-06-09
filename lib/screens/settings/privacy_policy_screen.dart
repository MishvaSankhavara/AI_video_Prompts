import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/colors.dart';
import '../../utils/text_app.dart';
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

  static const String _privacyPolicyUrl = '';

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
              debugPrint('WebView Error: \${error.description}');
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
        debugPrint('Could not launch $_privacyPolicyUrl');
      }
    } catch (e) {
      debugPrint('Error launching url: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainBackground,
      appBar: const CommonAppBar(
        title: 'Privacy Policy',
      ),
      body: _privacyPolicyUrl.isEmpty
          // No URL set yet — show coming soon placeholder
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.cardBackground,
                      ),
                      child: const Icon(
                        Icons.lock_outline_rounded,
                        size: 40,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Privacy Policy',
                      style: AppTextStyles.getStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Our privacy policy will be available here soon. Thank you for your patience!',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.getStyle(
                        color: AppColors.textMuted,
                        fontSize: 14,
                        height: 1.5,
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
                      const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                        ),
                      ),
                  ],
                )
              : Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.language_rounded,
                          size: 72,
                          color: AppColors.textMuted,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'View Privacy Policy Online',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.getStyle(
                            color: AppColors.textPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'This device or platform does not support inline web browsing. Tapping the button below will open our privacy policy website in your system browser.',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.getStyle(
                            color: AppColors.textMuted,
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton.icon(
                          onPressed: _launchUrl,
                          icon: const Icon(Icons.open_in_browser_rounded, color: Colors.white),
                          label: Text(
                            'Open Policy Website',
                            style: AppTextStyles.getStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
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
