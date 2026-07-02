import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/video_category.dart';
import 'api_const.dart';

class ApiService {
  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<VideoCategory>> fetchVideoCategories() async {
    final url = Uri.parse(
      '${ApiConst.baseUrl}${ApiConst.getAiVideoCategories}',
    );

    try {
      final response = await _client.get(
        url,
        headers: {
          'Authorization': 'Bearer ${ApiConst.authToken}',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedData = json.decode(response.body);
        if (decodedData['status'] == true) {
          final list = decodedData['data'] as List? ?? [];
          return list.map((json) => VideoCategory.fromJson(json)).toList();
        } else {
          throw Exception(
            decodedData['message'] ?? 'Failed to load video categories',
          );
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Connection failed: $e');
    }
  }

  Future<List<VideoItem>> fetchVideosByCategoryId(int categoryId) async {
    final url = Uri.parse(
      '${ApiConst.baseUrl}${ApiConst.getAiVideoByCategoryId}',
    );

    try {
      final response = await _client.post(
        url,
        headers: {
          'Authorization': 'Bearer ${ApiConst.authToken}',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({'category_id': categoryId}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedData = json.decode(response.body);
        if (decodedData['status'] == true) {
          final list = decodedData['data'] as List? ?? [];
          return list.map((json) => VideoItem.fromJson(json)).toList();
        } else {
          throw Exception(
            decodedData['message'] ?? 'Failed to load category videos',
          );
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Connection failed: $e');
    }
  }
}
