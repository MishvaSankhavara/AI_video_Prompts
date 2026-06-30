import 'dart:io';
import 'dart:ui' as ui;
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../adsmanager/native ad/native_ad_service.dart';
import '../../adsmanager/native ad/native_ad_shimmer.dart';
import '../../adsmanager/rewarded_ad_service.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../models/video_category.dart';
import '../../adsmanager/ad_ids.dart';
import '../../services/favorites_service.dart';
import '../../viewmodel/fetch_video_category.dart';
// import '../../services/analytics_service.dart';
import '../../utils/colors.dart';
import '../../utils/strings.dart';
import '../../widgets/text_app.dart';
import '../../widgets/prompt_grid_card.dart';
import '../../widgets/common_video_player.dart';
import '../../widgets/shimmer_loading.dart';
import '../../widgets/dialog/custom_app_dialog.dart';
import '../../widgets/common_app_bar.dart';
import '../../services/navigation_service.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class PromptDetailsScreen extends StatefulWidget {
  final VideoItem item;
  final List<VideoItem> categoryItems;
  final String categoryName;
  final int categoryId;

  const PromptDetailsScreen({
    super.key,
    required this.item,
    required this.categoryItems,
    required this.categoryName,
    required this.categoryId,
  });

  @override
  State<PromptDetailsScreen> createState() => _PromptDetailsScreenState();
}

class _PromptDetailsScreenState extends State<PromptDetailsScreen>
    with TickerProviderStateMixin {
  late VideoItem _currentItem;
  final Set<int> _unlockedItemIds = {};
  final ScrollController _scrollController = ScrollController();
  bool _isAppBarWhite = false;
  final NativeAdService _nativeAdService = NativeAdService();

  bool _isGridAdIndex(int index) {
    return (index + 1) % 6 == 0;
  }

  int _gridAdCountBefore(int index) {
    return (index + 1) ~/ 6;
  }

  int _gridIndexToContentIndex(int index) {
    return index - _gridAdCountBefore(index);
  }

  int _getGridItemCount(int contentCount) {
    if (contentCount == 0) return 0;
    return contentCount + (contentCount - 1) ~/ 5;
  }

  // Removed _loadGridAdForIndex logic

  // Animation for the button pulse and shimmer
  late AnimationController _btnController;
  late Animation<double> _shimmerAnimation;
  late Animation<double> _scaleAnimation;

  bool get _isUnlocked => _unlockedItemIds.contains(_currentItem.id);

  @override
  void initState() {
    super.initState();
    _currentItem = widget.item;
    _scrollController.addListener(_onScroll);

    _btnController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();

    _shimmerAnimation = Tween<double>(
      begin: -1.5,
      end: 2.5,
    ).animate(CurvedAnimation(parent: _btnController, curve: Curves.easeInOut));

    _scaleAnimation =
        TweenSequence<double>([
          TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.025), weight: 50),
          TweenSequenceItem(tween: Tween(begin: 1.025, end: 1.0), weight: 50),
        ]).animate(
          CurvedAnimation(parent: _btnController, curve: Curves.easeInOutQuad),
        );

    _logPromptView();
  }

  void _onScroll() {
    if (_scrollController.hasClients) {
      final isWhite = _scrollController.offset > 20.0;
      if (isWhite != _isAppBarWhite) {
        setState(() {
          _isAppBarWhite = isWhite;
        });
      }
    }
  }

  void _logPromptView() {}

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final favoritesService = Provider.of<FavoritesService>(
      context,
      listen: false,
    );
    if (favoritesService.isFavorite(_currentItem)) {
      _unlockedItemIds.add(_currentItem.id);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _btnController.dispose();
    _nativeAdService.dispose();
    super.dispose();
  }

  // Removed _loadNativeAd logic

  String _getTruncatedPrompt(String fullPrompt) {
    String trimmed = fullPrompt.trim();
    List<String> words = trimmed.split(RegExp(r'\s+'));
    if (words.length <= 10) {
      return '$trimmed${AppStrings.truncationSuffix}';
    }
    return '${words.take(10).join(' ')}${AppStrings.truncationSuffix}';
  }

  void _showUnlockDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return CustomAppDialog(
          title: AppStrings.unlockDialogTitle,
          subtitle: AppStrings.unlockDialogSubtitle,
          icon: FontAwesomeIcons.crown,
          primaryButtonText: AppStrings.unlockDialogBuyPro,
          onPrimaryPressed: () {
            Navigator.pop(context);
          },
          secondaryButtonText: AppStrings.unlockDialogWatchAd,
          onSecondaryPressed: () {
            Navigator.pop(context);
            // Unlock the prompt once the ad flow ends — whether it closes or
            // fails to show — so the user is never blocked by the ad.
            void grantUnlock() {
              setState(() {
                _unlockedItemIds.add(_currentItem.id);
              });
              _showRewardGrantedDialog();
            }

            RewardedAdService.showAd(
              context: context,
              customAdIds: [AdIds.rewardedHF, AdIds.rewardedLF],
              onUserEarnedReward: () {},
              onAdClosed: grantUnlock,
              onAdFailedToShow: grantUnlock,
            );
          },
          showCloseButton: true,
        );
      },
    );
  }

  void _showRewardGrantedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return CustomAppDialog(
          title: AppStrings.rewardDialogTitle,
          subtitle: AppStrings.rewardDialogSubtitle,
          icon: FontAwesomeIcons.circleCheck,
          primaryButtonText: AppStrings.rewardDialogDone,
          onPrimaryPressed: () {
            Navigator.pop(context);
            setState(() {
              _unlockedItemIds.add(_currentItem.id);
            });
          },
        );
      },
    );
  }

  //Unlock Button
  Widget _buildActionButton({
    required VoidCallback onTap,
    required FaIconData icon,
    required String label,
    bool isUnlock = false,
  }) {
    final List<Color> gradientColors = isUnlock
        ? [AppColors.unLockButton, AppColors.secondary, AppColors.primary]
        : [AppColors.primary, AppColors.secondary, AppColors.primary];

    return AnimatedBuilder(
      animation: _btnController,
      builder: (context, child) {
        return Transform.scale(
          scale: isUnlock ? _scaleAnimation.value : 1.0,
          child: Container(
            width: double.infinity,
            height: 62,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: gradientColors[1].withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.2),
                  blurRadius: 0,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                children: [
                  // Base Gradient
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: gradientColors,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                  ),

                  // Animated Liquid Shimmer
                  Positioned.fill(
                    child: FractionallySizedBox(
                      alignment: Alignment(_shimmerAnimation.value, 0),
                      widthFactor: 0.7,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withValues(alpha: 0.0),
                              Colors.white.withValues(alpha: 0.35),
                              Colors.white.withValues(alpha: 0.0),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Glossy Top Highlight
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 33,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white.withValues(alpha: 0.15),
                            Colors.white.withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Interaction Layer
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onTap,
                      splashColor: Colors.white.withValues(alpha: 0.3),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.18),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.25),
                                  width: 1,
                                ),
                              ),
                              child: FaIcon(
                                icon,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              label,
                              style: AppTextStyles.getStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLikeButton(FavoritesService favoritesService, bool isFav) {
    return Container(
      width: 62,
      height: 62,
      decoration: BoxDecoration(
        color: isFav ? AppColors.primary : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isFav ? AppColors.primary : AppColors.border,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isFav
                ? AppColors.primary.withValues(alpha: 0.25)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              favoritesService.toggleFavorite(_currentItem);
            },
            splashColor: (isFav ? Colors.white : AppColors.primary).withValues(
              alpha: 0.15,
            ),
            child: Center(
              child: AnimatedScale(
                scale: isFav ? 1.15 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: FaIcon(
                  isFav ? FontAwesomeIcons.solidHeart : FontAwesomeIcons.heart,
                  color: isFav ? Colors.white : AppColors.primary,
                  size: 22,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBlurredBackground() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: 540,
      child: ClipRect(
        child: Stack(
          children: [
            // Background thumbnail image
            Positioned.fill(
              child: _currentItem.videoThumbnailFullUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: _currentItem.videoThumbnailFullUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const ShimmerLoading(),
                      errorWidget: (context, url, error) =>
                          Container(color: AppColors.mainBackground),
                    )
                  : Container(color: AppColors.mainBackground),
            ),
            // Blur effect
            Positioned.fill(
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  color: Colors.white.withValues(
                    alpha: 0.65,
                  ), // Light theme translucent overlay
                ),
              ),
            ),
            // Smooth gradient fade to white at the bottom to remove the partition line
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.white38,
                      Colors.white70,
                      AppColors.mainBackground,
                    ],
                    stops: [0.0, 0.6, 0.85, 1.0],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final favoritesService = Provider.of<FavoritesService>(context);
    final isFav = favoritesService.isFavorite(_currentItem);

    List<VideoItem> categoryItems = widget.categoryItems;
    if (widget.categoryName == AppStrings.categoryFavorites) {
      final categoryVM = Provider.of<FetchVideoCategoryViewModel>(
        context,
        listen: false,
      );
      try {
        final matchedCategory = categoryVM.categories.firstWhere(
          (cat) => cat.items.any((item) => item.id == _currentItem.id),
        );
        categoryItems = matchedCategory.items;
      } catch (_) {}
    }

    final recommendedItems = categoryItems
        .where(
          (element) =>
              element.id != _currentItem.id &&
              !favoritesService.isFavorite(element),
        )
        .toList();

    final displayPrompt = (_isUnlocked || isFav)
        ? _currentItem.aiPrompt
        : _getTruncatedPrompt(_currentItem.aiPrompt);

    return Scaffold(
      backgroundColor: AppColors.mainBackground,
      extendBodyBehindAppBar: true,
      appBar: CommonAppBar(
        title: '',
        backgroundColor: _isAppBarWhite ? Colors.white : Colors.transparent,
        surfaceTintColor: _isAppBarWhite ? Colors.white : Colors.transparent,
        actions: (_isUnlocked || isFav)
            ? [
                IconButton(
                  icon: const FaIcon(
                    FontAwesomeIcons.shareNodes,
                    color: AppColors.textPrimary,
                  ),
                  onPressed: () {
                    SharePlus.instance.share(
                      ShareParams(text: _currentItem.aiPrompt),
                    );
                  },
                ),
              ]
            : null,
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Stack(
          children: [
            _buildBlurredBackground(),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 12.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: kToolbarHeight + 20),
                  Center(
                    child: Container(
                      width: 300,
                      height: 490,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),
                            blurRadius: 24,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: CommonVideoPlayer(
                        videoUrl: _currentItem.categoryVideoFullUrl,
                        thumbnailUrl: _currentItem.videoThumbnailFullUrl,
                        isMuted: false,
                        isLooping: true,
                        interactivePlayPause: true,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.border.withValues(alpha: 0.8),
                        width: 1.2,
                      ),
                    ),
                    child: Text(
                      displayPrompt,
                      style: AppTextStyles.getStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        height: 1.55,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (!(_isUnlocked || isFav))
                    _buildActionButton(
                      onTap: _showUnlockDialog,
                      icon: FontAwesomeIcons.lock,
                      label: AppStrings.detailsUnlockPrompt,
                      isUnlock: true,
                    )
                  else
                    Row(
                      children: [
                        Expanded(
                          child: _buildActionButton(
                            onTap: () {
                              Clipboard.setData(
                                ClipboardData(text: _currentItem.aiPrompt),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    AppStrings.detailsCopiedMessage,
                                  ),
                                  backgroundColor: AppColors.primary,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              );
                            },
                            icon: FontAwesomeIcons.copy,
                            label: AppStrings.detailsCopyPrompt,
                          ),
                        ),
                        const SizedBox(width: 12),
                        _buildLikeButton(favoritesService, isFav),
                      ],
                    ),
                  if (AdIds.showAdsEnabled) ...[
                    const SizedBox(height: 20),
                    Container(
                      key: const ValueKey('prompt_details_native_ad'),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.border.withValues(alpha: 0.8),
                          width: 1.2,
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
                      child: _nativeAdService.buildNativeAdTile(
                        0, // Using 0 as index for single ad
                        () => setState(() {}),
                        customAdIds: [AdIds.nativeHF, AdIds.nativeLF],
                        factoryId: Platform.isAndroid
                            ? AppStrings.nativeAdFactoryMediumAndroid
                            : AppStrings.nativeAdFactoryMediumIOS,
                        height: 16.h,
                        screenName: 'AiPromptDetailsScreen_Medium',
                        shimmer: ShimmerNativeAd.mediumNativeAdShimmer(),
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
                  if (_isUnlocked || isFav) ...[
                    _buildPromptGuidance(),
                    const SizedBox(height: 15),
                  ],
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppStrings.detailsExplore,
                        style: AppTextStyles.getStyle(
                          color: AppColors.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () => NavigationService.pop(context),
                        child: Text(
                          AppStrings.detailsViewMore,
                          style: AppTextStyles.getStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (recommendedItems.isEmpty)
                    Center(child: Text(AppStrings.detailsNoRecommendations))
                  else
                    MasonryGridView.builder(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverSimpleGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                          ),
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      itemCount: _getGridItemCount(recommendedItems.length),
                      itemBuilder: (context, index) {
                        if (_isGridAdIndex(index)) {
                          return Container(
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
                            child: _nativeAdService.buildNativeAdTile(
                              index,
                              () => setState(() {}),
                              customAdIds: [AdIds.nativeHF, AdIds.nativeLF],
                              factoryId: Platform.isAndroid
                                  ? AppStrings.nativeAdFactoryGridAndroid
                                  : AppStrings.nativeAdFactoryGridIOS,
                              height: 35.h,
                              screenName: 'AiPromptDetailsScreen_Grid',
                              shimmer:
                                  ShimmerNativeAd.gridViewNativeAdShimmer(),
                            ),
                          );
                        }

                        final contentIndex = _gridIndexToContentIndex(index);
                        final item = recommendedItems[contentIndex];
                        return AspectRatio(
                          aspectRatio: 0.72,
                          child: PromptGridCard(
                            item: item,
                            categoryName: '',
                            isPremium: contentIndex % 3 == 0,
                            onTap: () {
                              NavigationService.push(
                                context,
                                PromptDetailsScreen(
                                  item: item,
                                  categoryItems: widget.categoryItems,
                                  categoryName: widget.categoryName,
                                  categoryId: widget.categoryId,
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromptGuidance() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardBackground.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.8),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const FaIcon(
                FontAwesomeIcons.wandMagicSparkles,
                color: AppColors.primary,
                size: 22,
              ),
              const SizedBox(width: 14),
              Text(
                AppStrings.guidanceHeaderTitle,
                style: AppTextStyles.getStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          _buildStepRow(
            stepNumber: '1',
            title: AppStrings.guidanceStep1Title,
            description: AppStrings.guidanceStep1Desc,
            gradientColors: [const Color(0xFF0D9488), const Color(0xFF14B8A6)],
          ),
          const SizedBox(height: 18),
          _buildStepRow(
            stepNumber: '2',
            title: AppStrings.guidanceStep2Title,
            description: AppStrings.guidanceStep2Desc,
            gradientColors: [const Color(0xFF4F46E5), const Color(0xFF6366F1)],
          ),
          const SizedBox(height: 18),
          _buildStepRow(
            stepNumber: '3',
            title: AppStrings.guidanceStep3Title,
            description: AppStrings.guidanceStep3Desc,
            gradientColors: [const Color(0xFF8B5CF6), const Color(0xFFA78BFA)],
          ),
        ],
      ),
    );
  }

  Widget _buildStepRow({
    required String stepNumber,
    required String title,
    required String description,
    required List<Color> gradientColors,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: gradientColors),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: gradientColors[0].withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              stepNumber,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.getStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                description,
                style: AppTextStyles.getStyle(
                  color: AppColors.textMuted,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
