import 'package:logger/logger.dart';
import 'package:mochi_player/core/infrastructure/database/database_service.dart';
import 'package:mochi_player/core/infrastructure/database/entities/entities.dart';
import 'package:mochi_player/core/infrastructure/tmdb/tmdb_service.dart';
import 'package:mochi_player/features/library/infrastructure/metadata_search_title_variants.dart';

/// 元数据刮削服务
/// 负责协调 TMDB 搜索和数据库存储
/// 刮削结果容器
class ScrapeResult {
  final List<MovieMetadataEntity> newMovies = [];
  final List<TVShowMetadataEntity> newTVShows = [];
  int successCount = 0;
  int failCount = 0;
}

class ScrapeProgress {
  final int completed;
  final int total;
  final int successCount;
  final int failCount;
  final String currentTitle;
  final MovieMetadataEntity? movie;
  final TVShowMetadataEntity? tvShow;
  final bool seasonsChanged;

  const ScrapeProgress({
    required this.completed,
    required this.total,
    required this.successCount,
    required this.failCount,
    required this.currentTitle,
    this.movie,
    this.tvShow,
    this.seasonsChanged = false,
  });
}

typedef ScrapeProgressCallback = Future<void> Function(ScrapeProgress progress);

/// 元数据刮削服务
/// 负责协调 TMDB 搜索和数据库存储
class MetadataScraper {
  final TmdbService _tmdb;
  final DatabaseService _db;
  final Logger _logger;

  MetadataScraper({TmdbService? tmdb, DatabaseService? db})
    : _tmdb = tmdb ?? TmdbService(),
      _db = db ?? DatabaseService(),
      _logger = Logger(printer: PrettyPrinter(methodCount: 0));

  // ===== 公开 API =====

  /// 批量刮削文件
  /// 自动区分电影和剧集，处理并发和去重
  Future<ScrapeResult> scrapeBatch(List<MediaFileEntity> allFiles, {ScrapeProgressCallback? onProgress}) async {
    final result = ScrapeResult();
    if (!_tmdb.isConfigured) {
      _logger.w('⚠️ 未配置 TMDB API Key，跳过元数据刮削');
      return result;
    }

    final movieFiles = <MediaFileEntity>[];
    final tvFiles = <MediaFileEntity>[];

    // 1. 分类与预过滤
    for (final file in allFiles) {
      // 如果已有关联且元数据存在，跳过
      if (file.tmdbId != null && file.tmdbId!.isNotEmpty) {
        if (file.mediaType == StoredMediaType.movie) {
          if (await _db.getMovieByTmdbId(file.tmdbId!) != null) continue;
        } else if (file.mediaType == StoredMediaType.episode) {
          if (await _db.getEpisodeByTmdbId(file.tmdbId!) != null) continue;
        }
      }

      if (file.mediaType == StoredMediaType.movie) {
        movieFiles.add(file);
      } else if (file.mediaType == StoredMediaType.episode) {
        tvFiles.add(file);
      }
    }

    final tvGroups = <String, _TVShowScrapeGroup>{};
    for (final file in tvFiles) {
      final key = _buildTVGroupKey(file);
      tvGroups.putIfAbsent(key, () => _TVShowScrapeGroup(file.parsedTitle)).add(file);
    }

    final totalCount = movieFiles.length + tvFiles.length;
    var completedCount = 0;

    _logger.i('🎬 批量刮削开始: 电影 ${movieFiles.length} 个, 剧集文件 ${tvFiles.length} 个');

    // Publish the real workload before the first network request. The UI used
    // to initialise progress with the entire catalog size, even though most
    // files were filtered out because their metadata already existed.
    await onProgress?.call(
      ScrapeProgress(completed: 0, total: totalCount, successCount: 0, failCount: 0, currentTitle: ''),
    );

    // 2. 刮削电影 (并发)
    await _runWithConcurrency(movieFiles, (file) async {
      final movie = await _scrapeMovieSingle(file, result);
      completedCount++;
      await onProgress?.call(
        ScrapeProgress(
          completed: completedCount,
          total: totalCount,
          successCount: result.successCount,
          failCount: result.failCount,
          currentTitle: file.parsedTitle,
          movie: movie,
        ),
      );
    }, 5);

    // 3. 刮削剧集 (按剧名分组后并发)
    await _runWithConcurrency(tvGroups.values.toList(), (group) async {
      final tvShow = await _scrapeTVShowGroup(group.title, group.files, result);
      completedCount += group.files.length;
      await onProgress?.call(
        ScrapeProgress(
          completed: completedCount,
          total: totalCount,
          successCount: result.successCount,
          failCount: result.failCount,
          currentTitle: group.title,
          tvShow: tvShow,
          seasonsChanged: tvShow != null,
        ),
      );
    }, 5);

    _logger.i('✅ 批量刮削完成: 新增电影 ${result.newMovies.length} 部, 新增剧集 ${result.newTVShows.length} 部');
    return result;
  }

  // ===== 电影处理 =====

  Future<MovieMetadataEntity?> _scrapeMovieSingle(MediaFileEntity file, ScrapeResult result) async {
    try {
      MovieMetadataEntity? metadata;

      // A. ID已存在，直接获取
      if (file.tmdbId != null && file.tmdbId!.isNotEmpty) {
        // 先查库
        metadata = await _db.getMovieByTmdbId(file.tmdbId!);
        // 库里没有再查网
        metadata ??= await _tmdb.fetchMovieById(int.parse(file.tmdbId!));
      }

      // B. 搜索
      metadata ??= await _searchWithStrategies<MovieMetadataEntity>(
        file.parsedTitle,
        file.parsedYear,
        (t, y) => _tmdb.fetchMovie(t, year: y),
        (t) => _tmdb.fetchMovie(t),
      );

      if (metadata == null) {
        _logger.w('⚠️ 未找到电影: ${file.parsedTitle}');
        result.failCount++;
        return null;
      }

      // C. 保存与关联
      // 检查库中是否已存在 (可能由其他文件 scraping 刚刚写入)
      final existing = await _db.getMovieByTmdbId(metadata.tmdbId);
      if (existing == null) {
        await _db.saveMovieMetadata(metadata);
        result.newMovies.add(metadata);
      }

      file.tmdbId = metadata.tmdbId;
      await _db.saveMediaFile(file);
      result.successCount++;
      return metadata;
    } catch (e) {
      _logger.e('❌ 刮削电影出错: ${file.fileName} - $e');
      result.failCount++;
      return null;
    }
  }

  // ===== 剧集处理 =====

  Future<TVShowMetadataEntity?> _scrapeTVShowGroup(
    String showTitle,
    List<MediaFileEntity> files,
    ScrapeResult result,
  ) async {
    try {
      TVShowMetadataEntity? metadata;
      final firstFile = files.first;

      // A plain show ID used to be written as a fallback when a specific
      // episode could not be mapped. It is not a completed episode scrape and
      // may even belong to a similarly named, but incorrect show.
      await _clearFallbackShowLinks(files);

      // 1. Only an episode-specific ID is authoritative enough to recover a
      // show without searching again.
      final existingId = _extractShowTmdbIdFromFiles(files);
      if (existingId != null && _hasEpisodeSpecificId(files)) {
        metadata = await _db.getTVShowByTmdbId(existingId);
        metadata ??= await _tmdb.fetchTVShowById(int.parse(existingId));
      }

      // 2. 搜索
      metadata ??= await _searchWithStrategies<TVShowMetadataEntity>(
        showTitle,
        firstFile.parsedYear,
        (t, y) => _tmdb.fetchTVShow(t, year: y),
        (t) => _tmdb.fetchTVShow(t),
      );

      if (metadata == null) {
        _logger.w('⚠️ 未找到剧集: $showTitle');
        result.failCount += files.length;
        return null;
      }

      // 3. 保存剧集主体
      final existingShow = await _db.getTVShowByTmdbId(metadata.tmdbId);
      if (existingShow == null) {
        await _db.saveTVShowMetadata(metadata);
        result.newTVShows.add(metadata);
      }

      // 4. 处理季和集
      final tvId = int.parse(metadata.tmdbId);
      final seasonNumbers = files.map((f) => f.parsedSeason).whereType<int>().toSet();

      var matchedFileCount = 0;
      for (final seasonNum in seasonNumbers) {
        matchedFileCount += await _scrapeSeasonAndEpisodes(
          tvId,
          metadata.tmdbId,
          seasonNum,
          files.where((f) => f.parsedSeason == seasonNum).toList(),
        );
      }

      // Files without an episode mapping remain unlinked and are reported as
      // failures. Associating them with the show ID masks the problem and
      // makes later scans look like duplicate successful scrapes.
      result.successCount += matchedFileCount;
      final unmatchedFileCount = files.length - matchedFileCount;
      if (unmatchedFileCount > 0) {
        result.failCount += unmatchedFileCount;
        _logger.w('⚠️ 剧集 "$showTitle" 有 $unmatchedFileCount 集未匹配到 TMDB 单集信息');
      }
      return metadata;
    } catch (e) {
      _logger.e('❌ 刮削剧集出错: $showTitle - $e');
      result.failCount += files.length;
      return null;
    }
  }

  Future<int> _scrapeSeasonAndEpisodes(
    int tvId,
    String showTmdbId,
    int seasonNum,
    List<MediaFileEntity> seasonFiles,
  ) async {
    final seasonKey = '${showTmdbId}_s$seasonNum';
    final season = await _tmdb.fetchSeason(tvId, seasonNum, showTmdbId: showTmdbId);
    if (season == null) return 0;

    if (await _db.getSeasonByKey(seasonKey) == null) {
      await _db.saveSeasonMetadata(season.season);
    }
    final episodesByNumber = {for (final episode in season.episodes) episode.episodeNumber: episode};

    var matchedFileCount = 0;
    for (final file in seasonFiles) {
      final epNum = file.parsedEpisode;
      final episode = episodesByNumber[epNum];
      if (episode == null) continue;

      if (await _db.getEpisodeByTmdbId(episode.tmdbId) == null) {
        await _db.saveEpisodeMetadata(episode);
      }

      file.tmdbId = episode.tmdbId;
      await _db.saveMediaFile(file);
      matchedFileCount++;
    }
    return matchedFileCount;
  }

  // ===== 通用搜索策略 =====

  /// 搜索策略：
  /// 1. 原名 + 年份
  /// 2. 变体名 + 年份
  /// 3. 原名 (无年份)
  /// 4. 变体名 (无年份)
  Future<T?> _searchWithStrategies<T>(
    String title,
    int? year,
    Future<T?> Function(String, int?) searchWithYear,
    Future<T?> Function(String) searchWithoutYear,
  ) async {
    final variants = _buildSearchTitleVariants(title);

    // A. 带年份搜索
    for (final variant in variants) {
      final result = await searchWithYear(variant, year);
      if (result != null) {
        if (variant != title) {
          _logger.d('🎯 变体搜索成功(带年份): "$variant"');
        }
        return result;
      }
    }

    // B. 无年份搜索 (如果年份存在)
    if (year != null) {
      for (final variant in variants) {
        final result = await searchWithoutYear(variant);
        if (result != null) {
          if (variant != title) {
            _logger.d('🎯 变体搜索成功(无年份): "$variant"');
          }
          return result;
        }
      }
    }

    return null;
  }

  // ===== 辅助方法 =====

  String _buildTVGroupKey(MediaFileEntity file) {
    final showTmdbId = _extractShowTmdbId(file.tmdbId);
    if (showTmdbId != null) return 'tmdb:$showTmdbId';

    final titleKey = _normalizeGroupKey(file.parsedTitle);
    final yearKey = file.parsedYear?.toString() ?? '';
    return 'title:$titleKey:$yearKey';
  }

  String _normalizeGroupKey(String title) {
    final normalized = title.toLowerCase().replaceAll(RegExp(r'[\s._\-:：，。/\\\(\)\[\]【】]+'), '');
    return normalized.isEmpty ? title.trim().toLowerCase() : normalized;
  }

  String? _extractShowTmdbIdFromFiles(List<MediaFileEntity> files) {
    for (final file in files) {
      final showTmdbId = _extractShowTmdbId(file.tmdbId);
      if (showTmdbId != null) return showTmdbId;
    }
    return null;
  }

  String? _extractShowTmdbId(String? tmdbId) {
    if (tmdbId == null || tmdbId.isEmpty) return null;

    // 匹配 "12345_s1e1" 或 "12345"
    final match = RegExp(r'^(\d+)(?:_s|$)').firstMatch(tmdbId);
    return match?.group(1);
  }

  bool _hasEpisodeSpecificId(List<MediaFileEntity> files) {
    return files.any((file) => RegExp(r'^\d+_s\d+e\d+$').hasMatch(file.tmdbId ?? ''));
  }

  Future<void> _clearFallbackShowLinks(List<MediaFileEntity> files) async {
    for (final file in files) {
      final tmdbId = file.tmdbId;
      if (tmdbId == null || tmdbId.isEmpty || tmdbId.contains('_s')) continue;
      file.tmdbId = null;
      await _db.saveMediaFile(file);
    }
  }

  List<String> _buildSearchTitleVariants(String title) {
    return MetadataSearchTitleVariants.build(title);
  }

  Future<void> _runWithConcurrency<T>(List<T> tasks, Future<void> Function(T) action, int maxConcurrent) async {
    if (tasks.isEmpty) return;

    final workerCount = tasks.length < maxConcurrent ? tasks.length : maxConcurrent;
    var nextIndex = 0;

    Future<void> runWorker() async {
      while (nextIndex < tasks.length) {
        final item = tasks[nextIndex];
        nextIndex++;
        await action(item);
      }
    }

    await Future.wait(List.generate(workerCount, (_) => runWorker()));
  }
}

class _TVShowScrapeGroup {
  String title;
  final List<MediaFileEntity> files = [];

  _TVShowScrapeGroup(this.title);

  void add(MediaFileEntity file) {
    files.add(file);
    if (_isBetterTitle(file.parsedTitle, title)) {
      title = file.parsedTitle;
    }
  }

  bool _isBetterTitle(String candidate, String current) {
    final candidateText = candidate.trim();
    final currentText = current.trim();
    if (candidateText.isEmpty) return false;
    if (currentText.isEmpty) return true;
    if (int.tryParse(currentText) != null && int.tryParse(candidateText) == null) {
      return true;
    }
    return candidateText.length > currentText.length;
  }
}
