import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../utils/colors.dart';
import '../../utils/text_app.dart';

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
    final bool isPrimaryDisabled = widget.showRatingStars && _selectedRating == 0;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.mainBackground, // White
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: AppColors.border.withValues(alpha: 0.5),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
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
                    width: 32,
                    height: 32,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.border.withValues(alpha: 0.6),
                        width: 1,
                      ),
                    ),
                    child: const FaIcon(
                      FontAwesomeIcons.xmark,
                      size: 14,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
              ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                // Icon Container - Redesigned & centered
                Container(
                  width: 64,
                  height: 64,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primary,
                        AppColors.secondary,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.25),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Center(
                    child: FaIcon(
                      widget.icon,
                      color: Colors.white,
                      size: 26, // Reduced slightly for balanced sizing
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Title
                Text(
                  widget.title,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.getStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 12),
                // Subtitle
                Text(
                  widget.subtitle,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.getStyle(
                    color: AppColors.textMuted,
                    fontSize: 14,
                    height: 1.45,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (widget.showRatingStars) ...[
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final starIndex = index + 1;
                      final isSelected = starIndex <= _selectedRating;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedRating = starIndex),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: FaIcon(
                            isSelected ? FontAwesomeIcons.solidStar : FontAwesomeIcons.star,
                            color: isSelected ? const Color(0xFFFFC107) : AppColors.border,
                            size: isSelected ? 40 : 36,
                          ),
                        ),
                      );
                    }),
                  ),
                ],
                const SizedBox(height: 28),
                // Primary Button - Gradient with Shadow
                Container(
                  width: double.infinity,
                  height: 54,
                  decoration: BoxDecoration(
                    gradient: isPrimaryDisabled
                        ? null
                        : const LinearGradient(
                            colors: [AppColors.primary, AppColors.secondary],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                    color: isPrimaryDisabled ? AppColors.border : null,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: isPrimaryDisabled
                        ? null
                        : [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                  ),
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
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shadowColor: Colors.transparent,
                      disabledBackgroundColor: Colors.transparent,
                      disabledForegroundColor: AppColors.textMuted.withValues(alpha: 0.6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      widget.primaryButtonText,
                      style: AppTextStyles.getStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isPrimaryDisabled
                            ? AppColors.textMuted.withValues(alpha: 0.6)
                            : Colors.white,
                      ),
                    ),
                  ),
                ),
                // Secondary Button (if present) - Redesigned
                if (widget.secondaryButtonText != null && widget.onSecondaryPressed != null) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: OutlinedButton(
                      onPressed: widget.onSecondaryPressed,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primary, width: 1.5),
                        foregroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        widget.secondaryButtonText!,
                        style: AppTextStyles.getStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
