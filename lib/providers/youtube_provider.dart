// lib/providers/youtube_provider.dart

import 'package:flutter_riverpod/legacy.dart';
import 'package:quiz_panel/models/youtube_video_model.dart';
import 'package:quiz_panel/repositories/youtube_repository.dart';

/// **Why we used this class (YoutubeVideoState):**
/// This class represents the "snapshot" of the videos at any given moment.
/// It tells the UI:
/// 1. Are we waiting for results? (isLoading)
/// 2. Do we have videos to show? (videos)
/// 3. Did something break? (error)
///
/// **How it helps:**
/// By grouping these together, we avoid managing separate boolean and list variables in the UI.
/// The UI simply watches this one object and redraws itself based on the current values.
class YoutubeVideoState {
  final bool isLoading; // Shows a loading spinner if true.
  final List<YoutubeVideoModel> videos; // The list of videos fetched from YouTube.
  final String? error; // Stores an error message if the search failed.

  // **Constructor:**
  // Sets safe default values: not loading, empty list, no error.
  YoutubeVideoState({
    this.isLoading = false,
    this.videos = const [],
    this.error,
  });

// Helper method to update specific fields while keeping others the same
  YoutubeVideoState copyWith({
    bool? isLoading,
    List<YoutubeVideoModel>? videos,
    String? error,
  }) {
    return YoutubeVideoState(
      isLoading: isLoading ?? this.isLoading,
      videos: videos ?? this.videos,
      // If error is explicitly passed as null, we clear it. Otherwise keep existing.
      // NOTE: We logic this slightly differently usually, but for simplicity:
      error: error,
    );
  }
}

/// **Why we used this class (YoutubeVideoNotifier):**
/// This is the "Brain" or "Logic Controller" for the videos feature.
/// It acts as the middleman between the UI (Screen) and the Data (Repository).
///
/// **What it does:**
/// It receives a query to display the video, asks the repository to fetch data,
/// and then updates the `YoutubeVideoState` with the result.
class YoutubeVideoNotifier extends StateNotifier<YoutubeVideoState> {
  // We need the repository to perform the actual API call.
  final YoutubeRepository _repository;

  // Constructor: Inject the repository and set the initial empty state.
  YoutubeVideoNotifier(this._repository) : super(YoutubeVideoState());

  /// **Logic: Fetch Videos**
  /// This function orchestrates the fetching videos process.
  ///
  /// **How it works:**
  /// 1. **Validation:** Checks if the query is empty to avoid unnecessary calls.
  /// 2. **Loading:** Immediately updates state to `isLoading: true` (UI shows spinner).
  /// 3. **Fetch:** Calls the repository to get data from the YouTube API.
  /// 4. **Success:** Updates state with the list of videos and `isLoading: false`.
  /// 5. **Error:** Catches any crashes, updates state with the error message, and stops loading.
  Future<void> fetchVideos(String query) async {
    // state = YoutubeVideoState(isLoading: true, videos: state.videos);
    /*if (query.trim().isEmpty) {
      return; // Don't search for empty strings.
    }*/

    // Step 1: Start loading.
    state = YoutubeVideoState(isLoading: true,  videos: state.videos);

    try {
      // Step 2: Fetch data (pass maxResults for pagination control).
      final videos = await _repository.fetchRelatedVideos(query);

      // Step 3: Update state with success.
      state = YoutubeVideoState(isLoading: false, videos: videos);
    } catch (e) {
      // Step 4: Handle failure.
      state = YoutubeVideoState(
          isLoading: false,
          error: e.toString(),
          videos: [] // Clear previous results on error.
      );
    }
  }
}

/// **What is this Provider? (youtubeVideoProvider)**
/// This connects the `YoutubeVideoNotifier` to the Flutter UI.
///
/// **Key Features:**
/// - **autoDispose:** Automatically resets the video state (clears results) when the user leaves the screen.
/// - **Dependency Injection:** Automatically finds and injects the `youtubeRepositoryProvider`.
final youtubeVideoProvider = StateNotifierProvider.autoDispose<
    YoutubeVideoNotifier,
    YoutubeVideoState>((ref) {
  // We get the repository from the provider we created in Step 2
  final repository = ref.watch(youtubeRepositoryProvider);

  // Watch the repository provider to get the tool needed for searching.
  return YoutubeVideoNotifier(repository);
});