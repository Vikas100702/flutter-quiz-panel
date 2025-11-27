import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:profanity_filter/profanity_filter.dart';
import 'package:quiz_panel/config/secrets/blocked_keywords.dart';
import 'package:quiz_panel/models/youtube_video_model.dart';

final youtubeRepositoryProvider = Provider<YoutubeRepository>((ref) => YoutubeRepository());

class YoutubeRepository {
  final Dio _dio = Dio();
  final _filter = ProfanityFilter();

  String get _apiKey => dotenv.env['YOUTUBE_API_KEY'] ?? '';
  String get _baseUrl => dotenv.env['YOUTUBE_BASE_URL'] ?? 'https://www.googleapis.com/youtube/v3';

  // 2. अब async फ़ंक्शन की जरूरत नहीं है, यह सीधा चेक करेगा
  bool _isQueryAllowed(String query) {
    // A. Profanity Package Check
    if (_filter.hasProfanity(query)) {
      return false;
    }

    // B. Normalization (सफाई)
    String processedQuery = query.toLowerCase();
    String strictQuery = processedQuery.replaceAll(RegExp(r'[^a-z0-9]'), '');

    // C. Custom Blacklist Check (Directly from imported list)
    // 'blockedKeywordsList' अब सीधे उपलब्ध है
    for (final word in blockedKeywordsList) {
      // Logic 1: Strict Check (स्पेस हटाकर चेक करना: "h o t" -> "hot")
      if (strictQuery.contains(word.replaceAll(' ', ''))) {
        return false;
      }
      // Logic 2: Standard Check
      if (processedQuery.contains(word)) {
        return false;
      }
    }

    return true;
  }

  Future<List<YoutubeVideoModel>> searchVideos(String query, {int maxResults = 10}) async {
    if (_apiKey.isEmpty) {
      throw 'API Key not found. Please check your .env file.';
    }

    // --- LAYER 1: Pre-Search Keyword Blocking ---
    // अब 'await' की जरूरत नहीं है
    if (!_isQueryAllowed(query)) {
      throw 'Restricted Content: This search term is restricted for educational integrity.';
    }

    // --- LAYER 2: Educational Context Injection ---
    final String educationalQuery = "$query learning tutorial education class chapter";

    try {
      final response = await _dio.get(
        '$_baseUrl/search',
        queryParameters: {
          'part': 'snippet',
          'maxResults': maxResults,
          'q': educationalQuery,
          'type': 'video',
          'key': _apiKey,
          'safeSearch': 'strict', // Layer 3
          'videoCategoryId': '27', // Layer 4 (Education Category Only)
          'videoEmbeddable': 'true',
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
      } else if (e.response != null) {
        throw 'YouTube API Error: ${e.response?.statusCode}';
      } else {
        throw 'Something went wrong: ${e.message}';
      }
    } catch (e) {
      throw e.toString();
    }
  }
}