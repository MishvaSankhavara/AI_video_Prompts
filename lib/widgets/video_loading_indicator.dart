import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../utils/text_app.dart';

class VideoLoadingIndicator extends StatelessWidget {
  const VideoLoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.5.w, vertical: 0.75.h),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.45),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(5.5.w),
          bottomRight: Radius.circular(3.75.w),
          topRight: const Radius.circular(2),
          bottomLeft: const Radius.circular(2),
        ),
      ),
      child: Text(
        'Loading..',
        style: AppTextStyles.getStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
