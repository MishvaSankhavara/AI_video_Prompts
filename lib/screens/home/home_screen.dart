import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/app_state.dart';
import '../../utils/colors.dart';
import '../../utils/strings.dart';
import '../../widgets/prompt_grid_card.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../../models/video_category.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AppState>(context, listen: false).loadCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    
    return Scaffold(
      backgroundColor: AppColors.mainBackground,
      appBar: AppBar(
        title: const Text(
          AppStrings.homeTitle,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          // Pro Button
          Container(
            margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
            child: ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Pro subscription settings coming soon!'),
                    backgroundColor: AppColors.primary,
                  ),
                );
              },
              icon: const Icon(Icons.diamond_rounded, size: 16, color: Colors.white),
              label: const Text(
                'Pro',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00B0FF), // Pro blue accent matching original
                elevation: 0,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
        ],
      ),
      body: _buildBody(appState),
      floatingActionButton: FloatingActionButton(
        onPressed: () => appState.changeTab(2), // Switch to AI generator tab (index 2)
        backgroundColor: Colors.transparent,
        elevation: 6,
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary,
                Color(0xFF36ADA3), // Teal/cyan glow
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Center(
            child: Text(
              'AI',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: const CustomBottomBar(),
    );
  }

  Widget _buildBody(AppState appState) {
    switch (appState.currentTabIndex) {
      case 0:
        return _buildHomeTab(appState);
      case 1:
        return _buildLatestTab(appState);
      case 2:
        return _buildAITab(appState);
      case 3:
        return _buildFavoritesTab();
      case 4:
        return _buildSettingsTab();
      default:
        return _buildHomeTab(appState);
    }
  }

  // TAB 0: HOME
  Widget _buildHomeTab(AppState appState) {
    if (appState.isLoadingCategories) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      );
    }

    if (appState.apiError.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_off_rounded, size: 64, color: AppColors.textMuted),
              const SizedBox(height: 16),
              Text(
                appState.apiError,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => appState.loadCategories(),
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

    // Flatten items across all categories for Home feed
    final List<Map<String, dynamic>> allItems = [];
    for (var cat in appState.categories) {
      // Skip "Latest" category when flattening to prevent duplicates, or use it.
      // Let's include everything but make sure they are unique by ID
      for (var item in cat.items) {
        if (!allItems.any((element) => element['item'].id == item.id)) {
          allItems.add({
            'item': item,
            'categoryName': cat.categoryName,
          });
        }
      }
    }

    if (allItems.isEmpty) {
      return const Center(
        child: Text(
          'No templates available.',
          style: TextStyle(color: AppColors.textMuted),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 80),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.70, // Matches 9:16 layout ratio
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: allItems.length,
      itemBuilder: (context, index) {
        final itemMap = allItems[index];
        final item = itemMap['item'];
        final categoryName = _getThematicCategory(appState, item.id);
        // Mark first 3 items as premium/Pro for demonstration
        final isPremium = index < 3;

        return PromptGridCard(
          item: item,
          categoryName: categoryName,
          isPremium: isPremium,
          onTap: () {
            _showPromptDetails(context, item, categoryName);
          },
        );
      },
    );
  }

  // TAB 1: LATEST
  Widget _buildLatestTab(AppState appState) {
    if (appState.isLoadingCategories) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      );
    }

    // Find the 'Latest' category
    final latestCategory = appState.categories.firstWhere(
      (cat) => cat.categoryName.toLowerCase() == 'latest',
      orElse: () => appState.categories.isNotEmpty
          ? appState.categories.first
          : VideoCategory(categoryId: 0, categoryName: 'Latest', items: []),
    );

    if (latestCategory.items.isEmpty) {
      return const Center(
        child: Text(
          'No latest templates available.',
          style: TextStyle(color: AppColors.textMuted),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 80),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.70,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: latestCategory.items.length,
      itemBuilder: (context, index) {
        final item = latestCategory.items[index];
        final categoryName = _getThematicCategory(appState, item.id);
        return PromptGridCard(
          item: item,
          categoryName: categoryName,
          isPremium: index == 0,
          onTap: () {
            _showPromptDetails(context, item, categoryName);
          },
        );
      },
    );
  }

  // TAB 2: AI PROMPT CREATOR
  Widget _buildAITab(AppState appState) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.movie_creation_outlined,
                size: 40,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Custom AI Video Prompter',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Describe the video details you want our AI model to generate.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
          const SizedBox(height: 32),
          Container(
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border, width: 1.5),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              style: const TextStyle(color: AppColors.textPrimary),
              onChanged: (val) => appState.updatePrompt(val),
              decoration: const InputDecoration(
                hintText: AppStrings.generatePromptPlaceholder,
                hintStyle: TextStyle(color: AppColors.textMuted),
                border: InputBorder.none,
              ),
              maxLines: 4,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: appState.currentPrompt.trim().isEmpty
                ? null
                : () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Generating prompt: "${appState.currentPrompt}"'),
                        backgroundColor: AppColors.primary,
                      ),
                    );
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              disabledBackgroundColor: AppColors.primary.withOpacity(0.3),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: const Text(
              AppStrings.generateButton,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // TAB 3: FAVORITES (Placeholder)
  Widget _buildFavoritesTab() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border_rounded, size: 64, color: AppColors.textMuted),
          SizedBox(height: 16),
          Text(
            'No Favorites Yet',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Saved templates will appear here.',
            style: TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
        ],
      ),
    );
  }

  // TAB 4: SETTINGS (Placeholder)
  Widget _buildSettingsTab() {
    return ListView(
      padding: const EdgeInsets.all(24.0),
      children: [
        _buildSettingsItem(
          icon: Icons.person_outline,
          title: 'Account Settings',
          onTap: () {},
        ),
        _buildSettingsItem(
          icon: Icons.notifications_none_rounded,
          title: 'Notification Settings',
          onTap: () {},
        ),
        _buildSettingsItem(
          icon: Icons.lock_outline_rounded,
          title: 'Privacy Policy',
          onTap: () {},
        ),
        _buildSettingsItem(
          icon: Icons.info_outline_rounded,
          title: 'App Version',
          subtitle: '1.0.0',
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      color: AppColors.cardBackground,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: subtitle != null ? Text(subtitle, style: const TextStyle(color: AppColors.textMuted)) : null,
        trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
        onTap: onTap,
      ),
    );
  }

  // Show bottom sheet with details of prompt
  void _showPromptDetails(BuildContext context, VideoItem item, String category) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.mainBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      category,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'AI Prompt Text:',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    item.aiPrompt,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // Copy to clipboard or trigger action
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Prompt copied to clipboard!')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text('Use Prompt Template', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Helper to resolve specific thematic category name for a given template ID
  String _getThematicCategory(AppState appState, int itemId) {
    for (var cat in appState.categories) {
      if (cat.categoryName.toLowerCase() != 'latest') {
        if (cat.items.any((item) => item.id == itemId)) {
          return cat.categoryName;
        }
      }
    }
    return 'Latest';
  }
}
