import 'package:flutter/material.dart';
import '../../models/video_category.dart';
import '../../services/api_service.dart';
import '../../utils/colors.dart';
import '../../widgets/prompt_grid_card.dart';
import '../../widgets/shimmer_grid_card.dart';
import 'prompt_details_screen.dart';

class CategoryDetailsScreen extends StatefulWidget {
  final int categoryId;
  final String categoryName;

  const CategoryDetailsScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  State<CategoryDetailsScreen> createState() => _CategoryDetailsScreenState();
}

class _CategoryDetailsScreenState extends State<CategoryDetailsScreen> {
  final ApiService _apiService = ApiService();
  List<VideoItem> _videos = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchCategoryVideos();
  }

  Future<void> _fetchCategoryVideos() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final videos = await _apiService.fetchVideosByCategoryId(widget.categoryId);
      if (mounted) {
        setState(() {
          _videos = videos;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainBackground,
      appBar: AppBar(
        title: Text(
          widget.categoryName,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.70, // Standard 9:16 layout ratio
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: 6, // Show 6 shimmer cards while loading
        itemBuilder: (context, index) => const ShimmerGridCard(),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_off_rounded, size: 64, color: AppColors.textMuted),
              const SizedBox(height: 16),
              Text(
                _errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _fetchCategoryVideos,
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

    if (_videos.isEmpty) {
      return const Center(
        child: Text(
          'No templates found in this category.',
          style: TextStyle(color: AppColors.textMuted),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.70, // Standard 9:16 layout ratio
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _videos.length,
      itemBuilder: (context, index) {
        final item = _videos[index];
        return PromptGridCard(
          item: item,
          categoryName: '',
          isPremium: index < 1, // Mark first item as premium for representation
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PromptDetailsScreen(
                  item: item,
                  categoryItems: _videos,
                  categoryName: widget.categoryName,
                  categoryId: widget.categoryId,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
