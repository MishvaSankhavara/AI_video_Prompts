import 'package:flutter/material.dart';
import '../models/video_category.dart';
import '../services/api_service.dart';
import 'database_helper.dart';
import 'analytics_service.dart';

class AppState extends ChangeNotifier {
  AppState() {
    _loadFavorites();
  }

  final DatabaseHelper _dbHelper = DatabaseHelper();
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
    String screenName;
    switch (index) {
      case 0:
        screenName = 'home_tab';
        break;
      case 1:
        screenName = 'favorites_tab';
        break;
      case 2:
        screenName = 'settings_tab';
        break;
      default:
        screenName = 'home_tab';
    }
    AnalyticsService.instance.logScreenView(screenName: screenName);
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
  Future<void> toggleFavorite(VideoItem item) async {
    final isAlreadyFav = _favorites.any((fav) => fav.id == item.id);
    if (isAlreadyFav) {
      _favorites.removeWhere((fav) => fav.id == item.id);
      notifyListeners();
      await _dbHelper.deleteFavorite(item.id);
    } else {
      _favorites.add(item);
      notifyListeners();
      await _dbHelper.insertFavorite(item);
    }
  }

  Future<void> _loadFavorites() async {
    try {
      final dbFavs = await _dbHelper.getFavorites();
      _favorites.clear();
      _favorites.addAll(dbFavs);
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading favorites: $e');
    }
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
