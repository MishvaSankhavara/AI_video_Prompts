import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../models/video_category.dart';
import '../../services/app_state.dart';
import '../../utils/colors.dart';
import '../../utils/strings.dart';
import '../../utils/text_app.dart';
import '../../widgets/prompt_grid_card.dart';
import '../../widgets/common_video_player.dart';
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
  }

  void _changeCurrentItem(VideoItem newItem) {
    setState(() {
      _currentItem = newItem;
    });
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
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return CustomAppDialog(
          title: AppStrings.unlockDialogTitle,
          subtitle: AppStrings.unlockDialogSubtitle,
          primaryButtonText: AppStrings.unlockDialogBuyPro,
          onPrimaryPressed: () {
            Navigator.pop(context);
          },
          secondaryButtonText: AppStrings.unlockDialogWatchAd,
          onSecondaryPressed: () {
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
          primaryButtonText: AppStrings.rewardDialogDone,
          onPrimaryPressed: () {
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
      padding: EdgeInsets.all(5.5.w),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(6.w),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.8),
          width: 0.3.w,
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
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(3.w),
                ),
                child: Icon(
                  Icons.auto_awesome_rounded,
                  color: AppColors.primary,
                  size: 6.w,
                ),
              ),
              SizedBox(width: 3.w),
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
                    SizedBox(height: 0.2.h),
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
          SizedBox(height: 2.h),
          Divider(color: AppColors.border.withValues(alpha: 0.6), height: 1, thickness: 1.2),
          SizedBox(height: 2.h),

          // Step 1: Copy
          _buildStepRow(
            stepNumber: '1',
            title: AppStrings.guidanceStep1Title,
            description: AppStrings.guidanceStep1Desc,
            gradientColors: [const Color(0xFF0D9488), const Color(0xFF14B8A6)], // Vibrant Teal
          ),
          SizedBox(height: 2.h),

          // Step 2: Choose AI tool
          _buildStepRow(
            stepNumber: '2',
            title: AppStrings.guidanceStep2Title,
            description: AppStrings.guidanceStep2Desc,
            gradientColors: [const Color(0xFF4F46E5), const Color(0xFF6366F1)], // Vibrant Indigo
          ),
          SizedBox(height: 2.h),

          // Step 3: Paste and generate
          _buildStepRow(
            stepNumber: '3',
            title: AppStrings.guidanceStep3Title,
            description: AppStrings.guidanceStep3Desc,
            gradientColors: [const Color(0xFF8B5CF6), const Color(0xFFA78BFA)], // Vibrant Purple
          ),
          SizedBox(height: 2.h),

          // Beautiful Pro Tip Box
          Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.03),
                  AppColors.primary.withValues(alpha: 0.08),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(4.w),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.15),
                width: 0.25.w,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.tips_and_updates_rounded,
                  color: const Color(0xFFF59E0B), // Warm Gold color
                  size: 5.5.w,
                ),
                SizedBox(width: 3.w),
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
                      SizedBox(height: 0.5.h),
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
          width: 7.w,
          height: 7.w,
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
        SizedBox(width: 3.5.w),
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
              SizedBox(height: 0.5.h),
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
    if (widget.categoryName == 'Favorites') {
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
                  icon: Icon(
                    isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    color: isFav ? Colors.redAccent : AppColors.textPrimary,
                  ),
                  onPressed: () {
                    appState.toggleFavorite(_currentItem);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.ios_share_rounded, color: AppColors.textPrimary),
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
        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.5.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Large Vertical Preview Image/Video Player (9:16 layout)
            Center(
              child: Container(
                width: 85.w,
                height: 42.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4.w),
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
            SizedBox(height: 3.h),

            // 2. Prompt Text Card Description
            Container(
              padding: EdgeInsets.all(4.5.w),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(3.w),
                border: Border.all(color: AppColors.border, width: 0.25.w),
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
            SizedBox(height: 2.5.h),

            // 3. Action Button (Unlock or Copy)
            if (!(_isUnlocked || isFav))
              ElevatedButton.icon(
                onPressed: _showUnlockDialog,
                icon: Icon(Icons.lock_rounded, size: 5.w, color: Colors.white),
                label: Text(
                  'Unlock Prompt',
                  style: AppTextStyles.getStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(3.w),
                  ),
                  elevation: 0,
                ),
              )
            else
              ElevatedButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: _currentItem.aiPrompt));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Prompt copied to clipboard!'),
                      backgroundColor: AppColors.primary,
                    ),
                  );
                },
                icon: Icon(Icons.content_copy_rounded, size: 5.w, color: Colors.white),
                label: Text(
                  'Copy Prompt',
                  style: AppTextStyles.getStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(3.w),
                  ),
                  elevation: 0,
                ),
              ),
            if (_isUnlocked || isFav) ...[
              SizedBox(height: 3.h),
              _buildPromptGuidance(),
              SizedBox(height: 2.h),
            ] else ...[
              SizedBox(height: 4.h),
            ],

            // 4. Recommended Section Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recommended',
                  style: AppTextStyles.getStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    if (widget.categoryId == 999 || widget.categoryName == 'Favorites') {
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
                        final catName = matchedCategory?.categoryName ?? 'Category';
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
                    'View More',
                    style: AppTextStyles.getStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 1.h),

            // 5. Recommended Grids
            if (recommendedItems.isEmpty)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 3.h),
                child: Center(
                  child: Text(
                    'No recommendations available.',
                    style: AppTextStyles.getStyle(color: AppColors.textMuted),
                  ),
                ),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.70,
                  crossAxisSpacing: 2.5.w,
                  mainAxisSpacing: 2.5.w,
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
            SizedBox(height: 5.h),
          ],
        ),
      ),
    );
  }
}
