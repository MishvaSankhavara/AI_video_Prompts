import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../adsmanager/interstitial_ad_service.dart';
import '../../adsmanager/ad_ids.dart';
import '../../viewmodel/fetch_video_category.dart';
import '../../services/api_error_response.dart';
import '../../services/navigation_service.dart';
import '../../utils/colors.dart';
import '../../widgets/prompt_grid_card.dart';
import '../../widgets/shimmer_grid_card.dart';
import '../category/category_details_screen.dart';
import '../../widgets/text_app.dart';

/// Home tab content: the grid of video categories.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final categoryVM = Provider.of<FetchVideoCategoryViewModel>(context);

    if (categoryVM.isLoading) {
      return GridView.builder(
        padding: const EdgeInsets.only(
          left: 16,
          right: 16,
          top: 12,
          bottom: 150,
        ),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.70, // Matches 9:16 layout ratio
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: 6,
        itemBuilder: (context, index) => const ShimmerGridCard(),
      );
    }

    if (categoryVM.error.isNotEmpty) {
      return ApiErrorResponse(
        message: categoryVM.error,
        onRetry: () => categoryVM.loadCategories(),
      );
    }

    if (categoryVM.categories.isEmpty) {
      return Center(
        child: Text(
          'No categories available.',
          style: AppTextStyles.getStyle(color: AppColors.textMuted),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 150),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.70, // Matches 9:16 layout ratio
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: categoryVM.categories.length,
      itemBuilder: (context, index) {
        final category = categoryVM.categories[index];
        if (category.items.isEmpty) {
          return const SizedBox.shrink();
        }
        final firstItem = category.items.first;
        final isPremium = index == 0 || index == 1; // Mark some as premium

        return PromptGridCard(
          item: firstItem,
          categoryName: category.categoryName,
          isPremium: isPremium,
          onTap: () {
            // Continue to category details whether the ad shows, closes, or fails.
            void openCategory() {
              NavigationService.push(
                context,
                CategoryDetailsScreen(
                  categoryId: category.categoryId,
                  categoryName: category.categoryName,
                ),
              );
            }

            InterstitialAdService.showAd(
              context: context,
              customAdIds: [AdIds.interHomelHF1, AdIds.interHomeLF1],
              screenName: 'HomeScreen',
              onAdClosed: openCategory,
              onAdFailedToShow: openCategory,
            );
          },
        );
      },
    );
  }
}
