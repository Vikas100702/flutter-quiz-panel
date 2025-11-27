// lib/screens/student/youtube_learning_screen.dart
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_panel/config/theme/app_theme.dart';
import 'package:quiz_panel/models/youtube_video_model.dart';
import 'package:quiz_panel/providers/youtube_provider.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class YoutubeLearningScreen extends ConsumerStatefulWidget {
  final String initialQuery;

  const YoutubeLearningScreen({super.key, required this.initialQuery});

  @override
  ConsumerState<YoutubeLearningScreen> createState() =>
      _YoutubeLearningScreenState();
}

class _YoutubeLearningScreenState extends ConsumerState<YoutubeLearningScreen> {
  final _searchController = TextEditingController();
  YoutubePlayerController? _controller;

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.initialQuery;

    // Auto-search initial query after frame build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialQuery.isNotEmpty) {
        _performSearch(widget.initialQuery);
      }
    });
  }

  void _performSearch(String query) {
    if (query.trim().isNotEmpty) {
      FocusScope.of(context).unfocus();

      // --- LIMIT LOGIC ---
      // 50 for Web, 25 for Mobile
      final int limit = kIsWeb ? 50 : 25;

      ref.read(youtubeSearchProvider.notifier).search(query, maxResults: limit);
    }
  }

  void _playVideo(String videoId) {
    if (_controller != null) {
      _controller!.loadVideoById(videoId: videoId);
    } else {
      _controller = YoutubePlayerController.fromVideoId(
        videoId: videoId,
        autoPlay: true,
        params: const YoutubePlayerParams(
          showControls: true,
          showFullscreenButton: true,
          strictRelatedVideos: true,
        ),
      );
    }
    setState(() {});
  }

  @override
  void dispose() {
    _controller?.close();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(youtubeSearchProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Room'),
        backgroundColor: AppColors.primary,
      ),
      body: Column(
        children: [
          // 1. Player Area
          if (_controller != null)
            Container(
              color: Colors.black,
              width: double.infinity,
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: YoutubePlayer(
                  controller: _controller!,
                  aspectRatio: 16 / 9,
                ),
              ),
            ),

          // 2. Search Bar
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.white,
            child: TextField(
              controller: _searchController,
              onSubmitted: (val) => _performSearch(val),
              textInputAction: TextInputAction.search,
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'Search topic...',
                hintStyle: const TextStyle(color: AppColors.textTertiary),
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.textTertiary,
                ),
                suffixIcon: Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_forward_rounded, color: Colors.white),
                      onPressed: () => _performSearch(_searchController.text),
                      tooltip: 'Search',
                    ),
                  ),
                ),
                filled: true,
                fillColor: AppColors.surface,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.outline),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.outline),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 2
                  ),
                ),
              ),
            ),
          ),

          // 3. Video List / Grid
          Expanded(
            child: searchState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : searchState.error != null
                ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Error: ${searchState.error}',
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            )
                : searchState.videos.isEmpty
                ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.video_library_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text("Search for a topic to start learning"),
                ],
              ),
            )
            // --- LAYOUT SWITCH LOGIC ---
                : kIsWeb
                ? _buildGridView(searchState.videos)
                : _buildListView(searchState.videos),
          ),
        ],
      ),
    );
  }

  // --- List View for Mobile ---
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

  // --- Grid View for Web ---
  Widget _buildGridView(List<YoutubeVideoModel> videos) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 350, // Adjust card width for web
        childAspectRatio: 0.95, // Adjust height/width ratio
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: videos.length,
      itemBuilder: (context, index) {
        final video = videos[index];
        return _buildVideoCard(video, isGrid: true);
      },
    );
  }

  Widget _buildVideoCard(YoutubeVideoModel video, {bool isGrid = false}) {
    return Card(
      // Remove external margin if in grid, let GridView handle spacing
      margin: isGrid ? EdgeInsets.zero : const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _playVideo(video.id),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.network(
                      video.thumbnailUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (ctx, err, stack) =>
                          Container(color: Colors.grey[300]),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    video.title,
                    style: AppTextStyles.titleMedium.copyWith(fontSize: 16),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    video.channelTitle,
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.textTertiary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}