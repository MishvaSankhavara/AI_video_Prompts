import 'package:aivideoprompt/widgets/text_app.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../utils/colors.dart';

class ShimmerLoading extends StatelessWidget {
  const ShimmerLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Shimmer.fromColors(
          baseColor: AppColors.shimmerBase,
          highlightColor: AppColors.shimmerHighlight,
          child: Container(
            color: AppColors.white,
          ),
        ),
        Center(
          child: Text(
            "AI Video Prompts",
            style: AppTextStyles.getStyle(
              color: AppColors.grey.withValues(alpha: 0.4),
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
