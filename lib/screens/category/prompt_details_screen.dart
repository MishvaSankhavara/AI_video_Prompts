import 'package:aivideoprompt/widgets/text_app.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
import '../../widgets/prompt_grid_card.dart';
import '../../widgets/common_video_player.dart';
import '../../widgets/shimmer_loading.dart';
import '../../widgets/dialog/custom_app_dialog.dart';
import '../../widgets/common_app_bar.dart';
import '../../services/navigation_service.dart';
import '../../services/remote_config_service.dart';
import '../pro/pro_screen.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class PromptDetailsScreen extends StatefulWidget {
  final VideoItem item;
  final List<VideoItem> categoryItems;
  final String categoryName;
  final int categoryId;
  final bool isFromSaved;

  const PromptDetailsScreen({
    super.key,
    required this.item,
    required this.categoryItems,
    required this.categoryName,
    required this.categoryId,
    this.isFromSaved = false,
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
          TweenSequenceItem(tween: Tween(begin: 1, end: 1.025), weight: 50),
          TweenSequenceItem(tween: Tween(begin: 1.025, end: 1), weight: 50),
        ]).animate(
          CurvedAnimation(parent: _btnController, curve: Curves.easeInOutQuad),
        );

    _logPromptView();
  }

  void _onScroll() {
    if (_scrollController.hasClients) {
      final isWhite = _scrollController.offset > 20;
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
            NavigationService.push(context, const ProScreen());
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
              customAdIds: [AdIds.rewardedAds1, AdIds.rewardedAds2],
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

    Widget buildContent(double shimmerValue, double scaleValue) {
      return Transform.scale(
        scale: scaleValue,
        child: Container(
          width: double.infinity,
          height: 50.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18.r),
            boxShadow: [
              BoxShadow(
                color: gradientColors[1].withValues(alpha: 0.3),
                blurRadius: 20.r,
                offset: Offset(0.w, 10.h),
              ),
              BoxShadow(
                color: AppColors.white.withValues(alpha: 0.2),
                blurRadius: 0.r,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24.r),
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
                if (isUnlock)
                  Positioned.fill(
                    child: FractionallySizedBox(
                      alignment: Alignment(shimmerValue, 0),
                      widthFactor: 0.7,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.white.withValues(alpha: 0),
                              AppColors.white.withValues(alpha: 0.35),
                              AppColors.white.withValues(alpha: 0),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ),
                    ),
                  ),

                // Glossy Top Highlight
                if (isUnlock)
                  Positioned(
                    top: 0.h,
                    left: 0.w,
                    right: 0.w,
                    height: 33.h,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColors.white.withValues(alpha: 0.15),
                            AppColors.white.withValues(alpha: 0),
                          ],
                        ),
                      ),
                    ),
                  ),

                // Interaction Layer
                Material(
                  color: AppColors.transparent,
                  child: InkWell(
                    onTap: onTap,
                    splashColor: AppColors.white.withValues(alpha: 0.3),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.all(10.r),
                            decoration: BoxDecoration(
                              color: AppColors.white.withValues(alpha: 0.18),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.white.withValues(alpha: 0.25),
                                width: 1.w,
                              ),
                            ),
                            child: FaIcon(
                              icon,
                              size: 16.sp,
                              color: AppColors.white,
                            ),
                          ),
                          SizedBox(width: 16.w),
                          Text(
                            label,
                            style: AppTextStyles.getStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w900,
                              color: AppColors.white,
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
    }

    if (isUnlock) {
      return AnimatedBuilder(
        animation: _btnController,
        builder: (context, child) {
          return buildContent(_shimmerAnimation.value, _scaleAnimation.value);
        },
      );
    } else {
      return buildContent(0, 1);
    }
  }

  Widget _buildLikeButton(FavoritesService favoritesService, bool isFav) {
    return Container(
      // width: 62.w,
      // height: 62.h,
      width: 50.w,
      height: 50.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            blurRadius: 10.r,
            offset: Offset(0.w, 5.h),
          ),
        ],
      ),
      child: Material(
        color: AppColors.white,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18.r),
          side: BorderSide(
            color: AppColors.border,
            width: 1.5.w,
          ),
        ),
        child: InkWell(
          onTap: () {
            favoritesService.toggleFavorite(_currentItem);
          },
          splashColor: AppColors.primary.withValues(
            alpha: 0.15,
          ),
          child: Center(
            child: AnimatedScale(
              scale: isFav ? 1.12 : 1.10,
              duration: const Duration(milliseconds: 200),
              child: Image.asset(
                isFav
                    ? 'assets/images/ic_like.png'
                    : 'assets/images/ic_like_border.png',
                color: AppColors.primary,
                width: 24.w,
                height: 24.h,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBlurredBackground() {
    return Positioned(
      top: 0.h,
      left: 0.w,
      right: 0.w,
      height: 540.h,
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
                  color: AppColors.white.withValues(
                    alpha: 0.65,
                  ), // Light theme translucent overlay
                ),
              ),
            ),
            // Smooth gradient fade to white at the bottom to remove the partition line
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.transparent,
                      AppColors.white38,
                      AppColors.white70,
                      AppColors.mainBackground,
                    ],
                    stops: [0, 0.6, 0.85, 1],
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
        backgroundColor: _isAppBarWhite ? AppColors.white : AppColors.transparent,
        surfaceTintColor: _isAppBarWhite ? AppColors.white : AppColors.transparent,
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
              padding: EdgeInsets.symmetric(
                horizontal: 20.w,
                vertical: 12.h,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: kToolbarHeight + 20),
                  Center(
                    child: Container(
                      width: 300.w,
                      height: 490.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24.r),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.black.withValues(alpha: 0.12),
                            blurRadius: 24.r,
                            offset: Offset(0.w, 12.h),
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
                  SizedBox(height: 28.h),
                  Container(
                    padding: EdgeInsets.all(22.r),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20.r),
                        topRight: Radius.circular(20.r),
                        bottomLeft: Radius.circular((_isUnlocked || isFav) ? 20 : 0),
                        bottomRight: Radius.circular((_isUnlocked || isFav) ? 20 : 0),
                      ),
                      border: Border(
                        top: BorderSide(color: AppColors.border.withValues(alpha: 0.8), width: 1.2.w),
                        left: BorderSide(color: AppColors.border.withValues(alpha: 0.8), width: 1.2.w),
                        right: BorderSide(color: AppColors.border.withValues(alpha: 0.8), width: 1.2.w),
                        bottom: (_isUnlocked || isFav)
                            ? BorderSide(color: AppColors.border.withValues(alpha: 0.8), width: 1.2.w)
                            : BorderSide.none,
                      ),
                    ),
                    child: Text(
                      displayPrompt,
                      style: AppTextStyles.getStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16.sp,
                        height: 1.55.h,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),
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
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                ),
                              );
                            },
                            icon: FontAwesomeIcons.copy,
                            label: AppStrings.detailsCopyPrompt,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        _buildLikeButton(favoritesService, isFav),
                      ],
                    ),
                  if (RemoteConfigService.instance.showAdsEnabled) ...[
                    SizedBox(height: 20.h),
                    Container(
                      key: const ValueKey('prompt_details_native_ad'),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(20.r),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.black.withValues(alpha: 0.03),
                            blurRadius: 8.r,
                            offset: Offset(0.w, 4.h),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: _nativeAdService.buildNativeAdTile(
                        0, // Using 0 as index for single ad
                        () => setState(() {}),
                        customAdIds: [AdIds.nativeAd1, AdIds.nativeAd2],
                        factoryId: Platform.isAndroid
                            ? AppStrings.nativeAdFactoryMediumAndroid
                            : AppStrings.nativeAdFactoryMediumIOS,
                        height: 0.16.sh,
                        screenName: 'AiPromptDetailsScreen_Medium',
                        shimmer: ShimmerNativeAd.mediumNativeAdShimmer(),
                      ),
                    ),
                  ],
                  SizedBox(height: 10.h),
                  if (_isUnlocked || isFav) ...[
                    _buildPromptGuidance(),
                    SizedBox(height: 6.h),
                  ],
                                    if (!widget.isFromSaved) ...[
Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppStrings.detailsExplore,
                        style: AppTextStyles.getStyle(
                          color: AppColors.textPrimary,
                          fontSize: 20.sp,
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
                              borderRadius: BorderRadius.circular(24.r),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.black.withValues(alpha: 0.03),
                                  blurRadius: 8.r,
                                  offset: Offset(0.w, 4.h),
                                ),
                              ],
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: _nativeAdService.buildNativeAdTile(
                              index,
                              () => setState(() {}),
                              customAdIds: [AdIds.nativeAd1, AdIds.nativeAd2],
                              factoryId: Platform.isAndroid
                                  ? AppStrings.nativeAdFactoryGridAndroid
                                  : AppStrings.nativeAdFactoryGridIOS,
                              height: 0.35.sh,
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
                  ],

                  SizedBox(height: 20.h),
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
      padding: EdgeInsets.all(24.r),
      decoration: BoxDecoration(
        color: AppColors.cardBackground.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(28.r),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.8),
          width: 1.5.w,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              FaIcon(
                FontAwesomeIcons.wandMagicSparkles,
                color: AppColors.primary,
                size: 22.sp,
              ),
              SizedBox(width: 14.w),
              Text(
                AppStrings.guidanceHeaderTitle,
                style: AppTextStyles.getStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 22.h),
          _buildStepRow(
            stepNumber: '1',
            title: AppStrings.guidanceStep1Title,
            description: AppStrings.guidanceStep1Desc,
            gradientColors: const [AppColors.teal600, AppColors.teal400],
          ),
          SizedBox(height: 18.h),
          _buildStepRow(
            stepNumber: '2',
            title: AppStrings.guidanceStep2Title,
            description: AppStrings.guidanceStep2Desc,
            gradientColors: const [AppColors.indigo600, AppColors.indigo500],
          ),
          SizedBox(height: 18.h),
          _buildStepRow(
            stepNumber: '3',
            title: AppStrings.guidanceStep3Title,
            description: AppStrings.guidanceStep3Desc,
            gradientColors: const [AppColors.violet500, AppColors.violet400],
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
          width: 30.w,
          height: 30.h,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: gradientColors),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: gradientColors[0].withValues(alpha: 0.3),
                blurRadius: 8.r,
                offset: Offset(0.w, 4.h),
              ),
            ],
          ),
          child: Center(
            child: Text(
              stepNumber,
              style: AppTextStyles.getStyle(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13.sp,
              ),
            ),
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.getStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 5.h),
              Text(
                description,
                style: AppTextStyles.getStyle(
                  color: AppColors.textMuted,
                  fontSize: 13.sp,
                  height: 1.4.h,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
