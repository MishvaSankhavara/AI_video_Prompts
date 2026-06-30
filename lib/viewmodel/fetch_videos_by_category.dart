import 'package:flutter/material.dart';

import '../api/api_service.dart';
import '../models/video_category.dart';

/// View model that loads the videos for a single category and exposes the
/// loading / error / data state to the UI.
class FetchVideosByCategoryViewModel extends ChangeNotifier {
  FetchVideosByCategoryViewModel({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  final ApiService _apiService;

  List<VideoItem> _videos = [];
  bool _isLoading = false;
  String _error = '';

  List<VideoItem> get videos => _videos;
  bool get isLoading => _isLoading;
  String get error => _error;

  Future<void> fetchVideos(int categoryId) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final videos = await _apiService.fetchVideosByCategoryId(categoryId);
      for (final v in videos) {
        v.categoryId = categoryId;
      }
      _videos = videos;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
