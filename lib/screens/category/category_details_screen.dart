import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../adsmanager/native_ad_service.dart';
import '../../adsmanager/custom_native_ad.dart';
import '../../adsmanager/interstitial_ad_service.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../adsmanager/ad_ids.dart';
import '../../models/video_category.dart';
import '../../services/api_service.dart';
// import '../../services/analytics_service.dart';
import '../../utils/colors.dart';
import '../../utils/text_app.dart';
import '../../widgets/common_app_bar.dart';
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
  final ApiService _apiService = ApiService();
  List<VideoItem> _videos = [];
  bool _isLoading = true;
  String _errorMessage = '';

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
    if (_videos.isEmpty) return 0;
    return _videos.length + (_videos.length - 1) ~/ 5;
  }

  // Removed manual NativeAd loading and caching logic


  double _getItemHeight(int index) {
    final double baseHeight = 220.0;
    // Stable pseudo-random height variation based on index to create a natural staggered grid
    final int modifier = (index * 47) % 65; // Height modifier between 0 and 65 dp
    return baseHeight + modifier;
  }

  Widget _buildVideoCard(VideoItem item, int index) {
    final double height = _getItemHeight(index);
    return GestureDetector(
      onTap: () {
        // Show interstitial ad, then navigate to prompt details
        InterstitialAdService.showAd(
          context: context,
          customAdIds: [AdIds.interCategoryHF2, AdIds.interCategoryLF2],
          onAdClosed: () {
            NavigationService.push(
              context,
              PromptDetailsScreen(
                item: item,
                categoryItems: _videos,
                categoryName: widget.categoryName,
                categoryId: widget.categoryId,
              ),
            );
          },
        );
      },
      child: Container(
        height: height,
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
        child: CachedNetworkImage(
          imageUrl: item.videoThumbnailFullUrl,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            color: AppColors.cardBackground,
          ),
          errorWidget: (context, url, error) => Container(
            color: AppColors.cardBackground,
            alignment: Alignment.center,
            child: const FaIcon(
              FontAwesomeIcons.circleExclamation,
              color: AppColors.textMuted,
              size: 32,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    
    
    _fetchCategoryVideos();

    // Load Category Interstitial Ad
    
  }

  Future<void> _fetchCategoryVideos() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final videos = await _apiService.fetchVideosByCategoryId(widget.categoryId);
      for (var v in videos) {
        v.categoryId = widget.categoryId;
      }
      if (mounted) {
        setState(() {
          _videos = videos;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainBackground,
      appBar: CommonAppBar(
        title: widget.categoryName,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    // Loading state
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      );
    }

    // Error state
    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const FaIcon(FontAwesomeIcons.triangleExclamation, size: 64, color: AppColors.textMuted),
              const SizedBox(height: 16),
              Text(
                _errorMessage,
                textAlign: TextAlign.center,
                style: AppTextStyles.getStyle(color: AppColors.textPrimary, fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _fetchCategoryVideos,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    // Empty state
    if (_videos.isEmpty) {
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
            height: 280.0, // Optimized height to perfectly fit the medium ad template
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
            child: NativeAdService.instance.showAd(
              index,
              () => setState(() {}),
              customAdIds: [AdIds.nativeAdUnitId],
              factoryId: 'grid_ad_factory',
              screenName: 'AiCategoryDetailsScreen',
              shimmer: ShimmerNativeAd.gridViewNativeAdShimmer(),
            ),
          );
        }

        final contentIndex = _gridIndexToContentIndex(index);
        final item = _videos[contentIndex];
        return _buildVideoCard(item, index);
      },
    );
  }
}
