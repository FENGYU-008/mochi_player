import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:logger/logger.dart';

import 'package:mochi_player/core/infrastructure/tmdb/proxy_config.dart';

class TmdbClient {
  static const String _defaultApiKey = String.fromEnvironment('TMDB_API_KEY');
  static const String _defaultBaseUrl = 'https://api.themoviedb.org/3';
  static const Duration _connectTimeout = Duration(seconds: 8);
  static const Duration _sendTimeout = Duration(seconds: 8);
  static const Duration _receiveTimeout = Duration(seconds: 12);

  TmdbClient({Dio? dio, Logger? logger})
    : _dio = dio ?? Dio(),
      _logger = logger ?? Logger(printer: PrettyPrinter(methodCount: 0)) {
    _dio.options
      ..connectTimeout = _connectTimeout
      ..sendTimeout = _sendTimeout
      ..receiveTimeout = _receiveTimeout;
    _configureHttpClient();
  }

  final Dio _dio;
  final Logger _logger;
  String _apiKey = _defaultApiKey;
  String _baseUrl = _defaultBaseUrl;
  String _proxyUrl = '';
  bool _proxyEnabled = true;

  bool get isConfigured => _apiKey.trim().isNotEmpty;

  void configure({String? apiKey, String? apiBaseUrl, String? proxyUrl, bool? proxyEnabled}) {
    final key = apiKey?.trim();
    if (key != null) _apiKey = key.isEmpty ? _defaultApiKey : key;
    final baseUrl = apiBaseUrl?.trim();
    if (baseUrl != null) {
      _baseUrl = baseUrl.isEmpty ? _defaultBaseUrl : baseUrl.replaceFirst(RegExp(r'/+$'), '');
    }
    if (proxyUrl != null) _proxyUrl = proxyUrl.trim();
    if (proxyEnabled != null) _proxyEnabled = proxyEnabled;
    _configureHttpClient();
  }

  Future<Map<String, dynamic>?> get(
    String path, {
    required String operation,
    Map<String, dynamic> queryParameters = const {},
    String? notFoundMessage,
  }) async {
    if (!isConfigured) {
      _logger.w('⚠️ 未配置 TMDB API Key，跳过: $operation');
      return null;
    }
    try {
      final response = await _dio.get<dynamic>(
        '$_baseUrl$path',
        queryParameters: {'api_key': _apiKey, 'language': 'zh-CN', ...queryParameters},
      );
      final data = response.data;
      return response.statusCode == 200 && data is Map<String, dynamic> ? data : null;
    } on DioException catch (error) {
      if (error.response?.statusCode == 404 && notFoundMessage != null) {
        _logger.w('⚠️ $notFoundMessage');
      } else {
        _logger.w('⚠️ $operation失败: ${_describeError(error)}');
      }
      return null;
    } catch (error) {
      _logger.w('⚠️ $operation失败: $error');
      return null;
    }
  }

  void _configureHttpClient() {
    final proxyConfig = _proxyEnabled && _proxyUrl.isNotEmpty ? ProxyConfig.buildHttpProxy(_proxyUrl) : null;
    if (_proxyEnabled && _proxyUrl.isNotEmpty && proxyConfig == null) {
      _logger.w('⚠️ TMDB 代理地址无效，已改为直连: $_proxyUrl');
    }
    _dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final client = HttpClient();
        client.findProxy = (_) => proxyConfig ?? 'DIRECT';
        return client;
      },
    );
  }

  String _describeError(DioException error) {
    return switch (error.type) {
      DioExceptionType.connectionTimeout => '连接超时（${_connectTimeout.inSeconds} 秒），请检查网络或代理',
      DioExceptionType.sendTimeout => '发送请求超时（${_sendTimeout.inSeconds} 秒）',
      DioExceptionType.receiveTimeout => '等待响应超时（${_receiveTimeout.inSeconds} 秒）',
      DioExceptionType.transformTimeout => '处理响应超时',
      DioExceptionType.badResponse => '服务器返回 ${error.response?.statusCode ?? '异常状态'}',
      DioExceptionType.connectionError => '网络连接失败，请检查 DNS、代理或防火墙',
      DioExceptionType.badCertificate => '证书校验失败',
      DioExceptionType.cancel => '请求已取消',
      DioExceptionType.unknown => error.message ?? '未知网络错误',
    };
  }
}
