import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:mochi_player/core/infrastructure/database/database_service.dart';
import 'package:mochi_player/core/infrastructure/database/entities/entities.dart'
    as entity;
import 'package:mochi_player/core/infrastructure/tmdb/tmdb_service.dart';
import 'package:mochi_player/core/infrastructure/webdav/webdav_service.dart';
import 'package:mochi_player/features/library/application/media_library_catalog.dart';
import 'package:mochi_player/features/library/infrastructure/filename_parser.dart';
import 'package:mochi_player/features/library/infrastructure/library_scanner.dart';
import 'package:mochi_player/features/library/infrastructure/metadata_scraper.dart';

/// Coordinates database loading, WebDAV scans and TMDB metadata scraping.
class LibrarySyncController extends ChangeNotifier {
  LibrarySyncController({
    required MediaLibraryCatalog catalog,
    DatabaseService? database,
    TmdbService? tmdbService,
    MetadataScraper? metadataScraper,
    WebDavService Function()? webDavServiceFactory,
    LibraryScanner Function(WebDavService service)? scannerFactory,
  }) : _catalog = catalog,
       _db = database ?? DatabaseService(),
       _tmdbService = tmdbService ?? TmdbService(),
       _metadataScraper = metadataScraper ?? MetadataScraper(),
       _webDavServiceFactory = webDavServiceFactory ?? WebDavService.new,
       _scannerFactory = scannerFactory ?? LibraryScanner.new;

  final MediaLibraryCatalog _catalog;
  final DatabaseService _db;
  final TmdbService _tmdbService;
  final MetadataScraper _metadataScraper;
  final WebDavService Function() _webDavServiceFactory;
  final LibraryScanner Function(WebDavService service) _scannerFactory;
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

  bool get isLoading => _isScanning || _isScraping;
  String? get error => _error;

  double? get scrapeProgress {
    if (!_isScraping || _scrapeTotal <= 0) return null;
    return (_scrapeCompleted / _scrapeTotal).clamp(0.0, 1.0);
  }

  String? get activityMessage {
    if (_isScraping) {
      final count = _scrapeTotal > 0
          ? '$_scrapeCompleted/$_scrapeTotal'
          : '准备中';
      final summary = '已匹配 $_scrapeSuccessCount，失败 $_scrapeFailCount';
      final title = _scrapeCurrentTitle;
      if (title != null && title.isNotEmpty) {
        return '正在刮削 $count：$title · $summary';
      }
      return '正在刮削媒体库 $count · $summary';
    }
    if (_isScanning) return '正在扫描媒体库...';
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

  Future<void> refreshLibraryMetadata() async {
    if (isLoading) return;

    _isScanning = true;
    _error = null;
    notifyListeners();

    try {
      if (!_isInitialized) await loadFromDatabase();

      _catalog.replaceMediaFiles(await _db.getAllMediaFiles());
      _isInitialized = true;
      _catalog.markMediaCatalogChanged();

      final scanResult = await _scanFilesFromWebDav(
        webDavService: _webDavServiceFactory(),
        rootPath: '/',
        removeMissingFiles: true,
      );
      if (scanResult.hadReadError) {
        _error = 'WebDAV 扫描不完整，已跳过增量刮削，避免使用数据库旧文件';
        return;
      }
      if (_catalog.mediaFiles.isEmpty) {
        _error = '已扫描 WebDAV 根目录，但没有发现可刮削视频文件';
        return;
      }
      if (!_tmdbService.isConfigured) {
        _error = '未配置 TMDB API Key，无法增量刮削';
        return;
      }

      for (final file in _catalog.mediaFiles) {
        final parsed = FilenameParser.parse(
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
      await _db.saveMediaFiles(_catalog.mediaFiles);
      _catalog.markMediaCatalogChanged();
      notifyListeners();

      _isScanning = false;
      await _scrapeMetadata();
    } catch (error, stackTrace) {
      _logger.e('增量刮削失败', error: error, stackTrace: stackTrace);
      _error = '增量刮削失败: $error';
    } finally {
      _isScanning = false;
      notifyListeners();
    }
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

  Future<_LibraryScanResult> _scanFilesFromWebDav({
    required WebDavService webDavService,
    required String rootPath,
    required bool removeMissingFiles,
  }) async {
    final scanner = _scannerFactory(webDavService);
    var newCount = 0;
    var removedCount = 0;
    final scannedPaths = <String>{};

    await for (final file in scanner.scan(rootPath)) {
      scannedPaths.add(file.path);
      final existing = await _db.getMediaFileByPath(file.path);
      if (existing != null) continue;

      await _db.saveMediaFile(file);
      _catalog.mediaFiles.add(file);
      _catalog.markMediaCatalogChanged();
      newCount++;
      if (newCount % 10 == 0) notifyListeners();
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
    final staleFiles = _catalog.mediaFiles
        .where((file) => !scannedPaths.contains(file.path))
        .toList();
    if (staleFiles.isEmpty) return 0;

    final removedCount = await _db.deleteMediaFilesByIds(
      staleFiles.map((file) => file.id).toList(),
    );
    if (removedCount == 0) return 0;

    final stalePaths = staleFiles.map((file) => file.path).toSet();
    _catalog.mediaFiles.removeWhere((file) => stalePaths.contains(file.path));
    _catalog.recountContinueWatching();
    _catalog.markAllLibraryContentChanged();
    return removedCount;
  }

  void _upsertMovie(entity.MovieMetadataEntity movie) {
    final index = _catalog.movies.indexWhere(
      (item) => item.tmdbId == movie.tmdbId,
    );
    if (index >= 0) {
      _catalog.movies[index] = movie;
    } else {
      _catalog.movies.add(movie);
    }
  }

  void _upsertTVShow(entity.TVShowMetadataEntity show) {
    final index = _catalog.tvShows.indexWhere(
      (item) => item.tmdbId == show.tmdbId,
    );
    if (index >= 0) {
      _catalog.tvShows[index] = show;
    } else {
      _catalog.tvShows.add(show);
    }
  }

  entity.StoredMediaType _determineMediaType(ParsedMediaFilename parsed) {
    if (parsed.season != null || parsed.episode != null) {
      return entity.StoredMediaType.episode;
    }
    if (parsed.title.isNotEmpty) return entity.StoredMediaType.movie;
    return entity.StoredMediaType.unknown;
  }
}

class _LibraryScanResult {
  const _LibraryScanResult({
    required this.newCount,
    required this.removedCount,
    required this.hadReadError,
  });

  final int newCount;
  final int removedCount;
  final bool hadReadError;
}
