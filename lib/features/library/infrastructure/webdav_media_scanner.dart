import 'package:logger/logger.dart';
import 'package:mochi_player/core/domain/media/media_file_kind.dart';
import 'package:mochi_player/core/infrastructure/database/entities/entities.dart';
import 'package:mochi_player/core/infrastructure/webdav/webdav_service.dart';
import 'package:mochi_player/features/library/infrastructure/filename_parser.dart';
import 'package:mochi_player/features/library/infrastructure/media_file_metadata_mapper.dart';
import 'package:webdav_client/webdav_client.dart' as webdav;

/// Scans a WebDAV file tree and emits parsed video-file entities.
///
/// Database reconciliation and TMDB scraping belong to LibrarySyncController.
class WebDavMediaScanner {
  final WebDavFileSystem _webDavService;
  final _logger = Logger(printer: PrettyPrinter(methodCount: 0));
  bool _hadReadError = false;

  WebDavMediaScanner(this._webDavService);

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
      final parsed = FilenameParser.parse(fileName: fileName, filePath: filePath);

      final entity = MediaFileMetadataMapper.createEntity(
        path: filePath,
        fileName: fileName,
        size: file.size ?? 0,
        metadata: parsed,
      );

      fileCount++;
      yield entity;
    }

    _logger.i("✅ 媒体库扫描完成，发现 $fileCount 个文件");
  }

  /// 递归列出所有文件
  Stream<_ScannedWebDavFile> _recursivelyListFiles(String path) async* {
    try {
      final directoryPath = _normalizeDirectoryPath(path);
      final files = await _webDavService.readDir(directoryPath);

      for (final file in files) {
        final name = file.name;
        if (name == null || name.isEmpty || name.startsWith('.')) continue;
        if (file.isDir != true && MediaFileKindResolver.resolve(name) != MediaFileKind.video) {
          continue;
        }

        final itemPath = _joinPath(directoryPath, name, isDirectory: file.isDir == true);

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
    return withLeadingSlash.endsWith('/') ? withLeadingSlash : '$withLeadingSlash/';
  }

  String _joinPath(String directoryPath, String name, {required bool isDirectory}) {
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
