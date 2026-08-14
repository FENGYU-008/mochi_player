import 'package:shared_preferences/shared_preferences.dart';
import 'package:mochi_player/features/settings/domain/app_settings.dart';

class AppSettingsService {
  static const _webDavUrlKey = 'webdav_url';
  static const _webDavUsernameKey = 'webdav_username';
  static const _webDavPasswordKey = 'webdav_password';
  static const _tmdbApiKeyKey = 'tmdb_api_key';
  static const _tmdbApiBaseUrlKey = 'tmdb_api_base_url';
  static const _tmdbProxyUrlKey = 'tmdb_proxy_url';
  static const _tmdbProxyEnabledKey = 'tmdb_proxy_enabled';
  static const _playbackCacheSizeMbKey = 'playback_cache_size_mb';
  static const _playbackReadaheadSecondsKey = 'playback_readahead_seconds';
  static const _enableHardwareAccelerationKey = 'enable_hardware_acceleration';
  static const _subtitleLanguagePriorityKey = 'subtitle_language_priority';
  static const _subtitleFontSizeKey = 'subtitle_font_size';
  static final AppSettingsService _instance = AppSettingsService._internal();

  factory AppSettingsService() => _instance;

  AppSettingsService._internal();

  Future<AppSettings> load() async {
    final prefs = await SharedPreferences.getInstance();
    return AppSettings(
      webDavUrl: prefs.getString(_webDavUrlKey) ?? '',
      webDavUsername: prefs.getString(_webDavUsernameKey) ?? '',
      webDavPassword: prefs.getString(_webDavPasswordKey) ?? '',
      tmdbApiKey: prefs.getString(_tmdbApiKeyKey) ?? '',
      tmdbApiBaseUrl: prefs.getString(_tmdbApiBaseUrlKey) ?? '',
      tmdbProxyUrl: prefs.getString(_tmdbProxyUrlKey) ?? '',
      tmdbProxyEnabled:
          prefs.getBool(_tmdbProxyEnabledKey) ??
          AppSettings.defaultTmdbProxyEnabled,
      playbackCacheSizeMb:
          prefs.getInt(_playbackCacheSizeMbKey) ??
          AppSettings.defaultPlaybackCacheSizeMb,
      playbackReadaheadSeconds:
          prefs.getInt(_playbackReadaheadSecondsKey) ??
          AppSettings.defaultPlaybackReadaheadSeconds,
      enableHardwareAcceleration:
          prefs.getBool(_enableHardwareAccelerationKey) ??
          AppSettings.defaultEnableHardwareAcceleration,
      subtitleLanguagePriority:
          prefs.getString(_subtitleLanguagePriorityKey) ??
          AppSettings.defaultSubtitleLanguagePriority,
      subtitleFontSize:
          prefs.getDouble(_subtitleFontSizeKey) ??
          AppSettings.defaultSubtitleFontSize,
    );
  }

  Future<AppSettings> save(AppSettings settings) async {
    final settingsToSave = AppSettings(
      webDavUrl: settings.webDavUrl.trim(),
      webDavUsername: settings.webDavUsername.trim(),
      webDavPassword: settings.webDavPassword,
      tmdbApiKey: settings.tmdbApiKey.trim(),
      tmdbApiBaseUrl: settings.tmdbApiBaseUrl.trim(),
      tmdbProxyUrl: settings.tmdbProxyUrl.trim(),
      tmdbProxyEnabled: settings.tmdbProxyEnabled,
      playbackCacheSizeMb: settings.playbackCacheSizeMb
          .clamp(
            AppSettings.minPlaybackCacheSizeMb,
            AppSettings.maxPlaybackCacheSizeMb,
          )
          .toInt(),
      playbackReadaheadSeconds: settings.playbackReadaheadSeconds
          .clamp(
            AppSettings.minPlaybackReadaheadSeconds,
            AppSettings.maxPlaybackReadaheadSeconds,
          )
          .toInt(),
      enableHardwareAcceleration: settings.enableHardwareAcceleration,
      subtitleLanguagePriority: settings.subtitleLanguagePriority.trim(),
      subtitleFontSize: settings.subtitleFontSize.clamp(18.0, 40.0).toDouble(),
    );
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
    await prefs.setString(_tmdbProxyUrlKey, settingsToSave.tmdbProxyUrl);
    await prefs.setBool(_tmdbProxyEnabledKey, settingsToSave.tmdbProxyEnabled);
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
