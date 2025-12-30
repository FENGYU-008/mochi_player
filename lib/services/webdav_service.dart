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

  WebDavService._internal();

  // ---

  final _logger = Logger(printer: PrettyPrinter(methodCount: 0));
  webdav.Client? _client;
  String _baseUrl = '';
  String _username = '';
  String _password = '';
  String? _token;
  final _dio = Dio();

  /// 是否已初始化
  bool get isInitialized => _client != null;

  /// 初始化 WebDAV 客户端
  Future<void> init(String url, String username, String password) async {
    _logger.i("🔌 初始化 WebDAV 连接: $url");
    _baseUrl = url;
    _username = username;
    _password = password;

    _client = webdav.newClient(
      url,
      user: username,
      password: password,
      debug: false,
    );

    _client!.setConnectTimeout(10000); // 10秒超时

    // 尝试登录 Alist API 获取 Token
    await _login();
  }

  Future<void> _login() async {
    try {
      final response = await _dio.post(
        '$_baseUrl/api/auth/login',
        data: {'username': _username, 'password': _password},
      );
      if (response.statusCode == 200 && response.data['code'] == 200) {
        _token = response.data['data']['token'];
        _logger.i("✅ Alist API 登录成功，获取 Token");
      } else {
        _logger.w("⚠️ Alist API 登录失败: ${response.data['message']}");
      }
    } catch (e) {
      _logger.e("❌ Alist API 登录异常: $e");
    }
  }

  /// 获取文件的直链 (用于播放器)
  Future<String?> getDirectLink(String path) async {
    if (_token == null) {
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

    try {
      final response = await _dio.post(
        '$_baseUrl/api/fs/get',
        data: {'path': apiPath},
        options: Options(headers: {'Authorization': _token}),
      );
      if (response.statusCode == 200 && response.data['code'] == 200) {
        final rawUrl = response.data['data']['raw_url'];
        _logger.i("✅ 获取直链成功: $rawUrl");
        return rawUrl;
      } else {
        _logger.w("⚠️ 获取直链失败: ${response.data['message']}");
        return null;
      }
    } catch (e) {
      _logger.e("❌ 获取直链异常: $e");
      return null;
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
