import 'package:aivideoprompt/widgets/text_app.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../utils/colors.dart';

class CustomAppDialog extends StatefulWidget {
  final String title;
  final String subtitle;
  final FaIconData icon;
  final String primaryButtonText;
  final VoidCallback? onPrimaryPressed;
  final String? secondaryButtonText;
  final VoidCallback? onSecondaryPressed;
  final bool showCloseButton;
  final bool showRatingStars;
  final void Function(int rating)? onRatingSubmit;

  const CustomAppDialog({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon = FontAwesomeIcons.wandMagicSparkles,
    required this.primaryButtonText,
    this.onPrimaryPressed,
    this.secondaryButtonText,
    this.onSecondaryPressed,
    this.showCloseButton = false,
    this.showRatingStars = false,
    this.onRatingSubmit,
  });

  @override
  State<CustomAppDialog> createState() => _CustomAppDialogState();
}

class _CustomAppDialogState extends State<CustomAppDialog> {
  int _selectedRating = 0;

  @override
  Widget build(BuildContext context) {
    final bool isPrimaryDisabled =
        widget.showRatingStars && _selectedRating == 0;

    return Dialog(
      backgroundColor: AppColors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Container(
        padding: EdgeInsets.all(24.r),
        decoration: BoxDecoration(
          color: AppColors.mainBackground, // White
          borderRadius: BorderRadius.circular(28.r),
          border: Border.all(
            color: AppColors.border.withValues(alpha: 0.5),
            width: 1.2.w,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.08),
              blurRadius: 24.r,
              offset: Offset(0.w, 12.h),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Close button in top-right (if enabled)
            if (widget.showCloseButton)
              Positioned(
                top: 0.h,
                right: 0.w,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 32.w,
                    height: 32.h,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.border.withValues(alpha: 0.6),
                        width: 1.w,
                      ),
                    ),
                    child: FaIcon(
                      FontAwesomeIcons.xmark,
                      size: 14.sp,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
              ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 12.h),
                // Icon Container - Redesigned & centered
                Container(
                  width: 64.w,
                  height: 64.h,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.primary, AppColors.secondary],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.25),
                        blurRadius: 12.r,
                        offset: Offset(0.w, 6.h),
                      ),
                    ],
                  ),
                  child: Center(
                    child: FaIcon(
                      widget.icon,
                      color: AppColors.white,
                      size: 26.sp, // Reduced slightly for balanced sizing
                    ),
                  ),
                ),
                SizedBox(height: 24.h),
                // Title
                AppText(
                  widget.title,
                  textAlignment: TextAlign.center,
                  textColor: AppColors.textPrimary,
                  textSize: 20.sp,
                  textWeight: FontWeight.bold,
                  lettersSpace: 0.2,
                ),
                SizedBox(height: 12.h),
                // Subtitle
                AppText(
                  widget.subtitle,
                  textAlignment: TextAlign.center,
                  textColor: AppColors.textMuted,
                  textSize: 14.sp,
                  fontHeight: 1.45.h,
                  textWeight: FontWeight.w500,
                ),
                if (widget.showRatingStars) ...[
                  SizedBox(height: 24.h),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        final starIndex = index + 1;
                        final isSelected = starIndex <= _selectedRating;
                        return GestureDetector(
                          onTap: () =>
                              setState(() => _selectedRating = starIndex),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: EdgeInsets.symmetric(horizontal: 6.w),
                            child: FaIcon(
                              isSelected
                                  ? FontAwesomeIcons.solidStar
                                  : FontAwesomeIcons.star,
                              color: isSelected
                                  ? AppColors.amber500
                                  : AppColors.border,
                              size: isSelected ? 38.r : 32.r,
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
                SizedBox(height: 28.h),
                // Buttons Section
                Builder(
                  builder: (context) {
                    final Widget primaryBtn = ScaleButton(
                      onTap: isPrimaryDisabled
                          ? null
                          : (widget.showRatingStars
                                ? () {
                                    Navigator.pop(context);
                                    widget.onRatingSubmit?.call(
                                      _selectedRating,
                                    );
                                  }
                                : widget.onPrimaryPressed),
                      child: Container(
                        width: double.infinity,
                        height: 50.h,
                        decoration: BoxDecoration(
                          gradient: isPrimaryDisabled
                              ? null
                              : const LinearGradient(
                                  colors: [
                                    AppColors.buttonGradientStart,
                                    AppColors.primary,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                          color: isPrimaryDisabled ? AppColors.border : null,
                          borderRadius: BorderRadius.circular(30.r),
                          boxShadow: isPrimaryDisabled
                              ? null
                              : [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(
                                      alpha: 0.25,
                                    ),
                                    blurRadius: 14.r,
                                    offset: Offset(0.w, 6.h),
                                  ),
                                ],
                        ),
                        alignment: Alignment.center,
                        child: AppText(
                          widget.primaryButtonText,
                          textSize: 14.sp,
                          textWeight: FontWeight.bold,
                          textColor: isPrimaryDisabled
                              ? AppColors.textMuted.withValues(alpha: 0.6)
                              : AppColors.white,
                          lettersSpace: 0.5,
                        ),
                      ),
                    );

                    if (widget.secondaryButtonText != null &&
                        widget.onSecondaryPressed != null) {
                      return Row(
                        children: [
                          Expanded(
                            child: ScaleButton(
                              onTap: widget.onSecondaryPressed,
                              child: Container(
                                width: double.infinity,
                                height: 50.h,
                                decoration: BoxDecoration(
                                  color: AppColors.white,
                                  borderRadius: BorderRadius.circular(30.r),
                                  border: Border.all(
                                    color: AppColors.primary.withValues(
                                      alpha: 0.35,
                                    ),
                                    width: 1.5.w,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: AppText(
                                  widget.secondaryButtonText!,
                                  maxLinesCount: 1,
                                  fontOverflow: TextOverflow.ellipsis,
                                  textSize: 14.sp,
                                  textWeight: FontWeight.bold,
                                  textColor: AppColors.primary,
                                  lettersSpace: 0.5,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(child: primaryBtn),
                        ],
                      );
                    }

                    return primaryBtn;
                  },
                ),
              ],
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
