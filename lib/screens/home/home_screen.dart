import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/app_state.dart';
import '../../utils/colors.dart';
import '../../utils/strings.dart';
import '../../widgets/prompt_grid_card.dart';
import '../../widgets/shimmer_grid_card.dart';
import '../category/category_details_screen.dart';
import 'home_bottom_bar.dart';

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

  String _getAppBarTitle(int tabIndex) {
    switch (tabIndex) {
      case 0:
        return AppStrings.homeTitle;
      case 1:
        return AppStrings.tabFavorite;
      case 2:
        return AppStrings.tabSettings;
      default:
        return AppStrings.homeTitle;
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    
    return Scaffold(
      backgroundColor: AppColors.mainBackground,
      appBar: AppBar(
        title: Text(
          _getAppBarTitle(appState.currentTabIndex),
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: CustomBottomBar.getBody(appState),
      bottomNavigationBar: const CustomBottomBar(),
    );
  }
}

class HomeTabBody extends StatelessWidget {
  const HomeTabBody({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    if (appState.isLoadingCategories) {
      return GridView.builder(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 80),
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

    if (appState.categories.isEmpty) {
      return const Center(
        child: Text(
          'No categories available.',
          style: TextStyle(color: AppColors.textMuted),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 80),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.70, // Matches 9:16 layout ratio
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: appState.categories.length,
      itemBuilder: (context, index) {
        final category = appState.categories[index];
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
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CategoryDetailsScreen(
                  categoryId: category.categoryId,
                  categoryName: category.categoryName,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
