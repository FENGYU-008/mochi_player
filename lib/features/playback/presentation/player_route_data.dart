import 'package:mochi_player/core/domain/media/media_file.dart';

class PlayerRouteData {
  const PlayerRouteData({
    required this.videoItem,
    required this.url,
    this.contextTitle,
    this.playlist = const [],
  });

  final MediaFile videoItem;
  final String url;
  final String? contextTitle;
  final List<MediaFile> playlist;
}
