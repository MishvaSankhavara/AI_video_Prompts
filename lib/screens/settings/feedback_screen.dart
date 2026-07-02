import 'package:aivideoprompt/widgets/text_app.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
// import '../../services/analytics_service.dart';
import '../../utils/colors.dart';
import '../../utils/strings.dart';
import '../../widgets/common_app_bar.dart';
import '../../services/navigation_service.dart';
import 'package:google_fonts/google_fonts.dart';

class FeedbackScreen extends StatefulWidget {
  final int? rating;

  const FeedbackScreen({super.key, this.rating});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submitFeedback() async {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: AppText(AppStrings.feedbackEmpty),
          backgroundColor: AppColors.primary,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    /* AnalyticsService.instance.logEvent(
      name: 'feedback_submitted',
      parameters: {
        'rating': widget.rating ?? 0,
        'feedback_text_length': text.length,
      },
    ); */

    // Simulate submission delay
    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: AppText(AppStrings.feedbackThankYou),
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 2),
      ),
    );

    NavigationService.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainBackground,
      appBar: CommonAppBar(title: AppStrings.feedbackScreenTitle),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              AppStrings.feedbackWhatToImprove,
              textColor: AppColors.textPrimary,
              textSize: 17.sp,
              textWeight: FontWeight.w600,
            ),
            SizedBox(height: 12.h),
            // Text area
            Container(
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: TextField(
                controller: _controller,
                maxLines: 7,
                maxLength: 500,
                style: GoogleFonts.poppins(
                  color: AppColors.textPrimary,
                  fontSize: 15.sp,
                ),
                decoration: InputDecoration(
                  hintText: AppStrings.feedbackHint,
                  hintStyle: GoogleFonts.poppins(
                    color: AppColors.textMuted.withValues(alpha: 0.6),
                    fontSize: 15.sp,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16.r),
                  counterStyle: GoogleFonts.poppins(
                    color: AppColors.textMuted,
                    fontSize: 12.sp,
                  ),
                ),
              ),
            ),
            SizedBox(height: 28.h),
            // Submit button
            ScaleButton(
              onTap: _isSubmitting ? null : _submitFeedback,
              child: Container(
                width: double.infinity,
                height: 50.h,
                decoration: BoxDecoration(
                  gradient: _isSubmitting
                      ? null
                      : const LinearGradient(
                          colors: [
                            AppColors.buttonGradientStart,
                            AppColors.primary,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                  color: _isSubmitting ? AppColors.border : null,
                  borderRadius: BorderRadius.circular(30.r),
                  boxShadow: _isSubmitting
                      ? null
                      : [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.25),
                            blurRadius: 14.r,
                            offset: Offset(0.w, 6.h),
                          ),
                        ],
                ),
                alignment: Alignment.center,
                child: _isSubmitting
                    ? SizedBox(
                        height: 20.h,
                        width: 20.w,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.white,
                        ),
                      )
                    : AppText(
                        AppStrings.feedbackSubmit,
                        textSize: 16.sp,
                        textWeight: FontWeight.bold,
                        textColor: AppColors.white,
                        lettersSpace: 0.5,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ScaleButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;

  const ScaleButton({super.key, required this.child, this.onTap});

  @override
  State<ScaleButton> createState() => _ScaleButtonState();
}

class _ScaleButtonState extends State<ScaleButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(
      begin: 1,
      end: 0.96,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => widget.onTap != null ? _controller.forward() : null,
      onTapUp: (_) {
        if (widget.onTap != null) {
          _controller.reverse();
          widget.onTap!();
        }
      },
      onTapCancel: () => widget.onTap != null ? _controller.reverse() : null,
      child: ScaleTransition(scale: _scaleAnimation, child: widget.child),
    );
  }
}
