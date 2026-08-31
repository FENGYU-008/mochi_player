import 'package:mochi_player/core/domain/media/media_file.dart';
import 'package:mochi_player/core/domain/playback/playback_target.dart';

abstract interface class PlaybackTargetResolver {
  Future<PlaybackTarget?> resolve(MediaFile file);
}
