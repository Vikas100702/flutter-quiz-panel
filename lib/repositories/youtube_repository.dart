import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:quiz_panel/models/youtube_video_model.dart';

/// **What is this Provider? (youtubeRepositoryProvider)**
/// This provider creates and gives access to the `YoutubeRepository`.
///
/// **Why do we need it?**
/// This allows our `YoutubeSearchNotifier` (in the provider folder) to access the API functions easily.
final youtubeRepositoryProvider = Provider<YoutubeRepository>((ref) => YoutubeRepository());

/// **Why we used this class (YoutubeRepository):**
/// This class handles all communication with the YouTube Data API.
/// Its job is to fetch educational videos.
///
/// **How it helps:**
/// 1. **Context Injection:** Forces the search to be educational (adds "learning", "class").
/// 2. **Category Filtering:** Restricts results to the "Education" category only.
class YoutubeRepository {
  final Dio _dio = Dio(); // The tool used to make HTTP network requests.

  // Get the API Key and Base URL securely from the .env file.
  String get _apiKey => dotenv.env['YOUTUBE_API_KEY'] ?? '';
  String get _baseUrl => dotenv.env['YOUTUBE_BASE_URL'] ?? 'https://www.googleapis.com/youtube/v3';

  // --- PUBLIC FUNCTION: Search Videos ---

  /// **Logic: Fetch Educational Videos**
  /// This is the main function called when a student searches for a topic.
  ///
  /// **How it works:**
  /// 1. **Validation:** Checks API Key and Safety Rules (Layer 1).
  /// 2. **Context Injection (Layer 2):** Appends educational keywords to the user's query.
  ///    (e.g., User searches "Gravity" -> We search "Gravity learning tutorial education...").
  /// 3. **API Call:** Sends the request to YouTube with strict parameters:
  ///    - `safeSearch: strict` (Layer 3).
  ///    - `videoCategoryId: 27` (Layer 4 - Education Category).
  /// 4. **Parsing:** Converts the raw JSON response into a list of `YoutubeVideoModel` objects.
  Future<List<YoutubeVideoModel>> fetchVideosForTopic(String query, {int maxResults = 10}) async {
    // Safety Check: Ensure API key exists.
    if (_apiKey.isEmpty) {
      throw 'API Key not found. Please check your .env file.';
    }

    // --- LAYER 1: Educational Context Injection ---
    // We modify the query to prioritize learning resources.
    final String educationalQuery = "$query learning tutorial education class chapter";

    try {
      // Perform the GET request
      final response = await _dio.get(
        '$_baseUrl/search',
        queryParameters: {
          'part': 'snippet', // We only need the title/image (snippet).
          'maxResults': maxResults,
          'q': educationalQuery,
          'type': 'video',
          'key': _apiKey,
          'safeSearch': 'strict', // Layer 2: YouTube's strict filter.
          'videoCategoryId': '27', // Layer 3: Restrict to 'Education' category.
          'videoEmbeddable': 'true', // Ensure we can play it inside our app.
        },
      );

      if (response.statusCode == 200) {
        // Request Successful
        final data = response.data;
        final List<dynamic> items = data['items'];

        // Filter out channels/playlists and convert to our Model
        return items
            .where((item) => item['id']['kind'] == 'youtube#video')
            .map((item) => YoutubeVideoModel.fromJson(item))
            .toList();
      } else {
        throw 'Failed to fetch videos. Status: ${response.statusCode}';
      }
    } on DioException catch (e) {
      // Handle network errors gracefully
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