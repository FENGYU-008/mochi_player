import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mochi_player/core/ui/app_ui.dart';
import 'package:mochi_player/features/settings/application/app_settings_provider.dart';
import 'package:mochi_player/features/settings/application/theme_provider.dart';
import 'package:mochi_player/features/settings/domain/app_settings.dart';
import 'package:mochi_player/features/library/application/file_browser_provider.dart';
import 'package:mochi_player/features/library/application/media_library_provider.dart';
import 'package:provider/provider.dart';
import 'package:mochi_player/features/settings/presentation/widgets/settings_section.dart';
import 'package:mochi_player/features/settings/presentation/widgets/settings_test_button.dart';

const _settingsControlHeight = 36.0;
const _settingsFieldGap = 6.0;

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
  bool _isSyncingControllers = false;
  bool _showWebDavPassword = false;
  bool _showTmdbApiKey = false;
  bool _tmdbProxyEnabled = AppSettings.defaultTmdbProxyEnabled;
  bool _enableHardwareAcceleration =
      AppSettings.defaultEnableHardwareAcceleration;
  double _subtitleFontSize = AppSettings.defaultSubtitleFontSize;
  Timer? _saveDebounce;
  Timer? _feedbackTimer;
  bool _autoSaveInFlight = false;
  bool _autoSavePending = false;
  AppSettings? _lastPersistedSettings;
  String? _feedbackMessage;
  AppActivityBannerTone? _feedbackTone;

  List<TextEditingController> get _settingsControllers => [
    _webDavUrlController,
    _webDavUsernameController,
    _webDavPasswordController,
    _tmdbApiKeyController,
    _tmdbApiBaseUrlController,
    _tmdbProxyUrlController,
    _playbackCacheSizeMbController,
    _playbackReadaheadSecondsController,
    _audioLanguagePriorityController,
    _subtitleLanguagePriorityController,
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controllersInitialized) return;

    final settings = context.read<AppSettingsProvider>();
    _syncControllers(settings);
    _lastPersistedSettings = settings.settings;
    for (final controller in _settingsControllers) {
      controller.addListener(_scheduleAutoSave);
    }
    _controllersInitialized = true;
  }

  @override
  void dispose() {
    _saveDebounce?.cancel();
    _feedbackTimer?.cancel();
    for (final controller in _settingsControllers) {
      controller.removeListener(_scheduleAutoSave);
    }
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
      body: Stack(
        children: [
          Positioned.fill(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.page,
                AppHeader.height + AppSpacing.xxl,
                AppSpacing.page,
                AppSpacing.page,
              ),
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 760),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildThemeSettings(context),
                        const SizedBox(height: 28),
                        _buildWebDavSettings(context),
                        const SizedBox(height: 28),
                        _buildTmdbSettings(context),
                        const SizedBox(height: 28),
                        _buildPlaybackSettings(context),
                        const SizedBox(height: 28),
                        _buildLibraryMaintenance(context),
                        const SizedBox(height: AppSpacing.xxl),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: AppHeader.height,
            child: AppHeader(title: '设置', showSearch: false),
          ),
          Positioned(
            left: AppSpacing.page,
            right: AppSpacing.page,
            top: AppHeader.height + AppSpacing.sm,
            child: IgnorePointer(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                transitionBuilder: (child, animation) {
                  final offset =
                      Tween<Offset>(
                        begin: const Offset(0, 0.16),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOutCubic,
                        ),
                      );
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(position: offset, child: child),
                  );
                },
                child: _feedbackMessage == null
                    ? const SizedBox.shrink(key: ValueKey('no-feedback'))
                    : AppActivityBanner(
                        key: ValueKey(_feedbackMessage),
                        message: _feedbackMessage!,
                        tone: _feedbackTone ?? AppActivityBannerTone.info,
                      ),
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
        return SettingsSection(
          title: '外观',
          child: AppSegmentedControl<ThemeMode>(
            value: themeMode,
            segments: const [
              AppSegment(
                value: ThemeMode.light,
                label: '浅色',
                icon: Icons.light_mode_outlined,
              ),
              AppSegment(
                value: ThemeMode.dark,
                label: '深色',
                icon: Icons.dark_mode_outlined,
              ),
              AppSegment(
                value: ThemeMode.system,
                label: '跟随系统',
                icon: Icons.computer_rounded,
              ),
            ],
            onChanged: context.read<ThemeProvider>().setTheme,
          ),
        );
      },
    );
  }

  Widget _buildWebDavSettings(BuildContext context) {
    return Selector<AppSettingsProvider, bool>(
      selector: (context, provider) => provider.isSaving,
      builder: (context, isBusy, child) {
        return SettingsSection(
          title: 'WebDAV',
          trailing: SettingsTestButton(
            onPressed: isBusy ? null : _testWebDavConnection,
          ),
          child: AppFormGroup(
            children: [
              AppFormTextField(
                controller: _webDavUrlController,
                keyboardType: TextInputType.url,
                label: '服务器地址',
                icon: Icons.link_rounded,
              ),
              AppFormTextField(
                controller: _webDavUsernameController,
                label: '用户名',
                icon: Icons.person_outline_rounded,
                maxWidth: 240,
              ),
              AppFormTextField(
                controller: _webDavPasswordController,
                obscureText: !_showWebDavPassword,
                label: '密码',
                icon: Icons.lock_outline_rounded,
                maxWidth: 300,
                trailing: _VisibilityToggle(
                  visible: _showWebDavPassword,
                  onPressed: () {
                    setState(() {
                      _showWebDavPassword = !_showWebDavPassword;
                    });
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTmdbSettings(BuildContext context) {
    return Selector<AppSettingsProvider, bool>(
      selector: (context, provider) => provider.isSaving,
      builder: (context, isBusy, child) {
        return SettingsSection(
          title: 'TMDB',
          trailing: SettingsTestButton(
            onPressed: isBusy ? null : _testTmdbConnection,
          ),
          child: AppFormGroup(
            children: [
              AppFormTextField(
                controller: _tmdbApiKeyController,
                obscureText: !_showTmdbApiKey,
                label: 'API 密钥',
                icon: Icons.key_rounded,
                trailing: _VisibilityToggle(
                  visible: _showTmdbApiKey,
                  onPressed: () {
                    setState(() {
                      _showTmdbApiKey = !_showTmdbApiKey;
                    });
                  },
                ),
              ),
              AppFormTextField(
                controller: _tmdbApiBaseUrlController,
                keyboardType: TextInputType.url,
                label: 'API 地址',
                icon: Icons.travel_explore_rounded,
              ),
              AppFormSwitchRow(
                title: '使用 TMDB 代理',
                subtitle: '用于 TMDB API 和图片下载',
                icon: Icons.route_rounded,
                value: _tmdbProxyEnabled,
                onChanged: (value) {
                  setState(() {
                    _tmdbProxyEnabled = value;
                  });
                  _scheduleAutoSave();
                },
              ),
              AppFormTextField(
                controller: _tmdbProxyUrlController,
                enabled: _tmdbProxyEnabled,
                keyboardType: TextInputType.url,
                label: 'HTTP 代理',
                icon: Icons.route_rounded,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPlaybackSettings(BuildContext context) {
    return SettingsSection(
      title: '播放',
      child: AppFormGroup(
        children: [
          AppFormTextField(
            controller: _playbackCacheSizeMbController,
            keyboardType: TextInputType.number,
            label: '缓存大小',
            icon: Icons.storage_rounded,
            suffixText: 'MB',
            maxWidth: 120,
          ),
          AppFormTextField(
            controller: _playbackReadaheadSecondsController,
            keyboardType: TextInputType.number,
            label: '预读',
            icon: Icons.cloud_download_rounded,
            suffixText: '秒',
            maxWidth: 120,
          ),
          AppFormSwitchRow(
            title: '硬件解码',
            icon: Icons.memory_rounded,
            value: _enableHardwareAcceleration,
            onChanged: (value) {
              setState(() {
                _enableHardwareAcceleration = value;
              });
              _scheduleAutoSave();
            },
          ),
          AppFormTextField(
            controller: _audioLanguagePriorityController,
            label: '默认音轨语言',
            icon: Icons.graphic_eq_rounded,
          ),
          AppFormTextField(
            controller: _subtitleLanguagePriorityController,
            label: '默认字幕语言',
            icon: Icons.subtitles_rounded,
          ),
          AppFormSliderRow(
            label: '字幕大小',
            icon: Icons.format_size_rounded,
            value: _subtitleFontSize,
            min: 18,
            max: 40,
            divisions: 22,
            displayValue: _subtitleFontSize.round().toString(),
            onChanged: (value) {
              setState(() {
                _subtitleFontSize = value;
              });
              _scheduleAutoSave();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLibraryMaintenance(BuildContext context) {
    return Selector<MediaLibraryProvider, bool>(
      selector: (context, provider) => provider.isLoading,
      builder: (context, isBusy, child) {
        return SettingsSection(
          title: '媒体库',
          child: AppFormGroup(
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.compact),
                child: Wrap(
                  spacing: _settingsFieldGap,
                  runSpacing: _settingsFieldGap,
                  children: [
                    AppActionButton(
                      onPressed: isBusy ? null : _confirmRescrapeLibrary,
                      icon: Icons.manage_search_outlined,
                      label: isBusy ? '刮削中' : '补全元数据',
                      busy: isBusy,
                      variant: AppButtonVariant.secondary,
                      height: _settingsControlHeight,
                      borderRadius: AppRadii.control,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                      ),
                    ),
                    AppActionButton(
                      onPressed: isBusy ? null : _confirmClearLibrary,
                      icon: Icons.delete_sweep_outlined,
                      label: '清空媒体库',
                      destructive: true,
                      variant: AppButtonVariant.secondary,
                      height: _settingsControlHeight,
                      borderRadius: AppRadii.control,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _scheduleAutoSave() {
    if (!_controllersInitialized || _isSyncingControllers) return;

    _saveDebounce?.cancel();
    _saveDebounce = Timer(const Duration(milliseconds: 450), () {
      unawaited(_autoSaveSettings());
    });
  }

  Future<void> _autoSaveSettings() async {
    if (!mounted) return;
    if (_autoSaveInFlight) {
      _autoSavePending = true;
      return;
    }

    _autoSaveInFlight = true;
    try {
      final settingsProvider = context.read<AppSettingsProvider>();
      final previousSettings =
          _lastPersistedSettings ?? settingsProvider.settings;
      await _persistSettings();
      if (mounted && settingsProvider.error == null) {
        final currentSettings = settingsProvider.settings;
        _lastPersistedSettings = currentSettings;
        unawaited(_refreshAfterAutoSave(previousSettings, currentSettings));
      }
    } finally {
      _autoSaveInFlight = false;
      if (_autoSavePending && mounted) {
        _autoSavePending = false;
        _scheduleAutoSave();
      }
    }
  }

  void _showFeedback(
    String message,
    AppActivityBannerTone tone, {
    Duration duration = const Duration(seconds: 3),
  }) {
    if (!mounted) return;

    _feedbackTimer?.cancel();
    setState(() {
      _feedbackMessage = message;
      _feedbackTone = tone;
    });
    _feedbackTimer = Timer(duration, () {
      if (!mounted) return;
      setState(() {
        _feedbackMessage = null;
        _feedbackTone = null;
      });
    });
  }

  Future<void> _testWebDavConnection() async {
    final didSave = await _persistSettings();
    if (!didSave || !mounted) return;

    final settingsProvider = context.read<AppSettingsProvider>();
    final isConnected = await settingsProvider.testWebDavConnection();
    if (!mounted) return;

    _showFeedback(
      isConnected ? 'WebDAV 连接成功' : 'WebDAV 连接失败',
      isConnected ? AppActivityBannerTone.success : AppActivityBannerTone.error,
    );
  }

  Future<void> _testTmdbConnection() async {
    final didSave = await _persistSettings();
    if (!didSave || !mounted) return;

    final settingsProvider = context.read<AppSettingsProvider>();
    final isConnected = await settingsProvider.testTmdbConnection();
    if (!mounted) return;

    _showFeedback(
      isConnected ? 'TMDB 连接成功' : 'TMDB 连接失败',
      isConnected ? AppActivityBannerTone.success : AppActivityBannerTone.error,
    );
  }

  Future<void> _confirmRescrapeLibrary() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('补全媒体库元数据？'),
          content: const Text(
            '这会先同步 WebDAV 根目录，移除已不存在的本地记录，然后只为缺少元数据的文件请求 TMDB。已有匹配结果、播放进度和收藏会保留。',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('开始补全'),
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

    if (!settingsProvider.hasTmdbApiKey) {
      _showFeedback('补全元数据前请先设置 TMDB API 密钥', AppActivityBannerTone.error);
      return;
    }

    await mediaLibraryProvider.rescrapeLibrary();
    if (!mounted) return;

    final error = mediaLibraryProvider.error;
    _showFeedback(
      error ?? '已从 WebDAV 根目录补全媒体库元数据',
      error == null
          ? AppActivityBannerTone.success
          : AppActivityBannerTone.error,
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

    await mediaLibraryProvider.clearLibrary();
    if (!mounted) return;

    _showFeedback('媒体库已清空', AppActivityBannerTone.success);
  }

  Future<bool> _persistSettings() async {
    final settingsProvider = context.read<AppSettingsProvider>();

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
      _showFeedback(error, AppActivityBannerTone.error);
      return false;
    }

    _syncControllers(settingsProvider);
    _lastPersistedSettings = settingsProvider.settings;
    if (mounted) setState(() {});
    return true;
  }

  Future<void> _refreshAfterAutoSave(
    AppSettings previousSettings,
    AppSettings currentSettings,
  ) async {
    final webDavChanged =
        previousSettings.webDavUrl != currentSettings.webDavUrl ||
        previousSettings.webDavUsername != currentSettings.webDavUsername ||
        previousSettings.webDavPassword != currentSettings.webDavPassword;
    final tmdbChanged =
        previousSettings.tmdbApiKey != currentSettings.tmdbApiKey ||
        previousSettings.tmdbApiBaseUrl != currentSettings.tmdbApiBaseUrl ||
        previousSettings.tmdbProxyUrl != currentSettings.tmdbProxyUrl ||
        previousSettings.tmdbProxyEnabled != currentSettings.tmdbProxyEnabled;

    if (!mounted) return;

    if (webDavChanged &&
        (previousSettings.hasWebDavConfig || currentSettings.hasWebDavConfig)) {
      await context.read<FileBrowserProvider>().fetchFiles('/');
    }
    if (tmdbChanged &&
        mounted &&
        (previousSettings.hasTmdbApiKey || currentSettings.hasTmdbApiKey)) {
      await context.read<MediaLibraryProvider>().fetchTrending();
    }
  }

  void _syncControllers(AppSettingsProvider settingsProvider) {
    _isSyncingControllers = true;
    try {
      _setControllerText(_webDavUrlController, settingsProvider.webDavUrl);
      _setControllerText(
        _webDavUsernameController,
        settingsProvider.webDavUsername,
      );
      _setControllerText(
        _webDavPasswordController,
        settingsProvider.webDavPassword,
      );
      _setControllerText(_tmdbApiKeyController, settingsProvider.tmdbApiKey);
      _setControllerText(
        _tmdbApiBaseUrlController,
        settingsProvider.tmdbApiBaseUrl,
      );
      _setControllerText(
        _tmdbProxyUrlController,
        settingsProvider.tmdbProxyUrl,
      );
      _tmdbProxyEnabled = settingsProvider.tmdbProxyEnabled;
      _setControllerText(
        _playbackCacheSizeMbController,
        settingsProvider.playbackCacheSizeMb.toString(),
      );
      _setControllerText(
        _playbackReadaheadSecondsController,
        settingsProvider.playbackReadaheadSeconds.toString(),
      );
      _enableHardwareAcceleration = settingsProvider.enableHardwareAcceleration;
      _setControllerText(
        _audioLanguagePriorityController,
        settingsProvider.audioLanguagePriority,
      );
      _setControllerText(
        _subtitleLanguagePriorityController,
        settingsProvider.subtitleLanguagePriority,
      );
      _subtitleFontSize = settingsProvider.subtitleFontSize;
    } finally {
      _isSyncingControllers = false;
    }
  }

  void _setControllerText(TextEditingController controller, String text) {
    if (controller.text == text) return;

    controller.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }

  int _parseIntField(TextEditingController controller, int fallback) {
    return int.tryParse(controller.text.trim()) ?? fallback;
  }
}

class _VisibilityToggle extends StatelessWidget {
  final bool visible;
  final VoidCallback onPressed;

  const _VisibilityToggle({required this.visible, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: visible ? '隐藏' : '显示',
      onPressed: onPressed,
      color: AppColors.textSecondary(context),
      iconSize: 18,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints.tightFor(width: 28, height: 28),
      icon: Icon(
        visible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
      ),
    );
  }
}
