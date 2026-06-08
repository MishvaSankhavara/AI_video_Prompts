import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../models/video_category.dart';
import '../utils/colors.dart';
import 'shimmer_grid_card.dart';

class PromptGridCard extends StatefulWidget {
  final VideoItem item;
  final String categoryName;
  final bool isPremium;
  final VoidCallback onTap;

  const PromptGridCard({
    super.key,
    required this.item,
    required this.categoryName,
    this.isPremium = false,
    required this.onTap,
  });

  @override
  State<PromptGridCard> createState() => _PromptGridCardState();
}

class _PromptGridCardState extends State<PromptGridCard> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  @override
  void didUpdateWidget(covariant PromptGridCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.categoryVideoFullUrl != widget.item.categoryVideoFullUrl) {
      _controller.dispose();
      _isInitialized = false;
      _initializeController();
    }
  }

  void _initializeController() {
    final videoUrl = Uri.encodeFull(widget.item.categoryVideoFullUrl.trim());
    _controller = VideoPlayerController.networkUrl(
      Uri.parse(videoUrl),
    );
    _controller.initialize().then((_) {
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
        _controller.setLooping(true);
        _controller.setVolume(0.0); // Muted loop
        _controller.play();
      }
    }).catchError((e) {
      debugPrint("Error loading grid video: $e");
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.border,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Video Player or Shimmering/Thumbnail Image
            if (_isInitialized)
              FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _controller.value.size.width > 0 ? _controller.value.size.width : 9.0,
                  height: _controller.value.size.height > 0 ? _controller.value.size.height : 16.0,
                  child: VideoPlayer(_controller),
                ),
              )
            else
              Image.network(
                Uri.encodeFull(widget.item.videoThumbnailFullUrl.trim()),
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const ShimmerGridCard();
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: AppColors.cardBackground,
                    child: const Center(
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        color: AppColors.textMuted,
                        size: 32,
                      ),
                    ),
                  );
                },
              ),

            // Bottom Gradient Overlay for text readability
            if (widget.categoryName.isNotEmpty)
              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black38,
                        Colors.black87,
                      ],
                      stops: [0.6, 0.82, 1.0],
                    ),
                  ),
                ),
              ),

            // Text Title (Category Name / Prompt Tag)
            if (widget.categoryName.isNotEmpty)
              Positioned(
                bottom: 16,
                left: 12,
                right: 12,
                child: Text(
                  widget.categoryName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
