import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:quiz_panel/models/youtube_video_model.dart';

final youtubeRepositoryProvider = Provider<YoutubeRepository>((ref) =>
    YoutubeRepository());

class YoutubeRepository {
  // Securely get key from .env

  String get _apiKey => dotenv.env['YOUTUBE_API_KEY'] ?? '';

  String get _baseUrl =>
      dotenv.env['YOUTUBE_BASE_URL'] ?? 'https://www.googleapis.com/youtube/v3';

  Future<List<YoutubeVideoModel>> searchVideos(String query) async {
    if (_apiKey.isEmpty) {
      throw 'API KEY NOT FOUND.';
    }

    try {
      // URL encode the query to handle spaces and special characters
      final encodedQuery = Uri.encodeComponent(query);

      final response = await http.get(
        Uri.parse(
            '$_baseUrl/search?part=snippet&maxResults=10&q=$encodedQuery&type=video&key=$_apiKey'
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> items = data['items'];

        return items
            .where((item) => item['id']['kind'] == 'youtube#video')
            .map((item) => YoutubeVideoModel.fromJson(item))
            .toList();
      } else {
        throw 'Failed to fetch videos. Status: ${response.statusCode}';
      }
    } catch (e) {
      throw e.toString();
    }
  }
}
