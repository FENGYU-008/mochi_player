import 'package:mochi_player/core/domain/media/media_file.dart';

/// Formats media-related values for display.
abstract final class MediaFormat {
  static String fileSize(int bytes) {
    if (bytes < 0) return '';
    if (bytes == 0) return '0 B';

    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    var value = bytes.toDouble();
    var suffixIndex = 0;
    while (value >= 1024 && suffixIndex < suffixes.length - 1) {
      value /= 1024;
      suffixIndex++;
    }
    final decimals = suffixIndex == 0
        ? 0
        : suffixIndex >= 3
        ? 2
        : 1;
    return '${value.toStringAsFixed(decimals)} ${suffixes[suffixIndex]}';
  }

  static String clockDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return hours > 0 ? '$hours:$minutes:$seconds' : '$minutes:$seconds';
  }

  static String compactDuration(Duration duration) {
    if (duration.inHours > 0) {
      final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
      return '${duration.inHours}h ${minutes}m';
    }
    return '${duration.inMinutes}m';
  }

  static String? episodeLabel(MediaFile file) {
    final season = file.parsedSeason;
    final episode = file.parsedEpisode;
    if (season == null || episode == null) return null;
    return '第 $season 季 第 $episode 集';
  }

  static String seasonCount(int count) => '$count 季';
}
