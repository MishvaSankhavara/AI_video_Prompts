import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../../services/favorites_service.dart';
import '../../utils/colors.dart';
import '../../widgets/text_app.dart';
import '../../widgets/prompt_grid_card.dart';
import '../category/prompt_details_screen.dart';
import '../../services/navigation_service.dart';

class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favorites = Provider.of<FavoritesService>(context).favorites;

    if (favorites.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/ic_like.png',
              width: 64,
              height: 64,
              color: AppColors.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'No Favorites Yet',
              style: AppTextStyles.getStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Saved templates will appear here.',
              style: AppTextStyles.getStyle(
                color: AppColors.textMuted,
                fontSize: 13,
              ),
            ),
          ],
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
      itemCount: favorites.length,
      itemBuilder: (context, index) {
        final item = favorites[index];
        return PromptGridCard(
          item: item,
          categoryName: '',
          isPremium: false,
          onTap: () {
            NavigationService.push(
              context,
              PromptDetailsScreen(
                item: item,
                categoryItems: favorites,
                categoryName: 'Favorites',
                categoryId: 999,
              ),
            );
          },
        );
      },
    );
  }
}
