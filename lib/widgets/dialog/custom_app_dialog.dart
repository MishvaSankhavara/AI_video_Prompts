import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../utils/colors.dart';
import '../../utils/text_app.dart';

class CustomAppDialog extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
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
    this.icon = Icons.auto_awesome_rounded,
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
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: isLandscape ? 10.w : 6.w),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: isLandscape ? 380.0 : 450.0,
        ),
        child: Container(
          padding: EdgeInsets.all(isLandscape ? 18.0 : 6.w),
          decoration: BoxDecoration(
            color: AppColors.mainBackground, // White
            borderRadius: BorderRadius.circular(isLandscape ? 18.0 : 7.w),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Close button in top-right (if enabled)
              if (widget.showCloseButton)
                Positioned(
                  top: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: EdgeInsets.all(isLandscape ? 6.0 : 1.5.w),
                      decoration: const BoxDecoration(
                        color: AppColors.cardBackground,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        size: isLandscape ? 16.0 : 4.w,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                ),
              SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: isLandscape ? 10.0 : 1.5.h),
                    // Icon Container
                    Container(
                      width: isLandscape ? 50.0 : 16.w,
                      height: isLandscape ? 50.0 : 16.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.primary,
                            AppColors.textMuted,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        widget.icon,
                        color: Colors.white,
                        size: isLandscape ? 24.0 : 7.5.w,
                      ),
                    ),
                    SizedBox(height: isLandscape ? 12.0 : 2.5.h),
                    // Title
                    Text(
                      widget.title,
                      style: AppTextStyles.getStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: isLandscape ? 8.0 : 1.5.h),
                    // Subtitle
                    Text(
                      widget.subtitle,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.getStyle(
                        color: AppColors.textMuted,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                    if (widget.showRatingStars) ...[
                      SizedBox(height: isLandscape ? 12.0 : 3.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          final starIndex = index + 1;
                          final isSelected = starIndex <= _selectedRating;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedRating = starIndex),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: EdgeInsets.symmetric(horizontal: isLandscape ? 4.0 : 1.5.w),
                              child: Icon(
                                isSelected ? Icons.star_rounded : Icons.star_outline_rounded,
                                color: isSelected ? const Color(0xFFFFC107) : AppColors.border,
                                size: isLandscape ? 30.0 : (isSelected ? 11.w : 10.w),
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
                    SizedBox(height: isLandscape ? 16.0 : 3.h),
                    // Primary Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: widget.showRatingStars
                            ? (_selectedRating == 0
                                ? null
                                : () {
                                    Navigator.pop(context);
                                    widget.onRatingSubmit?.call(_selectedRating);
                                  })
                            : widget.onPrimaryPressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: AppColors.border,
                          disabledForegroundColor: AppColors.textMuted,
                          padding: EdgeInsets.symmetric(vertical: isLandscape ? 12.0 : 2.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(isLandscape ? 12.0 : 4.w),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          widget.primaryButtonText,
                          style: AppTextStyles.getStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    // Secondary Button (if present)
                    if (widget.secondaryButtonText != null && widget.onSecondaryPressed != null) ...[
                      SizedBox(height: isLandscape ? 8.0 : 1.5.h),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: widget.onSecondaryPressed,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.primary, width: 1.5),
                            foregroundColor: AppColors.primary,
                            padding: EdgeInsets.symmetric(vertical: isLandscape ? 12.0 : 2.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(isLandscape ? 12.0 : 4.w),
                            ),
                          ),
                          child: Text(
                            widget.secondaryButtonText!,
                            style: AppTextStyles.getStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
