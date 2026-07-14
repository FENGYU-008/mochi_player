import 'package:logger/logger.dart';
import 'package:mochi_player/core/infrastructure/database/database_service.dart';
import 'package:mochi_player/core/infrastructure/database/entities/entities.dart';
import 'package:mochi_player/core/infrastructure/tmdb/tmdb_service.dart';

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
  Future<ScrapeResult> scrapeBatch(
    List<MediaFileEntity> allFiles, {
    ScrapeProgressCallback? onProgress,
  }) async {
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
        if (file.mediaType == MediaType.movie) {
          if (await _db.getMovieByTmdbId(file.tmdbId!) != null) continue;
        } else if (file.mediaType == MediaType.episode) {
          if (await _db.getEpisodeByTmdbId(file.tmdbId!) != null) continue;
        }
      }

      if (file.mediaType == MediaType.movie) {
        movieFiles.add(file);
      } else if (file.mediaType == MediaType.episode) {
        tvFiles.add(file);
      }
    }

    final tvGroups = <String, _TVShowScrapeGroup>{};
    for (final file in tvFiles) {
      final key = _buildTVGroupKey(file);
      tvGroups
          .putIfAbsent(key, () => _TVShowScrapeGroup(file.parsedTitle))
          .add(file);
    }

    final totalCount = movieFiles.length + tvFiles.length;
    var completedCount = 0;

    _logger.i('🎬 批量刮削开始: 电影 ${movieFiles.length} 个, 剧集文件 ${tvFiles.length} 个');

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

    _logger.i(
      '✅ 批量刮削完成: 新增电影 ${result.newMovies.length} 部, 新增剧集 ${result.newTVShows.length} 部',
    );
    return result;
  }

  // ===== 电影处理 =====

  Future<MovieMetadataEntity?> _scrapeMovieSingle(
    MediaFileEntity file,
    ScrapeResult result,
  ) async {
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

      // 1. 尝试从文件 ID 恢复
      final existingId = _extractShowTmdbIdFromFiles(files);
      if (existingId != null) {
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
      final seasonNumbers = files
          .map((f) => f.parsedSeason)
          .whereType<int>()
          .toSet();

      for (final seasonNum in seasonNumbers) {
        await _scrapeSeasonAndEpisodes(
          tvId,
          metadata.tmdbId,
          seasonNum,
          files.where((f) => f.parsedSeason == seasonNum).toList(),
        );
      }

      // 5. 兜底更新文件关联 (以防某些文件在 _scrapeSeasonAndEpisodes 中没被处理)
      for (final file in files) {
        if (file.tmdbId == null || file.tmdbId!.isEmpty) {
          file.tmdbId = metadata.tmdbId; // 关联到剧集ID作为fallback
          await _db.saveMediaFile(file);
        }
      }
      result.successCount += files.length;
      return metadata;
    } catch (e) {
      _logger.e('❌ 刮削剧集出错: $showTitle - $e');
      result.failCount += files.length;
      return null;
    }
  }

  Future<void> _scrapeSeasonAndEpisodes(
    int tvId,
    String showTmdbId,
    int seasonNum,
    List<MediaFileEntity> seasonFiles,
  ) async {
    // 检查/保存季元数据
    final seasonKey = '${showTmdbId}_s$seasonNum';
    if (await _db.getSeasonByKey(seasonKey) == null) {
      final seasonMeta = await _tmdb.fetchSeason(
        tvId,
        seasonNum,
        showTmdbId: showTmdbId,
      );
      if (seasonMeta != null) {
        await _db.saveSeasonMetadata(seasonMeta);
      }
    }

    // 获取单集详情列表
    final seasonRaw = await _tmdb.fetchSeasonRaw(tvId, seasonNum);
    if (seasonRaw == null) return;

    final episodesList = seasonRaw['episodes'] as List? ?? [];

    // 建立 episode_number -> episodeData 映射
    final epMap = <int, Map<String, dynamic>>{};
    for (final ep in episodesList) {
      final num = ep['episode_number'] as int?;
      if (num != null) epMap[num] = ep;
    }

    for (final file in seasonFiles) {
      final epNum = file.parsedEpisode;
      if (epNum == null || !epMap.containsKey(epNum)) continue;

      final epData = epMap[epNum]!;
      final epMeta = _tmdb.parseEpisodeEntity(epData, showTmdbId, seasonNum);

      // 检查/保存单集
      if (await _db.getEpisodeByTmdbId(epMeta.tmdbId) == null) {
        await _db.saveEpisodeMetadata(epMeta);
      }

      // 关联文件
      file.tmdbId = epMeta.tmdbId;
      await _db.saveMediaFile(file);
    }
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
    final normalized = title.toLowerCase().replaceAll(
      RegExp(r'[\s._\-:：，。/\\\(\)\[\]【】]+'),
      '',
    );
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

  List<String> _buildSearchTitleVariants(String title) {
    final variants = <String>[];
    _addTitleVariant(variants, title);

    final withoutBrackets = title
        .replaceAll(RegExp(r'[\[\(（【][^\]\)）】]+[\]\)）】]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    _addTitleVariant(variants, withoutBrackets);

    // 中文
    final zh = RegExp(
      r'[\u4e00-\u9fff\u3400-\u4dbf：，。！？]+',
    ).allMatches(title).map((m) => m.group(0)!).join(' ').trim();
    _addTitleVariant(variants, zh);

    // 英文
    final en = RegExp(
      r"[A-Za-z][A-Za-z\s\-']+[A-Za-z]",
    ).allMatches(title).map((m) => m.group(0)!).join(' ').trim();
    _addTitleVariant(variants, en);

    return variants;
  }

  void _addTitleVariant(List<String> variants, String value) {
    final normalized = value.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (normalized.isEmpty) return;

    final key = _normalizeGroupKey(normalized);
    final exists = variants.any((item) => _normalizeGroupKey(item) == key);
    if (!exists) variants.add(normalized);
  }

  Future<void> _runWithConcurrency<T>(
    List<T> tasks,
    Future<void> Function(T) action,
    int maxConcurrent,
  ) async {
    if (tasks.isEmpty) return;

    final workerCount = tasks.length < maxConcurrent
        ? tasks.length
        : maxConcurrent;
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
    if (int.tryParse(currentText) != null &&
        int.tryParse(candidateText) == null) {
      return true;
    }
    return candidateText.length > currentText.length;
  }
}
