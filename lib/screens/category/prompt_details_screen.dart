import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../models/video_category.dart';
import '../../services/app_state.dart';
import '../../services/analytics_service.dart';
import '../../utils/colors.dart';
import '../../utils/strings.dart';
import '../../utils/text_app.dart';
import '../../widgets/prompt_grid_card.dart';
import '../../widgets/video_player.dart';
import '../../widgets/dialog/custom_app_dialog.dart';
import '../../widgets/common_app_bar.dart';
import 'category_details_screen.dart';

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

class _PromptDetailsScreenState extends State<PromptDetailsScreen> {
  late VideoItem _currentItem;
  final Set<int> _unlockedItemIds = {};

  bool get _isUnlocked => _unlockedItemIds.contains(_currentItem.id);

  @override
  void initState() {
    super.initState();
    _currentItem = widget.item;
    _logPromptView();
  }

  void _logPromptView() {
    AnalyticsService.instance.logScreenView(screenName: 'prompt_details');
    AnalyticsService.instance.logEvent(
      name: 'view_prompt',
      parameters: {
        'prompt_id': _currentItem.id,
        'category_name': widget.categoryName,
        'category_id': widget.categoryId,
      },
    );
  }

  void _changeCurrentItem(VideoItem newItem) {
    setState(() {
      _currentItem = newItem;
    });
    _logPromptView();
  }

  @override
  void dispose() {
    super.dispose();
  }

  String _getTruncatedPrompt(String fullPrompt) {
    String trimmed = fullPrompt.trim();
    List<String> words = trimmed.split(RegExp(r'\s+'));
    if (words.length <= 10) {
      return '$trimmed....';
    }
    return '${words.take(10).join(' ')}....';
  }

  void _showUnlockDialog() {
    AnalyticsService.instance.logEvent(
      name: 'unlock_prompt_dialog_viewed',
      parameters: {'prompt_id': _currentItem.id},
    );
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
            AnalyticsService.instance.logEvent(
              name: 'unlock_prompt_buy_pro_tapped',
              parameters: {'prompt_id': _currentItem.id},
            );
            Navigator.pop(context);
          },
          secondaryButtonText: AppStrings.unlockDialogWatchAd,
          onSecondaryPressed: () {
            AnalyticsService.instance.logEvent(
              name: 'unlock_prompt_watch_ad_tapped',
              parameters: {'prompt_id': _currentItem.id},
            );
            Navigator.pop(context); // Close Unlock Dialog
            _showRewardGrantedDialog();
          },
          showCloseButton: true,
        );
      },
    );
  }

  void _showRewardGrantedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // User must press Done
      builder: (BuildContext context) {
        return CustomAppDialog(
          title: AppStrings.rewardDialogTitle,
          subtitle: AppStrings.rewardDialogSubtitle,
          icon: FontAwesomeIcons.circleCheck,
          primaryButtonText: AppStrings.rewardDialogDone,
          onPrimaryPressed: () {
            AnalyticsService.instance.logEvent(
              name: 'unlock_prompt_success',
              parameters: {'prompt_id': _currentItem.id},
            );
            Navigator.pop(context); // Close Dialog
            setState(() {
              _unlockedItemIds.add(_currentItem.id);
            });
          },
        );
      },
    );
  }

  Widget _buildPromptGuidance() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.8),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row with glowing icon
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const FaIcon(
                  FontAwesomeIcons.wandMagicSparkles,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.guidanceHeaderTitle,
                      style: AppTextStyles.getStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      AppStrings.guidanceHeaderSubtitle,
                      style: AppTextStyles.getStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Divider(color: AppColors.border.withValues(alpha: 0.6), height: 1, thickness: 1.2),
          const SizedBox(height: 15),

          // Step 1: Copy
          _buildStepRow(
            stepNumber: '1',
            title: AppStrings.guidanceStep1Title,
            description: AppStrings.guidanceStep1Desc,
            gradientColors: [const Color(0xFF0D9488), const Color(0xFF14B8A6)], // Vibrant Teal
          ),
          const SizedBox(height: 15),

          // Step 2: Choose AI tool
          _buildStepRow(
            stepNumber: '2',
            title: AppStrings.guidanceStep2Title,
            description: AppStrings.guidanceStep2Desc,
            gradientColors: [const Color(0xFF4F46E5), const Color(0xFF6366F1)], // Vibrant Indigo
          ),
          const SizedBox(height: 15),

          // Step 3: Paste and generate
          _buildStepRow(
            stepNumber: '3',
            title: AppStrings.guidanceStep3Title,
            description: AppStrings.guidanceStep3Desc,
            gradientColors: [const Color(0xFF8B5CF6), const Color(0xFFA78BFA)], // Vibrant Purple
          ),
          const SizedBox(height: 15),

          // Beautiful Pro Tip Box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.03),
                  AppColors.primary.withValues(alpha: 0.08),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.15),
                width: 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const FaIcon(
                  FontAwesomeIcons.lightbulb,
                  color: Color(0xFFF59E0B), // Warm Gold color
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.guidanceTipTitle,
                        style: AppTextStyles.getStyle(
                          color: AppColors.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppStrings.guidanceTipDesc,
                        style: AppTextStyles.getStyle(
                          color: AppColors.textMuted,
                          fontSize: 12,
                          height: 1.4,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
        // Number badge with a glowing shadow
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: gradientColors[0].withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: Text(
              stepNumber,
              style: AppTextStyles.getStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        // Step details
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
              const SizedBox(height: 4),
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

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isFav = appState.isFavorite(_currentItem);

    // Get the category items: if we came from Favorites screen, find the original category of this item
    List<VideoItem> categoryItems = widget.categoryItems;
    if (widget.categoryName == AppStrings.categoryFavorites) {
      try {
        final matchedCategory = appState.categories.firstWhere(
          (cat) {
            if (_currentItem.categoryId != null && _currentItem.categoryId != 0) {
              return cat.categoryId == _currentItem.categoryId;
            }
            return cat.items.any((item) => item.id == _currentItem.id);
          },
        );
        categoryItems = matchedCategory.items;
      } catch (_) {
        // Fallback to widget.categoryItems if not found
      }
    }

    // Filter out the currently selected item and any favorited items from the recommended grid
    final recommendedItems = categoryItems
        .where((element) => element.id != _currentItem.id && !appState.isFavorite(element))
        .toList();

    final displayPrompt = (_isUnlocked || isFav) 
        ? _currentItem.aiPrompt 
        : _getTruncatedPrompt(_currentItem.aiPrompt);

    return Scaffold(
      backgroundColor: AppColors.mainBackground,
      appBar: CommonAppBar(
        title: '',
        actions: (_isUnlocked || isFav)
            ? [
                IconButton(
                  icon: FaIcon(
                    isFav ? FontAwesomeIcons.solidHeart : FontAwesomeIcons.heart,
                    color: isFav ? Colors.redAccent : AppColors.textPrimary,
                  ),
                  onPressed: () {
                    appState.toggleFavorite(_currentItem);
                    AnalyticsService.instance.logEvent(
                      name: 'toggle_favorite',
                      parameters: {
                        'prompt_id': _currentItem.id,
                        'is_favorite': (!isFav).toString(),
                      },
                    );
                  },
                ),
                IconButton(
                  icon: const FaIcon(FontAwesomeIcons.shareNodes, color: AppColors.textPrimary),
                  onPressed: () {
                    SharePlus.instance.share(
                      ShareParams(text: _currentItem.aiPrompt),
                    );
                    AnalyticsService.instance.logEvent(
                      name: 'share_prompt',
                      parameters: {
                        'prompt_id': _currentItem.id,
                      },
                    );
                  },
                ),
              ]
            : null,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Large Vertical Preview Image/Video Player (9:16 layout)
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.85,
                height: 380,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
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
            const SizedBox(height: 24),

            // 2. Prompt Text Card Description
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border, width: 1),
              ),
              child: Text(
                displayPrompt,
                style: AppTextStyles.getStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  height: 1.45,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 3. Action Button (Unlock or Copy)
            if (!(_isUnlocked || isFav))
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _showUnlockDialog,
                  icon: const FaIcon(
                    FontAwesomeIcons.lock,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  label: Text(
                    AppStrings.detailsUnlockPrompt,
                    style: AppTextStyles.getStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF8F9FB),
                    foregroundColor: AppColors.textPrimary,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: AppColors.textPrimary.withValues(alpha: 0.15),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              )
            else
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Clipboard.setData(
                      ClipboardData(text: _currentItem.aiPrompt),
                    );

                    AnalyticsService.instance.logEvent(
                      name: 'copy_prompt',
                      parameters: {
                        'prompt_id': _currentItem.id,
                        'category_name': widget.categoryName,
                      },
                    );

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text(
                          AppStrings.detailsCopiedMessage,
                        ),
                        backgroundColor: AppColors.primary,
                      ),
                    );
                  },
                  icon: const FaIcon(
                    FontAwesomeIcons.copy,
                    size: 18,
                    color: AppColors.textPrimary,
                  ),
                  label: Text(
                    AppStrings.detailsCopyPrompt,
                    style: AppTextStyles.getStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textPrimary,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: AppColors.textPrimary.withValues(alpha: 0.15),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),

            if (_isUnlocked || isFav) ...[
              const SizedBox(height: 24),
              _buildPromptGuidance(),
              const SizedBox(height: 16),
            ] else ...[
              const SizedBox(height: 32),
            ],

            // 4. Recommended Section Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppStrings.detailsExplore,
                  style: AppTextStyles.getStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    if (widget.categoryId == 999 || widget.categoryName == AppStrings.categoryFavorites) {
                      final appState = Provider.of<AppState>(context, listen: false);
                      int? targetCategoryId = _currentItem.categoryId;
                      
                      VideoCategory? matchedCategory;
                      try {
                        matchedCategory = appState.categories.firstWhere(
                          (cat) {
                            if (targetCategoryId != null && targetCategoryId != 0) {
                              return cat.categoryId == targetCategoryId;
                            }
                            return cat.items.any((item) => item.id == _currentItem.id);
                          },
                        );
                        targetCategoryId = matchedCategory.categoryId;
                      } catch (_) {
                        // Fallback
                      }

                      if (targetCategoryId != null && targetCategoryId != 0) {
                        final catName = matchedCategory?.categoryName ?? AppStrings.categoryDefaultFallback;
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CategoryDetailsScreen(
                              categoryId: targetCategoryId!,
                              categoryName: catName,
                            ),
                          ),
                        );
                      } else {
                        Navigator.pop(context);
                      }
                    } else {
                      Navigator.pop(context);
                    }
                  },
                  child: Text(
                    AppStrings.detailsViewMore,
                    style: AppTextStyles.getStyle(
                      fontSize: 14,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // 5. Recommended Grids
            if (recommendedItems.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: Center(
                  child: Text(
                    AppStrings.detailsNoRecommendations,
                    style: AppTextStyles.getStyle(color: AppColors.textMuted),
                  ),
                ),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.70,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: recommendedItems.length,
                itemBuilder: (context, index) {
                  final recItem = recommendedItems[index];
                  // Hide labels on cards by passing empty categoryName as requested
                  return PromptGridCard(
                    item: recItem,
                    categoryName: '',
                    isPremium: index == 0,
                    onTap: () {
                      _changeCurrentItem(recItem);
                    },
                  );
                },
              ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
