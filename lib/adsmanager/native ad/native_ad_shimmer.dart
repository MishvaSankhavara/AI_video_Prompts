import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shimmer/shimmer.dart';

import '../../utils/colors.dart';

/// Realistic, ad-shaped shimmer placeholders shown while a native ad loads.
///
/// Ported from prompt_app_v2 (`shimmer_native_ad.dart`) and refactored to this
/// app's [AppColors]. Each layout mirrors the corresponding native ad template
/// (grid / medium / large / fullscreen) so the loading state matches the final
/// ad footprint.
class ShimmerNativeAd {
  const ShimmerNativeAd._();

  static Widget _wrap(Widget child) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHighlight,
      child: child,
    );
  }

  static Widget _block({double? width, double? height, double radius = 4}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  /// Fullscreen native ad (e.g. onboarding ad slide).
  static Widget fullscreenNativeAdShimmer() {
    return _wrap(
      SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          children: [
            // Fullscreen media (semi-transparent so the children read through).
            Container(
              width: double.infinity,
              height: double.infinity,
              color: AppColors.white.withValues(alpha: 0.25),
            ),

            // Ad badge + headline.
            Positioned(
              left: 4.w,
              bottom: 16.h,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _block(height: 2.2.h, width: 6.w),
                  SizedBox(height: 0.8.h),
                  _block(height: 2.2.h, width: 60.w),
                ],
              ),
            ),

            // Body text (2 lines).
            Positioned(
              left: 4.w,
              right: 4.w,
              bottom: 10.h,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _block(height: 1.6.h, width: double.infinity),
                  SizedBox(height: 0.6.h),
                  _block(height: 1.6.h, width: 80.w),
                ],
              ),
            ),

            // CTA button.
            Positioned(
              left: 4.w,
              right: 4.w,
              bottom: 3.h,
              child: _block(height: 6.h, radius: 8),
            ),
          ],
        ),
      ),
    );
  }

  /// Large native ad: media on top, icon + text row, CTA at the bottom.
  static Widget largeNativeAdShimmer() {
    return _wrap(
      Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.8.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Media view.
            Container(
              height: 12.h,
              width: double.infinity,
              margin: EdgeInsets.symmetric(vertical: 0.8.h),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),

            // App icon + text content.
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 6.2.h,
                  height: 6.2.h,
                  margin: EdgeInsets.only(right: 2.w),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _block(height: 1.8.h, width: 12.w, radius: 3),
                      SizedBox(height: 0.6.h),
                      _block(height: 1.6.h, width: double.infinity),
                      SizedBox(height: 0.6.h),
                      _block(height: 1.2.h, width: 90.w),
                      SizedBox(height: 0.4.h),
                      _block(height: 1.2.h, width: 70.w),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 1.2.h),

            // CTA button.
            _block(height: 4.2.h, width: double.infinity, radius: 8),
          ],
        ),
      ),
    );
  }

  /// Medium native ad: horizontal media + content (badge, headline, body, CTA).
  static Widget mediumNativeAdShimmer() {
    return _wrap(
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Media image (left).
            _block(width: 30.w, height: 12.h, radius: 8),
            SizedBox(width: 3.w),

            // Content (right).
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _block(height: 1.8.h, width: 12.w, radius: 3),
                  SizedBox(height: 1.h),
                  _block(height: 1.5.h, width: double.infinity),
                  SizedBox(height: 0.5.h),
                  _block(height: 1.h, width: 80.w),
                  SizedBox(height: 1.h),
                  _block(height: 4.h, width: 25.w, radius: 6),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Grid native ad: badge, media, centered headline + body, CTA.
  static Widget gridViewNativeAdShimmer() {
    return _wrap(
      Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 1.w),

          // Ad badge.
          Padding(
            padding: EdgeInsets.only(left: 2.w),
            child: _block(height: 2.h, width: 8.w, radius: 3),
          ),

          SizedBox(height: 1.w),

          // Media image.
          Container(
            margin: EdgeInsets.symmetric(horizontal: 1.5.w),
            height: 18.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(8),
            ),
          ),

          SizedBox(height: 1.h),

          // Headline.
          Center(
            child: _block(height: 2.h, width: 60.w),
          ),
          SizedBox(height: 1.h),

          // Body text (2 lines).
          Center(
            child: _block(height: 1.5.h, width: 80.w),
          ),
          SizedBox(height: 0.5.h),
          Center(
            child: _block(height: 1.5.h, width: 70.w),
          ),

          SizedBox(height: 1.h),

          // CTA button.
          Container(
            height: 5.h,
            margin: EdgeInsets.symmetric(horizontal: 3.w),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ],
      ),
    );
  }
}
