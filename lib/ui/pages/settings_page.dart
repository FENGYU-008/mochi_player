import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mochi_player/providers/app_settings_provider.dart';
import 'package:mochi_player/providers/file_browser_provider.dart';
import 'package:mochi_player/providers/media_library_provider.dart';
import 'package:mochi_player/providers/theme_provider.dart';
import 'package:mochi_player/services/app_settings_service.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _webDavUrlController = TextEditingController();
  final _webDavUsernameController = TextEditingController();
  final _webDavPasswordController = TextEditingController();
  final _tmdbApiKeyController = TextEditingController();
  final _tmdbApiBaseUrlController = TextEditingController();
  final _tmdbProxyUrlController = TextEditingController();
  final _playbackCacheSizeMbController = TextEditingController();
  final _playbackReadaheadSecondsController = TextEditingController();
  final _audioLanguagePriorityController = TextEditingController();
  final _subtitleLanguagePriorityController = TextEditingController();

  bool _controllersInitialized = false;
  bool _showWebDavPassword = false;
  bool _showTmdbApiKey = false;
  bool _tmdbProxyEnabled = AppSettings.defaultTmdbProxyEnabled;
  bool _enableHardwareAcceleration =
      AppSettings.defaultEnableHardwareAcceleration;
  double _subtitleFontSize = AppSettings.defaultSubtitleFontSize;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controllersInitialized) return;

    final settings = context.read<AppSettingsProvider>();
    _syncControllers(settings);
    _controllersInitialized = true;
  }

  @override
  void dispose() {
    _webDavUrlController.dispose();
    _webDavUsernameController.dispose();
    _webDavPasswordController.dispose();
    _tmdbApiKeyController.dispose();
    _tmdbApiBaseUrlController.dispose();
    _tmdbProxyUrlController.dispose();
    _playbackCacheSizeMbController.dispose();
    _playbackReadaheadSecondsController.dispose();
    _audioLanguagePriorityController.dispose();
    _subtitleLanguagePriorityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: ListView(
        padding: const EdgeInsets.all(40.0),
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '设置',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 40),
                  _buildThemeSettings(context),
                  const SizedBox(height: 36),
                  _buildWebDavSettings(context),
                  const SizedBox(height: 36),
                  _buildTmdbSettings(context),
                  const SizedBox(height: 36),
                  _buildPlaybackSettings(context),
                  const SizedBox(height: 36),
                  _buildLibraryMaintenance(context),
                  const SizedBox(height: 32),
                  _buildActions(context),
                  _buildSettingsError(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeSettings(BuildContext context) {
    return Selector<ThemeProvider, ThemeMode>(
      selector: (context, provider) => provider.themeMode,
      builder: (context, themeMode, child) {
        return _SettingsSection(
          title: '外观',
          child: SegmentedButton<ThemeMode>(
            segments: const [
              ButtonSegment(
                value: ThemeMode.light,
                label: Text('浅色'),
                icon: Icon(Icons.light_mode_outlined),
              ),
              ButtonSegment(
                value: ThemeMode.dark,
                label: Text('深色'),
                icon: Icon(Icons.dark_mode_outlined),
              ),
              ButtonSegment(
                value: ThemeMode.system,
                label: Text('跟随系统'),
                icon: Icon(Icons.computer_rounded),
              ),
            ],
            selected: {themeMode},
            onSelectionChanged: (selection) {
              context.read<ThemeProvider>().setTheme(selection.first);
            },
          ),
        );
      },
    );
  }

  Widget _buildWebDavSettings(BuildContext context) {
    return _SettingsSection(
      title: 'WebDAV',
      child: Column(
        children: [
          TextField(
            controller: _webDavUrlController,
            keyboardType: TextInputType.url,
            decoration: _inputDecoration(
              context,
              label: '服务器地址',
              icon: Icons.link_rounded,
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _webDavUsernameController,
            decoration: _inputDecoration(
              context,
              label: '用户名',
              icon: Icons.person_outline_rounded,
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _webDavPasswordController,
            obscureText: !_showWebDavPassword,
            decoration: _inputDecoration(
              context,
              label: '密码',
              icon: Icons.lock_outline_rounded,
              suffixIcon: IconButton(
                tooltip: _showWebDavPassword ? '隐藏' : '显示',
                icon: Icon(
                  _showWebDavPassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
                onPressed: () {
                  setState(() {
                    _showWebDavPassword = !_showWebDavPassword;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTmdbSettings(BuildContext context) {
    return _SettingsSection(
      title: 'TMDB',
      child: Column(
        children: [
          TextField(
            controller: _tmdbApiKeyController,
            obscureText: !_showTmdbApiKey,
            decoration: _inputDecoration(
              context,
              label: 'API 密钥',
              icon: Icons.key_rounded,
              suffixIcon: IconButton(
                tooltip: _showTmdbApiKey ? '隐藏' : '显示',
                icon: Icon(
                  _showTmdbApiKey
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
                onPressed: () {
                  setState(() {
                    _showTmdbApiKey = !_showTmdbApiKey;
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _tmdbApiBaseUrlController,
            keyboardType: TextInputType.url,
            decoration: _inputDecoration(
              context,
              label: 'API 地址',
              icon: Icons.travel_explore_rounded,
            ),
          ),
          const SizedBox(height: 14),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('使用 TMDB 代理'),
            subtitle: const Text('用于 TMDB API 和图片下载'),
            secondary: const Icon(Icons.route_rounded),
            value: _tmdbProxyEnabled,
            onChanged: (value) {
              setState(() {
                _tmdbProxyEnabled = value;
              });
            },
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _tmdbProxyUrlController,
            enabled: _tmdbProxyEnabled,
            keyboardType: TextInputType.url,
            decoration: _inputDecoration(
              context,
              label: 'HTTP 代理',
              icon: Icons.route_rounded,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaybackSettings(BuildContext context) {
    return _SettingsSection(
      title: '播放',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SettingsRow(
            label: '缓存大小',
            child: TextField(
              controller: _playbackCacheSizeMbController,
              keyboardType: TextInputType.number,
              decoration: _inputDecoration(
                context,
                label: 'MB',
                icon: Icons.storage_rounded,
              ),
            ),
          ),
          const SizedBox(height: 14),
          _SettingsRow(
            label: '预读',
            child: TextField(
              controller: _playbackReadaheadSecondsController,
              keyboardType: TextInputType.number,
              decoration: _inputDecoration(
                context,
                label: '秒',
                icon: Icons.cloud_download_rounded,
              ),
            ),
          ),
          const SizedBox(height: 14),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('硬件解码'),
            secondary: const Icon(Icons.memory_rounded),
            value: _enableHardwareAcceleration,
            onChanged: (value) {
              setState(() {
                _enableHardwareAcceleration = value;
              });
            },
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _audioLanguagePriorityController,
            decoration: _inputDecoration(
              context,
              label: '默认音轨语言',
              icon: Icons.graphic_eq_rounded,
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _subtitleLanguagePriorityController,
            decoration: _inputDecoration(
              context,
              label: '默认字幕语言',
              icon: Icons.subtitles_rounded,
            ),
          ),
          const SizedBox(height: 14),
          _SettingsRow(
            label: '字幕大小',
            child: Row(
              children: [
                Expanded(
                  child: Slider(
                    value: _subtitleFontSize,
                    min: 18,
                    max: 40,
                    divisions: 22,
                    label: _subtitleFontSize.round().toString(),
                    onChanged: (value) {
                      setState(() {
                        _subtitleFontSize = value;
                      });
                    },
                  ),
                ),
                SizedBox(
                  width: 40,
                  child: Text(
                    _subtitleFontSize.round().toString(),
                    textAlign: TextAlign.end,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Selector<AppSettingsProvider, bool>(
      selector: (context, provider) => provider.isSaving,
      builder: (context, isBusy, child) {
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            FilledButton.icon(
              onPressed: isBusy ? null : _saveSettings,
              icon: isBusy
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_outlined),
              label: Text(isBusy ? '保存中' : '保存'),
            ),
            OutlinedButton.icon(
              onPressed: isBusy ? null : _testWebDavConnection,
              icon: const Icon(Icons.wifi_tethering_rounded),
              label: const Text('测试 WebDAV'),
            ),
            OutlinedButton.icon(
              onPressed: isBusy ? null : _testTmdbConnection,
              icon: const Icon(Icons.public_rounded),
              label: const Text('测试 TMDB'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSettingsError() {
    return Selector<AppSettingsProvider, String?>(
      selector: (context, provider) => provider.error,
      builder: (context, error, child) {
        if (error == null) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Text(error, style: const TextStyle(color: Colors.redAccent)),
        );
      },
    );
  }

  Widget _buildLibraryMaintenance(BuildContext context) {
    return Selector<MediaLibraryProvider, bool>(
      selector: (context, provider) => provider.isLoading,
      builder: (context, isBusy, child) {
        return _SettingsSection(
          title: '媒体库',
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              OutlinedButton.icon(
                onPressed: isBusy ? null : _confirmRescrapeLibrary,
                icon: isBusy
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.manage_search_outlined),
                label: Text(isBusy ? '重新刮削中' : '重新刮削媒体库'),
              ),
              OutlinedButton.icon(
                onPressed: isBusy ? null : _confirmClearLibrary,
                icon: const Icon(Icons.delete_sweep_outlined),
                label: const Text('清空媒体库'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.redAccent,
                  side: const BorderSide(color: Colors.redAccent),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  InputDecoration _inputDecoration(
    BuildContext context, {
    required String label,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    final theme = Theme.of(context);
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: theme.canvasColor,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: theme.dividerColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
      ),
    );
  }

  Future<void> _saveSettings() async {
    final didSave = await _persistSettings();
    if (!didSave || !mounted) return;

    final settingsProvider = context.read<AppSettingsProvider>();
    final fileBrowserProvider = context.read<FileBrowserProvider>();
    final mediaLibraryProvider = context.read<MediaLibraryProvider>();
    final messenger = ScaffoldMessenger.of(context);

    messenger.showSnackBar(const SnackBar(content: Text('设置已保存')));
    unawaited(
      _refreshAfterSave(
        settingsProvider,
        fileBrowserProvider,
        mediaLibraryProvider,
      ),
    );
  }

  Future<void> _refreshAfterSave(
    AppSettingsProvider settingsProvider,
    FileBrowserProvider fileBrowserProvider,
    MediaLibraryProvider mediaLibraryProvider,
  ) async {
    if (settingsProvider.hasWebDavConfig) {
      await fileBrowserProvider.fetchFiles('/');
    }

    if (settingsProvider.hasTmdbApiKey) {
      await mediaLibraryProvider.fetchTrending();
    }
  }

  Future<void> _testWebDavConnection() async {
    final didSave = await _persistSettings();
    if (!didSave || !mounted) return;

    final settingsProvider = context.read<AppSettingsProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final isConnected = await settingsProvider.testWebDavConnection();
    if (!mounted) return;

    messenger.showSnackBar(
      SnackBar(
        content: Text(isConnected ? 'WebDAV 连接成功' : 'WebDAV 连接失败'),
        backgroundColor: isConnected ? null : Colors.redAccent,
      ),
    );
  }

  Future<void> _testTmdbConnection() async {
    final didSave = await _persistSettings();
    if (!didSave || !mounted) return;

    final settingsProvider = context.read<AppSettingsProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final isConnected = await settingsProvider.testTmdbConnection();
    if (!mounted) return;

    messenger.showSnackBar(
      SnackBar(
        content: Text(isConnected ? 'TMDB 连接成功' : 'TMDB 连接失败'),
        backgroundColor: isConnected ? null : Colors.redAccent,
      ),
    );
  }

  Future<void> _confirmRescrapeLibrary() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('重新刮削媒体库？'),
          content: const Text(
            '这会清空本地元数据和 TMDB 匹配结果，然后重新刮削已经扫描到的文件。播放进度、收藏和 WebDAV 文件会保留。',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('重新刮削'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    final didSave = await _persistSettings();
    if (!didSave || !mounted) return;

    final settingsProvider = context.read<AppSettingsProvider>();
    final mediaLibraryProvider = context.read<MediaLibraryProvider>();
    final messenger = ScaffoldMessenger.of(context);

    if (!settingsProvider.hasTmdbApiKey) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('重新刮削前请先设置 TMDB API 密钥'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    await mediaLibraryProvider.rescrapeLibrary();
    if (!mounted) return;

    final error = mediaLibraryProvider.error;
    messenger.showSnackBar(
      SnackBar(
        content: Text(error ?? '已从 WebDAV 根目录重新刮削媒体库'),
        backgroundColor: error == null ? null : Colors.redAccent,
      ),
    );
  }

  Future<void> _confirmClearLibrary() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('清空媒体库？'),
          content: const Text('这会清空本地扫描文件、元数据、播放进度和收藏，不会删除 WebDAV 上的文件。'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
              child: const Text('清空'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    final mediaLibraryProvider = context.read<MediaLibraryProvider>();
    final messenger = ScaffoldMessenger.of(context);

    await mediaLibraryProvider.clearLibrary();
    if (!mounted) return;

    messenger.showSnackBar(const SnackBar(content: Text('媒体库已清空')));
  }

  Future<bool> _persistSettings() async {
    final settingsProvider = context.read<AppSettingsProvider>();
    final messenger = ScaffoldMessenger.of(context);

    await settingsProvider.saveSettings(
      webDavUrl: _webDavUrlController.text,
      webDavUsername: _webDavUsernameController.text,
      webDavPassword: _webDavPasswordController.text,
      tmdbApiKey: _tmdbApiKeyController.text,
      tmdbApiBaseUrl: _tmdbApiBaseUrlController.text,
      tmdbProxyUrl: _tmdbProxyUrlController.text,
      tmdbProxyEnabled: _tmdbProxyEnabled,
      playbackCacheSizeMb: _parseIntField(
        _playbackCacheSizeMbController,
        AppSettings.defaultPlaybackCacheSizeMb,
      ),
      playbackReadaheadSeconds: _parseIntField(
        _playbackReadaheadSecondsController,
        AppSettings.defaultPlaybackReadaheadSeconds,
      ),
      enableHardwareAcceleration: _enableHardwareAcceleration,
      audioLanguagePriority: _audioLanguagePriorityController.text,
      subtitleLanguagePriority: _subtitleLanguagePriorityController.text,
      subtitleFontSize: _subtitleFontSize,
    );
    if (!mounted) return false;

    final error = settingsProvider.error;
    if (error != null) {
      messenger.showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.redAccent),
      );
      return false;
    }

    _syncControllers(settingsProvider);
    setState(() {});
    return true;
  }

  void _syncControllers(AppSettingsProvider settingsProvider) {
    _webDavUrlController.text = settingsProvider.webDavUrl;
    _webDavUsernameController.text = settingsProvider.webDavUsername;
    _webDavPasswordController.text = settingsProvider.webDavPassword;
    _tmdbApiKeyController.text = settingsProvider.tmdbApiKey;
    _tmdbApiBaseUrlController.text = settingsProvider.tmdbApiBaseUrl;
    _tmdbProxyUrlController.text = settingsProvider.tmdbProxyUrl;
    _tmdbProxyEnabled = settingsProvider.tmdbProxyEnabled;
    _playbackCacheSizeMbController.text = settingsProvider.playbackCacheSizeMb
        .toString();
    _playbackReadaheadSecondsController.text = settingsProvider
        .playbackReadaheadSeconds
        .toString();
    _enableHardwareAcceleration = settingsProvider.enableHardwareAcceleration;
    _audioLanguagePriorityController.text =
        settingsProvider.audioLanguagePriority;
    _subtitleLanguagePriorityController.text =
        settingsProvider.subtitleLanguagePriority;
    _subtitleFontSize = settingsProvider.subtitleFontSize;
  }

  int _parseIntField(TextEditingController controller, int fallback) {
    return int.tryParse(controller.text.trim()) ?? fallback;
  }
}

class _SettingsRow extends StatelessWidget {
  final String label;
  final Widget child;

  const _SettingsRow({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 560;
        final labelWidget = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        );

        if (compact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [labelWidget, const SizedBox(height: 8), child],
          );
        }

        return Row(
          children: [
            SizedBox(width: 180, child: labelWidget),
            Expanded(child: child),
          ],
        );
      },
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final Widget child;

  const _SettingsSection({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
        const SizedBox(height: 16),
        child,
      ],
    );
  }
}
