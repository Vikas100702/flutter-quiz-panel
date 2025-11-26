import 'package:dio/dio.dart'; // Dio import karein
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:quiz_panel/models/youtube_video_model.dart';

final youtubeRepositoryProvider = Provider<YoutubeRepository>((ref) => YoutubeRepository());

class YoutubeRepository {
  // Dio ka instance banayein
  final Dio _dio = Dio();

  // Env se keys fetch karein
  String get _apiKey => dotenv.env['YOUTUBE_API_KEY'] ?? '';
  String get _baseUrl => dotenv.env['YOUTUBE_BASE_URL'] ?? 'https://www.googleapis.com/youtube/v3';

  Future<List<YoutubeVideoModel>> searchVideos(String query) async {
    if (_apiKey.isEmpty) {
      throw 'API Key not found. Please check your .env file.';
    }

    try {
      // Dio request mein query parameters ko alag se pass kar sakte hain,
      // jo URL encoding ko apne aap handle kar leta hai.
      final response = await _dio.get(
        '$_baseUrl/search',
        queryParameters: {
          'part': 'snippet',
          'maxResults': 10,
          'q': query,
          'type': 'video',
          'key': _apiKey,
        },
      );

      // Dio status code 200-299 ko success maanta hai
      if (response.statusCode == 200) {
        // Note: Dio response.data directly Map/JSON object hota hai, decode nahi karna padta
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
      // Dio specific errors handle karein
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