// lib/screens/student/youtube_learning_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_panel/config/theme/app_theme.dart';
import 'package:quiz_panel/models/youtube_video_model.dart';
import 'package:quiz_panel/providers/youtube_provider.dart';
import 'package:quiz_panel/widgets/inputs/app_text_field.dart';
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
      FocusScope.of(context).unfocus(); // Important: Close keyboard on mobile
      ref.read(youtubeSearchProvider.notifier).search(query);
    }
  }

  void _playVideo(String videoId) {
    if (_controller != null) {
      _controller!.loadVideoById(videoId: videoId);
    } else {
      // .fromVideoId is the recommended way to support both Web and Mobile (WebView)
      _controller = YoutubePlayerController.fromVideoId(
        videoId: videoId,
        autoPlay: true,
        params: const YoutubePlayerParams(
          showControls: true,
          showFullscreenButton: true,
          strictRelatedVideos: true, // Prevents showing unrelated videos on mobile
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
                  // Ensure aspectRatio is set to match the container
                  aspectRatio: 16 / 9,
                ),
              ),
            ),

          // 2. Search Bar
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: AppTextField(
                    controller: _searchController,
                    label: 'Search topic...',
                    prefixIcon: Icons.search,
                    onSubmitted: (val) => _performSearch(val),
                  ),
                ),
                const SizedBox(width: 12),
                InkWell(
                  onTap: () => _performSearch(_searchController.text),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    height: 56,
                    width: 56,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.search_rounded,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 3. Video List
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
                : ListView.builder(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              itemCount: searchState.videos.length,
              itemBuilder: (context, index) {
                final video = searchState.videos[index];
                return _buildVideoCard(video);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoCard(YoutubeVideoModel video) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
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
                  decoration: BoxDecoration(
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