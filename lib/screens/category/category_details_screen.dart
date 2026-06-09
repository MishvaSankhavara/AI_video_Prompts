import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../models/video_category.dart';
import '../../services/api_service.dart';
import '../../utils/colors.dart';
import '../../widgets/prompt_grid_card.dart';
import '../../widgets/shimmer_grid_card.dart';
import '../../utils/text_app.dart';
import '../../widgets/common_app_bar.dart';
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
      for (var v in videos) {
        v.categoryId = widget.categoryId;
      }
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
      appBar: CommonAppBar(
        title: widget.categoryName,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return GridView.builder(
        padding: EdgeInsets.all(4.w),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.70, // Standard 9:16 layout ratio
          crossAxisSpacing: 2.5.w,
          mainAxisSpacing: 2.5.w,
        ),
        itemCount: 6, // Show 6 shimmer cards while loading
        itemBuilder: (context, index) => const ShimmerGridCard(),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(6.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cloud_off_rounded, size: 16.w, color: AppColors.textMuted),
              SizedBox(height: 2.h),
              Text(
                _errorMessage,
                textAlign: TextAlign.center,
                style: AppTextStyles.getStyle(color: AppColors.textPrimary, fontSize: 16),
              ),
              SizedBox(height: 3.h),
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
      return Center(
        child: Text(
          'No templates found in this category.',
          style: AppTextStyles.getStyle(color: AppColors.textMuted),
        ),
      );
    }

    return GridView.builder(
      padding: EdgeInsets.all(4.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.70, // Standard 9:16 layout ratio
        crossAxisSpacing: 2.5.w,
        mainAxisSpacing: 2.5.w,
      ),
      itemCount: _videos.length,
      itemBuilder: (context, index) {
        final item = _videos[index];
        return PromptGridCard(
          item: item,
          categoryName: '',
          isPremium: index < 1, // Mark first item as premium for representation
          showLoadingIndicator: false,
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
