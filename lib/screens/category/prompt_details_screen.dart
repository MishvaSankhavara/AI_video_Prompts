import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_player/video_player.dart';
import '../../models/video_category.dart';
import '../../services/app_state.dart';
import '../../utils/colors.dart';
import '../../utils/strings.dart';
import '../../widgets/prompt_grid_card.dart';
import '../../widgets/shimmer_grid_card.dart';
import '../../widgets/dialog/custom_app_dialog.dart';

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

  late VideoPlayerController _videoController;
  bool _isVideoInitialized = false;

  bool get _isUnlocked => _unlockedItemIds.contains(_currentItem.id);

  @override
  void initState() {
    super.initState();
    _currentItem = widget.item;
    _initializeVideoPlayer();
  }

  void _videoPlayerListener() {
    if (mounted) {
      setState(() {});
    }
  }

  void _initializeVideoPlayer() {
    final videoUrl = Uri.encodeFull(_currentItem.categoryVideoFullUrl.trim());
    _videoController = VideoPlayerController.networkUrl(
      Uri.parse(videoUrl),
    );
    _videoController.addListener(_videoPlayerListener);
    _videoController.initialize().then((_) {
      if (mounted) {
        setState(() {
          _isVideoInitialized = true;
        });
        _videoController.setLooping(true);
        _videoController.play();
      }
    }).catchError((e) {
      debugPrint("Error loading details video: $e");
    });
  }

  void _changeCurrentItem(VideoItem newItem) {
    if (_isVideoInitialized) {
      _videoController.removeListener(_videoPlayerListener);
      _videoController.dispose();
      _isVideoInitialized = false;
    }
    setState(() {
      _currentItem = newItem;
    });
  }

  @override
  void dispose() {
    _videoController.removeListener(_videoPlayerListener);
    _videoController.dispose();
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
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Pro subscription settings coming soon!'),
                backgroundColor: AppColors.primary,
              ),
            );
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

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isFav = appState.isFavorite(_currentItem);

    // Filter out the currently selected item from the recommended grid
    final recommendedItems = widget.categoryItems
        .where((element) => element.id != _currentItem.id)
        .toList();

    final displayPrompt = _isUnlocked 
        ? _currentItem.aiPrompt 
        : _getTruncatedPrompt(_currentItem.aiPrompt);

    return Scaffold(
      backgroundColor: AppColors.mainBackground,
      appBar: AppBar(
        title: const Text(
          AppStrings.appName,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: _isUnlocked
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
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
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
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (_isVideoInitialized)
                      FittedBox(
                        fit: BoxFit.cover,
                        child: SizedBox(
                          width: _videoController.value.size.width > 0 ? _videoController.value.size.width : 9.0,
                          height: _videoController.value.size.height > 0 ? _videoController.value.size.height : 16.0,
                          child: VideoPlayer(_videoController),
                        ),
                      )
                    else
                      Image.network(
                        Uri.encodeFull(_currentItem.videoThumbnailFullUrl.trim()),
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
                                Icons.broken_image_outlined,
                                color: AppColors.textMuted,
                                size: 48,
                              ),
                            ),
                          );
                        },
                      ),
                    
                    // Tap overlay to play/pause on details screen
                    if (_isVideoInitialized)
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            if (_videoController.value.isPlaying) {
                              _videoController.pause();
                            } else {
                              _videoController.play();
                            }
                          });
                        },
                        child: Container(
                          color: Colors.transparent,
                          child: Center(
                            child: AnimatedOpacity(
                              opacity: _videoController.value.isPlaying ? 0.0 : 1.0,
                              duration: const Duration(milliseconds: 300),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.5),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.play_arrow_rounded,
                                  color: Colors.white,
                                  size: 40,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 2. Prompt Text Card Description
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border, width: 1),
              ),
              child: Text(
                displayPrompt,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  height: 1.45,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 3. Action Button (Unlock or Copy)
            if (!_isUnlocked)
              ElevatedButton.icon(
                onPressed: _showUnlockDialog,
                icon: const Icon(Icons.lock_rounded, size: 20, color: Colors.white),
                label: const Text(
                  'Unlock Prompt',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
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
                icon: const Icon(Icons.content_copy_rounded, size: 20, color: Colors.white),
                label: const Text(
                  'Copy Prompt',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
              ),
            const SizedBox(height: 32),

            // 4. Recommended Section Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recommended',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'View More',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // 5. Recommended Grids
            if (recommendedItems.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24.0),
                child: Center(
                  child: Text(
                    'No recommendations available.',
                    style: TextStyle(color: AppColors.textMuted),
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
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
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
