import 'package:webdav_client/webdav_client.dart' as webdav;
import 'package:logger/logger.dart';

abstract interface class WebDavFileSystem {
  bool get isInitialized;

  Future<List<webdav.File>> readDir(String path);
}

/// Provides authenticated WebDAV directory access.
///
/// This service only owns WebDAV client configuration, path normalization, and
/// raw directory reads. Media filtering belongs to library consumers, while
/// playable-link resolution belongs to the OpenList playback service.
class WebDavService implements WebDavFileSystem {
  // --- 单例模式实现 ---
  static final WebDavService _instance = WebDavService._internal();

  factory WebDavService() => _instance;

  WebDavService._internal();

  final _logger = Logger(printer: PrettyPrinter(methodCount: 0));
  webdav.Client? _client;

  /// 是否已初始化
  @override
  bool get isInitialized => _client != null;

  /// 初始化 WebDAV 客户端
  Future<void> init(String url, String username, String password) async {
    final normalizedUrl = _normalizeBaseUrl(url);
    _logger.i("🔌 初始化 WebDAV 连接: $normalizedUrl");
    _client = webdav.newClient(normalizedUrl, user: username.trim(), password: password, debug: false);

    _client!.setConnectTimeout(10000); // 10秒超时
  }

  void clear() {
    _client = null;
  }

  /// 读取目录内容，返回原始 WebDAV 文件列表
  ///
  /// 这是核心方法，被 WebDavMediaScanner 和 FileBrowserProvider 使用
  @override
  Future<List<webdav.File>> readDir(String path) async {
    if (_client == null) {
      _logger.w("WebDAV 客户端尚未初始化，请先调用 init()");
      throw Exception("WebDAV client not initialized.");
    }
    try {
      final requestPath = _normalizePath(path);
      _logger.d("📂 正在读取目录: $requestPath");
      final files = await _client!.readDir(requestPath);
      return files;
    } catch (e) {
      _logger.e("❌ 读取目录 '$path' 失败: $e");
      rethrow;
    }
  }

  /// 测试连接是否正常
  Future<bool> testConnection() async {
    try {
      await readDir('/');
      return true;
    } catch (e) {
      return false;
    }
  }

  // ===== 私有辅助方法 =====

  /// 标准化路径，确保 WebDAV 请求路径格式正确
  String _normalizePath(String path) {
    if (path == '/') return '/dav';
    if (path.startsWith('/dav')) return path;
    return '/dav$path';
  }

  String _normalizeBaseUrl(String url) {
    return url.trim().replaceFirst(RegExp(r'/+$'), '');
  }
}
