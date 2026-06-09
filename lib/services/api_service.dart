import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/video_category.dart';

class ApiService {
  static const String baseUrl = 'https://ai-prompt.aivibecode.in/api/v1/ngd';
  static const String authToken = r'x.NF#f25G),Ew55J8HnwsXGQ}2j%N4F5[.DHyJkG4R$HP@;2LOF5kz!Ovex,X.X6)dr6s3fniU}o@3)zFVyNN$2Akx)2=t+qlEbk';

  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<VideoCategory>> fetchVideoCategories() async {
    final url = Uri.parse('$baseUrl/getAiVideoCategories');
    
    try {
      final response = await _client.get(
        url,
        headers: {
          'Authorization': 'Bearer $authToken',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedData = json.decode(response.body);
        if (decodedData['status'] == true) {
          final list = decodedData['data'] as List? ?? [];
          return list.map((json) => VideoCategory.fromJson(json)).toList();
        } else {
          throw Exception(decodedData['message'] ?? 'Failed to load video categories');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Connection failed: $e');
    }
  }

  Future<List<VideoItem>> fetchVideosByCategoryId(int categoryId) async {
    final url = Uri.parse('$baseUrl/getAiVideoByCategoryId');
    
    try {
      final response = await _client.post(
        url,
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'category_id': categoryId,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedData = json.decode(response.body);
        if (decodedData['status'] == true) {
          final list = decodedData['data'] as List? ?? [];
          return list.map((json) => VideoItem.fromJson(json)).toList();
        } else {
          throw Exception(decodedData['message'] ?? 'Failed to load category videos');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Connection failed: $e');
    }
  }
}
