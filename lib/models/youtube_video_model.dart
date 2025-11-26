class YoutubeVideoModel {
  final String id;
  final String title;
  final String thumbnailUrl;
  final String channelTitle;

  YoutubeVideoModel({
    required this.id,
    required this.title,
    required this.thumbnailUrl,
    required this.channelTitle,
  });

  factory YoutubeVideoModel.fromJson(Map<String, dynamic> json) {
    final snippet = json['snippet'];

    return YoutubeVideoModel(
      id: json['id']['videoId'] ?? '',
      title: snippet['title'] ?? '',
      thumbnailUrl: snippet['thumbnails']['high']['url'] ?? '',
      channelTitle: snippet['channelTitle'] ?? '',
    );
  }
}
