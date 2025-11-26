import 'package:flutter_riverpod/legacy.dart';
import 'package:quiz_panel/models/youtube_video_model.dart';
import 'package:quiz_panel/repositories/youtube_repository.dart';

class YoutubeSearchState {
  final bool isLoading;
  final List<YoutubeVideoModel> videos;
  final String? error;

  YoutubeSearchState({
    this.isLoading = false,
    this.videos = const [],
    this.error,
  });
}

// Notifier
class YoutubeSearchNotifier extends StateNotifier<YoutubeSearchState> {
  final YoutubeRepository _repository;

  YoutubeSearchNotifier(this._repository) : super(YoutubeSearchState());

  Future<void> search(String query) async {
    if (query
        .trim()
        .isEmpty) {
      return;
    }

    state = YoutubeSearchState(isLoading: true);

    try {
      final videos = await _repository.searchVideos(query);
      state = YoutubeSearchState(videos: videos, isLoading: false);
    } catch (e) {
      state = YoutubeSearchState(
          isLoading: false,
          error: e.toString(),
          videos: []
      );
    }
  }
}

// Provider
final youtubeSearchProvider = StateNotifierProvider.autoDispose<
    YoutubeSearchNotifier,
    YoutubeSearchState>((ref) {
  return YoutubeSearchNotifier(ref.watch(youtubeRepositoryProvider));
});
