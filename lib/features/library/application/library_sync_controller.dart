import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:mochi_player/core/domain/storage/models.dart';
import 'package:mochi_player/core/infrastructure/database/database_service.dart';
import 'package:mochi_player/core/infrastructure/database/entities/entities.dart' as entity;
import 'package:mochi_player/core/infrastructure/storage/storage_source_service.dart';
import 'package:mochi_player/core/infrastructure/storage/storage_provider_registry.dart';
import 'package:mochi_player/core/infrastructure/tmdb/tmdb_service.dart';
import 'package:mochi_player/features/library/application/media_library_catalog.dart';
import 'package:mochi_player/features/library/infrastructure/filename_parser.dart';
import 'package:mochi_player/features/library/infrastructure/media_file_metadata_mapper.dart';
import 'package:mochi_player/features/library/infrastructure/metadata_scraper.dart';
import 'package:mochi_player/features/library/infrastructure/storage_media_scanner.dart';

/// Coordinates database loading, WebDAV scans and TMDB metadata scraping.
class LibrarySyncController extends ChangeNotifier {
  LibrarySyncController({
    required MediaLibraryCatalog catalog,
    DatabaseService? database,
    TmdbService? tmdbService,
    MetadataScraper? metadataScraper,
    StorageSourceService? storageSourceService,
    StorageProviderRegistry? storageProviderRegistry,
    StorageMediaScanner Function(StorageConnection connection)? storageScannerFactory,
  }) : _catalog = catalog,
       _db = database ?? DatabaseService(),
       _tmdbService = tmdbService ?? TmdbService(),
       _metadataScraper = metadataScraper ?? MetadataScraper(),
       _storageSourceService = storageSourceService ?? StorageSourceService(),
       _storageProviderRegistry = storageProviderRegistry ?? StorageProviderRegistry.defaults(),
       _storageScannerFactory = storageScannerFactory ?? StorageMediaScanner.new;

  final MediaLibraryCatalog _catalog;
  final DatabaseService _db;
  final TmdbService _tmdbService;
  final MetadataScraper _metadataScraper;
  final StorageSourceService _storageSourceService;
  final StorageProviderRegistry _storageProviderRegistry;
  final StorageMediaScanner Function(StorageConnection connection) _storageScannerFactory;
  final _logger = Logger(printer: PrettyPrinter(methodCount: 0));

  bool _isScanning = false;
  bool _isScraping = false;
  bool _isInitialized = false;
  String? _error;
  int _scrapeCompleted = 0;
  int _scrapeTotal = 0;
  int _scrapeSuccessCount = 0;
  int _scrapeFailCount = 0;
  String? _scrapeCurrentTitle;
  int _scanCompletedSources = 0;
  int _scanTotalSources = 0;
  String? _scanCurrentSource;

  bool get isLoading => _isScanning || _isScraping;

  String? get error => _error;

  double? get scrapeProgress {
    if (!_isScraping || _scrapeTotal <= 0) return null;
    return (_scrapeCompleted / _scrapeTotal).clamp(0.0, 1.0);
  }

  String? get activityMessage {
    if (_isScraping) {
      final count = _scrapeTotal > 0 ? '$_scrapeCompleted/$_scrapeTotal' : '准备中';
      final summary = '已匹配 $_scrapeSuccessCount，失败 $_scrapeFailCount';
      final title = _scrapeCurrentTitle;
      if (title != null && title.isNotEmpty) {
        return '正在刮削 $count：$title · $summary';
      }
      return '正在刮削媒体库 $count · $summary';
    }
    if (_isScanning) {
      final progress = _scanTotalSources > 0 ? '$_scanCompletedSources/$_scanTotalSources' : '准备中';
      final source = _scanCurrentSource;
      return source == null ? '正在扫描已启用的媒体源...' : '正在扫描 $progress：$source';
    }
    return null;
  }

  Future<void> loadFromDatabase() async {
    if (_isInitialized) return;

    _logger.i('从数据库加载媒体库...');
    _catalog.replaceAll(
      mediaFiles: await _db.getAllMediaFiles(),
      movies: await _db.getAllMovies(),
      tvShows: await _db.getAllTVShows(),
      seasons: await _db.getAllSeasons(),
      episodes: await _db.getAllEpisodes(),
    );
    _isInitialized = true;
    _catalog.markAllLibraryContentChanged();
    _logger.i(
      '加载完成: ${_catalog.mediaFiles.length} 个文件, ${_catalog.movies.length} 部电影, '
      '${_catalog.tvShows.length} 部剧集, ${_catalog.seasons.length} 季, '
      '${_catalog.episodes.length} 集',
    );
    notifyListeners();
  }

  /// Scans every enabled media source and updates the local file index.
  ///
  /// This workflow deliberately does not require a TMDB key. Metadata
  /// scraping is a separate optional step after files have been discovered.
  Future<MediaSourceScanSummary?> scanEnabledMediaSources() async {
    if (isLoading) return null;

    _isScanning = true;
    _error = null;
    _scanCompletedSources = 0;
    _scanTotalSources = 0;
    _scanCurrentSource = null;
    notifyListeners();

    try {
      if (!_isInitialized) await loadFromDatabase();

      _catalog.replaceMediaFiles(await _db.getAllMediaFiles());
      _isInitialized = true;
      _catalog.markMediaCatalogChanged();

      final sources = (await _storageSourceService.getAll())
          .where((source) => source.enabled && _storageProviderRegistry.supports(source.type))
          .toList(growable: false);
      if (sources.isEmpty) {
        _error = '请先添加并启用至少一个可扫描的媒体源';
        return null;
      }

      _scanTotalSources = sources.length;
      var completedSourceCount = 0;
      var failedSourceCount = 0;
      var discoveredFileCount = 0;
      var newFileCount = 0;
      var removedFileCount = 0;
      for (final source in sources) {
        _scanCurrentSource = source.name;
        notifyListeners();
        try {
          final credentials = await _storageSourceService.readCredentials(source.id);
          final connection = await _storageProviderRegistry.connect(source, credentials);
          final result = await _scanFilesFromStorage(connection);
          discoveredFileCount += result.discoveredCount;
          newFileCount += result.newCount;
          removedFileCount += result.removedCount;
          _logger.i(
            '媒体源 ${source.name} 扫描完成：发现 ${result.discoveredCount} 个视频，'
            '新增 ${result.newCount} 个，移除 ${result.removedCount} 个',
          );
          if (result.hadReadError) {
            failedSourceCount++;
            _logger.w('媒体源 ${source.name} 的扫描不完整，已跳过失效文件清理');
          } else {
            completedSourceCount++;
          }
        } catch (error) {
          failedSourceCount++;
          _logger.w('扫描媒体源 ${source.name} 失败: $error');
        } finally {
          _scanCompletedSources++;
          notifyListeners();
        }
      }
      _catalog.markMediaCatalogChanged();
      final summary = MediaSourceScanSummary(
        enabledSourceCount: sources.length,
        completedSourceCount: completedSourceCount,
        failedSourceCount: failedSourceCount,
        discoveredFileCount: discoveredFileCount,
        newFileCount: newFileCount,
        removedFileCount: removedFileCount,
      );
      _logger.i(
        '全部媒体源扫描完成：启用 ${summary.enabledSourceCount} 个，'
        '成功 ${summary.completedSourceCount} 个，失败 ${summary.failedSourceCount} 个，'
        '发现 ${summary.discoveredFileCount} 个视频，新增 ${summary.newFileCount} 个，'
        '移除 ${summary.removedFileCount} 个',
      );
      await _scrapeScannedMediaFiles();
      return summary;
    } catch (error, stackTrace) {
      _logger.e('扫描媒体源失败', error: error, stackTrace: stackTrace);
      _error = '扫描媒体源失败: $error';
      return null;
    } finally {
      _isScanning = false;
      _scanCurrentSource = null;
      notifyListeners();
    }
  }

  /// Retained for callers that explicitly request a full scan and metadata
  /// refresh. A normal scan now follows the same workflow.
  Future<void> refreshLibraryMetadata() async {
    await scanEnabledMediaSources();
  }

  /// Parses every discovered file again before scraping so both newly added
  /// and existing media can receive updated TMDB identifiers and metadata.
  Future<void> _scrapeScannedMediaFiles() async {
    if (_catalog.mediaFiles.isEmpty || !_tmdbService.isConfigured) return;

    for (final file in _catalog.mediaFiles) {
      final parsed = FilenameParser.parse(fileName: file.fileName, filePath: file.path);
      MediaFileMetadataMapper.updateEntity(file, parsed);
    }
    await _db.saveMediaFiles(_catalog.mediaFiles);
    _catalog.markMediaCatalogChanged();
    notifyListeners();
    await _scrapeMetadata();
  }

  void reset() {
    _isScanning = false;
    _isScraping = false;
    _isInitialized = false;
    _error = null;
    _scrapeCompleted = 0;
    _scrapeTotal = 0;
    _scrapeSuccessCount = 0;
    _scrapeFailCount = 0;
    _scrapeCurrentTitle = null;
    _scanCompletedSources = 0;
    _scanTotalSources = 0;
    _scanCurrentSource = null;
    notifyListeners();
  }

  Future<void> _scrapeMetadata() async {
    if (_isScraping) return;

    _isScraping = true;
    _scrapeCompleted = 0;
    _scrapeTotal = _catalog.mediaFiles.length;
    _scrapeSuccessCount = 0;
    _scrapeFailCount = 0;
    _scrapeCurrentTitle = null;
    notifyListeners();

    try {
      final result = await _metadataScraper.scrapeBatch(
        _catalog.mediaFiles,
        onProgress: (progress) async {
          _scrapeCompleted = progress.completed;
          _scrapeTotal = progress.total;
          _scrapeSuccessCount = progress.successCount;
          _scrapeFailCount = progress.failCount;
          _scrapeCurrentTitle = progress.currentTitle;

          var mediaCatalogChanged = false;
          var metadataChanged = false;
          if (progress.movie != null) {
            _upsertMovie(progress.movie!);
            mediaCatalogChanged = true;
            metadataChanged = true;
          }
          if (progress.tvShow != null) {
            _upsertTVShow(progress.tvShow!);
            mediaCatalogChanged = true;
            metadataChanged = true;
          }
          if (progress.seasonsChanged) {
            _catalog.seasons
              ..clear()
              ..addAll(await _db.getAllSeasons());
            _catalog.episodes
              ..clear()
              ..addAll(await _db.getAllEpisodes());
            metadataChanged = true;
          }
          if (mediaCatalogChanged) _catalog.markMediaCatalogChanged();
          if (metadataChanged) _catalog.markMetadataChanged();
          notifyListeners();
        },
      );

      _catalog.replaceMetadata(
        movies: await _db.getAllMovies(),
        tvShows: await _db.getAllTVShows(),
        seasons: await _db.getAllSeasons(),
        episodes: await _db.getAllEpisodes(),
      );
      if (result.successCount > 0) {
        _catalog.markMetadataChanged();
        _catalog.markMediaCatalogChanged();
      }
    } catch (error, stackTrace) {
      _logger.e('刮削失败', error: error, stackTrace: stackTrace);
      _error = '刮削失败: $error';
    } finally {
      _isScraping = false;
      _scrapeCurrentTitle = null;
      notifyListeners();
    }
  }

  Future<_LibraryScanResult> _scanFilesFromStorage(StorageConnection connection) async {
    final scanner = _storageScannerFactory(connection);
    var newCount = 0;
    var removedCount = 0;
    var discoveredCount = 0;
    final scannedPaths = <String>{};

    await for (final file in scanner.scan()) {
      discoveredCount++;
      scannedPaths.add(file.path);
      final existing = await _db.getMediaFile(file.sourceId, file.path);
      if (existing != null) continue;

      await _db.saveMediaFile(file);
      _catalog.mediaFiles.add(file);
      _catalog.markMediaCatalogChanged();
      newCount++;
      if (newCount % 10 == 0) notifyListeners();
    }

    if (scanner.hadReadError) {
      _logger.w('跳过失效文件清理，因为来源 ${connection.source.name} 的扫描存在读取失败');
    } else {
      removedCount = await _removeMissingMediaFiles(connection.source.id, scannedPaths);
    }

    return _LibraryScanResult(
      discoveredCount: discoveredCount,
      newCount: newCount,
      removedCount: removedCount,
      hadReadError: scanner.hadReadError,
    );
  }

  Future<int> _removeMissingMediaFiles(String sourceId, Set<String> scannedPaths) async {
    final staleFiles = _catalog.mediaFiles
        .where((file) => file.sourceId == sourceId && !scannedPaths.contains(file.path))
        .toList();
    if (staleFiles.isEmpty) return 0;

    final removedCount = await _db.deleteMediaFilesByIds(staleFiles.map((file) => file.id).toList());
    if (removedCount == 0) return 0;

    final staleIds = staleFiles.map((file) => file.id).toSet();
    _catalog.mediaFiles.removeWhere((file) => staleIds.contains(file.id));
    _catalog.recountContinueWatching();
    _catalog.markAllLibraryContentChanged();
    return removedCount;
  }

  void _upsertMovie(entity.MovieMetadataEntity movie) {
    final index = _catalog.movies.indexWhere((item) => item.tmdbId == movie.tmdbId);
    if (index >= 0) {
      _catalog.movies[index] = movie;
    } else {
      _catalog.movies.add(movie);
    }
  }

  void _upsertTVShow(entity.TVShowMetadataEntity show) {
    final index = _catalog.tvShows.indexWhere((item) => item.tmdbId == show.tmdbId);
    if (index >= 0) {
      _catalog.tvShows[index] = show;
    } else {
      _catalog.tvShows.add(show);
    }
  }
}

class _LibraryScanResult {
  const _LibraryScanResult({
    required this.discoveredCount,
    required this.newCount,
    required this.removedCount,
    required this.hadReadError,
  });

  final int discoveredCount;
  final int newCount;
  final int removedCount;
  final bool hadReadError;
}

/// The outcome of scanning all currently enabled media sources.
class MediaSourceScanSummary {
  const MediaSourceScanSummary({
    required this.enabledSourceCount,
    required this.completedSourceCount,
    required this.failedSourceCount,
    required this.discoveredFileCount,
    required this.newFileCount,
    required this.removedFileCount,
  });

  final int enabledSourceCount;
  final int completedSourceCount;
  final int failedSourceCount;
  final int discoveredFileCount;
  final int newFileCount;
  final int removedFileCount;
}
