import 'package:isar/isar.dart';
import 'package:mochi_player/core/infrastructure/database/entities/stored_media_type.dart';
import 'package:mochi_player/core/infrastructure/database/entities/stored_watch_status.dart';

part 'media_file_entity.g.dart';

/// 物理媒体文件实体
/// 每个文件对应一条记录，通过 tmdbId 关联到元数据
@collection
class MediaFileEntity {
  Id id = Isar.autoIncrement;

  /// 文件完整路径 (唯一标识)
  @Index(unique: true)
  late String path;

  /// 原始文件名
  late String fileName;

  /// 解析后的标题 (用于搜索 TMDB)
  late String parsedTitle;

  /// 解析出的年份
  int? parsedYear;

  /// 解析出的季号 (剧集用)
  int? parsedSeason;

  /// 解析出的集号 (剧集用)
  int? parsedEpisode;

  /// 媒体类型 (movie/episode/unknown)
  @Enumerated(EnumType.ordinal)
  StoredMediaType mediaType = StoredMediaType.unknown;

  // ===== 关联 =====

  /// TMDB ID (刮削后填充，用于关联元数据)
  @Index()
  String? tmdbId;

  // ===== 技术信息 =====

  /// 文件大小 (字节)
  int size = 0;

  /// 容器格式 (mkv, mp4)
  String? container;

  /// 视频宽度 (像素)
  int? width;

  /// 视频高度 (像素)
  int? height;

  /// 视频编码 (hevc, h264)
  String? videoCodec;

  /// 音频编码 (aac, dts)
  String? audioCodec;

  /// 音频声道 (2.0, 5.1, 7.1)
  String? audioChannels;

  /// 是否 HDR
  bool isHdr = false;

  /// HDR 格式 (dolby_vision, hdr10, hdr10plus)
  String? hdrFormat;

  /// 版本标识 (如 "1080p BluRay DTS")
  String? versionLabel;

  // ===== 播放状态 =====

  /// 总时长 (毫秒)
  int duration = 0;

  /// 播放进度 (毫秒)
  int position = 0;

  /// 观看状态
  @Index()
  @Enumerated(EnumType.ordinal)
  StoredWatchStatus watchStatus = StoredWatchStatus.notStarted;

  /// 最后观看时间
  @Index()
  DateTime? lastWatchedAt;

  // ===== 用户状态 =====

  /// 是否收藏
  @Index()
  bool isFavorite = false;

  /// 添加时间
  @Index()
  DateTime addedAt = DateTime.now();

  // ===== 计算属性 =====

  /// 播放进度百分比
  double get progress => duration == 0 ? 0 : position / duration;

  /// 质量标签 (从分辨率计算)
  String get quality {
    if (height == null) return '';
    if (height! >= 2160) return '4K';
    if (height! >= 1080) return '1080p';
    if (height! >= 720) return '720p';
    return 'SD';
  }
}
