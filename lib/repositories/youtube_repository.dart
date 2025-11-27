// lib/repositories/youtube_repository.dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:quiz_panel/models/youtube_video_model.dart';

final youtubeRepositoryProvider = Provider<YoutubeRepository>((ref) => YoutubeRepository());

class YoutubeRepository {
  final Dio _dio = Dio();

  String get _apiKey => dotenv.env['YOUTUBE_API_KEY'] ?? '';
  String get _baseUrl => dotenv.env['YOUTUBE_BASE_URL'] ?? 'https://www.googleapis.com/youtube/v3';

  // Added maxResults parameter with a default
  Future<List<YoutubeVideoModel>> searchVideos(String query, {int maxResults = 10}) async {
    if (_apiKey.isEmpty) {
      throw 'API Key not found. Please check your .env file.';
    }

    try {
      final response = await _dio.get(
        '$_baseUrl/search',
        queryParameters: {
          'part': 'snippet',
          'maxResults': maxResults, // Uses the passed limit
          'q': query,
          'type': 'video',
          'key': _apiKey,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final List<dynamic> items = data['items'];

        return items
            .where((item) => item['id']['kind'] == 'youtube#video')
            .map((item) => YoutubeVideoModel.fromJson(item))
            .toList();
      } else {
        throw 'Failed to fetch videos. Status: ${response.statusCode}';
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout) {
        throw 'Connection Timed Out. Please check your internet.';
      } else if (e.type == DioExceptionType.connectionError) {
        throw 'No Internet Connection.';
      } else if (e.response != null) {
        throw 'YouTube API Error: ${e.response?.statusCode} - ${e.response?.statusMessage}';
      } else {
        throw 'Something went wrong: ${e.message}';
      }
    } catch (e) {
      throw e.toString();
    }
  }
}