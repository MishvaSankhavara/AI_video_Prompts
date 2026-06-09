class VideoCategory {
  final int categoryId;
  final String categoryName;
  final List<VideoItem> items;

  VideoCategory({
    required this.categoryId,
    required this.categoryName,
    required this.items,
  });

  factory VideoCategory.fromJson(Map<String, dynamic> json) {
    final list = json['items'] as List? ?? [];
    final categoryId = json['category_id'] ?? 0;
    final itemList = list.map((i) {
      final item = VideoItem.fromJson(i);
      item.categoryId = categoryId;
      return item;
    }).toList();
    
    return VideoCategory(
      categoryId: categoryId,
      categoryName: json['category_name'] ?? '',
      items: itemList,
    );
  }
}

class VideoItem {
  final int id;
  final String aiPrompt;
  final String videoThumbnail;
  final int noOfVideo;
  final bool nameChange;
  final String videoThumbnailFullUrl;
  final String categoryVideo;
  final String categoryVideoFullUrl;
  int? categoryId;

  VideoItem({
    required this.id,
    required this.aiPrompt,
    required this.videoThumbnail,
    required this.noOfVideo,
    required this.nameChange,
    required this.videoThumbnailFullUrl,
    required this.categoryVideo,
    required this.categoryVideoFullUrl,
    this.categoryId,
  });

  factory VideoItem.fromJson(Map<String, dynamic> json) {
    return VideoItem(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      aiPrompt: json['ai_prompt'] ?? '',
      videoThumbnail: json['video_thumbnail'] ?? '',
      noOfVideo: json['no_of_video'] is int
          ? json['no_of_video'] as int
          : int.tryParse(json['no_of_video']?.toString() ?? '') ?? 1,
      nameChange: json['name_change'] == true ||
          json['name_change'] == 1 ||
          json['name_change']?.toString() == '1',
      videoThumbnailFullUrl: json['video_thumbnail_full_url'] ?? '',
      categoryVideo: json['category_video'] ?? '',
      categoryVideoFullUrl: json['category_video_full_url'] ?? '',
      categoryId: json['category_id'] is int
          ? json['category_id'] as int
          : int.tryParse(json['category_id']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ai_prompt': aiPrompt,
      'video_thumbnail': videoThumbnail,
      'no_of_video': noOfVideo,
      'name_change': nameChange ? 1 : 0,
      'video_thumbnail_full_url': videoThumbnailFullUrl,
      'category_video': categoryVideo,
      'category_video_full_url': categoryVideoFullUrl,
      'category_id': categoryId,
    };
  }

  factory VideoItem.fromMap(Map<String, dynamic> map) {
    return VideoItem(
      id: map['id'] is int ? map['id'] as int : int.parse(map['id'].toString()),
      aiPrompt: map['ai_prompt'] ?? '',
      videoThumbnail: map['video_thumbnail'] ?? '',
      noOfVideo: map['no_of_video'] is int ? map['no_of_video'] as int : int.parse(map['no_of_video'].toString()),
      nameChange: (map['name_change'] ?? 0) == 1,
      videoThumbnailFullUrl: map['video_thumbnail_full_url'] ?? '',
      categoryVideo: map['category_video'] ?? '',
      categoryVideoFullUrl: map['category_video_full_url'] ?? '',
      categoryId: map['category_id'] is int
          ? map['category_id'] as int
          : (map['category_id'] != null ? int.tryParse(map['category_id'].toString()) : null),
    );
  }
}
