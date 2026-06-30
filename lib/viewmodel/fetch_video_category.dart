import 'package:flutter/material.dart';

import '../api/api_service.dart';
import '../models/video_category.dart';

/// View model that loads the AI video categories from the API and exposes the
/// loading / error / data state to the UI.
class FetchVideoCategoryViewModel extends ChangeNotifier {
  FetchVideoCategoryViewModel({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  final ApiService _apiService;

  List<VideoCategory> _categories = [];
  bool _isLoading = false;
  String _error = '';

  List<VideoCategory> get categories => _categories;
  bool get isLoading => _isLoading;
  String get error => _error;

  Future<void> loadCategories() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _categories = await _apiService.fetchVideoCategories();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
