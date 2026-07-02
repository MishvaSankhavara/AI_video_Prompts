import 'package:aivideoprompt/widgets/text_app.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import '../models/video_category.dart';
import '../utils/colors.dart';
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
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(color: AppColors.border, width: 1.w),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.03),
              blurRadius: 8.r,
              offset: Offset(0.w, 4.h),
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
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.transparent,
                        AppColors.black38,
                        AppColors.black87,
                      ],
                      stops: [0.6, 0.82, 1],
                    ),
                  ),
                ),
              ),

            // Text Title (Category Name / Prompt Tag)
            if (categoryName.isNotEmpty)
              Positioned(
                bottom: 16.h,
                left: 12.w,
                right: 12.w,
                child: AppText(
                  categoryName,
                  textAlignment: TextAlign.center,
                  maxLinesCount: 1,
                  fontOverflow: TextOverflow.ellipsis,
                  textColor: AppColors.white,
                  textSize: 15.sp,
                  textWeight: FontWeight.bold,
                  lettersSpace: 0.1,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
