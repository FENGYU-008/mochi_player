import 'package:mochi_player/core/domain/media/media_file.dart';

abstract final class MediaFormat {
  static String fileSize(int bytes) {
    if (bytes <= 0) return '';
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
      final minutes = duration.inMinutes
          .remainder(60)
          .toString()
          .padLeft(2, '0');
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

  static String seasonCount(int count) => count == 1 ? '1 季' : '$count 季';
}

abstract final class MediaFilePresentation {
  static String versionTitle(MediaFile file) {
    final parsedLabel = file.versionLabel?.trim();
    if (parsedLabel != null && parsedLabel.isNotEmpty) return parsedLabel;

    final parts = [
      file.quality,
      file.videoCodec,
      if (file.isHdr) file.hdrFormat ?? 'HDR',
    ].whereType<String>().where((part) => part.trim().isNotEmpty).toSet();
    return parts.isEmpty ? file.fileName : parts.join(' • ');
  }

  static String versionSubtitle(
    MediaFile file, {
    bool includeContainer = true,
    bool includeResumePosition = false,
  }) {
    final parts = <String>[];
    final codec = file.audioCodec;
    if (codec != null && codec.isNotEmpty) {
      parts.add(codec);
    }
    final channels = file.audioChannels;
    if (channels != null && channels.isNotEmpty) {
      parts.add(channels);
    }
    final container = file.container;
    if (includeContainer && container != null && container.isNotEmpty) {
      parts.add(container.toUpperCase());
    }
    if (file.size > 0) parts.add(MediaFormat.fileSize(file.size));
    if (includeResumePosition &&
        file.position > 0 &&
        file.duration > 0 &&
        file.progress < 0.95) {
      parts.add(
        '从 ${MediaFormat.clockDuration(Duration(milliseconds: file.position))} 继续',
      );
    }
    return parts.isEmpty ? file.fileName : parts.join(' • ');
  }

  /// Compact title used by playable-version cards.
  ///
  /// The stored label also contains codecs; those belong in the details line.
  static String playableVersionTitle(MediaFile file) {
    var title = file.versionLabel?.trim() ?? '';
    if (title.isEmpty) {
      return file.quality.isNotEmpty ? file.quality : file.fileName;
    }

    final technicalParts = [
      _formattedCodec(file.videoCodec),
      _formattedCodec(file.audioCodec),
      _formattedHdr(file.hdrFormat),
    ].whereType<String>().where((part) => part.isNotEmpty);
    for (final part in technicalParts) {
      title = title.replaceAll(
        RegExp(RegExp.escape(part), caseSensitive: false),
        ' ',
      );
    }
    title = title.replaceAll(RegExp(r'\s+'), ' ').trim();
    return title.isEmpty
        ? (file.quality.isNotEmpty ? file.quality : file.fileName)
        : title;
  }

  /// Technical details displayed below a playable version title.
  static String playableVersionDetails(MediaFile file) {
    final parts = <String>[];
    final videoParts = [
      _formattedCodec(file.videoCodec),
      _formattedHdr(file.hdrFormat),
    ].whereType<String>().where((part) => part.isNotEmpty).toList();
    if (videoParts.isNotEmpty) parts.add(videoParts.join(' '));

    final audioParts = [
      _formattedCodec(file.audioCodec),
      file.audioChannels,
    ].whereType<String>().where((part) => part.isNotEmpty).toList();
    if (audioParts.isNotEmpty) parts.add(audioParts.join(' '));

    final container = file.container;
    if (container != null && container.isNotEmpty) {
      parts.add(container.toUpperCase());
    }
    if (file.size > 0) parts.add(MediaFormat.fileSize(file.size));
    return parts.isEmpty ? file.fileName : parts.join(' · ');
  }

  static String? _formattedHdr(String? value) {
    if (value == null || value.isEmpty) return null;
    return switch (value.toLowerCase()) {
      'dolby_vision' => 'Dolby Vision',
      'hdr10plus' => 'HDR10+',
      _ => value.replaceAll('_', ' ').toUpperCase(),
    };
  }

  static String? _formattedCodec(String? value) {
    if (value == null || value.isEmpty) return null;
    return value.toUpperCase();
  }
}
