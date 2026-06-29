import 'package:flutter/material.dart';

class ShimmerNativeAd extends StatefulWidget {
  final String factoryId;

  const ShimmerNativeAd({super.key, required this.factoryId});

  /// Factory method to easily create a grid view shimmer
  static Widget gridViewNativeAdShimmer() {
    return const ShimmerNativeAd(factoryId: 'grid_ad_factory');
  }

  /// Factory method to easily create a medium ad shimmer
  static Widget mediumNativeAdShimmer() {
    return const ShimmerNativeAd(factoryId: 'medium_ad_factory');
  }

  /// Factory method to easily create a large ad shimmer
  static Widget largeNativeAdShimmer() {
    return const ShimmerNativeAd(factoryId: 'large_ad_factory');
  }

  /// Factory method to easily create a fullscreen ad shimmer
  static Widget fullscreenNativeAdShimmer() {
    return const ShimmerNativeAd(factoryId: 'fullscreen_ad_factory');
  }

  @override
  State<ShimmerNativeAd> createState() => _ShimmerNativeAdState();
}

class _ShimmerNativeAdState extends State<ShimmerNativeAd> with SingleTickerProviderStateMixin {
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

  Widget _buildShimmerBlock({double? width, double? height, double borderRadius = 8.0, BoxShape shape = BoxShape.rectangle}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white, // The mask will replace this color
        borderRadius: shape == BoxShape.rectangle ? BorderRadius.circular(borderRadius) : null,
        shape: shape,
      ),
    );
  }

  Widget _buildSkeletonLayout() {
    // 1. Medium Ad Layout
    if (widget.factoryId == 'medium_ad_factory') {
      return Padding(
        padding: const EdgeInsets.all(4.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildShimmerBlock(width: 120, height: 120, borderRadius: 12),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 4),
                  _buildShimmerBlock(width: 100, height: 14),
                  const SizedBox(height: 8),
                  _buildShimmerBlock(width: double.infinity, height: 12),
                  const SizedBox(height: 4),
                  _buildShimmerBlock(width: 140, height: 12),
                  const SizedBox(height: 12),
                  _buildShimmerBlock(width: 100, height: 32, borderRadius: 16),
                ],
              ),
            ),
          ],
        ),
      );
    } 
    
    // 2. Fullscreen Ad Layout
    if (widget.factoryId == 'fullscreen_ad_factory') {
      return Stack(
        fit: StackFit.expand,
        children: [
          _buildShimmerBlock(width: double.infinity, height: double.infinity, borderRadius: 0),
          Positioned(
            bottom: 24,
            left: 16,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildShimmerBlock(width: 140, height: 16, borderRadius: 4),
                const SizedBox(height: 12),
                _buildShimmerBlock(width: double.infinity, height: 14, borderRadius: 4),
                const SizedBox(height: 6),
                _buildShimmerBlock(width: 200, height: 14, borderRadius: 4),
                const SizedBox(height: 16),
                _buildShimmerBlock(width: double.infinity, height: 48, borderRadius: 24),
              ],
            ),
          ),
        ],
      );
    }

    // 3. Default for Large & Grid Ads
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildShimmerBlock(width: double.infinity, height: 120, borderRadius: 12),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildShimmerBlock(width: 40, height: 40, shape: BoxShape.circle),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 2),
                    _buildShimmerBlock(width: 120, height: 14),
                    const SizedBox(height: 8),
                    _buildShimmerBlock(width: double.infinity, height: 12),
                    const SizedBox(height: 4),
                    _buildShimmerBlock(width: 160, height: 12),
                  ],
                ),
              ),
            ],
          ),
          const Spacer(),
          _buildShimmerBlock(width: double.infinity, height: 44, borderRadius: 22),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            color: Colors.transparent,
            child: ShaderMask(
              blendMode: BlendMode.srcIn,
              shaderCallback: (bounds) {
                return LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: const [
                    Color(0xFFE5E7EB),
                    Color(0xFFF3F4F6),
                    Colors.white,
                    Color(0xFFF3F4F6),
                    Color(0xFFE5E7EB),
                  ],
                  stops: const [0.0, 0.35, 0.5, 0.65, 1.0],
                  transform: _HorizontalSlidingTransform(
                    slidePercent: _controller.value,
                  ),
                ).createShader(bounds);
              },
              child: _buildSkeletonLayout(),
            ),
          ),
        );
      },
    );
  }
}

class _HorizontalSlidingTransform extends GradientTransform {
  final double slidePercent;

  const _HorizontalSlidingTransform({required this.slidePercent});

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    final double tx = -bounds.width + (slidePercent * 2 * bounds.width);
    return Matrix4.translationValues(tx, 0.0, 0.0);
  }
}
