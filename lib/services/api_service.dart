import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/video_category.dart';

class ApiService {
  static const String baseUrl = 'https://aiphotomaker.aivibecode.in/api/v1/ngd';
  static const String authToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9fe5re84gf56gre48d1re4dsg15er48dgf1re56re21reg65';

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
}
