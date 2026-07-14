import 'dart:async';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:mochi_player/features/library/infrastructure/library_scanner.dart';
import 'package:mochi_player/features/library/infrastructure/metadata_scraper.dart';
import 'package:mochi_player/core/domain/media/models.dart';
import 'package:mochi_player/core/infrastructure/database/database_service.dart';
import 'package:mochi_player/core/infrastructure/database/entities/entities.dart'
    as entity;
import 'package:mochi_player/core/infrastructure/database/model_converter.dart';
import 'package:mochi_player/core/infrastructure/tmdb/tmdb_service.dart';
import 'package:mochi_player/core/infrastructure/webdav/webdav_service.dart';
import 'package:mochi_player/features/library/infrastructure/filename_parser.dart';

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
  int _mediaCatalogRevision = 0;
  int _metadataRevision = 0;
  int _watchProgressRevision = 0;
  int _favoriteRevision = 0;
  int _trendingRevision = 0;
  int _continueWatchingCount = 0;

  bool _isLoading = false;
  bool _isScraping = false;
  bool _isInitialized = false;
  String? _error;
  int _scrapeCompleted = 0;
  int _scrapeTotal = 0;
  int _scrapeSuccessCount = 0;
  int _scrapeFailCount = 0;
  String? _scrapeCurrentTitle;
  StreamSubscription? _scanSubscription;

  // Trending 状态 (从 TMDB 获取，不持久化)
  List<TrendingItem> _trendingMovies = [];
  List<TrendingItem> _trendingTV = [];
  List<TrendingItem> _topRated = [];
  bool _isTrendingLoading = false;

  void _markMediaCatalogChanged() {
    _mediaCatalogRevision++;
  }

  void _markMetadataChanged() {
    _metadataRevision++;
  }

  void _markWatchProgressChanged() {
    _watchProgressRevision++;
  }

  void _markFavoriteChanged() {
    _favoriteRevision++;
  }

  void _markTrendingChanged() {
    _trendingRevision++;
  }

  void _markAllLibraryContentChanged() {
    _markMediaCatalogChanged();
    _markMetadataChanged();
    _markWatchProgressChanged();
    _markFavoriteChanged();
  }

  void _recountContinueWatching() {
    _continueWatchingCount = _mediaFileEntities
        .where((file) => file.watchStatus == entity.WatchStatus.watching)
        .length;
  }

  // ===== 公开 API (返回 Domain 模型) =====

  List<MediaFile> get mediaFiles =>
      _mediaFileEntities.map(ModelConverter.toMediaFile).toList();

  List<Movie> get movies {
    final availableTmdbIds = _availableMovieTmdbIds;
    return _movieMetadataEntities
        .where((movie) => availableTmdbIds.contains(movie.tmdbId))
        .map(ModelConverter.toMovie)
        .toList();
  }

  List<TVShow> get tvShows {
    final availableTmdbIds = _availableTVShowTmdbIds;
    return _tvShowMetadataEntities
        .where((show) => availableTmdbIds.contains(show.tmdbId))
        .map(_convertTVShowWithSeasons)
        .toList();
  }

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

  bool get isLoading => _isLoading || _isScraping;
  bool get isScraping => _isScraping;
  bool get isInitialized => _isInitialized;
  String? get error => _error;
  int get mediaCatalogRevision => _mediaCatalogRevision;
  int get metadataRevision => _metadataRevision;
  int get watchProgressRevision => _watchProgressRevision;
  int get favoriteRevision => _favoriteRevision;
  int get trendingRevision => _trendingRevision;
  int get scrapeCompleted => _scrapeCompleted;
  int get scrapeTotal => _scrapeTotal;
  double? get scrapeProgress {
    if (!_isScraping || _scrapeTotal <= 0) return null;
    return (_scrapeCompleted / _scrapeTotal).clamp(0.0, 1.0);
  }

  String? get libraryActivityMessage {
    if (_isScraping) {
      final count = _scrapeTotal > 0
          ? '$_scrapeCompleted/$_scrapeTotal'
          : '准备中';
      final title = _scrapeCurrentTitle;
      final summary = '已匹配 $_scrapeSuccessCount，失败 $_scrapeFailCount';
      if (title != null && title.isNotEmpty) {
        return '正在刮削 $count：$title · $summary';
      }
      return '正在刮削媒体库 $count · $summary';
    }
    if (_isLoading) {
      return '正在扫描媒体库...';
    }
    return null;
  }

  int get totalFiles => _mediaFileEntities.length;

  bool get hasHomeContent {
    if (_hasVisibleMetadata) {
      return true;
    }
    if (_trendingMovies.isNotEmpty ||
        _trendingTV.isNotEmpty ||
        _topRated.isNotEmpty) {
      return true;
    }
    return _continueWatchingCount > 0;
  }

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
      final showTmdbId = _showKeyFromTmdbId(tmdbId) ?? tmdbId;
      final entity = _tvShowMetadataEntities.firstWhere(
        (t) => t.tmdbId == showTmdbId,
      );
      return _convertTVShowWithSeasons(entity);
    } catch (_) {
      return null;
    }
  }

  /// 根据 TMDB ID 获取同一资源的所有版本
  /// 对于电影：精确匹配 tmdbId
  /// 对于剧集：匹配以 tmdbId 开头的文件（如 123_s1e1）
  List<MediaFile> getVersions(String tmdbId) {
    return _mediaFileEntities
        .where(
          (f) =>
              f.tmdbId == tmdbId ||
              (f.tmdbId?.startsWith('${tmdbId}_') ?? false),
        )
        .map(ModelConverter.toMediaFile)
        .toList();
  }

  /// 为播放器构建轻量队列。
  ///
  /// 剧集优先按 TMDB 剧集前缀归组，未刮削或刮削不完整时退回到解析标题。
  /// 这里只返回文件项，直链仍在播放器切换时按需获取。
  List<MediaFile> getPlaybackQueue(MediaFile currentFile) {
    if (currentFile.mediaType != MediaType.episode) {
      return [currentFile];
    }

    final showKey = _showKeyForMediaFile(currentFile);
    if (showKey == null || showKey.isEmpty) {
      return [currentFile];
    }

    final candidates = _mediaFileEntities
        .where(
          (file) =>
              file.mediaType == entity.MediaType.episode &&
              _showKeyForEntity(file) == showKey,
        )
        .toList();

    if (candidates.isEmpty) {
      return [currentFile];
    }

    candidates.sort(_compareEpisodeEntities);

    final queue = candidates.map(ModelConverter.toMediaFile).toList();
    final hasCurrent = queue.any(
      (file) => file.id == currentFile.id || file.path == currentFile.path,
    );
    return hasCurrent ? queue : [currentFile, ...queue];
  }

  String? _showKeyForMediaFile(MediaFile file) {
    final tmdbKey = _showKeyFromTmdbId(file.tmdbId);
    if (tmdbKey != null) return 'tmdb:$tmdbKey';

    final title = file.parsedTitle.trim().toLowerCase();
    return title.isEmpty ? null : 'title:$title';
  }

  String? _showKeyForEntity(entity.MediaFileEntity file) {
    final tmdbKey = _showKeyFromTmdbId(file.tmdbId);
    if (tmdbKey != null) return 'tmdb:$tmdbKey';

    final title = file.parsedTitle.trim().toLowerCase();
    return title.isEmpty ? null : 'title:$title';
  }

  String? _showKeyFromTmdbId(String? tmdbId) {
    if (tmdbId == null || tmdbId.isEmpty) return null;
    final match = RegExp(r'^(\d+)(?:_s\d+e\d+)?$').firstMatch(tmdbId);
    return match?.group(1);
  }

  int _compareEpisodeEntities(
    entity.MediaFileEntity a,
    entity.MediaFileEntity b,
  ) {
    final seasonCompare = (a.parsedSeason ?? 999999).compareTo(
      b.parsedSeason ?? 999999,
    );
    if (seasonCompare != 0) return seasonCompare;

    final episodeCompare = (a.parsedEpisode ?? 999999).compareTo(
      b.parsedEpisode ?? 999999,
    );
    if (episodeCompare != 0) return episodeCompare;

    return a.path.toLowerCase().compareTo(b.path.toLowerCase());
  }

  /// 获取 Trending 列表
  List<TrendingItem> get trendingMovies => _trendingMovies;
  List<TrendingItem> get trendingTV => _trendingTV;
  List<TrendingItem> get topRated => _topRated;
  bool get isTrendingLoading => _isTrendingLoading;

  /// 获取最近添加的电影和剧集（用于首页展示）
  List<dynamic> get recentlyAddedContent {
    // 合并电影和剧集，按添加时间排序（使用相关 mediaFile 的 addedAt）
    final List<MapEntry<DateTime, dynamic>> items = [];
    final availableMovieTmdbIds = _availableMovieTmdbIds;
    final availableTVShowTmdbIds = _availableTVShowTmdbIds;

    for (final movie in _movieMetadataEntities) {
      if (!availableMovieTmdbIds.contains(movie.tmdbId)) continue;

      // 找到该电影关联的 mediaFile 的最早添加时间
      final relatedFiles = _mediaFileEntities.where(
        (f) => f.tmdbId == movie.tmdbId,
      );
      if (relatedFiles.isNotEmpty) {
        final earliestDate = relatedFiles
            .map((f) => f.addedAt)
            .reduce((a, b) => a.isBefore(b) ? a : b);
        items.add(MapEntry(earliestDate, ModelConverter.toMovie(movie)));
      }
    }

    for (final show in _tvShowMetadataEntities) {
      if (!availableTVShowTmdbIds.contains(show.tmdbId)) continue;

      final relatedFiles = _mediaFileEntities.where(
        (f) => _showKeyFromTmdbId(f.tmdbId) == show.tmdbId,
      );
      if (relatedFiles.isNotEmpty) {
        final earliestDate = relatedFiles
            .map((f) => f.addedAt)
            .reduce((a, b) => a.isBefore(b) ? a : b);
        items.add(MapEntry(earliestDate, _convertTVShowWithSeasons(show)));
      }
    }

    // 按添加时间倒序
    items.sort((a, b) => b.key.compareTo(a.key));
    return items.map((e) => e.value).toList();
  }

  /// 获取随机 Hero 项目 (Movie 或 TVShow)
  dynamic getRandomHeroItem() {
    final allItems = <dynamic>[...movies, ...tvShows];
    if (allItems.isEmpty) return null;

    // 使用当前日期作为种子，使同一天内显示相同的 hero
    final today = DateTime.now();
    final seed = today.year * 10000 + today.month * 100 + today.day;
    final random = (seed % allItems.length);
    return allItems[random];
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
    _recountContinueWatching();

    _isInitialized = true;
    _markAllLibraryContentChanged();
    _logger.i(
      '✅ 加载完成: ${_mediaFileEntities.length} 个文件, ${_movieMetadataEntities.length} 部电影, ${_tvShowMetadataEntities.length} 部剧集, ${_seasonMetadataEntities.length} 季, ${_episodeMetadataEntities.length} 集',
    );
    notifyListeners();
  }

  /// 加载 TMDB 热门趋势（三个分类并行加载）
  Future<void> fetchTrending() async {
    if (_isTrendingLoading) return;

    _isTrendingLoading = true;
    notifyListeners();

    try {
      final tmdb = TmdbService();
      if (!tmdb.isConfigured) {
        _trendingMovies = [];
        _trendingTV = [];
        _topRated = [];
        _markTrendingChanged();
        return;
      }

      // 并行请求三个分类
      final results = await Future.wait([
        tmdb.fetchTrendingMovies(limit: 3),
        tmdb.fetchTrendingTV(limit: 3),
        tmdb.fetchTopRated(limit: 3),
      ]);
      _trendingMovies = results[0];
      _trendingTV = results[1];
      _topRated = results[2];
      _markTrendingChanged();
      _logger.i(
        '✅ 加载热门趋势: 电影 ${_trendingMovies.length}, 剧集 ${_trendingTV.length}, 高分 ${_topRated.length}',
      );
    } catch (e) {
      _logger.e('❌ 加载热门趋势失败: $e');
    } finally {
      _isTrendingLoading = false;
      notifyListeners();
    }
  }

  // ===== 扫描 =====

  /// 扫描媒体库
  Future<void> scanLibrary({String rootPath = '/'}) async {
    if (isLoading) return;

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
      final scanResult = await _scanFilesFromWebDav(
        webDavService: webDavService,
        rootPath: rootPath,
        removeMissingFiles: rootPath == '/',
      );

      _logger.i(
        '✅ 扫描完成，新增 ${scanResult.newCount} 个文件，移除 ${scanResult.removedCount} 个失效文件',
      );
      notifyListeners();

      _isLoading = false;
      if (scanResult.hadReadError) {
        _error = 'WebDAV 扫描不完整，已跳过自动刮削，避免使用数据库旧文件';
        notifyListeners();
        return;
      }
      notifyListeners();

      // 刮削元数据在后台执行，扫描结果可以先显示出来。
      unawaited(_scrapeMetadata());
    } catch (e, stackTrace) {
      _logger.e('❌ 扫描失败: $e', error: e, stackTrace: stackTrace);
      _error = '扫描失败: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 刮削元数据
  Future<void> _scrapeMetadata() async {
    if (_isScraping) return;

    final scraper = MetadataScraper();

    _isScraping = true;
    _scrapeCompleted = 0;
    _scrapeTotal = _mediaFileEntities.length;
    _scrapeSuccessCount = 0;
    _scrapeFailCount = 0;
    _scrapeCurrentTitle = null;
    notifyListeners();

    _logger.i('🎬 开始批量刮削...');

    try {
      final result = await scraper.scrapeBatch(
        _mediaFileEntities,
        onProgress: (progress) async {
          _scrapeCompleted = progress.completed;
          _scrapeTotal = progress.total;
          _scrapeSuccessCount = progress.successCount;
          _scrapeFailCount = progress.failCount;
          _scrapeCurrentTitle = progress.currentTitle;

          var mediaCatalogChanged = false;
          var metadataChanged = false;
          if (progress.movie != null) {
            _upsertMovieMetadata(progress.movie!);
            mediaCatalogChanged = true;
            metadataChanged = true;
          }
          if (progress.tvShow != null) {
            _upsertTVShowMetadata(progress.tvShow!);
            mediaCatalogChanged = true;
            metadataChanged = true;
          }
          if (progress.seasonsChanged) {
            _seasonMetadataEntities = await _db.getAllSeasons();
            _episodeMetadataEntities = await _db.getAllEpisodes();
            metadataChanged = true;
          }
          if (mediaCatalogChanged) {
            _markMediaCatalogChanged();
          }
          if (metadataChanged) {
            _markMetadataChanged();
          }

          notifyListeners();
        },
      );

      // 最后全量同步一次，确保并发刮削期间的缓存与数据库一致。
      _movieMetadataEntities = await _db.getAllMovies();
      _tvShowMetadataEntities = await _db.getAllTVShows();
      _seasonMetadataEntities = await _db.getAllSeasons();
      _episodeMetadataEntities = await _db.getAllEpisodes();
      if (result.successCount > 0) {
        _markMetadataChanged();
        _markMediaCatalogChanged();
      }

      if (result.successCount > 0) {
        _logger.i(
          '✅ 刮削更新: 新增电影 ${result.newMovies.length}, 新增剧集 ${result.newTVShows.length}',
        );
      } else {
        _logger.i('✅ 刮削完成: 无新增元数据');
      }
    } finally {
      _isScraping = false;
      _scrapeCurrentTitle = null;
      notifyListeners();
    }
  }

  /// 增量补全元数据
  Future<void> rescrapeLibrary() async {
    if (isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (!_isInitialized) {
        await loadFromDatabase();
      }

      _mediaFileEntities = await _db.getAllMediaFiles();
      _isInitialized = true;
      _recountContinueWatching();
      _markMediaCatalogChanged();

      _logger.i('增量刮削前按启动算法扫描 WebDAV 根目录...');
      final scanResult = await _scanFilesFromWebDav(
        webDavService: WebDavService(),
        rootPath: '/',
        removeMissingFiles: true,
      );
      _logger.i(
        '✅ 增量刮削前根目录扫描完成，新增 ${scanResult.newCount} 个文件，移除 ${scanResult.removedCount} 个失效文件',
      );

      if (scanResult.hadReadError) {
        _error = 'WebDAV 扫描不完整，已跳过增量刮削，避免使用数据库旧文件';
        return;
      }

      if (_mediaFileEntities.isEmpty) {
        _error = '已扫描 WebDAV 根目录，但没有发现可刮削视频文件';
        return;
      }

      final tmdb = TmdbService();
      if (!tmdb.isConfigured) {
        _error = '未配置 TMDB API Key，无法增量刮削';
        return;
      }

      for (final file in _mediaFileEntities) {
        final parsed = FileNameParser.parse(
          fileName: file.fileName,
          filePath: file.path,
        );
        final existingTmdbId = file.tmdbId?.trim();
        final parsedTmdbId = parsed.tmdbId?.trim();
        file.parsedTitle = parsed.title;
        file.parsedYear = parsed.year;
        file.parsedSeason = parsed.season;
        file.parsedEpisode = parsed.episode;
        file.mediaType = _determineMediaType(parsed);
        file.tmdbId = parsedTmdbId != null && parsedTmdbId.isNotEmpty
            ? parsedTmdbId
            : existingTmdbId != null && existingTmdbId.isNotEmpty
            ? existingTmdbId
            : null;
        file.container = parsed.container;
        file.height = parsed.height;
        file.videoCodec = parsed.videoCodec;
        file.audioCodec = parsed.audioCodec;
        file.audioChannels = parsed.audioChannels;
        file.isHdr = parsed.isHdr;
        file.hdrFormat = parsed.hdrFormat;
        file.versionLabel = parsed.versionLabel.isNotEmpty
            ? parsed.versionLabel
            : null;
      }
      await _db.saveMediaFiles(_mediaFileEntities);
      _markMediaCatalogChanged();
      notifyListeners();

      await _scrapeMetadata();
    } catch (e, stackTrace) {
      _logger.e('❌ 增量刮削失败: $e', error: e, stackTrace: stackTrace);
      _error = '增量刮削失败: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ===== 播放状态 =====

  /// 更新播放进度
  Future<void> updateProgress(
    MediaFile file,
    int position, {
    int? duration,
  }) async {
    final mediaFileEntity = _findMediaFileEntity(file);
    if (mediaFileEntity == null) {
      _logger.d('跳过临时文件播放进度: ${file.path}');
      return;
    }

    final wasWatching =
        mediaFileEntity.watchStatus == entity.WatchStatus.watching;
    await _db.updateProgress(mediaFileEntity, position, duration: duration);
    final isWatching =
        mediaFileEntity.watchStatus == entity.WatchStatus.watching;
    if (wasWatching != isWatching) {
      _continueWatchingCount += isWatching ? 1 : -1;
      if (_continueWatchingCount < 0) {
        _continueWatchingCount = 0;
      }
    }
    _markWatchProgressChanged();
    notifyListeners();
  }

  /// 获取最新的媒体文件状态，播放恢复时避免使用旧的 UI 快照。
  Future<MediaFile?> getLatestMediaFile(MediaFile file) async {
    entity.MediaFileEntity? mediaFileEntity;

    if (file.path.isNotEmpty) {
      mediaFileEntity = await _db.getMediaFileByPath(file.path);
    }

    mediaFileEntity ??= _findMediaFileEntity(file);
    if (mediaFileEntity == null) return null;

    final index = _mediaFileEntities.indexWhere(
      (item) => item.id == mediaFileEntity!.id || item.path == file.path,
    );
    if (index >= 0) {
      _mediaFileEntities[index] = mediaFileEntity;
    }

    return ModelConverter.toMediaFile(mediaFileEntity);
  }

  entity.MediaFileEntity? _findMediaFileEntity(MediaFile file) {
    for (final mediaFileEntity in _mediaFileEntities) {
      if (mediaFileEntity.id == file.id || mediaFileEntity.path == file.path) {
        return mediaFileEntity;
      }
    }
    return null;
  }

  /// 切换收藏
  Future<void> toggleFavorite(MediaFile file) async {
    final entity = _mediaFileEntities.firstWhere((e) => e.id == file.id);
    await _db.toggleFavorite(entity);
    _markFavoriteChanged();
    notifyListeners();
  }

  // ===== 清理 =====

  /// 清空媒体库
  Future<void> clearLibrary() async {
    await _db.clearAll();
    _mediaFileEntities.clear();
    _movieMetadataEntities.clear();
    _tvShowMetadataEntities.clear();
    _seasonMetadataEntities.clear();
    _episodeMetadataEntities.clear();
    _continueWatchingCount = 0;
    _error = null;
    _markAllLibraryContentChanged();
    _markTrendingChanged();
    notifyListeners();
  }

  @override
  void dispose() {
    _scanSubscription?.cancel();
    super.dispose();
  }

  // ===== 辅助方法 =====

  Future<_LibraryScanResult> _scanFilesFromWebDav({
    required WebDavService webDavService,
    required String rootPath,
    bool removeMissingFiles = false,
  }) async {
    final scanner = LibraryScanner(webDavService);
    var newCount = 0;
    var removedCount = 0;
    final scannedPaths = <String>{};

    await for (final mediaFileEntity in scanner.scan(rootPath)) {
      scannedPaths.add(mediaFileEntity.path);
      final existing = await _db.getMediaFileByPath(mediaFileEntity.path);

      if (existing == null) {
        await _db.saveMediaFile(mediaFileEntity);
        _mediaFileEntities.add(mediaFileEntity);
        _markMediaCatalogChanged();
        newCount++;

        if (newCount % 10 == 0) {
          notifyListeners();
        }
      }
    }

    if (removeMissingFiles && scanner.hadReadError) {
      _logger.w('跳过失效文件清理，因为本次 WebDAV 扫描存在读取失败');
    } else if (removeMissingFiles) {
      removedCount = await _removeMissingMediaFiles(scannedPaths);
    }

    return _LibraryScanResult(
      newCount: newCount,
      removedCount: removedCount,
      hadReadError: scanner.hadReadError,
    );
  }

  Future<int> _removeMissingMediaFiles(Set<String> scannedPaths) async {
    final staleFiles = _mediaFileEntities
        .where((file) => !scannedPaths.contains(file.path))
        .toList();
    if (staleFiles.isEmpty) return 0;

    final removedCount = await _db.deleteMediaFilesByIds(
      staleFiles.map((file) => file.id).toList(),
    );
    if (removedCount == 0) return 0;

    final stalePaths = staleFiles.map((file) => file.path).toSet();
    _mediaFileEntities.removeWhere((file) => stalePaths.contains(file.path));
    _recountContinueWatching();
    _markAllLibraryContentChanged();
    _logger.i('🧹 已移除 $removedCount 个 WebDAV 中不存在的媒体文件');

    return removedCount;
  }

  void _upsertMovieMetadata(entity.MovieMetadataEntity movie) {
    final index = _movieMetadataEntities.indexWhere(
      (item) => item.tmdbId == movie.tmdbId,
    );
    if (index >= 0) {
      _movieMetadataEntities[index] = movie;
    } else {
      _movieMetadataEntities.add(movie);
    }
  }

  void _upsertTVShowMetadata(entity.TVShowMetadataEntity show) {
    final index = _tvShowMetadataEntities.indexWhere(
      (item) => item.tmdbId == show.tmdbId,
    );
    if (index >= 0) {
      _tvShowMetadataEntities[index] = show;
    } else {
      _tvShowMetadataEntities.add(show);
    }
  }

  entity.MediaType _determineMediaType(ParsedResult parsed) {
    if (parsed.season != null || parsed.episode != null) {
      return entity.MediaType.episode;
    }
    if (parsed.title.isNotEmpty) {
      return entity.MediaType.movie;
    }
    return entity.MediaType.unknown;
  }

  Set<String> get _availableMovieTmdbIds {
    return _mediaFileEntities
        .where(
          (file) =>
              file.mediaType == entity.MediaType.movie &&
              file.tmdbId != null &&
              file.tmdbId!.isNotEmpty,
        )
        .map((file) => file.tmdbId!)
        .toSet();
  }

  Set<String> get _availableTVShowTmdbIds {
    return _mediaFileEntities
        .where(
          (file) =>
              file.mediaType == entity.MediaType.episode &&
              file.tmdbId != null &&
              file.tmdbId!.isNotEmpty,
        )
        .map((file) => _showKeyFromTmdbId(file.tmdbId))
        .whereType<String>()
        .toSet();
  }

  bool get _hasVisibleMetadata {
    final availableMovieTmdbIds = _availableMovieTmdbIds;
    final hasMovie = _movieMetadataEntities.any(
      (movie) => availableMovieTmdbIds.contains(movie.tmdbId),
    );
    if (hasMovie) return true;

    final availableTVShowTmdbIds = _availableTVShowTmdbIds;
    return _tvShowMetadataEntities.any(
      (show) => availableTVShowTmdbIds.contains(show.tmdbId),
    );
  }
}

class _LibraryScanResult {
  final int newCount;
  final int removedCount;
  final bool hadReadError;

  const _LibraryScanResult({
    required this.newCount,
    required this.removedCount,
    required this.hadReadError,
  });
}
