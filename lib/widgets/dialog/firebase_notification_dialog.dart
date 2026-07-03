import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:palette_generator/palette_generator.dart';
import '../../utils/colors.dart';
import '../../widgets/text_app.dart';

class FirebaseNotificationDialog extends StatefulWidget {
  final String title;
  final String message;
  final String imageUrl;
  final VoidCallback onTryNow;

  const FirebaseNotificationDialog({
    super.key,
    required this.title,
    required this.message,
    required this.imageUrl,
    required this.onTryNow,
  });

  @override
  State<FirebaseNotificationDialog> createState() =>
      _FirebaseNotificationDialogState();
}

class _FirebaseNotificationDialogState
    extends State<FirebaseNotificationDialog> {
  Color? _dominantColor;
  Color? _textColor;
  Color? _buttonColor;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (widget.imageUrl.isNotEmpty) {
      _extractColors();
    } else {
      _isLoading = false;
    }
  }

  Future<void> _extractColors() async {
    try {
      final PaletteGenerator paletteGenerator =
          await PaletteGenerator.fromImageProvider(
        CachedNetworkImageProvider(widget.imageUrl),
        maximumColorCount: 10,
      );

      final dominant = paletteGenerator.dominantColor?.color ??
          paletteGenerator.vibrantColor?.color ??
          AppColors.primary;

      final bool isDark = dominant.computeLuminance() < 0.5;

      if (mounted) {
        setState(() {
          _dominantColor = dominant;
          _textColor = isDark ? Colors.white : Colors.black87;
          _buttonColor = isDark ? Colors.white : Colors.black87;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _dominantColor = Colors.black;
          _textColor = Colors.white;
          _buttonColor = Colors.white;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Fallbacks while loading or on error
    final dominant = _dominantColor ?? Colors.black;
    final textColor = _textColor ?? Colors.white;
    final buttonBg = _buttonColor ?? Colors.white;
    // Button text should contrast with button background. If button is dark, text is white, else it's the dominant color.
    final buttonTextColor =
        buttonBg == Colors.black87 ? Colors.white : dominant;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      child: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Colors.white))
        : ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.85,
            ),
            child: ClipRRect(
          borderRadius: BorderRadius.circular(20.r),
          child: Stack(
            children: [
              // 1. Dynamic Image
              if (widget.imageUrl.isNotEmpty)
                CachedNetworkImage(
                  imageUrl: widget.imageUrl,
                  width: double.infinity,
                  fit: BoxFit.contain,
                  placeholder: (context, url) => Container(
                    width: double.infinity,
                    height: 400.h,
                    color: AppColors.mainBackground,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: double.infinity,
                    height: 400.h,
                    color: AppColors.mainBackground,
                    child: Icon(Icons.broken_image,
                        size: 40.w, color: AppColors.textMuted),
                  ),
                )
              else
                Container(
                  width: double.infinity,
                  height: 400.h,
                  color: AppColors.mainBackground,
                ),

              // 2. Bottom Gradient Overlay & Text/Button
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.only(
                      top: 140.h, bottom: 24.h, left: 24.w, right: 24.w),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        dominant.withValues(alpha: 0.65),
                        dominant.withValues(alpha: 0.95),
                        dominant, // solid at the very bottom
                      ],
                      stops: const [0.0, 0.4, 0.8, 1.0],
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      if (widget.title.isNotEmpty)
                        AppText(
                          widget.title,
                          textSize: 20.sp,
                          textWeight: FontWeight.bold,
                          textColor: textColor,
                          textAlignment: TextAlign.left,
                        ),

                      if (widget.title.isNotEmpty && widget.message.isNotEmpty)
                        SizedBox(height: 8.h),

                      // Message
                      if (widget.message.isNotEmpty)
                        AppText(
                          widget.message,
                          textSize: 13.sp,
                          textColor: textColor.withValues(alpha: 0.9),
                          textAlignment: TextAlign.left,
                        ),

                      SizedBox(height: 24.h),

                      // Continue / Try Now Button
                      Container(
                        width: double.infinity,
                        height: 52.h,
                        decoration: BoxDecoration(
                          color: buttonBg,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: ElevatedButton(
                          onPressed: widget.onTryNow,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                          child: AppText(
                            'Continue',
                            textColor: buttonTextColor,
                            textSize: 16.sp,
                            textWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 3. Top Right Close Button
              Positioned(
                top: 12.h,
                right: 12.w,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: EdgeInsets.all(8.r),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close,
                      size: 16.w,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
