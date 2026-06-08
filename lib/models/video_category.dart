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
    final itemList = list.map((i) => VideoItem.fromJson(i)).toList();
    
    return VideoCategory(
      categoryId: json['category_id'] ?? 0,
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

  VideoItem({
    required this.id,
    required this.aiPrompt,
    required this.videoThumbnail,
    required this.noOfVideo,
    required this.nameChange,
    required this.videoThumbnailFullUrl,
    required this.categoryVideo,
    required this.categoryVideoFullUrl,
  });

  factory VideoItem.fromJson(Map<String, dynamic> json) {
    return VideoItem(
      id: json['id'] ?? 0,
      aiPrompt: json['ai_prompt'] ?? '',
      videoThumbnail: json['video_thumbnail'] ?? '',
      noOfVideo: json['no_of_video'] ?? 1,
      nameChange: json['name_change'] ?? false,
      videoThumbnailFullUrl: json['video_thumbnail_full_url'] ?? '',
      categoryVideo: json['category_video'] ?? '',
      categoryVideoFullUrl: json['category_video_full_url'] ?? '',
    );
  }
}
