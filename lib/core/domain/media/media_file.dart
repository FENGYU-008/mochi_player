import 'package:mochi_player/core/domain/media/media_type.dart';
import 'package:mochi_player/core/domain/media/watch_status.dart';

/// 媒体文件 Domain Model
class MediaFile {
  final int id;
  final String sourceId;
  final String path;
  final String fileName;
  final String parsedTitle;
  final int? parsedYear;
  final int? parsedSeason;
  final int? parsedEpisode;
  final MediaType mediaType;
  final String? movieTmdbId;
  final String? tvShowTmdbId;
  final String? episodeTmdbId;
  final int size;
  final String? container;
  final int? width;
  final int? height;
  final String? videoCodec;
  final String? audioCodec;
  final String? audioChannels;
  final bool isHdr;
  final String? hdrFormat;
  final String? versionLabel;
  final int duration;
  final int position;
  final WatchStatus watchStatus;
  final DateTime? lastWatchedAt;
  final bool isFavorite;
  final DateTime addedAt;

  const MediaFile({
    required this.id,
    this.sourceId = '',
    required this.path,
    required this.fileName,
    required this.parsedTitle,
    this.parsedYear,
    this.parsedSeason,
    this.parsedEpisode,
    this.mediaType = MediaType.unknown,
    this.movieTmdbId,
    this.tvShowTmdbId,
    this.episodeTmdbId,
    this.size = 0,
    this.container,
    this.width,
    this.height,
    this.videoCodec,
    this.audioCodec,
    this.audioChannels,
    this.isHdr = false,
    this.hdrFormat,
    this.versionLabel,
    this.duration = 0,
    this.position = 0,
    this.watchStatus = WatchStatus.notStarted,
    this.lastWatchedAt,
    this.isFavorite = false,
    required this.addedAt,
  });

  /// Metadata ID of the directly playable item: movie for movies, episode for
  /// TV episodes. Parent show IDs intentionally live in [tvShowTmdbId].
  String? get tmdbId => movieTmdbId ?? episodeTmdbId;

  /// 播放进度百分比
  double get progress => duration == 0 ? 0 : position / duration;

  /// 质量标签
  String get quality {
    if (height == null) return '';
    if (height! >= 2160) return '4K';
    if (height! >= 1080) return '1080p';
    if (height! >= 720) return '720p';
    return 'SD';
  }
}
