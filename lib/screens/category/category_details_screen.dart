import 'dart:io';

import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../adsmanager/native ad/native_ad_service.dart';
import '../../adsmanager/native ad/native_ad_shimmer.dart';
import '../../adsmanager/interstitial_ad_service.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../adsmanager/ad_ids.dart';
import '../../models/video_category.dart';
import '../../viewmodel/fetch_videos_by_category.dart';
import '../../services/api_error_response.dart';
// import '../../services/analytics_service.dart';
import '../../utils/colors.dart';
import '../../utils/strings.dart';
import '../../widgets/text_app.dart';
import '../../widgets/common_app_bar.dart';
import '../../widgets/prompt_grid_card.dart';
import 'prompt_details_screen.dart';
import '../../services/navigation_service.dart';

class CategoryDetailsScreen extends StatefulWidget {
  final int categoryId;
  final String categoryName;

  const CategoryDetailsScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  State<CategoryDetailsScreen> createState() => _CategoryDetailsScreenState();
}

class _CategoryDetailsScreenState extends State<CategoryDetailsScreen> {
  final FetchVideosByCategoryViewModel _viewModel =
      FetchVideosByCategoryViewModel();
  final NativeAdService _nativeAdService = NativeAdService();

  bool _isAdIndex(int index) {
    return (index + 1) % 6 == 0;
  }

  int _adCountBefore(int index) {
    return (index + 1) ~/ 6;
  }

  int _gridIndexToContentIndex(int index) {
    return index - _adCountBefore(index);
  }

  int get _gridItemCount {
    final videos = _viewModel.videos;
    if (videos.isEmpty) return 0;
    return videos.length + (videos.length - 1) ~/ 5;
  }

  // Removed manual NativeAd loading and caching logic

  double _getItemHeight(int index) {
    final double baseHeight = 220.0;
    // Stable pseudo-random height variation based on index to create a natural staggered grid
    final int modifier =
        (index * 47) % 65; // Height modifier between 0 and 65 dp
    return baseHeight + modifier;
  }

  Widget _buildVideoCard(VideoItem item, int index) {
    void openDetails() {
      NavigationService.push(
        context,
        PromptDetailsScreen(
          item: item,
          categoryItems: _viewModel.videos,
          categoryName: widget.categoryName,
          categoryId: widget.categoryId,
        ),
      );
    }

    return SizedBox(
      height: _getItemHeight(index),
      child: PromptGridCard(
        item: item,
        categoryName: '',
        playVideo: false, // Category grid shows thumbnails only — no playback.
        onTap: () {
          // Continue to prompt details whether the ad shows, closes, or fails.
          InterstitialAdService.showAd(
            context: context,
            customAdIds: [AdIds.interCategoryHF2, AdIds.interCategoryLF2],
            onAdClosed: openDetails,
            onAdFailedToShow: openDetails,
          );
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    _viewModel.fetchVideos(widget.categoryId);
  }

  @override
  void dispose() {
    _viewModel.dispose();
    _nativeAdService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainBackground,
      appBar: CommonAppBar(title: widget.categoryName),
      body: AnimatedBuilder(
        animation: _viewModel,
        builder: (context, _) => _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    // Loading state
    if (_viewModel.isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      );
    }

    // Error state
    if (_viewModel.error.isNotEmpty) {
      return ApiErrorResponse(
        message: _viewModel.error,
        onRetry: () => _viewModel.fetchVideos(widget.categoryId),
      );
    }

    // Empty state
    if (_viewModel.videos.isEmpty) {
      return Center(
        child: Text(
          'No templates found in this category.',
          style: AppTextStyles.getStyle(color: AppColors.textMuted),
        ),
      );
    }

    // Thumbnail-only staggered grid
    return MasonryGridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverSimpleGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
      ),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      itemCount: _gridItemCount,
      itemBuilder: (context, index) {
        if (_isAdIndex(index)) {
          return Container(
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
            child: _nativeAdService.buildNativeAdTile(
              index,
              () => setState(() {}),
              customAdIds: [AdIds.nativeHF, AdIds.nativeLF],
              factoryId: Platform.isAndroid
                  ? AppStrings.nativeAdFactoryGridAndroid
                  : AppStrings.nativeAdFactoryGridIOS,
              height: 35.h,
              screenName: 'AiCategoryDetailsScreen',
              shimmer: ShimmerNativeAd.gridViewNativeAdShimmer(),
            ),
          );
        }

        final contentIndex = _gridIndexToContentIndex(index);
        final item = _viewModel.videos[contentIndex];
        return _buildVideoCard(item, index);
      },
    );
  }
}
