import 'package:flutter/material.dart';
import '../models/video_category.dart';
import '../services/api_service.dart';

class AppState extends ChangeNotifier {
  String _currentPrompt = '';
  bool _isGenerating = false;
  final List<String> _promptHistory = [];

  // Bottom Navigation Index
  int _currentTabIndex = 0;

  // Categories API States
  final ApiService _apiService = ApiService();
  List<VideoCategory> _categories = [];
  bool _isLoadingCategories = false;
  String _apiError = '';

  // Favorites State
  final List<VideoItem> _favorites = [];

  // Getters
  String get currentPrompt => _currentPrompt;
  bool get isGenerating => _isGenerating;
  List<String> get promptHistory => _promptHistory;
  int get currentTabIndex => _currentTabIndex;

  List<VideoCategory> get categories => _categories;
  bool get isLoadingCategories => _isLoadingCategories;
  String get apiError => _apiError;

  List<VideoItem> get favorites => _favorites;

  // Change tab selection
  void changeTab(int index) {
    _currentTabIndex = index;
    notifyListeners();
  }

  // Load Categories from API
  Future<void> loadCategories() async {
    _isLoadingCategories = true;
    _apiError = '';
    notifyListeners();

    try {
      _categories = await _apiService.fetchVideoCategories();
    } catch (e) {
      _apiError = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoadingCategories = false;
      notifyListeners();
    }
  }

  // Favorites Actions
  void toggleFavorite(VideoItem item) {
    if (_favorites.any((fav) => fav.id == item.id)) {
      _favorites.removeWhere((fav) => fav.id == item.id);
    } else {
      _favorites.add(item);
    }
    notifyListeners();
  }

  bool isFavorite(VideoItem item) {
    return _favorites.any((fav) => fav.id == item.id);
  }

  // Prompt Actions
  void updatePrompt(String prompt) {
    _currentPrompt = prompt;
    notifyListeners();
  }

  void startGeneration() {
    if (_currentPrompt.isEmpty) return;
    _isGenerating = true;
    notifyListeners();
  }

  void completeGeneration(String outputVideoUrl) {
    _isGenerating = false;
    if (_currentPrompt.isNotEmpty && !_promptHistory.contains(_currentPrompt)) {
      _promptHistory.insert(0, _currentPrompt);
    }
    notifyListeners();
  }

  void clearPrompt() {
    _currentPrompt = '';
    notifyListeners();
  }
}
