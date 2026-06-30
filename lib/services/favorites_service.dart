import 'package:flutter/material.dart';

import '../models/video_category.dart';
import '../utils/common_utils.dart';
import 'database_helper.dart';

/// Holds the user's favorite videos, backed by [DatabaseHelper].
///
/// Exposed as a [ChangeNotifier] so the UI rebuilds when favorites change.
class FavoritesService extends ChangeNotifier {
  FavoritesService() {
    _loadFavorites();
  }

  final DatabaseHelper _dbHelper = DatabaseHelper();
  final List<VideoItem> _favorites = [];

  List<VideoItem> get favorites => _favorites;

  Future<void> _loadFavorites() async {
    try {
      final dbFavs = await _dbHelper.getFavorites();
      _favorites
        ..clear()
        ..addAll(dbFavs);
      notifyListeners();
    } catch (e) {
      // CommonUtils.printLog('Error loading favorites: $e');
    }
  }

  bool isFavorite(VideoItem item) => _favorites.any((fav) => fav.id == item.id);

  Future<void> toggleFavorite(VideoItem item) async {
    if (isFavorite(item)) {
      _favorites.removeWhere((fav) => fav.id == item.id);
      notifyListeners();
      await _dbHelper.deleteFavorite(item.id);
    } else {
      _favorites.add(item);
      notifyListeners();
      await _dbHelper.insertFavorite(item);
    }
  }
}
