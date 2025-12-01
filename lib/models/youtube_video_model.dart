// lib/models/youtube_video_model.dart

/// **Why we used this class (YoutubeVideoModel):**
/// This class acts as a "container" or "blueprint" for a single YouTube video.
/// When we search for videos using the YouTube API, the result comes back as complex JSON data.
/// We use this class to convert that raw data into a clean, easy-to-use Dart object.
///
/// **How it helps:**
/// Instead of writing `json['snippet']['title']` everywhere in our app (which is error-prone),
/// we can simply use `video.title`. It makes the code cleaner and safer.
class YoutubeVideoModel {
  // **Data Fields:**
  // These variables hold the specific details for one video.

  final String id; // The unique Video ID (e.g., "dQw4w9WgXcQ"). Used to play the video.
  final String title; // The main headline/title of the video.
  final String thumbnailUrl; // The internet link (URL) to the video's cover image.
  final String channelTitle; // The name of the YouTube channel that uploaded this video.

  // **Constructor:**
  // Creates a standard YoutubeVideoModel instance.
  YoutubeVideoModel({
    required this.id,
    required this.title,
    required this.thumbnailUrl,
    required this.channelTitle,
  });

  /// **What is this Factory Constructor? (fromJson)**
  /// This acts as a "Translator". The YouTube API gives us data in a specific, nested JSON format.
  /// This function knows exactly where to find the data we need inside that messy JSON structure.
  ///
  /// **How it works:**
  /// 1. It takes a `Map` (the JSON object).
  /// 2. It extracts the `snippet` part, which contains most of the visible info (title, image).
  /// 3. It digs into the nested maps to find the specific strings we need.
  /// 4. It uses `??` (null check) to provide safe empty strings if the API sends incomplete data.
  factory YoutubeVideoModel.fromJson(Map<String, dynamic> json) {
    // The 'snippet' field contains title, description, thumbnails, etc.
    final snippet = json['snippet'];

    return YoutubeVideoModel(
      // The Video ID is usually inside an 'id' object: { "id": { "videoId": "..." } }
      id: json['id']['videoId'] ?? '',

      // Title is directly inside the snippet.
      title: snippet['title'] ?? 'No Title',

      // Thumbnails are nested deep: snippet -> thumbnails -> high -> url.
      thumbnailUrl: snippet['thumbnails']['high']['url'] ?? '',

      // The channel name is also directly in the snippet.
      channelTitle: snippet['channelTitle'] ?? '',
    );
  }
}