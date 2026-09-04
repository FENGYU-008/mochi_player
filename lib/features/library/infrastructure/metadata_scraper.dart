import 'package:logger/logger.dart';
import 'package:mochi_player/core/infrastructure/database/database_service.dart';
import 'package:mochi_player/core/infrastructure/database/entities/entities.dart';
import 'package:mochi_player/core/infrastructure/tmdb/tmdb_service.dart';
import 'package:mochi_player/features/library/application/scrape_candidate.dart';
import 'package:mochi_player/features/library/infrastructure/metadata_importer.dart';
import 'package:mochi_player/features/library/infrastructure/metadata_match_resolver.dart';

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
  final DatabaseService _db;
  final MetadataMatchResolver _matchResolver;
  final MetadataImporter _importer;
  final Logger _logger;

  MetadataScraper({
    TmdbService? tmdb,
    DatabaseService? db,
    MetadataMatchResolver? matchResolver,
    MetadataImporter? importer,
  }) : _db = db ?? DatabaseService(),
       _matchResolver =
           matchResolver ?? MetadataMatchResolver(tmdb: tmdb, database: db),
       _importer = importer ?? MetadataImporter(database: db),
       _logger = Logger(printer: PrettyPrinter(methodCount: 0));

  // ===== 公开 API =====

  /// 批量刮削文件
  /// 自动区分电影和剧集，处理并发和去重
  Future<ScrapeResult> scrapeBatch(
    List<MediaFileEntity> allFiles, {
    ScrapeProgressCallback? onProgress,
  }) async {
    final result = ScrapeResult();
    if (!_matchResolver.isConfigured) {
      _logger.w('⚠️ 未配置 TMDB API Key，跳过元数据刮削');
      return result;
    }

    final movieFiles = <MediaFileEntity>[];
    final tvFiles = <MediaFileEntity>[];
    final knownMovieIds = (await _db.getAllMovies())
        .map((item) => item.tmdbId)
        .toSet();
    final knownEpisodeIds = (await _db.getAllEpisodes())
        .map((item) => item.tmdbId)
        .toSet();

    // 1. 分类与预过滤
    for (final file in allFiles) {
      final candidate = ScrapeCandidate.fromMediaFile(file);
      final explicitIdOverridesMovieMatch =
          candidate.numericExplicitTmdbId != null &&
          candidate.numericExplicitTmdbId != candidate.movieTmdbId;
      final explicitIdOverridesTVMatch =
          candidate.numericExplicitTmdbId != null &&
          candidate.numericExplicitTmdbId != candidate.tvShowTmdbId;
      if (candidate.isMovie &&
          !explicitIdOverridesMovieMatch &&
          candidate.movieTmdbId != null &&
          knownMovieIds.contains(candidate.movieTmdbId)) {
        continue;
      }
      if (candidate.isEpisode &&
          !explicitIdOverridesTVMatch &&
          candidate.episodeTmdbId != null &&
          knownEpisodeIds.contains(candidate.episodeTmdbId)) {
        continue;
      }

      if (candidate.isMovie) {
        movieFiles.add(file);
      } else if (candidate.isEpisode) {
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

    // Publish the real workload before the first network request. The UI used
    // to initialise progress with the entire catalog size, even though most
    // files were filtered out because their metadata already existed.
    await onProgress?.call(
      ScrapeProgress(
        completed: 0,
        total: totalCount,
        successCount: 0,
        failCount: 0,
        currentTitle: '',
      ),
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
      final candidate = ScrapeCandidate.fromMediaFile(file);
      final metadata = (await _matchResolver.resolveMovie(candidate)).metadata;

      if (metadata == null) {
        _logger.w('⚠️ 未找到电影: ${file.parsedTitle}');
        await _importer.markUnmatched([file]);
        result.failCount++;
        return null;
      }

      if (await _importer.importMovie(metadata, file)) {
        result.newMovies.add(metadata);
      }
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

      // Any episode-specific association is stronger evidence than the first
      // file's title. Otherwise the first file represents the group's parsed
      // show title and year.
      final candidates = files
          .map(ScrapeCandidate.fromMediaFile)
          .toList(growable: false);
      final resolverCandidate = candidates.cast<ScrapeCandidate?>().firstWhere(
        (candidate) => candidate!.tvShowTmdbId != null,
        orElse: () => candidates.first,
      )!;
      metadata = (await _matchResolver.resolveTVShow(
        resolverCandidate,
      )).metadata;

      if (metadata == null) {
        _logger.w('⚠️ 未找到剧集: $showTitle');
        await _importer.markUnmatched(files);
        result.failCount += files.length;
        return null;
      }

      if (await _importer.importTVShow(metadata)) {
        result.newTVShows.add(metadata);
      }

      // 4. 处理季和集
      final tvId = int.parse(metadata.tmdbId);
      final seasonNumbers = files
          .map((f) => f.parsedSeason)
          .whereType<int>()
          .toSet();

      var matchedFileCount = 0;
      for (final seasonNum in seasonNumbers) {
        matchedFileCount += await _scrapeSeasonAndEpisodes(
          tvId,
          metadata.tmdbId,
          seasonNum,
          files.where((f) => f.parsedSeason == seasonNum).toList(),
        );
      }

      // A file only becomes confirmed when its exact episode has been found.
      result.successCount += matchedFileCount;
      final unmatchedFileCount = files.length - matchedFileCount;
      if (unmatchedFileCount > 0) {
        await _importer.markUnmatched(
          files
              .where((file) => file.episodeTmdbId == null)
              .toList(growable: false),
        );
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
    final season = await _matchResolver.fetchSeason(
      tvId,
      seasonNum,
      showTmdbId: showTmdbId,
    );
    if (season == null) return 0;

    return _importer.importSeasonEpisodes(season, showTmdbId, seasonFiles);
  }

  // ===== 辅助方法 =====

  String _buildTVGroupKey(MediaFileEntity file) {
    final showTmdbId = file.tvShowTmdbId;
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
