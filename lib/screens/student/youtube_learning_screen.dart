// lib/screens/student/youtube_learning_screen.dart

/*
/// Why we used this file (YoutubeLearningScreen):
/// This screen serves as the **'Study Room'** for students. It provides an integrated and focused environment
/// for students to search for and consume supplemental educational content from external sources, primarily YouTube.
/// This is used to facilitate immediate learning after a quiz, or when a student decides to study a new topic.

/// What it is doing:
/// 1. **Video Playback:** Integrates the `Youtubeer_iframe` to enable in-app, distraction-reduced video playback.
/// 2. **Responsive Layout:** Automatically switches between a vertical list (for mobile) and a multi-column grid (for web/desktop) to optimize content display for the current device.

/// How it is working:
/// The screen uses **Riverpod** to manage the state of the YouTube search results (`youtubeSearchProvider`). The core logic handles
/// the initialization and disposal of the video player controller (`YoutubePlayerController`) and adjusts the search result limit based on the platform (`kIsWeb`).

/// How it's helpful:
/// It enhances the learning experience by providing easy access to external resources without leaving the application. This promotes
/// a self-directed learning approach and offers a crucial tool for remediation and deeper understanding of subjects covered in the quizzes.
*/
import 'package:flutter/foundation.dart'; // Why we used: This import is crucial for checking the platform at runtime, specifically via `kIsWeb`.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_panel/config/theme/app_theme.dart';
import 'package:quiz_panel/models/youtube_video_model.dart';
import 'package:quiz_panel/providers/youtube_provider.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

/// Why we used this Widget:
/// This is the main screen widget, defined as a `ConsumerStatefulWidget` because it needs to read (consume) Riverpod state
/// AND manage local mutable state (the `_controller` for the YouTube player and the `_searchController`).
class YoutubeLearningScreen extends ConsumerStatefulWidget {
  final String initialQuery;

  // Why we used `initialQuery`: It allows the previous screen (e.g., the quiz result screen) to seamlessly pass a starting search term, like the quiz subject.
  // The topic is now mandatory as it's the only source for fetching videos.
  const YoutubeLearningScreen({super.key, required this.initialQuery});

  @override
  ConsumerState<YoutubeLearningScreen> createState() =>
      _YoutubeLearningScreenState();
}

/// What it is doing: Manages the internal state for the screen, handling controllers and implementing all UI logic.
class _YoutubeLearningScreenState extends ConsumerState<YoutubeLearningScreen> {
  // Why we used `YoutubePlayerController`: This object is essential for controlling the embedded video player (loading, playing, pausing).
  YoutubePlayerController? _controller;

  @override
  void initState() {
    super.initState();
    // How it is working: Automatically fetch videos when the screen loads.
    // *after* the widget has been built and rendered to the screen, preventing potential frame-build errors.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // What it is doing: Automatically fetch videos when the screen loads.
      ref.read(youtubeVideoProvider.notifier).fetchVideos(widget.initialQuery);
    });
  }

  /*/// What it is doing: Calculate limits and call the provider
  void _fetchVideos(String query) {
    if (query.trim().isNotEmpty) {
      // --- LIMIT LOGIC ---
      // Why we used this: To optimize resource usage and load times, especially important on mobile data plans.
      // 50 is the maximum allowed value for 'maxResults' in the YouTube Data API.
      const int limit = 50;

      // How it is working: Calls the `youtubeSearchProvider` notifier to trigger the asynchronous API call and update the state.
      ref.read(youtubeVideoProvider.notifier).fetchVideos(
          query, maxResults: limit);
    }
  }*/

  /// What it is doing: Loads and plays the video corresponding to the given ID.
  void _playVideo(String videoId) {
    if (_controller != null) {
      _controller!.close();
      // How it is working: If a player instance already exists, it simply loads the new video by ID, which is faster than re-initializing.
      _controller!.loadVideoById(videoId: videoId);
    }

    _controller =
        YoutubePlayerController.fromVideoId(
            videoId: videoId, autoPlay: true, params: const YoutubePlayerParams(
            showControls: true,
            showFullscreenButton: true,
            mute: false
        ));
    /*else {
      // How it is working: If this is the first video, it initializes the controller with specific, safe parameters.
      // Why we used these params: `strictRelatedVideos` is helpful for maintaining focus on educational content and minimizing distractions.
      _controller = YoutubePlayerController.fromVideoId(
        videoId: videoId,
        autoPlay: true,
        params: const YoutubePlayerParams(
          showControls: true,
          showFullscreenButton: true,
          mute: false,
          // strictRelatedVideos: true,
          // playsInline: true,
        ),
      );
    }*/
    // What it is doing: Triggers a state change to render the newly created or updated video player widget.
    setState(() {});
  }

  @override
  /// What it is doing: Cleans up the `YoutubePlayerController` and `TextEditingController`.
  /// How it's helpful: Essential for preventing memory leaks, especially when dealing with platform-specific resources like video players.
  void dispose() {
    // Important: Close the player to prevent memory leaks
    _controller
        ?.close(); // Specific method to properly close the YouTube player.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch the state from our provider
    final state = ref.watch(youtubeVideoProvider);
    final size = MediaQuery
        .of(context)
        .size;

    return Scaffold(
      appBar: AppBar(
        // Display the topic name in the AppBar since there's no search bar.
        title: Text('Study: ${widget.initialQuery}'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // 1. Player Area
          // What it is doing: Conditionally renders the video player only if a controller has been initialized (i.e., a video has been selected).
          if (_controller != null)
            Container(
              color: Colors.black,
              width: double.infinity,
              // alignment: Alignment.center,
              // Centers the video if constrained
              // Add vertical padding on web for better aesthetics
              padding: kIsWeb
                  ? const EdgeInsets.symmetric(vertical: 20)
                  : EdgeInsets.zero,
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    // On Web: Limit height to 60% of screen so it doesn't push the list off.
                    // On Mobile: Allow it to take natural height based on width.
                    maxHeight: kIsWeb ? size.height * 0.6 : double.infinity,
                    // On Web: Limit width so it doesn't look stretched on ultra-wide monitors.
                    maxWidth: 800,
                  ),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: YoutubePlayer(
                      key: ObjectKey(_controller),
                      controller: _controller!,
                      aspectRatio: 16 / 9,
                    ),
                  ),
                ),
              ),
            ),

          // 2. Video Grid
          Expanded(
            child: state.isLoading
            // How it's helpful: Provides immediate visual feedback that a request is in progress.
                ? const Center(child: CircularProgressIndicator())
                : state.error != null
                ? _buildErrorView(state.error!)
                : state.videos.isEmpty
                ? const Center(
              // What it is doing: Shows a friendly prompt when there are no search results or before the first search.
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.video_library_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text("No videos found for this topic."),
                ],
              ),
            )
            // Use _buildGridView for both, but configure columns differently.
                : _buildVideoGrid(state.videos),
          ),
        ],
      ),
    );
  }

  /*// --- List View for Mobile ---
  /// What it is doing: Constructs a vertically scrollable list of video cards.
  Widget _buildListView(List<YoutubeVideoModel> videos) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      itemCount: videos.length,
      itemBuilder: (context, index) {
        final video = videos[index];
        return _buildVideoCard(video);
      },
    );
  }
*/

  // Helper: Error View
  Widget _buildErrorView(String error) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              'Oops! $error',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref
                    .read(youtubeVideoProvider.notifier)
                    .fetchVideos(widget.initialQuery);
              },
              child: const Text("Try Again"),
            ),
          ],
        ),
      ),
    );
  }

  // --- Grid View for both Web and Mobile ---
  /// What it is doing: Constructs a responsive grid layout.
  /// Mobile: Fixed 2 columns.
  /// Web: Adaptive max extent (responsive).
  Widget _buildVideoGrid(List<YoutubeVideoModel> videos) {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      // How it is working: `SliverGridDelegateWithMaxCrossAxisExtent` automatically calculates the number of columns
      // based on the available width, ensuring responsiveness.
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        // Responsive columns: 1 on phone, 2 on tablet, 3-4 on web
        crossAxisCount: kIsWeb
            ? (MediaQuery
            .of(context)
            .size
            .width > 800 ? 4 : 3)
            : 2,
        childAspectRatio: 0.85, // Adjust card height
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: videos.length,
      itemBuilder: (context, index) {
        final video = videos[index];
        // What it is doing: Passes `isGrid: true` to adjust the card's internal padding/margin.
        return _buildVideoCard(video);
      },
    );
  }

  /// What it is doing: Renders a single video result card.
  Widget _buildVideoCard(YoutubeVideoModel video) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _playVideo(video.id),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail Image
            Expanded(
              flex: 6,
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      video.thumbnailUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) =>
                          Container(
                            color: Colors.grey,
                          ), // c: context, e: error, s: stackTrace
                    ),
                    const Center(
                      child: Icon(
                        Icons.play_circle_fill,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Title & Channel
            Expanded(
              flex: 4,
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      video.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      video.channelTitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey[600], fontSize: 11),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
