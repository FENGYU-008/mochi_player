import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:logger/logger.dart';
import '../models/entity/entities.dart';
import '../models/domain/trending_item.dart';
import '../utils/proxy_config.dart';

/// TMDB API 服务
/// 负责与 TMDB API 交互并返回解析后的 Entity 模型
class TmdbService {
  // --- 配置 ---
  static const String _defaultApiKey = String.fromEnvironment('TMDB_API_KEY');
  static const String _defaultApiBaseUrl = 'https://api.themoviedb.org/3';
  static const String _imageBaseUrl = 'https://image.tmdb.org/t/p/w500';
  static const String _backdropBaseUrl = 'https://image.tmdb.org/t/p/w1280';
  static const String _profileBaseUrl = 'https://image.tmdb.org/t/p/w185';
  static const String _logoBaseUrl = 'https://image.tmdb.org/t/p/w500';
  static const String _language = 'zh-CN';
  static const Duration _connectTimeout = Duration(seconds: 8);
  static const Duration _sendTimeout = Duration(seconds: 8);
  static const Duration _receiveTimeout = Duration(seconds: 12);

  final Dio _dio = Dio();
  final Logger _logger = Logger(printer: PrettyPrinter(methodCount: 0));
  String _apiKey = _defaultApiKey;
  String _apiBaseUrl = _defaultApiBaseUrl;
  String _proxyUrl = '';
  bool _proxyEnabled = true;

  // 单例模式
  static final TmdbService _instance = TmdbService._internal();

  factory TmdbService({String? apiKey}) {
    if (apiKey != null) {
      _instance.configureApiKey(apiKey);
    }
    return _instance;
  }

  TmdbService._internal() {
    _dio.options.connectTimeout = _connectTimeout;
    _dio.options.receiveTimeout = _receiveTimeout;
    _dio.options.sendTimeout = _sendTimeout;
    _configureHttpClient();
  }

  bool get isConfigured => _apiKey.trim().isNotEmpty;

  void configureApiKey(String apiKey) {
    configure(apiKey: apiKey);
  }

  void configure({
    String? apiKey,
    String? apiBaseUrl,
    String? proxyUrl,
    bool? proxyEnabled,
  }) {
    final trimmedApiKey = apiKey?.trim();
    if (trimmedApiKey != null) {
      _apiKey = trimmedApiKey.isNotEmpty ? trimmedApiKey : _defaultApiKey;
    }

    final trimmedApiBaseUrl = apiBaseUrl?.trim();
    if (trimmedApiBaseUrl != null) {
      _apiBaseUrl = trimmedApiBaseUrl.isNotEmpty
          ? _normalizeBaseUrl(trimmedApiBaseUrl)
          : _defaultApiBaseUrl;
    }

    final trimmedProxyUrl = proxyUrl?.trim();
    if (trimmedProxyUrl != null) {
      _proxyUrl = trimmedProxyUrl;
    }

    if (proxyEnabled != null) {
      _proxyEnabled = proxyEnabled;
    }

    _configureHttpClient();
  }

  // ===== 公开 API =====

  /// 搜索并获取电影完整元数据
  Future<MovieMetadataEntity?> fetchMovie(String title, {int? year}) async {
    final searchData = await _search('/search/movie', title, year: year);
    if (searchData == null) return null;

    final movieId = searchData['id'] as int;
    return await fetchMovieById(movieId);
  }

  /// 根据 ID 获取电影元数据
  Future<MovieMetadataEntity?> fetchMovieById(int movieId) async {
    if (!_requireApiKey('获取电影详情')) return null;

    try {
      final response = await _dio.get(
        '$_apiBaseUrl/movie/$movieId',
        queryParameters: {
          'api_key': _apiKey,
          'language': _language,
          'append_to_response': 'credits,release_dates,images',
          'include_image_language': 'zh,en,null',
        },
      );

      if (response.statusCode == 200) {
        return _parseMovieEntity(response.data);
      }
    } catch (e) {
      _logger.w("⚠️ TMDB 获取电影详情失败: ID:$movieId - ${_describeError(e)}");
    }
    return null;
  }

  /// 搜索并获取剧集完整元数据
  Future<TVShowMetadataEntity?> fetchTVShow(String title, {int? year}) async {
    final searchData = await _search(
      '/search/tv',
      title,
      year: year,
      yearKey: 'first_air_date_year',
    );
    if (searchData == null) return null;

    final tvId = searchData['id'] as int;
    return await fetchTVShowById(tvId);
  }

  /// 根据 ID 获取剧集元数据
  Future<TVShowMetadataEntity?> fetchTVShowById(int tvId) async {
    if (!_requireApiKey('获取剧集详情')) return null;

    try {
      final response = await _dio.get(
        '$_apiBaseUrl/tv/$tvId',
        queryParameters: {
          'api_key': _apiKey,
          'language': _language,
          'append_to_response': 'credits,content_ratings,images',
          'include_image_language': 'zh,en,null',
        },
      );

      if (response.statusCode == 200) {
        return _parseTVShowEntity(response.data);
      }
    } catch (e) {
      _logger.w("⚠️ TMDB 获取剧集详情失败: ID:$tvId - ${_describeError(e)}");
    }
    return null;
  }

  /// 获取季详情（包含所有集）
  Future<SeasonMetadataEntity?> fetchSeason(
    int tvId,
    int seasonNumber, {
    required String showTmdbId,
  }) async {
    if (!_requireApiKey('获取季详情')) return null;

    try {
      final response = await _dio.get(
        '$_apiBaseUrl/tv/$tvId/season/$seasonNumber',
        queryParameters: {'api_key': _apiKey, 'language': _language},
      );

      if (response.statusCode == 200) {
        return _parseSeasonEntity(response.data, showTmdbId, seasonNumber);
      }
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 404) {
        _logger.w("⚠️ TMDB 未找到季详情: ID:$tvId S$seasonNumber");
      } else {
        _logger.e(
          "❌ TMDB 获取季详情异常: ID:$tvId S$seasonNumber - ${_describeError(e)}",
        );
      }
    }
    return null;
  }

  /// 获取季原始数据（用于解析集）
  Future<Map<String, dynamic>?> fetchSeasonRaw(
    int tvId,
    int seasonNumber,
  ) async {
    if (!_requireApiKey('获取季原始数据')) return null;

    try {
      final response = await _dio.get(
        '$_apiBaseUrl/tv/$tvId/season/$seasonNumber',
        queryParameters: {'api_key': _apiKey, 'language': _language},
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
    } catch (e) {
      _logger.w(
        "⚠️ TMDB 获取季原始数据失败: ID:$tvId S$seasonNumber - ${_describeError(e)}",
      );
    }
    return null;
  }

  /// 获取热门趋势内容（电影和剧集混合）
  /// [timeWindow] 可选 'day' 或 'week'
  /// 返回包含 movie 和 tv 类型的原始数据列表
  Future<List<Map<String, dynamic>>> fetchTrending({
    String timeWindow = 'week',
    int limit = 20,
  }) async {
    if (!_requireApiKey('获取热门趋势')) return [];

    try {
      final response = await _dio.get(
        '$_apiBaseUrl/trending/all/$timeWindow',
        queryParameters: {'api_key': _apiKey, 'language': _language},
      );

      if (response.statusCode == 200) {
        final results = response.data['results'] as List;
        // 过滤只保留 movie 和 tv，限制数量
        return results
            .where(
              (item) =>
                  item['media_type'] == 'movie' || item['media_type'] == 'tv',
            )
            .take(limit)
            .map((item) => item as Map<String, dynamic>)
            .toList();
      }
    } catch (e) {
      _logger.w('⚠️ TMDB 获取热门趋势失败: ${_describeError(e)}');
    }
    return [];
  }

  /// 将热门趋势的原始数据转换为简化的展示模型
  TrendingItem parseTrendingItem(
    Map<String, dynamic> data, {
    bool? forceMovie,
  }) {
    final isMovie = forceMovie ?? (data['media_type'] == 'movie');
    return TrendingItem(
      tmdbId: data['id'].toString(),
      title: isMovie ? (data['title'] ?? '') : (data['name'] ?? ''),
      posterUrl: buildPosterUrl(data['poster_path']),
      backdropUrl: buildBackdropUrl(data['backdrop_path']),
      overview: data['overview'],
      rating: (data['vote_average'] ?? 0.0).toDouble(),
      releaseYear: _parseYear(
        isMovie ? data['release_date'] : data['first_air_date'],
      ),
      genres: _parseGenreNames(data['genre_ids']),
      isMovie: isMovie,
    );
  }

  /// 获取热门电影（仅电影）
  Future<List<TrendingItem>> fetchTrendingMovies({int limit = 3}) async {
    if (!_requireApiKey('获取热门电影')) return [];

    try {
      final response = await _dio.get(
        '$_apiBaseUrl/trending/movie/week',
        queryParameters: {'api_key': _apiKey, 'language': _language},
      );
      if (response.statusCode == 200) {
        return _parseTrendingList(response.data, isMovie: true, limit: limit);
      }
    } catch (e) {
      _logger.w('⚠️ TMDB 获取热门电影失败: ${_describeError(e)}');
    }
    return [];
  }

  /// 获取热门剧集（仅 TV）
  Future<List<TrendingItem>> fetchTrendingTV({int limit = 3}) async {
    if (!_requireApiKey('获取热门剧集')) return [];

    try {
      final response = await _dio.get(
        '$_apiBaseUrl/trending/tv/week',
        queryParameters: {'api_key': _apiKey, 'language': _language},
      );
      if (response.statusCode == 200) {
        return _parseTrendingList(response.data, isMovie: false, limit: limit);
      }
    } catch (e) {
      _logger.w('⚠️ TMDB 获取热门剧集失败: ${_describeError(e)}');
    }
    return [];
  }

  /// 获取高分佳作（电影）
  Future<List<TrendingItem>> fetchTopRated({int limit = 3}) async {
    if (!_requireApiKey('获取高分佳作')) return [];

    try {
      final response = await _dio.get(
        '$_apiBaseUrl/movie/top_rated',
        queryParameters: {'api_key': _apiKey, 'language': _language},
      );
      if (response.statusCode == 200) {
        return _parseTrendingList(response.data, isMovie: true, limit: limit);
      }
    } catch (e) {
      _logger.w('⚠️ TMDB 获取高分佳作失败: ${_describeError(e)}');
    }
    return [];
  }

  /// 解析趋势列表数据
  List<TrendingItem> _parseTrendingList(
    Map<String, dynamic> data, {
    required bool isMovie,
    required int limit,
  }) {
    final results = data['results'] as List? ?? [];
    return results
        .take(limit)
        .map(
          (item) => parseTrendingItem(
            item as Map<String, dynamic>,
            forceMovie: isMovie,
          ),
        )
        .toList();
  }

  /// 从 genre_ids 解析类型名称
  List<String> _parseGenreNames(List<dynamic>? genreIds) {
    if (genreIds == null || genreIds.isEmpty) return [];
    // 常见类型 ID 映射（简化版本）
    const genreMap = {
      28: 'Action', 12: 'Adventure', 16: 'Animation', 35: 'Comedy',
      80: 'Crime', 99: 'Documentary', 18: 'Drama', 10751: 'Family',
      14: 'Fantasy', 36: 'History', 27: 'Horror', 10402: 'Music',
      9648: 'Mystery', 10749: 'Romance', 878: 'Sci-Fi', 10770: 'TV Movie',
      53: 'Thriller', 10752: 'War', 37: 'Western',
      // TV genres
      10759: 'Action', 10762: 'Kids', 10763: 'News', 10764: 'Reality',
      10765: 'Sci-Fi', 10766: 'Soap', 10767: 'Talk', 10768: 'Politics',
    };
    return genreIds
        .take(2)
        .map((id) => genreMap[id] ?? '')
        .where((name) => name.isNotEmpty)
        .toList();
  }

  // ===== 图片 URL 构建 =====

  static String? buildPosterUrl(String? path) {
    if (path == null || path.isEmpty) return null;
    return '$_imageBaseUrl$path';
  }

  static String? buildBackdropUrl(String? path) {
    if (path == null || path.isEmpty) return null;
    return '$_backdropBaseUrl$path';
  }

  static String? buildProfileUrl(String? path) {
    if (path == null || path.isEmpty) return null;
    return '$_profileBaseUrl$path';
  }

  static String? buildLogoUrl(String? path) {
    if (path == null || path.isEmpty) return null;
    return '$_logoBaseUrl$path';
  }

  // ===== 私有方法：API 请求 =====

  Future<Map<String, dynamic>?> _search(
    String endpoint,
    String query, {
    int? year,
    String yearKey = 'year',
  }) async {
    if (!_requireApiKey('搜索 TMDB')) return null;

    try {
      final queryParams = <String, dynamic>{
        'api_key': _apiKey,
        'language': _language,
        'query': query,
        'include_adult': false,
      };

      if (year != null) {
        queryParams[yearKey] = year;
      }

      final response = await _dio.get(
        '$_apiBaseUrl$endpoint',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final results = response.data['results'] as List;
        if (results.isNotEmpty) {
          return _pickBestSearchResult(results, query, endpoint);
        }
      }
    } catch (e) {
      _logger.w("⚠️ TMDB 搜索失败: $query ($year) - ${_describeError(e)}");
    }
    return null;
  }

  Map<String, dynamic> _pickBestSearchResult(
    List<dynamic> results,
    String query,
    String endpoint,
  ) {
    final isTV = endpoint.contains('/tv');
    Map<String, dynamic>? best;
    var bestScore = double.negativeInfinity;

    for (final item in results) {
      if (item is! Map<String, dynamic>) continue;

      final score = _scoreSearchResult(item, query, isTV: isTV);
      if (score > bestScore) {
        best = item;
        bestScore = score;
      }
    }

    return best ?? results.first as Map<String, dynamic>;
  }

  double _scoreSearchResult(
    Map<String, dynamic> item,
    String query, {
    required bool isTV,
  }) {
    final title = (isTV ? item['name'] : item['title'])?.toString() ?? '';
    final originalTitle =
        (isTV ? item['original_name'] : item['original_title'])?.toString() ??
        '';
    final queryKey = _normalizeSearchText(query);
    final titleKey = _normalizeSearchText(title);
    final originalTitleKey = _normalizeSearchText(originalTitle);

    final titleScore = _titleSimilarityScore(queryKey, titleKey);
    final originalTitleScore = _titleSimilarityScore(
      queryKey,
      originalTitleKey,
    );

    var score = titleScore > originalTitleScore
        ? titleScore + originalTitleScore * 0.15
        : originalTitleScore + titleScore * 0.15;

    if (item['poster_path'] != null) score += 3;
    final popularity = (item['popularity'] as num?)?.toDouble() ?? 0;
    score += popularity.clamp(0, 80) / 20;

    return score;
  }

  double _titleSimilarityScore(String query, String candidate) {
    if (query.isEmpty || candidate.isEmpty) return 0;
    if (query == candidate) return 120;

    if (candidate.contains(query) || query.contains(candidate)) {
      final shortest = query.length < candidate.length
          ? query.length
          : candidate.length;
      final longest = query.length > candidate.length
          ? query.length
          : candidate.length;
      final ratio = shortest / longest;
      if (ratio >= 0.65) return 76;
      if (ratio >= 0.4) return 48;
      return 18;
    }

    final queryTokens = _tokenizeSearchText(query);
    final candidateTokens = _tokenizeSearchText(candidate);
    if (queryTokens.isEmpty || candidateTokens.isEmpty) return 0;

    final intersection = queryTokens.intersection(candidateTokens).length;
    final union = queryTokens.union(candidateTokens).length;
    if (union == 0) return 0;

    return (intersection / union) * 55;
  }

  String _normalizeSearchText(String value) {
    return value
        .toLowerCase()
        .replaceAll(RegExp(r'[\u3000\s._\-:：，。/\\\(\)\[\]【】]+'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  Set<String> _tokenizeSearchText(String value) {
    final tokens = value
        .split(' ')
        .map((token) => token.trim())
        .where((token) => token.isNotEmpty)
        .toSet();

    final cjk = RegExp(r'[\u4e00-\u9fff\u3400-\u4dbf]+')
        .allMatches(value)
        .map((match) => match.group(0)!)
        .where((token) => token.isNotEmpty);

    return {...tokens, ...cjk};
  }

  bool _requireApiKey(String operation) {
    if (isConfigured) return true;
    _logger.w('⚠️ 未配置 TMDB API Key，跳过: $operation');
    return false;
  }

  void _configureHttpClient() {
    final proxyConfig = _proxyEnabled ? _buildProxyConfig(_proxyUrl) : null;
    _dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final client = HttpClient();
        client.findProxy = (uri) {
          if (proxyConfig != null) return proxyConfig;
          return 'DIRECT';
        };
        return client;
      },
    );
  }

  String _normalizeBaseUrl(String url) {
    return url.replaceFirst(RegExp(r'/+$'), '');
  }

  String? _buildProxyConfig(String proxyUrl) {
    if (proxyUrl.trim().isEmpty) return null;

    final proxyConfig = ProxyConfig.buildHttpProxy(proxyUrl);
    if (proxyConfig == null) {
      _logger.w('⚠️ TMDB 代理地址无效，已改为直连: $proxyUrl');
    }

    return proxyConfig;
  }

  String _describeError(Object error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
          return '连接超时（${_connectTimeout.inSeconds} 秒），请检查网络或代理';
        case DioExceptionType.sendTimeout:
          return '发送请求超时（${_sendTimeout.inSeconds} 秒）';
        case DioExceptionType.receiveTimeout:
          return '等待响应超时（${_receiveTimeout.inSeconds} 秒）';
        case DioExceptionType.badResponse:
          return '服务器返回 ${error.response?.statusCode ?? '异常状态'}';
        case DioExceptionType.connectionError:
          return '网络连接失败，请检查 DNS、代理或防火墙';
        case DioExceptionType.badCertificate:
          return '证书校验失败';
        case DioExceptionType.cancel:
          return '请求已取消';
        case DioExceptionType.unknown:
          return error.message ?? '未知网络错误';
      }
    }
    return error.toString();
  }

  // ===== 私有方法：Entity 解析 =====

  MovieMetadataEntity _parseMovieEntity(Map<String, dynamic> data) {
    return MovieMetadataEntity()
      ..tmdbId = data['id'].toString()
      ..title = data['title'] ?? ''
      ..originalTitle = data['original_title']
      ..releaseYear = _parseYear(data['release_date'])
      ..releaseDate = _parseDate(data['release_date'])
      ..posterUrl = buildPosterUrl(data['poster_path'])
      ..backdropUrl = buildBackdropUrl(data['backdrop_path'])
      ..overview = data['overview']
      ..certification = _parseCertification(data['release_dates'])
      ..rating = (data['vote_average'] ?? 0.0).toDouble()
      ..genres = _parseGenres(data['genres'])
      ..cast = _parseCast(data['credits'])
      ..logoUrl = _parseLogoUrl(data['images']);
  }

  TVShowMetadataEntity _parseTVShowEntity(Map<String, dynamic> data) {
    return TVShowMetadataEntity()
      ..tmdbId = data['id'].toString()
      ..title = data['name'] ?? ''
      ..originalTitle = data['original_name']
      ..releaseYear = _parseYear(data['first_air_date'])
      ..firstAirDate = _parseDate(data['first_air_date'])
      ..posterUrl = buildPosterUrl(data['poster_path'])
      ..backdropUrl = buildBackdropUrl(data['backdrop_path'])
      ..overview = data['overview']
      ..certification = _parseTvCertification(data['content_ratings'])
      ..rating = (data['vote_average'] ?? 0.0).toDouble()
      ..genres = _parseGenres(data['genres'])
      ..cast = _parseCast(data['credits'])
      ..logoUrl = _parseLogoUrl(data['images'])
      ..status = data['status']
      ..numberOfSeasons = data['number_of_seasons']
      ..numberOfEpisodes = data['number_of_episodes'];
  }

  SeasonMetadataEntity _parseSeasonEntity(
    Map<String, dynamic> data,
    String showTmdbId,
    int seasonNumber,
  ) {
    final seasonKey = '${showTmdbId}_s$seasonNumber';
    final episodesData = data['episodes'] as List? ?? [];

    return SeasonMetadataEntity()
      ..seasonKey = seasonKey
      ..seasonNumber = seasonNumber
      ..title = data['name'] ?? '第 $seasonNumber 季'
      ..posterUrl = buildPosterUrl(data['poster_path'])
      ..overview = data['overview']
      ..numberOfEpisodes = episodesData.length;
  }

  /// 解析单集数据
  EpisodeMetadataEntity parseEpisodeEntity(
    Map<String, dynamic> data,
    String showTmdbId,
    int seasonNumber,
  ) {
    final epNum = data['episode_number'] as int;
    final epTmdbId = '${showTmdbId}_s${seasonNumber}e$epNum';

    return EpisodeMetadataEntity()
      ..tmdbId = epTmdbId
      ..episodeNumber = epNum
      ..title = data['name'] ?? 'Episode $epNum'
      ..airDate = _parseDate(data['air_date'])
      ..overview = data['overview']
      ..stillUrl = buildBackdropUrl(data['still_path'])
      ..guestStars = _parseGuestStars(data['guest_stars']);
  }

  // ===== 私有方法：数据解析 =====

  int? _parseYear(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return null;
    return int.tryParse(dateStr.split('-').first);
  }

  DateTime? _parseDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return null;
    return DateTime.tryParse(dateStr);
  }

  List<String> _parseGenres(List<dynamic>? genres) {
    if (genres == null) return [];
    return genres.map((g) => g['name'].toString()).toList();
  }

  List<ArtistEmbedded> _parseCast(Map<String, dynamic>? credits) {
    if (credits == null || credits['cast'] == null) return [];
    final castList = credits['cast'] as List;
    return castList.take(10).map((c) {
      return ArtistEmbedded()
        ..tmdbId = c['id']?.toString()
        ..name = c['name'] ?? '未知'
        ..character = c['character']
        ..profileUrl = buildProfileUrl(c['profile_path']);
    }).toList();
  }

  /// 解析 Logo URL，优先选择中文 Logo
  String? _parseLogoUrl(Map<String, dynamic>? images) {
    if (images == null) return null;
    final logos = images['logos'] as List?;
    if (logos == null || logos.isEmpty) return null;

    // 优先级: zh > en > null (无语言标记)
    final priorities = ['zh', 'en', null];
    for (final lang in priorities) {
      final logo = logos.firstWhere(
        (l) => l['iso_639_1'] == lang,
        orElse: () => null,
      );
      if (logo != null && logo['file_path'] != null) {
        return buildLogoUrl(logo['file_path']);
      }
    }
    // 如果都没找到，返回第一个
    if (logos.first['file_path'] != null) {
      return buildLogoUrl(logos.first['file_path']);
    }
    return null;
  }

  List<ArtistEmbedded> _parseGuestStars(List<dynamic>? guests) {
    if (guests == null) return [];
    return guests.take(5).map((g) {
      return ArtistEmbedded()
        ..tmdbId = g['id']?.toString()
        ..name = g['name'] ?? '未知'
        ..character = g['character']
        ..profileUrl = buildProfileUrl(g['profile_path']);
    }).toList();
  }

  String? _parseCertification(Map<String, dynamic>? releaseDates) {
    if (releaseDates == null) return null;
    final results = releaseDates['results'] as List?;
    if (results == null || results.isEmpty) return null;

    // 优先查找 US 或 CN 的分级
    final targetIso = ['US', 'CN'];
    for (final iso in targetIso) {
      final countryData = results.firstWhere(
        (element) => element['iso_3166_1'] == iso,
        orElse: () => null,
      );
      if (countryData != null) {
        final dates = countryData['release_dates'] as List?;
        if (dates != null && dates.isNotEmpty) {
          // 找第一个非空的 certification
          final cert = dates.firstWhere(
            (d) =>
                d['certification'] != null &&
                d['certification'].toString().isNotEmpty,
            orElse: () => null,
          );
          if (cert != null) {
            return cert['certification'].toString();
          }
        }
      }
    }
    return null;
  }

  String? _parseTvCertification(Map<String, dynamic>? contentRatings) {
    if (contentRatings == null) return null;
    final results = contentRatings['results'] as List?;
    if (results == null || results.isEmpty) return null;

    final targetIso = ['US', 'CN'];
    for (final iso in targetIso) {
      final countryData = results.firstWhere(
        (element) => element['iso_3166_1'] == iso,
        orElse: () => null,
      );
      if (countryData != null) {
        final rating = countryData['rating'] as String?;
        if (rating != null && rating.isNotEmpty) {
          return rating;
        }
      }
    }
    return null;
  }
}
