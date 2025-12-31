import 'dart:async';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import '../models/entity/entities.dart' as entity;
import '../models/domain/models.dart';
import '../models/model_converter.dart';
import '../services/database_service.dart';
import '../services/library_scanner.dart';
import '../services/webdav_service.dart';
import '../services/metadata_scraper.dart';

/// 媒体库 Provider
/// 管理媒体文件和元数据的状态
class MediaLibraryProvider extends ChangeNotifier {
  final _logger = Logger(printer: PrettyPrinter(methodCount: 0));
  final _db = DatabaseService();

  // 内部状态 (Entity)
  // TODO: 当数据量较大时，考虑使用 IsarLinks 实现懒加载
  // 目前全量加载到内存，适用于小型媒体库（< 10000 条记录）
  List<entity.MediaFileEntity> _mediaFileEntities = [];
  List<entity.MovieMetadataEntity> _movieMetadataEntities = [];
  List<entity.TVShowMetadataEntity> _tvShowMetadataEntities = [];
  List<entity.SeasonMetadataEntity> _seasonMetadataEntities = [];
  List<entity.EpisodeMetadataEntity> _episodeMetadataEntities = [];

  bool _isLoading = false;
  bool _isInitialized = false;
  String? _error;
  StreamSubscription? _scanSubscription;

  // ===== 公开 API (返回 Domain 模型) =====

  List<MediaFile> get mediaFiles =>
      _mediaFileEntities.map(ModelConverter.toMediaFile).toList();

  List<Movie> get movies =>
      _movieMetadataEntities.map(ModelConverter.toMovie).toList();

  List<TVShow> get tvShows =>
      _tvShowMetadataEntities.map(_convertTVShowWithSeasons).toList();

  /// 转换 TVShow 并填充 seasons/episodes
  TVShow _convertTVShowWithSeasons(entity.TVShowMetadataEntity show) {
    // 找出该剧的所有季
    final showSeasons = _seasonMetadataEntities
        .where((s) => s.seasonKey.startsWith('${show.tmdbId}_'))
        .map((s) {
          // 找出该季的所有集
          final seasonEpisodes = _episodeMetadataEntities
              .where(
                (e) =>
                    e.tmdbId.startsWith('${show.tmdbId}_s${s.seasonNumber}e'),
              )
              .map(ModelConverter.toEpisode)
              .toList();
          seasonEpisodes.sort(
            (a, b) => a.episodeNumber.compareTo(b.episodeNumber),
          );

          return ModelConverter.toSeasonWithEpisodes(s, seasonEpisodes);
        })
        .toList();
    showSeasons.sort((a, b) => a.seasonNumber.compareTo(b.seasonNumber));

    return ModelConverter.toTVShowWithSeasons(show, showSeasons);
  }

  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  String? get error => _error;

  int get totalFiles => _mediaFileEntities.length;

  /// 获取未分类的文件
  List<MediaFile> get uncategorized => _mediaFileEntities
      .where((f) => f.tmdbId == null)
      .map(ModelConverter.toMediaFile)
      .toList();

  /// 获取继续观看
  List<MediaFile> get continueWatching {
    final list = _mediaFileEntities
        .where((f) => f.watchStatus == entity.WatchStatus.watching)
        .toList();
    list.sort(
      (a, b) => (b.lastWatchedAt ?? DateTime(0)).compareTo(
        a.lastWatchedAt ?? DateTime(0),
      ),
    );
    return list.map(ModelConverter.toMediaFile).toList();
  }

  /// 获取收藏
  List<MediaFile> get favorites => _mediaFileEntities
      .where((f) => f.isFavorite)
      .map(ModelConverter.toMediaFile)
      .toList();

  /// 获取最近添加
  List<MediaFile> get recentlyAdded {
    final list = _mediaFileEntities.toList();
    list.sort((a, b) => b.addedAt.compareTo(a.addedAt));
    return list.map(ModelConverter.toMediaFile).toList();
  }

  /// 根据 TMDB ID 获取电影元数据
  Movie? getMovieMetadata(String tmdbId) {
    try {
      final entity = _movieMetadataEntities.firstWhere(
        (m) => m.tmdbId == tmdbId,
      );
      return ModelConverter.toMovie(entity);
    } catch (_) {
      return null;
    }
  }

  /// 根据 TMDB ID 获取剧集元数据 (包含 seasons/episodes)
  TVShow? getTVShowMetadata(String tmdbId) {
    try {
      final entity = _tvShowMetadataEntities.firstWhere(
        (t) => t.tmdbId == tmdbId,
      );
      return _convertTVShowWithSeasons(entity);
    } catch (_) {
      return null;
    }
  }

  /// 根据 TMDB ID 获取同一资源的所有版本
  List<MediaFile> getVersions(String tmdbId) {
    return _mediaFileEntities
        .where((f) => f.tmdbId == tmdbId)
        .map(ModelConverter.toMediaFile)
        .toList();
  }

  // ===== 初始化 =====

  /// 从数据库加载已保存的数据
  Future<void> loadFromDatabase() async {
    if (_isInitialized) return;

    _logger.i('📂 从数据库加载媒体库...');

    _mediaFileEntities = await _db.getAllMediaFiles();
    _movieMetadataEntities = await _db.getAllMovies();
    _tvShowMetadataEntities = await _db.getAllTVShows();
    _seasonMetadataEntities = await _db.getAllSeasons();
    _episodeMetadataEntities = await _db.getAllEpisodes();

    _isInitialized = true;
    _logger.i(
      '✅ 加载完成: ${_mediaFileEntities.length} 个文件, ${_movieMetadataEntities.length} 部电影, ${_tvShowMetadataEntities.length} 部剧集, ${_seasonMetadataEntities.length} 季, ${_episodeMetadataEntities.length} 集',
    );
    notifyListeners();
  }

  // ===== 扫描 =====

  /// 扫描媒体库
  Future<void> scanLibrary({String rootPath = '/'}) async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    await _scanSubscription?.cancel();

    try {
      // 确保先从数据库加载已有数据
      if (!_isInitialized) {
        await loadFromDatabase();
      }

      final webDavService = WebDavService();
      final scanner = LibraryScanner(webDavService);

      int newCount = 0;

      // 扫描文件
      await for (final entity in scanner.scan(rootPath)) {
        // 使用数据库查询检查是否已存在（比内存更可靠）
        final existing = await _db.getMediaFileByPath(entity.path);

        if (existing == null) {
          await _db.saveMediaFile(entity);
          _mediaFileEntities.add(entity);
          newCount++;

          if (newCount % 10 == 0) {
            notifyListeners();
          }
        }
      }

      _logger.i('✅ 扫描完成，发现 $newCount 个新文件');
      notifyListeners();

      // 刮削元数据
      await _scrapeMetadata();

      _isLoading = false;
      notifyListeners();
    } catch (e, stackTrace) {
      _logger.e('❌ 扫描失败: $e', error: e, stackTrace: stackTrace);
      _error = '扫描失败: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 刮削元数据
  Future<void> _scrapeMetadata() async {
    final scraper = MetadataScraper();

    _logger.i('🎬 开始批量刮削...');
    final result = await scraper.scrapeBatch(_mediaFileEntities);

    // 更新内存状态 (避免全量 Movie/TVShow 重载)
    if (result.successCount > 0) {
      _movieMetadataEntities.addAll(result.newMovies);
      _tvShowMetadataEntities.addAll(result.newTVShows);

      // 季和集信息更新 (由于 Scraper 内部产生且未返回，这里做一次增量/全量刷新)
      // 考虑到季/集数量可能较多但通常变动的是新增部分，
      // 这里暂时全量刷新 季/集 (比刷新 Movie 快)，或者后续优化 Scraper 返回它们
      _seasonMetadataEntities = await _db.getAllSeasons();
      _episodeMetadataEntities = await _db.getAllEpisodes();

      _logger.i(
        '✅ 刮削更新: 新增电影 ${result.newMovies.length}, 新增剧集 ${result.newTVShows.length}',
      );
      notifyListeners();
    } else {
      _logger.i('✅ 刮削完成: 无新增元数据');
    }
  }

  // ===== 播放状态 =====

  /// 更新播放进度
  Future<void> updateProgress(MediaFile file, int position) async {
    final entity = _mediaFileEntities.firstWhere((e) => e.id == file.id);
    await _db.updateProgress(entity, position);
    notifyListeners();
  }

  /// 切换收藏
  Future<void> toggleFavorite(MediaFile file) async {
    final entity = _mediaFileEntities.firstWhere((e) => e.id == file.id);
    await _db.toggleFavorite(entity);
    notifyListeners();
  }

  // ===== 清理 =====

  /// 清空媒体库
  Future<void> clearLibrary() async {
    await _db.clearAll();
    _mediaFileEntities.clear();
    _movieMetadataEntities.clear();
    _tvShowMetadataEntities.clear();
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _scanSubscription?.cancel();
    super.dispose();
  }

  // ===== 辅助方法 =====
}
