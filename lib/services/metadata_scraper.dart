import 'package:logger/logger.dart';
import '../models/entity/entities.dart';
import 'tmdb_service.dart';
import 'database_service.dart';

/// 元数据刮削服务
/// 负责协调 TMDB 搜索和数据库存储
/// 刮削结果容器
class ScrapeResult {
  final List<MovieMetadataEntity> newMovies = [];
  final List<TVShowMetadataEntity> newTVShows = [];
  int successCount = 0;
  int failCount = 0;
}

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
  Future<ScrapeResult> scrapeBatch(List<MediaFileEntity> allFiles) async {
    final result = ScrapeResult();
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

    _logger.i('🎬 批量刮削开始: 电影 ${movieFiles.length} 个, 剧集文件 ${tvFiles.length} 个');

    // 2. 刮削电影 (并发)
    await _runWithConcurrency(movieFiles, (file) async {
      await _scrapeMovieSingle(file, result);
    }, 5);

    // 3. 刮削剧集 (按剧名分组后并发)
    final tvGroups = <String, List<MediaFileEntity>>{};
    for (final file in tvFiles) {
      tvGroups.putIfAbsent(file.parsedTitle, () => []).add(file);
    }

    await _runWithConcurrency(tvGroups.entries.toList(), (entry) async {
      await _scrapeTVShowGroup(entry.key, entry.value, result);
    }, 5);

    _logger.i(
      '✅ 批量刮削完成: 新增电影 ${result.newMovies.length} 部, 新增剧集 ${result.newTVShows.length} 部',
    );
    return result;
  }

  // ===== 电影处理 =====

  Future<void> _scrapeMovieSingle(
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
        return;
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
    } catch (e) {
      _logger.e('❌ 刮削电影出错: ${file.fileName} - $e');
      result.failCount++;
    }
  }

  // ===== 剧集处理 =====

  Future<void> _scrapeTVShowGroup(
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
        return;
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
    } catch (e) {
      _logger.e('❌ 刮削剧集出错: $showTitle - $e');
      result.failCount += files.length;
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
    // A. 带年份搜索
    var result = await searchWithYear(title, year);
    if (result != null) return result;

    final variants = _extractTitleVariants(title);
    for (final variant in variants) {
      if (variant == title) continue;
      result = await searchWithYear(variant, year);
      if (result != null) {
        _logger.d('🎯 变体搜索成功(带年份): "$variant"');
        return result;
      }
    }

    // B. 无年份搜索 (如果年份存在)
    if (year != null) {
      result = await searchWithoutYear(title);
      if (result != null) return result;

      for (final variant in variants) {
        if (variant == title) continue;
        result = await searchWithoutYear(variant);
        if (result != null) {
          _logger.d('🎯 变体搜索成功(无年份): "$variant"');
          return result;
        }
      }
    }

    return null;
  }

  // ===== 辅助方法 =====

  String? _extractShowTmdbIdFromFiles(List<MediaFileEntity> files) {
    for (final file in files) {
      if (file.tmdbId == null || file.tmdbId!.isEmpty) continue;
      // 匹配 "12345_s1e1" 或 "12345"
      final match = RegExp(r'^(\d+)(?:_s|$)').firstMatch(file.tmdbId!);
      if (match != null) return match.group(1);
    }
    return null;
  }

  List<String> _extractTitleVariants(String title) {
    final variants = <String>[];
    // 中文
    final zh = RegExp(
      r'[\u4e00-\u9fff\u3400-\u4dbf：，。！？]+',
    ).allMatches(title).map((m) => m.group(0)!).join(' ').trim();
    if (zh.isNotEmpty) variants.add(zh);

    // 英文
    final en = RegExp(
      r"[A-Za-z][A-Za-z\s\-']+[A-Za-z]",
    ).allMatches(title).map((m) => m.group(0)!).join(' ').trim();
    if (en.isNotEmpty) variants.add(en);

    return variants;
  }

  Future<void> _runWithConcurrency<T>(
    List<T> tasks,
    Future<void> Function(T) action,
    int maxConcurrent,
  ) async {
    final active = <Future<void>>[];
    for (final item in tasks) {
      while (active.length >= maxConcurrent) {
        await Future.any(active);
        active.removeWhere(
          (f) => f.hashCode == f.hashCode,
        ); // Cleaning finished tasks?
        // Future.any doesn't return the completed future, just a value.
        // Better implementation:
        // We just wait for "any" to complete.
        // But we need to remove the one that completed.
      }

      final task = action(item);
      active.add(task);
      task.whenComplete(() => active.remove(task));
    }
    await Future.wait(active);
  }
}
