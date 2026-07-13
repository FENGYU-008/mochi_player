import 'package:dio/dio.dart';
import 'package:webdav_client/webdav_client.dart' as webdav;
import 'package:logger/logger.dart';

/// WebDAV 服务 - 纯粹的文件系统操作
///
/// 职责：
/// - 连接 WebDAV/Alist 服务器
/// - 读取目录内容
/// - 获取文件直链
///
/// 注意：不涉及任何业务模型转换，只返回原始 webdav.File 对象
class WebDavService {
  // --- 单例模式实现 ---
  static final WebDavService _instance = WebDavService._internal();

  factory WebDavService() => _instance;

  WebDavService._internal() {
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);
  }

  // ---

  final _logger = Logger(printer: PrettyPrinter(methodCount: 0));
  webdav.Client? _client;
  String _baseUrl = '';
  String _username = '';
  String _password = '';
  String? _token;
  Future<bool>? _tokenRefreshFuture;
  final _dio = Dio();

  /// 是否已初始化
  bool get isInitialized => _client != null;

  /// 初始化 WebDAV 客户端
  Future<void> init(String url, String username, String password) async {
    final normalizedUrl = _normalizeBaseUrl(url);
    _logger.i("🔌 初始化 WebDAV 连接: $normalizedUrl");
    _baseUrl = normalizedUrl;
    _username = username.trim();
    _password = password;
    _token = null;
    _tokenRefreshFuture = null;

    _client = webdav.newClient(
      _baseUrl,
      user: _username,
      password: password,
      debug: false,
    );

    _client!.setConnectTimeout(10000); // 10秒超时

    // Alist token is fetched lazily when a direct playback link is needed.
  }

  void clear() {
    _client = null;
    _baseUrl = '';
    _username = '';
    _password = '';
    _token = null;
    _tokenRefreshFuture = null;
  }

  Future<bool> _login() async {
    try {
      final response = await _dio.post(
        '$_baseUrl/api/auth/login',
        data: {'username': _username, 'password': _password},
      );
      if (response.statusCode == 200 && response.data['code'] == 200) {
        final token = response.data['data']['token'];
        if (token is String && token.isNotEmpty) {
          _token = token;
          _logger.i("✅ Alist API 登录成功");
          return true;
        }
        _logger.w("⚠️ Alist API 登录失败：响应中缺少 Token");
      } else {
        _logger.w("⚠️ Alist API 登录失败: ${response.data['message']}");
      }
      return false;
    } catch (e) {
      _logger.e("❌ Alist API 登录异常: $e");
      return false;
    }
  }

  Future<bool> _ensureToken() {
    if (_token != null) return Future.value(true);
    return _tokenRefreshFuture ??= _login().whenComplete(() {
      _tokenRefreshFuture = null;
    });
  }

  /// 获取文件的直链 (用于播放器)
  Future<String?> getDirectLink(String path) async {
    if (!await _ensureToken()) {
      _logger.w("无法获取直链，因为未登录 Alist API");
      return null;
    }

    // 移除 WebDAV 路径中的 /dav 前缀，以适配 Alist API
    String apiPath = path;
    if (apiPath.startsWith('/dav')) {
      apiPath = apiPath.substring(4);
      if (apiPath.isEmpty) apiPath = '/';
    }

    _logger.d("🔗 正在为 Alist API 请求路径: $apiPath");

    var result = await _requestDirectLink(apiPath);
    if (!result.tokenInvalid) return result.url;

    // AList tokens may expire while the app remains open. Refresh once and
    // retry the original request instead of requiring the user to reconnect.
    _token = null;
    if (!await _ensureToken()) return null;
    result = await _requestDirectLink(apiPath);
    return result.url;
  }

  Future<_DirectLinkResult> _requestDirectLink(String apiPath) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/api/fs/get',
        data: {'path': apiPath},
        options: Options(headers: {'Authorization': _token}),
      );
      final data = response.data;
      final apiCode = data is Map ? data['code'] : null;
      final tokenInvalid = response.statusCode == 401 || apiCode == 401;
      if (response.statusCode == 200 && apiCode == 200) {
        final rawUrl = data['data']['raw_url'];
        if (rawUrl is String && rawUrl.isNotEmpty) {
          _logger.i("✅ 获取直链成功");
          return _DirectLinkResult(url: rawUrl);
        }
      }
      _logger.w("⚠️ 获取直链失败: ${data is Map ? data['message'] : data}");
      return _DirectLinkResult(tokenInvalid: tokenInvalid);
    } on DioException catch (error) {
      final tokenInvalid = error.response?.statusCode == 401;
      _logger.e("❌ 获取直链异常: $error");
      return _DirectLinkResult(tokenInvalid: tokenInvalid);
    } catch (error) {
      _logger.e("❌ 获取直链异常: $error");
      return const _DirectLinkResult();
    }
  }

  /// 读取目录内容，返回原始 WebDAV 文件列表
  ///
  /// 这是核心方法，被 LibraryScanner 和 FileBrowserProvider 使用
  Future<List<webdav.File>> readDir(String path) async {
    if (_client == null) {
      _logger.w("WebDAV 客户端尚未初始化，请先调用 init()");
      throw Exception("WebDAV client not initialized.");
    }
    try {
      final requestPath = _normalizePath(path);
      _logger.d("📂 正在读取目录: $requestPath");
      final files = await _client!.readDir(requestPath);
      // 只返回有效的文件
      return files.where(_isValidFile).toList();
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

  /// 检查是否为有效的媒体文件或目录
  bool _isValidFile(webdav.File file) {
    // 忽略隐藏文件
    if (file.name == null || file.name!.startsWith('.')) {
      return false;
    }
    // 目录始终有效
    if (file.isDir == true) {
      return true;
    }
    // 只保留视频文件
    const videoExtensions = {
      '.mp4',
      '.mkv',
      '.avi',
      '.mov',
      '.wmv',
      '.flv',
      '.webm',
      '.ts',
      '.m2ts',
    };
    final extension = file.name!.contains('.')
        ? '.${file.name!.split('.').last.toLowerCase()}'
        : '';
    return videoExtensions.contains(extension);
  }
}

class _DirectLinkResult {
  final String? url;
  final bool tokenInvalid;

  const _DirectLinkResult({this.url, this.tokenInvalid = false});
}
