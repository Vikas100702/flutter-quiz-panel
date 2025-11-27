import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:profanity_filter/profanity_filter.dart';
import 'package:quiz_panel/config/secrets/blocked_keywords.dart';
import 'package:quiz_panel/models/youtube_video_model.dart';

/// **What is this Provider? (youtubeRepositoryProvider)**
/// This provider creates and gives access to the `YoutubeRepository`.
///
/// **Why do we need it?**
/// This allows our `YoutubeSearchNotifier` (in the provider folder) to access the API functions easily.
final youtubeRepositoryProvider = Provider<YoutubeRepository>((ref) => YoutubeRepository());

/// **Why we used this class (YoutubeRepository):**
/// This class handles all communication with the YouTube Data API.
/// Its job is to fetch educational videos while ensuring the content is safe for students.
///
/// **How it helps:**
/// It implements a **"4-Layer Safety System"** to prevent students from accessing harmful content:
/// 1. **Keyword Blocking:** Checks for bad words before searching.
/// 2. **Context Injection:** Forces the search to be educational (adds "learning", "class").
/// 3. **Safe Search:** Tells YouTube to filter explicit results.
/// 4. **Category Filtering:** Restricts results to the "Education" category only.
class YoutubeRepository {
  final Dio _dio = Dio(); // The tool used to make HTTP network requests.
  final _filter = ProfanityFilter(); // A utility to detect swear words.

  // Get the API Key and Base URL securely from the .env file.
  String get _apiKey => dotenv.env['YOUTUBE_API_KEY'] ?? '';
  String get _baseUrl => dotenv.env['YOUTUBE_BASE_URL'] ?? 'https://www.googleapis.com/youtube/v3';

  // --- INTERNAL HELPER: Safety Check ---

  /// **Logic: Query Validation (Layer 1)**
  /// This function checks if the user's search term is allowed BEFORE we even send it to YouTube.
  ///
  /// **How it works:**
  /// 1. **Profanity Check:** Uses a library to catch standard bad words.
  /// 2. **Normalization:** Cleans the text (lowercase, removes symbols) to catch tricky inputs.
  /// 3. **Blacklist Check:** Compares the query against our custom list of `blockedKeywords`.
  bool _isQueryAllowed(String query) {
    // A. Standard Profanity Check
    if (_filter.hasProfanity(query)) {
      return false;
    }

    // B. Normalization (Cleaning the input)
    // Example: "H.O.T" becomes "hot" to ensure we catch it.
    String processedQuery = query.toLowerCase();
    String strictQuery = processedQuery.replaceAll(RegExp(r'[^a-z0-9]'), '');

    // C. Custom Blacklist Check
    // We loop through our manual list of bad words.
    for (final word in blockedKeywordsList) {
      // Logic 1: Strict Check (matches hidden words like "b a d")
      if (strictQuery.contains(word.replaceAll(' ', ''))) {
        return false;
      }
      // Logic 2: Standard Check (matches normal words)
      if (processedQuery.contains(word)) {
        return false;
      }
    }

    return true; // If all checks pass, the query is safe.
  }

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
  Future<List<YoutubeVideoModel>> searchVideos(String query, {int maxResults = 10}) async {
    // Safety Check: Ensure API key exists.
    if (_apiKey.isEmpty) {
      throw 'API Key not found. Please check your .env file.';
    }

    // --- LAYER 1: Pre-Search Blocking ---
    // If the query contains bad words, stop immediately. Don't even call the API.
    if (!_isQueryAllowed(query)) {
      throw 'Restricted Content: This search term is restricted for educational integrity.';
    }

    // --- LAYER 2: Educational Context Injection ---
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
          'safeSearch': 'strict', // Layer 3: YouTube's strict filter.
          'videoCategoryId': '27', // Layer 4: Restrict to 'Education' category.
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