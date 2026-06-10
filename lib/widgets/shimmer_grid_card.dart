import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../utils/colors.dart';

class ShimmerGridCard extends StatefulWidget {
  const ShimmerGridCard({super.key});

  @override
  State<ShimmerGridCard> createState() => _ShimmerGridCardState();
}

class _ShimmerGridCardState extends State<ShimmerGridCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6.w),
            border: Border.all(
              color: AppColors.border.withValues(alpha: 0.5),
              width: 0.25.w,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Base background
              Container(color: AppColors.shimmerBase),

              // Left-to-right shimmer sweep
              ShaderMask(
                blendMode: BlendMode.srcIn,
                shaderCallback: (bounds) {
                  return LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: const [
                      AppColors.shimmerBase,
                      AppColors.shimmerHighlight,
                      AppColors.white,
                      AppColors.shimmerHighlight,
                      AppColors.shimmerBase,
                    ],
                    stops: const [0.0, 0.35, 0.5, 0.65, 1.0],
                    transform: _HorizontalSlidingTransform(
                      slidePercent: _controller.value,
                    ),
                  ).createShader(bounds);
                },
                child: Container(color: AppColors.shimmerBase),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Slides the gradient strictly horizontally — left to right.
class _HorizontalSlidingTransform extends GradientTransform {
  final double slidePercent;

  const _HorizontalSlidingTransform({required this.slidePercent});

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    // Move from -width to +width so the highlight sweeps fully across
    final double tx = -bounds.width + (slidePercent * 2 * bounds.width);
    return Matrix4.translationValues(tx, 0.0, 0.0);
  }
}
