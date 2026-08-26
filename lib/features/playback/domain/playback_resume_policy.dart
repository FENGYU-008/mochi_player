import 'package:mochi_player/core/domain/media/media_file.dart';

/// Decides whether playback should resume and where it should start.
class PlaybackResumePolicy {
  static const Duration backoff = Duration(seconds: 5);
  static const double completionThreshold = 0.95;

  static Duration? positionFor(MediaFile item, {required bool hasRestoredPosition}) {
    if (hasRestoredPosition || item.position <= 0) return null;
    if (item.duration > 0 && item.position >= item.duration * completionThreshold) {
      return null;
    }

    final positionMs = (item.position - backoff.inMilliseconds).clamp(0, item.position).toInt();
    return positionMs > 0 ? Duration(milliseconds: positionMs) : null;
  }
}
