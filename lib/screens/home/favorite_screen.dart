import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../services/app_state.dart';
import '../../utils/colors.dart';
import '../../utils/text_app.dart';
import '../../widgets/prompt_grid_card.dart';
import '../category/prompt_details_screen.dart';

class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final favorites = appState.favorites;

    if (favorites.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border_rounded, size: 16.w, color: AppColors.textMuted),
            SizedBox(height: 2.h),
            Text(
              'No Favorites Yet',
              style: AppTextStyles.getStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'Saved templates will appear here.',
              style: AppTextStyles.getStyle(color: AppColors.textMuted, fontSize: 13),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: EdgeInsets.only(left: 4.w, right: 4.w, top: 1.5.h, bottom: 10.h),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.70, // Matches 9:16 layout ratio
        crossAxisSpacing: 2.5.w,
        mainAxisSpacing: 2.5.w,
      ),
      itemCount: favorites.length,
      itemBuilder: (context, index) {
        final item = favorites[index];
        return PromptGridCard(
          item: item,
          categoryName: '',
          isPremium: false,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PromptDetailsScreen(
                  item: item,
                  categoryItems: favorites,
                  categoryName: 'Favorites',
                  categoryId: 999,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
