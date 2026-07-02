import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/video_category.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final pathString = join(dbPath, 'favorites.db');

    return await openDatabase(pathString, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE favorites (
        id INTEGER PRIMARY KEY,
        ai_prompt TEXT,
        video_thumbnail TEXT,
        video_thumbnail_full_url TEXT
      )
    ''');
  }

  Future<void> insertFavorite(VideoItem item) async {
    final db = await database;
    // Only persist the columns the favorites table actually keeps.
    await db.insert('favorites', {
      'id': item.id,
      'ai_prompt': item.aiPrompt,
      'video_thumbnail': item.videoThumbnail,
      'video_thumbnail_full_url': item.videoThumbnailFullUrl,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> deleteFavorite(int id) async {
    final db = await database;
    await db.delete('favorites', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<VideoItem>> getFavorites() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('favorites');

    return List.generate(maps.length, (i) {
      final map = maps[i];
      // Build directly from the kept columns; fields not stored in the
      // favorites table fall back to defaults.
      return VideoItem(
        id: map['id'] is int
            ? map['id'] as int
            : int.parse(map['id'].toString()),
        aiPrompt: map['ai_prompt'] ?? '',
        videoThumbnail: map['video_thumbnail'] ?? '',
        videoThumbnailFullUrl: map['video_thumbnail_full_url'] ?? '',
        noOfVideo: 0,
        nameChange: false,
        categoryVideo: '',
        categoryVideoFullUrl: '',
      );
    });
  }
}
