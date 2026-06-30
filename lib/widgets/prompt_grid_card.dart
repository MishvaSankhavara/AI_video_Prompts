import 'package:flutter/material.dart';
import '../models/video_category.dart';
import '../utils/colors.dart';
import 'text_app.dart';
import 'common_video_player.dart';

class PromptGridCard extends StatelessWidget {
  final VideoItem item;
  final String categoryName;
  final bool isPremium;
  final VoidCallback onTap;
  final bool showLoadingIndicator;

  /// When false, the card shows the thumbnail only (no video playback).
  final bool playVideo;

  const PromptGridCard({
    super.key,
    required this.item,
    required this.categoryName,
    this.isPremium = false,
    required this.onTap,
    this.showLoadingIndicator = true,
    this.playVideo = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.border, width: 1),
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
            // Reusable common video player
            CommonVideoPlayer(
              videoUrl: item.categoryVideoFullUrl,
              thumbnailUrl: item.videoThumbnailFullUrl,
              isMuted: true,
              isLooping: true,
              interactivePlayPause: false,
              showLoadingIndicator: showLoadingIndicator,
              playVideo: playVideo,
            ),

            // Bottom Gradient Overlay for text readability
            if (categoryName.isNotEmpty)
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
            if (categoryName.isNotEmpty)
              Positioned(
                bottom: 16,
                left: 12,
                right: 12,
                child: Text(
                  categoryName,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.getStyle(
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
