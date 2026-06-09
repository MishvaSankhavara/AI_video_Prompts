import 'package:flutter_test/flutter_test.dart';
import 'package:aivideoprompt/models/video_category.dart';

void main() {
  group('VideoItem.fromJson', () {
    test('should parse name_change when it is boolean true', () {
      final json = {
        'id': 1,
        'ai_prompt': 'Test prompt',
        'video_thumbnail': 'thumb.webp',
        'no_of_video': 1,
        'name_change': true,
        'video_thumbnail_full_url': 'https://example.com/thumb.webp',
        'category_video': 'video.mp4',
        'category_video_full_url': 'https://example.com/video.mp4',
        'category_id': 2,
      };

      final item = VideoItem.fromJson(json);

      expect(item.nameChange, isTrue);
    });

    test('should parse name_change when it is boolean false', () {
      final json = {
        'id': 1,
        'ai_prompt': 'Test prompt',
        'video_thumbnail': 'thumb.webp',
        'no_of_video': 1,
        'name_change': false,
        'video_thumbnail_full_url': 'https://example.com/thumb.webp',
        'category_video': 'video.mp4',
        'category_video_full_url': 'https://example.com/video.mp4',
        'category_id': 2,
      };

      final item = VideoItem.fromJson(json);

      expect(item.nameChange, isFalse);
    });

    test('should parse name_change when it is integer 1', () {
      final json = {
        'id': 1,
        'ai_prompt': 'Test prompt',
        'video_thumbnail': 'thumb.webp',
        'no_of_video': 1,
        'name_change': 1,
        'video_thumbnail_full_url': 'https://example.com/thumb.webp',
        'category_video': 'video.mp4',
        'category_video_full_url': 'https://example.com/video.mp4',
        'category_id': 2,
      };

      final item = VideoItem.fromJson(json);

      expect(item.nameChange, isTrue);
    });

    test('should parse name_change when it is integer 0', () {
      final json = {
        'id': 1,
        'ai_prompt': 'Test prompt',
        'video_thumbnail': 'thumb.webp',
        'no_of_video': 1,
        'name_change': 0,
        'video_thumbnail_full_url': 'https://example.com/thumb.webp',
        'category_video': 'video.mp4',
        'category_video_full_url': 'https://example.com/video.mp4',
        'category_id': 2,
      };

      final item = VideoItem.fromJson(json);

      expect(item.nameChange, isFalse);
    });

    test('should parse name_change when it is string "1"', () {
      final json = {
        'id': 1,
        'ai_prompt': 'Test prompt',
        'video_thumbnail': 'thumb.webp',
        'no_of_video': 1,
        'name_change': '1',
        'video_thumbnail_full_url': 'https://example.com/thumb.webp',
        'category_video': 'video.mp4',
        'category_video_full_url': 'https://example.com/video.mp4',
        'category_id': 2,
      };

      final item = VideoItem.fromJson(json);

      expect(item.nameChange, isTrue);
    });

    test('should parse name_change when it is null', () {
      final json = {
        'id': 1,
        'ai_prompt': 'Test prompt',
        'video_thumbnail': 'thumb.webp',
        'no_of_video': 1,
        'name_change': null,
        'video_thumbnail_full_url': 'https://example.com/thumb.webp',
        'category_video': 'video.mp4',
        'category_video_full_url': 'https://example.com/video.mp4',
        'category_id': 2,
      };

      final item = VideoItem.fromJson(json);

      expect(item.nameChange, isFalse);
    });
  });
}
