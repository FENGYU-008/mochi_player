import 'package:shared_preferences/shared_preferences.dart';

class AppSettings {
  static const defaultPlaybackCacheSizeMb = 256;
  static const defaultPlaybackReadaheadSeconds = 60;
  static const minPlaybackCacheSizeMb = 16;
  static const maxPlaybackCacheSizeMb = 4096;
  static const minPlaybackReadaheadSeconds = 5;
  static const maxPlaybackReadaheadSeconds = 1800;
  static const defaultEnableHardwareAcceleration = true;
  static const defaultAudioLanguagePriority = 'zh,chi,zho,jpn,ja,eng';
  static const defaultSubtitleLanguagePriority = 'zh,chi,zho,chs,cht,eng';
  static const defaultSubtitleFontSize = 24.0;

  final String webDavUrl;
  final String webDavUsername;
  final String webDavPassword;
  final String tmdbApiKey;
  final String tmdbApiBaseUrl;
  final String tmdbProxyUrl;
  final int playbackCacheSizeMb;
  final int playbackReadaheadSeconds;
  final bool enableHardwareAcceleration;
  final String audioLanguagePriority;
  final String subtitleLanguagePriority;
  final double subtitleFontSize;

  const AppSettings({
    this.webDavUrl = '',
    this.webDavUsername = '',
    this.webDavPassword = '',
    this.tmdbApiKey = '',
    this.tmdbApiBaseUrl = '',
    this.tmdbProxyUrl = '',
    this.playbackCacheSizeMb = defaultPlaybackCacheSizeMb,
    this.playbackReadaheadSeconds = defaultPlaybackReadaheadSeconds,
    this.enableHardwareAcceleration = defaultEnableHardwareAcceleration,
    this.audioLanguagePriority = defaultAudioLanguagePriority,
    this.subtitleLanguagePriority = defaultSubtitleLanguagePriority,
    this.subtitleFontSize = defaultSubtitleFontSize,
  });

  bool get hasWebDavConfig =>
      webDavUrl.trim().isNotEmpty &&
      webDavUsername.trim().isNotEmpty &&
      webDavPassword.isNotEmpty;

  bool get hasTmdbApiKey => tmdbApiKey.trim().isNotEmpty;

  int get playbackCacheMaxBytes => playbackCacheSizeMb * 1024 * 1024;

  String get normalizedAudioLanguagePriority => _normalizeLanguagePriority(
    audioLanguagePriority,
    defaultAudioLanguagePriority,
  );

  String get normalizedSubtitleLanguagePriority => _normalizeLanguagePriority(
    subtitleLanguagePriority,
    defaultSubtitleLanguagePriority,
  );

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
      playbackCacheSizeMb: playbackCacheSizeMb
          .clamp(minPlaybackCacheSizeMb, maxPlaybackCacheSizeMb)
          .toInt(),
      playbackReadaheadSeconds: playbackReadaheadSeconds
          .clamp(minPlaybackReadaheadSeconds, maxPlaybackReadaheadSeconds)
          .toInt(),
      enableHardwareAcceleration: enableHardwareAcceleration,
      audioLanguagePriority: _normalizeLanguagePriority(
        audioLanguagePriority,
        fallback.audioLanguagePriority,
      ),
      subtitleLanguagePriority: _normalizeLanguagePriority(
        subtitleLanguagePriority,
        fallback.subtitleLanguagePriority,
      ),
      subtitleFontSize: subtitleFontSize.clamp(18.0, 40.0).toDouble(),
    );
  }

  static String _normalizeLanguagePriority(String value, String fallback) {
    final parts = value
        .split(',')
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return fallback;
    return parts.join(',');
  }
}

class AppSettingsService {
  static const _webDavUrlKey = 'webdav_url';
  static const _webDavUsernameKey = 'webdav_username';
  static const _webDavPasswordKey = 'webdav_password';
  static const _tmdbApiKeyKey = 'tmdb_api_key';
  static const _tmdbApiBaseUrlKey = 'tmdb_api_base_url';
  static const _tmdbProxyUrlKey = 'tmdb_proxy_url';
  static const _playbackCacheSizeMbKey = 'playback_cache_size_mb';
  static const _playbackReadaheadSecondsKey = 'playback_readahead_seconds';
  static const _enableHardwareAccelerationKey = 'enable_hardware_acceleration';
  static const _audioLanguagePriorityKey = 'audio_language_priority';
  static const _subtitleLanguagePriorityKey = 'subtitle_language_priority';
  static const _subtitleFontSizeKey = 'subtitle_font_size';
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
      playbackCacheSizeMb:
          prefs.getInt(_playbackCacheSizeMbKey) ??
          AppSettings.defaultPlaybackCacheSizeMb,
      playbackReadaheadSeconds:
          prefs.getInt(_playbackReadaheadSecondsKey) ??
          AppSettings.defaultPlaybackReadaheadSeconds,
      enableHardwareAcceleration:
          prefs.getBool(_enableHardwareAccelerationKey) ??
          AppSettings.defaultEnableHardwareAcceleration,
      audioLanguagePriority:
          prefs.getString(_audioLanguagePriorityKey) ??
          AppSettings.defaultAudioLanguagePriority,
      subtitleLanguagePriority:
          prefs.getString(_subtitleLanguagePriorityKey) ??
          AppSettings.defaultSubtitleLanguagePriority,
      subtitleFontSize:
          prefs.getDouble(_subtitleFontSizeKey) ??
          AppSettings.defaultSubtitleFontSize,
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
    await prefs.setInt(
      _playbackCacheSizeMbKey,
      settingsToSave.playbackCacheSizeMb,
    );
    await prefs.setInt(
      _playbackReadaheadSecondsKey,
      settingsToSave.playbackReadaheadSeconds,
    );
    await prefs.setBool(
      _enableHardwareAccelerationKey,
      settingsToSave.enableHardwareAcceleration,
    );
    await prefs.setString(
      _audioLanguagePriorityKey,
      settingsToSave.audioLanguagePriority,
    );
    await prefs.setString(
      _subtitleLanguagePriorityKey,
      settingsToSave.subtitleLanguagePriority,
    );
    await prefs.setDouble(
      _subtitleFontSizeKey,
      settingsToSave.subtitleFontSize,
    );
    return settingsToSave;
  }
}
