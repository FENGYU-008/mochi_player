import 'package:logger/logger.dart';
import 'package:webdav_client/webdav_client.dart' as webdav;

import 'package:mochi_player/models/entity/entities.dart';
import 'package:mochi_player/services/webdav_service.dart';
import 'package:mochi_player/utils/filename_parser.dart';

/// 媒体库扫描器
///
/// 职责：
/// - 递归扫描 WebDAV 目录
/// - 解析文件名提取元信息
/// - 输出 MediaFileEntity 流
class LibraryScanner {
  final WebDavService _webDavService;
  final _logger = Logger(printer: PrettyPrinter(methodCount: 0));
  bool _hadReadError = false;

  LibraryScanner(this._webDavService);

  bool get hadReadError => _hadReadError;

  /// 扫描媒体库，返回 `Stream<MediaFileEntity>`
  Stream<MediaFileEntity> scan(String rootPath) async* {
    _hadReadError = false;
    _logger.i("🚀 开始扫描媒体库: $rootPath");

    int fileCount = 0;

    await for (final scannedFile in _recursivelyListFiles(rootPath)) {
      final file = scannedFile.file;
      final filePath = scannedFile.path;
      final fileName = file.name ?? '';

      // 解析文件名，提取所有信息
      final parsed = FileNameParser.parse(
        fileName: fileName,
        filePath: filePath,
      );

      // 创建 MediaFileEntity 并填充所有解析信息
      final entity = MediaFileEntity()
        // 基础信息
        ..path = filePath
        ..fileName = fileName
        ..parsedTitle = parsed.title
        ..parsedYear = parsed.year
        ..parsedSeason = parsed.season
        ..parsedEpisode = parsed.episode
        ..mediaType = _determineMediaType(parsed)
        // TMDB ID（如果路径中包含 {tmdbid-xxx}）
        ..tmdbId = parsed.tmdbId
        // 技术信息（从文件名解析）
        ..size = file.size ?? 0
        ..container = parsed.container
        ..height = parsed.height
        ..videoCodec = parsed.videoCodec
        ..audioCodec = parsed.audioCodec
        ..audioChannels = parsed.audioChannels
        ..isHdr = parsed.isHdr
        ..hdrFormat = parsed.hdrFormat
        ..versionLabel = parsed.versionLabel.isNotEmpty
            ? parsed.versionLabel
            : null;

      fileCount++;
      yield entity;
    }

    _logger.i("✅ 媒体库扫描完成，发现 $fileCount 个文件");
  }

  /// 判断媒体类型
  MediaType _determineMediaType(ParsedResult parsed) {
    // 有季号或集号的是剧集
    if (parsed.season != null || parsed.episode != null) {
      return MediaType.episode;
    }
    // 有标题且没有季/集信息的是电影
    if (parsed.title.isNotEmpty) {
      return MediaType.movie;
    }
    return MediaType.unknown;
  }

  /// 递归列出所有文件
  Stream<_ScannedWebDavFile> _recursivelyListFiles(String path) async* {
    try {
      final directoryPath = _normalizeDirectoryPath(path);
      final files = await _webDavService.readDir(directoryPath);

      for (final file in files) {
        final name = file.name;
        if (name == null || name.isEmpty) continue;

        final itemPath = _joinPath(
          directoryPath,
          name,
          isDirectory: file.isDir == true,
        );

        if (file.isDir == true) {
          yield* _recursivelyListFiles(itemPath);
        } else {
          yield _ScannedWebDavFile(file, itemPath);
        }
      }
    } catch (e) {
      _hadReadError = true;
      _logger.w("⚠️ 扫描路径失败: $path - $e");
    }
  }

  String _normalizeDirectoryPath(String path) {
    final trimmed = path.trim();
    if (trimmed.isEmpty || trimmed == '/') return '/';
    final withLeadingSlash = trimmed.startsWith('/') ? trimmed : '/$trimmed';
    return withLeadingSlash.endsWith('/')
        ? withLeadingSlash
        : '$withLeadingSlash/';
  }

  String _joinPath(
    String directoryPath,
    String name, {
    required bool isDirectory,
  }) {
    final base = _normalizeDirectoryPath(directoryPath);
    final cleanName = name.replaceAll(RegExp(r'^/+|/+$'), '');
    final path = base == '/' ? '/$cleanName' : '$base$cleanName';
    return isDirectory && !path.endsWith('/') ? '$path/' : path;
  }
}

class _ScannedWebDavFile {
  final webdav.File file;
  final String path;

  const _ScannedWebDavFile(this.file, this.path);
}
