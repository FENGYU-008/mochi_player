import 'package:mochi_player/core/domain/media/media_file.dart';
import 'package:mochi_player/core/domain/playback/playback_target.dart';

class PlayerRouteData {
  const PlayerRouteData({required this.videoItem, required this.target, this.contextTitle, this.playlist = const []});

  final MediaFile videoItem;
  final PlaybackTarget target;
  final String? contextTitle;
  final List<MediaFile> playlist;
}
