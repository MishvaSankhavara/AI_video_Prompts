import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
              left: 0.04.sw,
              bottom: 0.16.sh,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _block(height: 0.022.sh, width: 0.06.sw),
                  SizedBox(height: 0.008.sh),
                  _block(height: 0.022.sh, width: 0.6.sw),
                ],
              ),
            ),

            // Body text (2 lines).
            Positioned(
              left: 0.04.sw,
              right: 0.04.sw,
              bottom: 0.1.sh,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _block(height: 0.016.sh, width: double.infinity),
                  SizedBox(height: 0.006.sh),
                  _block(height: 0.016.sh, width: 0.8.sw),
                ],
              ),
            ),

            // CTA button.
            Positioned(
              left: 0.04.sw,
              right: 0.04.sw,
              bottom: 0.03.sh,
              child: _block(height: 0.06.sh, radius: 8),
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
        padding: EdgeInsets.symmetric(horizontal: 0.03.sw, vertical: 0.008.sh),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Media view.
            Container(
              height: 0.12.sh,
              width: double.infinity,
              margin: EdgeInsets.symmetric(vertical: 0.008.sh),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),

            // App icon + text content.
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 0.062.sh,
                  height: 0.062.sh,
                  margin: EdgeInsets.only(right: 0.02.sw),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _block(height: 0.018.sh, width: 0.12.sw, radius: 3),
                      SizedBox(height: 0.006.sh),
                      _block(height: 0.016.sh, width: double.infinity),
                      SizedBox(height: 0.006.sh),
                      _block(height: 0.012.sh, width: 0.9.sw),
                      SizedBox(height: 0.004.sh),
                      _block(height: 0.012.sh, width: 0.7.sw),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 0.012.sh),

            // CTA button.
            _block(height: 0.042.sh, width: double.infinity, radius: 8),
          ],
        ),
      ),
    );
  }

  /// Medium native ad: horizontal media + content (badge, headline, body, CTA).
  static Widget mediumNativeAdShimmer() {
    return _wrap(
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 0.02.sw, vertical: 0.01.sh),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Media image (left).
            _block(width: 0.3.sw, height: 0.12.sh, radius: 8),
            SizedBox(width: 0.03.sw),

            // Content (right).
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _block(height: 0.018.sh, width: 0.12.sw, radius: 3),
                  SizedBox(height: 0.01.sh),
                  _block(height: 0.015.sh, width: double.infinity),
                  SizedBox(height: 0.005.sh),
                  _block(height: 0.01.sh, width: 0.8.sw),
                  SizedBox(height: 0.01.sh),
                  _block(height: 0.04.sh, width: 0.25.sw, radius: 6),
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
          SizedBox(height: 0.01.sw),

          // Ad badge.
          Padding(
            padding: EdgeInsets.only(left: 0.02.sw),
            child: _block(height: 0.02.sh, width: 0.08.sw, radius: 3),
          ),

          SizedBox(height: 0.01.sw),

          // Media image.
          Container(
            margin: EdgeInsets.symmetric(horizontal: 0.015.sw),
            height: 0.18.sh,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),

          SizedBox(height: 0.01.sh),

          // Headline.
          Center(
            child: _block(height: 0.02.sh, width: 0.6.sw),
          ),
          SizedBox(height: 0.01.sh),

          // Body text (2 lines).
          Center(
            child: _block(height: 0.015.sh, width: 0.8.sw),
          ),
          SizedBox(height: 0.005.sh),
          Center(
            child: _block(height: 0.015.sh, width: 0.7.sw),
          ),

          SizedBox(height: 0.01.sh),

          // CTA button.
          Container(
            height: 0.05.sh,
            margin: EdgeInsets.symmetric(horizontal: 0.03.sw),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
        ],
      ),
    );
  }
}
