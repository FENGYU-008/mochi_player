import 'package:shared_preferences/shared_preferences.dart';

class AppSettings {
  final String webDavUrl;
  final String webDavUsername;
  final String webDavPassword;
  final String tmdbApiKey;
  final String tmdbApiBaseUrl;
  final String tmdbProxyUrl;

  const AppSettings({
    this.webDavUrl = '',
    this.webDavUsername = '',
    this.webDavPassword = '',
    this.tmdbApiKey = '',
    this.tmdbApiBaseUrl = '',
    this.tmdbProxyUrl = '',
  });

  bool get hasWebDavConfig =>
      webDavUrl.trim().isNotEmpty &&
      webDavUsername.trim().isNotEmpty &&
      webDavPassword.isNotEmpty;

  bool get hasTmdbApiKey => tmdbApiKey.trim().isNotEmpty;

  AppSettings withFallbacks(AppSettings fallback) {
    return AppSettings(
      webDavUrl: webDavUrl.trim().isNotEmpty ? webDavUrl : fallback.webDavUrl,
      webDavUsername: webDavUsername.trim().isNotEmpty
          ? webDavUsername
          : fallback.webDavUsername,
      webDavPassword: webDavPassword.isNotEmpty
          ? webDavPassword
          : fallback.webDavPassword,
      tmdbApiKey: tmdbApiKey.trim().isNotEmpty
          ? tmdbApiKey
          : fallback.tmdbApiKey,
      tmdbApiBaseUrl: tmdbApiBaseUrl.trim().isNotEmpty
          ? tmdbApiBaseUrl
          : fallback.tmdbApiBaseUrl,
      tmdbProxyUrl: tmdbProxyUrl.trim(),
    );
  }
}

class AppSettingsService {
  static const _webDavUrlKey = 'webdav_url';
  static const _webDavUsernameKey = 'webdav_username';
  static const _webDavPasswordKey = 'webdav_password';
  static const _tmdbApiKeyKey = 'tmdb_api_key';
  static const _tmdbApiBaseUrlKey = 'tmdb_api_base_url';
  static const _tmdbProxyUrlKey = 'tmdb_proxy_url';
  static const _testDefaults = AppSettings(
    webDavUrl: String.fromEnvironment(
      'WEBDAV_URL',
      defaultValue: 'http://127.0.0.1:5244',
    ),
    webDavUsername: String.fromEnvironment(
      'WEBDAV_USERNAME',
      defaultValue: 'admin',
    ),
    webDavPassword: String.fromEnvironment(
      'WEBDAV_PASSWORD',
      defaultValue: '12345678',
    ),
    tmdbApiKey: String.fromEnvironment(
      'TMDB_API_KEY',
      defaultValue: '8f256bccbacc37341c6f01aa1e35af29',
    ),
    tmdbApiBaseUrl: String.fromEnvironment(
      'TMDB_API_BASE_URL',
      defaultValue: 'https://api.themoviedb.org/3',
    ),
    tmdbProxyUrl: String.fromEnvironment(
      'TMDB_PROXY_URL',
      defaultValue: 'http://127.0.0.1:7890',
    ),
  );

  static final AppSettingsService _instance = AppSettingsService._internal();

  factory AppSettingsService() => _instance;

  AppSettingsService._internal();

  Future<AppSettings> load() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSavedProxyUrl = prefs.containsKey(_tmdbProxyUrlKey);
    final savedSettings = AppSettings(
      webDavUrl: prefs.getString(_webDavUrlKey) ?? '',
      webDavUsername: prefs.getString(_webDavUsernameKey) ?? '',
      webDavPassword: prefs.getString(_webDavPasswordKey) ?? '',
      tmdbApiKey: prefs.getString(_tmdbApiKeyKey) ?? '',
      tmdbApiBaseUrl: prefs.getString(_tmdbApiBaseUrlKey) ?? '',
      tmdbProxyUrl: hasSavedProxyUrl
          ? prefs.getString(_tmdbProxyUrlKey) ?? ''
          : _testDefaults.tmdbProxyUrl,
    );

    return savedSettings.withFallbacks(_testDefaults);
  }

  Future<AppSettings> save(AppSettings settings) async {
    final settingsToSave = settings.withFallbacks(_testDefaults);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_webDavUrlKey, settingsToSave.webDavUrl.trim());
    await prefs.setString(
      _webDavUsernameKey,
      settingsToSave.webDavUsername.trim(),
    );
    await prefs.setString(_webDavPasswordKey, settingsToSave.webDavPassword);
    await prefs.setString(_tmdbApiKeyKey, settingsToSave.tmdbApiKey.trim());
    await prefs.setString(
      _tmdbApiBaseUrlKey,
      settingsToSave.tmdbApiBaseUrl.trim(),
    );
    await prefs.setString(_tmdbProxyUrlKey, settings.tmdbProxyUrl.trim());
    return settingsToSave;
  }
}
