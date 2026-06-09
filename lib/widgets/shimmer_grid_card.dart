import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../utils/colors.dart';
import '../utils/text_app.dart';

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
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Shimmering background container
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return ShaderMask(
                blendMode: BlendMode.srcATop,
                shaderCallback: (bounds) {
                  return LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: const [
                      Color(0xFFE2E8F0), // Muted Slate Base
                      Color(0xFFF8FAFC), // Glowing White Highlight
                      Color(0xFFE2E8F0),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                    transform: _SlidingGradientTransform(slidePercent: _controller.value),
                  ).createShader(bounds);
                },
                child: child,
               );
            },
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(6.w),
                border: Border.all(
                  color: AppColors.border.withValues(alpha: 0.5),
                  width: 0.25.w,
                ),
              ),
            ),
          ),
        ),
        // Static un-shimmered bold text overlay on top for perfect legibility
        Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Text(
              'AI Video Prompts',
              textAlign: TextAlign.center,
              style: AppTextStyles.getStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.textMuted.withValues(alpha: 0.8),
                letterSpacing: 0.1,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  final double slidePercent;

  const _SlidingGradientTransform({required this.slidePercent});

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    final double width = bounds.width;
    final double height = bounds.height;
    // Translate the gradient from top-left (-width, -height) to bottom-right (width, height)
    final double tx = -width + (slidePercent * 2 * width);
    final double ty = -height + (slidePercent * 2 * height);
    return Matrix4.translationValues(tx, ty, 0.0);
  }
}
