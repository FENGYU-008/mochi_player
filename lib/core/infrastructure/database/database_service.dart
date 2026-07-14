import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:logger/logger.dart';
import 'entities/entities.dart';

/// 数据库服务 - 管理 Isar 数据库操作
class DatabaseService {
  // 单例模式
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  final _logger = Logger(printer: PrettyPrinter(methodCount: 0));
  late Isar _isar;
  bool _isInitialized = false;

  /// 获取 Isar 实例
  Isar get isar => _isar;

  /// 初始化数据库
  Future<void> init() async {
    if (_isInitialized) return;

    final dir = await getApplicationDocumentsDirectory();
    _logger.i('📦 初始化 Isar 数据库: ${dir.path}');

    _isar = await Isar.open([
      MediaFileEntitySchema,
      MovieMetadataEntitySchema,
      TVShowMetadataEntitySchema,
      SeasonMetadataEntitySchema,
      EpisodeMetadataEntitySchema,
    ], directory: dir.path);

    _isInitialized = true;
    _logger.i('✅ Isar 数据库初始化成功');
  }

  // ===== MediaFile CRUD =====

  /// 保存或更新媒体文件（使用 path 唯一索引）
  Future<void> saveMediaFile(MediaFileEntity file) async {
    await _isar.writeTxn(() async {
      // 使用 putByIndex 确保基于唯一索引更新，避免冲突
      await _isar.mediaFileEntitys.putByPath(file);
    });
  }

  /// 批量保存媒体文件
  Future<void> saveMediaFiles(List<MediaFileEntity> files) async {
    await _isar.writeTxn(() async {
      await _isar.mediaFileEntitys.putAll(files);
    });
  }

  /// 根据路径获取媒体文件
  Future<MediaFileEntity?> getMediaFileByPath(String path) async {
    return await _isar.mediaFileEntitys.filter().pathEqualTo(path).findFirst();
  }

  /// 获取所有媒体文件
  Future<List<MediaFileEntity>> getAllMediaFiles() async {
    return await _isar.mediaFileEntitys.where().findAll();
  }

  /// 批量删除媒体文件
  Future<int> deleteMediaFilesByIds(List<Id> ids) async {
    if (ids.isEmpty) return 0;

    return await _isar.writeTxn(() async {
      return _isar.mediaFileEntitys.deleteAll(ids);
    });
  }

  /// 获取正在观看的媒体文件 (按最后观看时间排序)
  Future<List<MediaFileEntity>> getContinueWatching() async {
    return await _isar.mediaFileEntitys
        .filter()
        .watchStatusEqualTo(WatchStatus.watching)
        .sortByLastWatchedAtDesc()
        .findAll();
  }

  /// 获取收藏的媒体文件
  Future<List<MediaFileEntity>> getFavorites() async {
    return await _isar.mediaFileEntitys
        .filter()
        .isFavoriteEqualTo(true)
        .findAll();
  }

  /// 获取最近添加的媒体文件
  Future<List<MediaFileEntity>> getRecentlyAdded({int limit = 20}) async {
    return await _isar.mediaFileEntitys
        .where()
        .sortByAddedAtDesc()
        .limit(limit)
        .findAll();
  }

  /// 获取某个 TMDB ID 的所有版本
  Future<List<MediaFileEntity>> getVersionsByTmdbId(String tmdbId) async {
    return await _isar.mediaFileEntitys
        .filter()
        .tmdbIdEqualTo(tmdbId)
        .findAll();
  }

  /// 更新播放进度
  Future<void> updateProgress(
    MediaFileEntity file,
    int position, {
    int? duration,
  }) async {
    if (duration != null && duration > 0) {
      file.duration = duration;
    }

    final normalizedPosition = position < 0 ? 0 : position;
    file.position = file.duration > 0
        ? normalizedPosition.clamp(0, file.duration).toInt()
        : normalizedPosition;
    file.lastWatchedAt = DateTime.now();

    // 自动计算观看状态
    if (file.position == 0) {
      file.watchStatus = WatchStatus.notStarted;
    } else if (file.duration > 0 && file.position >= file.duration * 0.95) {
      file.watchStatus = WatchStatus.completed;
    } else {
      file.watchStatus = WatchStatus.watching;
    }

    await saveMediaFile(file);
  }

  /// 切换收藏状态
  Future<void> toggleFavorite(MediaFileEntity file) async {
    file.isFavorite = !file.isFavorite;
    await saveMediaFile(file);
  }

  // ===== MovieMetadata CRUD =====

  /// 保存电影元数据（使用 tmdbId 唯一索引）
  Future<void> saveMovieMetadata(MovieMetadataEntity movie) async {
    await _isar.writeTxn(() async {
      await _isar.movieMetadataEntitys.putByTmdbId(movie);
    });
  }

  /// 根据 TMDB ID 获取电影元数据
  Future<MovieMetadataEntity?> getMovieByTmdbId(String tmdbId) async {
    return await _isar.movieMetadataEntitys
        .filter()
        .tmdbIdEqualTo(tmdbId)
        .findFirst();
  }

  /// 获取所有电影元数据
  Future<List<MovieMetadataEntity>> getAllMovies() async {
    return await _isar.movieMetadataEntitys.where().findAll();
  }

  // ===== TVShowMetadata CRUD =====

  /// 保存剧集元数据（使用 tmdbId 唯一索引）
  Future<void> saveTVShowMetadata(TVShowMetadataEntity show) async {
    await _isar.writeTxn(() async {
      await _isar.tVShowMetadataEntitys.putByTmdbId(show);
    });
  }

  /// 根据 TMDB ID 获取剧集元数据
  Future<TVShowMetadataEntity?> getTVShowByTmdbId(String tmdbId) async {
    return await _isar.tVShowMetadataEntitys
        .filter()
        .tmdbIdEqualTo(tmdbId)
        .findFirst();
  }

  /// 获取所有剧集元数据
  Future<List<TVShowMetadataEntity>> getAllTVShows() async {
    return await _isar.tVShowMetadataEntitys.where().findAll();
  }

  // ===== SeasonMetadata CRUD =====

  /// 保存季元数据（使用 seasonKey 唯一索引）
  Future<void> saveSeasonMetadata(SeasonMetadataEntity season) async {
    await _isar.writeTxn(() async {
      await _isar.seasonMetadataEntitys.putBySeasonKey(season);
    });
  }

  /// 根据 seasonKey 获取季元数据
  Future<SeasonMetadataEntity?> getSeasonByKey(String seasonKey) async {
    return await _isar.seasonMetadataEntitys
        .filter()
        .seasonKeyEqualTo(seasonKey)
        .findFirst();
  }

  /// 获取所有季元数据
  Future<List<SeasonMetadataEntity>> getAllSeasons() async {
    return await _isar.seasonMetadataEntitys.where().findAll();
  }

  // ===== EpisodeMetadata CRUD =====

  /// 保存集元数据（使用 tmdbId 唯一索引）
  Future<void> saveEpisodeMetadata(EpisodeMetadataEntity episode) async {
    await _isar.writeTxn(() async {
      await _isar.episodeMetadataEntitys.putByTmdbId(episode);
    });
  }

  /// 根据 tmdbId 获取集元数据
  Future<EpisodeMetadataEntity?> getEpisodeByTmdbId(String tmdbId) async {
    return await _isar.episodeMetadataEntitys
        .filter()
        .tmdbIdEqualTo(tmdbId)
        .findFirst();
  }

  /// 获取所有集元数据
  Future<List<EpisodeMetadataEntity>> getAllEpisodes() async {
    return await _isar.episodeMetadataEntitys.where().findAll();
  }

  // ===== 清理 =====

  /// 清空所有数据
  Future<void> clearAll() async {
    await _isar.writeTxn(() async {
      await _isar.mediaFileEntitys.clear();
      await _isar.movieMetadataEntitys.clear();
      await _isar.tVShowMetadataEntitys.clear();
      await _isar.seasonMetadataEntitys.clear();
      await _isar.episodeMetadataEntitys.clear();
    });
    _logger.i('🗑️ 已清空所有数据库数据');
  }

  /// 清空刮削元数据，保留媒体文件、播放进度和收藏状态
  Future<void> clearMetadata() async {
    await _isar.writeTxn(() async {
      await _isar.movieMetadataEntitys.clear();
      await _isar.tVShowMetadataEntitys.clear();
      await _isar.seasonMetadataEntitys.clear();
      await _isar.episodeMetadataEntitys.clear();
    });
    _logger.i('🗑️ 已清空所有刮削元数据');
  }

  /// 关闭数据库
  Future<void> close() async {
    await _isar.close();
    _isInitialized = false;
  }
}
