import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import '../../utils/colors.dart';
import '../../widgets/text_app.dart';

class NotificationOfferDialog extends StatelessWidget {
  final String title;
  final String message;
  final String imageUrl;
  final VoidCallback onTryNow;

  const NotificationOfferDialog({
    super.key,
    required this.title,
    required this.message,
    required this.imageUrl,
    required this.onTryNow,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.1),
              blurRadius: 20.r,
              offset: Offset(0, 10.h),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Close Button Row
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  padding: EdgeInsets.all(6.r),
                  decoration: BoxDecoration(
                    color: AppColors.mainBackground,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close,
                    size: 16.w,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            ),
            SizedBox(height: 8.h),

            // Image Section
            if (imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(16.r),
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  height: 180.h,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Shimmer.fromColors(
                    baseColor: AppColors.mainBackground,
                    highlightColor: AppColors.white,
                    child: Container(
                      height: 180.h,
                      width: double.infinity,
                      color: AppColors.white,
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: 180.h,
                    width: double.infinity,
                    color: AppColors.mainBackground,
                    child: Icon(Icons.broken_image, color: AppColors.textMuted),
                  ),
                ),
              ),

            SizedBox(height: 20.h),

            // Title
            if (title.isNotEmpty)
              AppText(
                title,
                textSize: 20.sp,
                textWeight: FontWeight.bold,
                textColor: AppColors.textPrimary,
                textAlignment: TextAlign.center,
              ),

            SizedBox(height: 10.h),

            // Message
            if (message.isNotEmpty)
              AppText(
                message,
                textSize: 14.sp,
                textColor: AppColors.textMuted,
                textAlignment: TextAlign.center,
                maxLinesCount: 3,
                fontOverflow: TextOverflow.ellipsis,
              ),

            SizedBox(height: 24.h),

            // Try Now Button
            Container(
              width: double.infinity,
              height: 50.h,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.purpleAccent],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(28.r),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 15.r,
                    offset: Offset(0, 8.h),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: onTryNow,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.transparent,
                  shadowColor: AppColors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28.r),
                  ),
                ),
                child: AppText(
                  'Try Now',
                  textColor: AppColors.white,
                  textSize: 16.sp,
                  textWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
