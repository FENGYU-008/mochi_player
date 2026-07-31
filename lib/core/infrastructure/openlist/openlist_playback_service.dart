import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

/// Resolves playable media links through OpenList's HTTP API.
///
/// Authentication and token refresh live here independently from WebDAV
/// directory access because they use a different protocol and lifecycle.
class OpenListPlaybackService {
  static final OpenListPlaybackService _instance =
      OpenListPlaybackService._internal();

  factory OpenListPlaybackService() => _instance;

  OpenListPlaybackService._internal() {
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);
  }

  final _logger = Logger(printer: PrettyPrinter(methodCount: 0));
  final _dio = Dio();
  String _baseUrl = '';
  String _username = '';
  String _password = '';
  String? _token;
  Future<bool>? _tokenRefreshFuture;

  bool get isConfigured => _baseUrl.isNotEmpty;

  void configure(String url, String username, String password) {
    _baseUrl = url.trim().replaceFirst(RegExp(r'/+$'), '');
    _username = username.trim();
    _password = password;
    _token = null;
    _tokenRefreshFuture = null;
  }

  void clear() {
    _baseUrl = '';
    _username = '';
    _password = '';
    _token = null;
    _tokenRefreshFuture = null;
  }

  Future<String?> getDirectLink(String path) async {
    if (!isConfigured || !await _ensureToken()) {
      _logger.w('无法获取直链，因为 OpenList 尚未配置或登录失败');
      return null;
    }

    var apiPath = path;
    if (apiPath.startsWith('/dav')) {
      apiPath = apiPath.substring(4);
      if (apiPath.isEmpty) apiPath = '/';
    }

    var result = await _requestDirectLink(apiPath);
    if (!result.tokenInvalid) return result.url;

    _token = null;
    if (!await _ensureToken()) return null;
    result = await _requestDirectLink(apiPath);
    return result.url;
  }

  Future<bool> _login() async {
    try {
      final response = await _dio.post(
        '$_baseUrl/api/auth/login',
        data: {'username': _username, 'password': _password},
      );
      final data = response.data;
      final payload = data is Map ? data['data'] : null;
      final token = payload is Map ? payload['token'] : null;
      if (response.statusCode == 200 &&
          data is Map &&
          data['code'] == 200 &&
          token is String &&
          token.isNotEmpty) {
        _token = token;
        return true;
      }
      _logger.w('OpenList API 登录失败');
      return false;
    } catch (error) {
      _logger.e('OpenList API 登录异常: $error');
      return false;
    }
  }

  Future<bool> _ensureToken() {
    if (_token != null) return Future.value(true);
    return _tokenRefreshFuture ??= _login().whenComplete(() {
      _tokenRefreshFuture = null;
    });
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
      if (response.statusCode == 200 && apiCode == 200 && data is Map) {
        final payload = data['data'];
        final rawUrl = payload is Map ? payload['raw_url'] : null;
        if (rawUrl is String && rawUrl.isNotEmpty) {
          return _DirectLinkResult(url: rawUrl);
        }
      }
      _logger.w('获取 OpenList 直链失败');
      return _DirectLinkResult(tokenInvalid: tokenInvalid);
    } on DioException catch (error) {
      _logger.e('获取 OpenList 直链异常: $error');
      return _DirectLinkResult(tokenInvalid: error.response?.statusCode == 401);
    } catch (error) {
      _logger.e('获取 OpenList 直链异常: $error');
      return const _DirectLinkResult();
    }
  }
}

class _DirectLinkResult {
  final String? url;
  final bool tokenInvalid;

  const _DirectLinkResult({this.url, this.tokenInvalid = false});
}
