import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mochi_player/core/ui/app_ui.dart';
import 'package:mochi_player/features/home/application/trending_media_provider.dart';
import 'package:mochi_player/features/library/application/file_browser_provider.dart';
import 'package:mochi_player/features/library/application/media_library_provider.dart';
import 'package:mochi_player/features/settings/application/app_settings_provider.dart';
import 'package:mochi_player/features/settings/application/theme_provider.dart';
import 'package:mochi_player/features/settings/domain/app_settings.dart';
import 'package:mochi_player/features/settings/presentation/widgets/settings_section.dart';
import 'package:mochi_player/features/settings/presentation/widgets/settings_switch_item.dart';
import 'package:mochi_player/features/settings/presentation/widgets/settings_text_field.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

enum _SettingsTab { appearance, mediaSource, metadata, playback, library }

class _SettingsPageState extends State<SettingsPage> {
  final _webDavUrlController = TextEditingController();
  final _webDavUsernameController = TextEditingController();
  final _webDavPasswordController = TextEditingController();
  final _tmdbApiKeyController = TextEditingController();
  final _tmdbApiBaseUrlController = TextEditingController();
  final _tmdbProxyUrlController = TextEditingController();
  final _playbackCacheSizeMbController = TextEditingController();
  final _playbackReadaheadSecondsController = TextEditingController();
  final _subtitleLanguagePriorityController = TextEditingController();

  bool _controllersInitialized = false;
  bool _isSyncingControllers = false;
  bool _showWebDavPassword = false;
  bool _showTmdbApiKey = false;
  bool _tmdbProxyEnabled = AppSettings.defaultTmdbProxyEnabled;
  bool _enableHardwareAcceleration = AppSettings.defaultEnableHardwareAcceleration;
  double _subtitleFontSize = AppSettings.defaultSubtitleFontSize;
  var _selectedTab = _SettingsTab.appearance;
  Timer? _saveDebounce;
  bool _autoSaveInFlight = false;
  bool _autoSavePending = false;
  bool _runtimeApplyPending = false;

  List<TextEditingController> get _settingsControllers => [
    _webDavUrlController,
    _webDavUsernameController,
    _webDavPasswordController,
    _tmdbApiKeyController,
    _tmdbApiBaseUrlController,
    _tmdbProxyUrlController,
    _playbackCacheSizeMbController,
    _playbackReadaheadSecondsController,
    _subtitleLanguagePriorityController,
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controllersInitialized) return;

    final settings = context.read<AppSettingsProvider>();
    _syncControllers(settings);
    for (final controller in _settingsControllers) {
      controller.addListener(_scheduleAutoSave);
    }
    _controllersInitialized = true;
  }

  @override
  void dispose() {
    _saveDebounce?.cancel();
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
    _subtitleLanguagePriorityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          const SizedBox(
            height: AppHeader.height,
            child: AppHeader(title: '设置'),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
            child: Align(
              alignment: Alignment.center,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1240),
                child: AppTabs<_SettingsTab>(
                  value: _selectedTab,
                  onChanged: (tab) => setState(() => _selectedTab = tab),
                  tabs: const [
                    AppTab(value: _SettingsTab.appearance, label: '外观', icon: Icons.light_mode_outlined),
                    AppTab(value: _SettingsTab.mediaSource, label: '媒体源', icon: Icons.storage_outlined),
                    AppTab(value: _SettingsTab.metadata, label: '元数据', icon: Icons.sell_outlined),
                    AppTab(value: _SettingsTab.playback, label: '播放', icon: Icons.play_circle_outline_rounded),
                    AppTab(value: _SettingsTab.library, label: '媒体库', icon: Icons.inventory_2_outlined),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              key: PageStorageKey<String>('settings-scroll:${_selectedTab.name}'),
              padding: const EdgeInsets.fromLTRB(AppSpacing.page, AppSpacing.xxl, AppSpacing.page, AppSpacing.page),
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1040),
                    child: _buildSelectedTab(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedTab(BuildContext context) {
    return switch (_selectedTab) {
      _SettingsTab.appearance => _buildThemeSettings(context),
      _SettingsTab.mediaSource => _buildOpenListSettings(context),
      _SettingsTab.metadata => _buildTmdbSettings(context),
      _SettingsTab.playback => _buildPlaybackSettings(context),
      _SettingsTab.library => _buildLibraryMaintenance(context),
    };
  }

  Widget _buildThemeSettings(BuildContext context) {
    return Selector<ThemeProvider, ThemeMode>(
      selector: (context, provider) => provider.themeMode,
      builder: (context, themeMode, child) {
        return SettingsSection(
          title: '外观',
          subtitle: '调整应用主题与内容显示方式',
          groups: [
            AppFormGroup(
              title: '界面主题',
              children: [
                AppFormItem(
                  label: '主题模式',
                  subtitle: '选择应用使用的明暗外观',
                  labelWidth: null,
                  control: Align(
                    alignment: Alignment.centerRight,
                    child: SizedBox(
                      width: 300,
                      child: AppSegmentedControl<ThemeMode>(
                        value: themeMode,
                        options: const [
                          AppSegmentedOption(value: ThemeMode.light, label: '浅色', icon: Icons.light_mode_outlined),
                          AppSegmentedOption(value: ThemeMode.dark, label: '深色', icon: Icons.dark_mode_outlined),
                          AppSegmentedOption(value: ThemeMode.system, label: '跟随系统', icon: Icons.computer_rounded),
                        ],
                        onChanged: context.read<ThemeProvider>().setTheme,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildOpenListSettings(BuildContext context) {
    return Selector<AppSettingsProvider, bool>(
      selector: (context, provider) => provider.isSaving,
      builder: (context, isBusy, child) {
        return SettingsSection(
          title: '媒体源',
          subtitle: '配置用于浏览与播放的 WebDAV 媒体服务器',
          groups: [
            AppFormGroup(
              title: '服务器配置',
              children: [
                SettingsTextField(
                  controller: _webDavUrlController,
                  keyboardType: TextInputType.url,
                  label: 'OpenList 服务器地址',
                  onFocusLost: _commitNetworkSettings,
                ),
                SettingsTextField(
                  controller: _webDavUsernameController,
                  label: '用户名',
                  onFocusLost: _commitNetworkSettings,
                ),
                SettingsTextField(
                  controller: _webDavPasswordController,
                  obscureText: !_showWebDavPassword,
                  label: '密码',
                  onFocusLost: _commitNetworkSettings,
                  inputSuffix: _VisibilityToggle(
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
            AppFormGroup(
              title: '连接测试',
              children: [
                AppFormItem(
                  label: '连接状态',
                  subtitle: '通过 WebDAV 检查目录访问是否可用',
                  labelWidth: null,
                  expandControl: false,
                  control: _SettingsActionButton(onPressed: isBusy ? null : _testWebDavConnection, label: '测试连接'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildTmdbSettings(BuildContext context) {
    return Selector<AppSettingsProvider, bool>(
      selector: (context, provider) => provider.isSaving,
      builder: (context, isBusy, child) {
        return SettingsSection(
          title: '元数据',
          subtitle: '配置媒体信息的获取方式与网络访问',
          groups: [
            AppFormGroup(
              title: 'TMDB 配置',
              children: [
                SettingsTextField(
                  controller: _tmdbApiKeyController,
                  obscureText: !_showTmdbApiKey,
                  label: 'API 密钥',
                  onFocusLost: _commitNetworkSettings,
                  inputSuffix: _VisibilityToggle(
                    visible: _showTmdbApiKey,
                    onPressed: () {
                      setState(() {
                        _showTmdbApiKey = !_showTmdbApiKey;
                      });
                    },
                  ),
                ),
                SettingsTextField(
                  controller: _tmdbApiBaseUrlController,
                  keyboardType: TextInputType.url,
                  label: 'API 地址',
                  onFocusLost: _commitNetworkSettings,
                ),
              ],
            ),
            AppFormGroup(
              title: '网络代理',
              children: [
                SettingsSwitchItem(
                  label: '使用 TMDB 代理',
                  subtitle: '用于 TMDB API 和图片下载',
                  value: _tmdbProxyEnabled,
                  onChanged: (value) {
                    setState(() {
                      _tmdbProxyEnabled = value;
                    });
                    _scheduleAutoSave(applyRuntime: true, immediate: true);
                  },
                ),
                SettingsTextField(
                  controller: _tmdbProxyUrlController,
                  enabled: _tmdbProxyEnabled,
                  keyboardType: TextInputType.url,
                  label: 'HTTP 代理',
                  onFocusLost: _commitNetworkSettings,
                ),
              ],
            ),
            AppFormGroup(
              title: '连接测试',
              children: [
                AppFormItem(
                  label: '连接状态',
                  subtitle: '检查当前 TMDB 配置是否可用',
                  labelWidth: null,
                  expandControl: false,
                  control: _SettingsActionButton(onPressed: isBusy ? null : _testTmdbConnection, label: '测试连接'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildPlaybackSettings(BuildContext context) {
    return SettingsSection(
      title: '播放',
      subtitle: '调整缓存、解码与字幕偏好',
      groups: [
        AppFormGroup(
          title: '缓存设置',
          children: [
            SettingsTextField(
              controller: _playbackCacheSizeMbController,
              keyboardType: TextInputType.number,
              label: '缓存大小',
              suffixText: 'MB',
              maxWidth: 120,
            ),
            SettingsTextField(
              controller: _playbackReadaheadSecondsController,
              keyboardType: TextInputType.number,
              label: '预读',
              suffixText: '秒',
              maxWidth: 120,
            ),
          ],
        ),
        AppFormGroup(
          title: '播放设置',
          children: [
            SettingsSwitchItem(
              label: '硬件解码',
              value: _enableHardwareAcceleration,
              onChanged: (value) {
                setState(() {
                  _enableHardwareAcceleration = value;
                });
                _scheduleAutoSave();
              },
            ),
          ],
        ),
        AppFormGroup(
          title: '字幕设置',
          children: [
            SettingsTextField(controller: _subtitleLanguagePriorityController, label: '默认字幕语言'),
            AppFormItem(
              label: '字幕大小',
              control: Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  width: 160,
                  child: AppInputNumber(
                    value: _subtitleFontSize.round(),
                    min: 18,
                    max: 40,
                    onChanged: (value) {
                      setState(() {
                        _subtitleFontSize = value.toDouble();
                      });
                      _scheduleAutoSave();
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLibraryMaintenance(BuildContext context) {
    return Selector<MediaLibraryProvider, bool>(
      selector: (context, provider) => provider.isLoading,
      builder: (context, isBusy, child) {
        return SettingsSection(
          title: '媒体库',
          subtitle: '管理本地媒体索引与元数据',
          groups: [
            AppFormGroup(
              title: '媒体库维护',
              children: [
                AppFormItem(
                  label: '补全元数据',
                  subtitle: '同步 WebDAV，并为缺少信息的媒体重新匹配',
                  labelWidth: null,
                  expandControl: false,
                  control: _SettingsActionButton(
                    onPressed: isBusy ? null : _confirmRescrapeLibrary,
                    icon: Icons.manage_search_outlined,
                    label: isBusy ? '刮削中' : '开始补全',
                    busy: isBusy,
                  ),
                ),
              ],
            ),
            AppFormGroup(
              title: '危险操作',
              children: [
                AppFormItem(
                  label: '清空媒体库',
                  subtitle: '删除本地索引、元数据、播放进度和收藏',
                  labelWidth: null,
                  expandControl: false,
                  control: _SettingsActionButton(
                    onPressed: isBusy ? null : _confirmClearLibrary,
                    icon: Icons.delete_sweep_outlined,
                    label: '清空',
                    destructive: true,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _scheduleAutoSave({bool applyRuntime = false, bool immediate = false}) {
    if (!_controllersInitialized || _isSyncingControllers) return;
    if (applyRuntime) _runtimeApplyPending = true;

    _saveDebounce?.cancel();
    _saveDebounce = Timer(immediate ? Duration.zero : const Duration(milliseconds: 450), () {
      unawaited(_autoSaveSettings());
    });
  }

  void _commitNetworkSettings() {
    _scheduleAutoSave(applyRuntime: true, immediate: true);
  }

  Future<void> _autoSaveSettings() async {
    if (!mounted) return;
    if (_autoSaveInFlight) {
      _autoSavePending = true;
      return;
    }

    _autoSaveInFlight = true;
    final shouldApplyRuntime = _runtimeApplyPending;
    _runtimeApplyPending = false;
    try {
      final settingsProvider = context.read<AppSettingsProvider>();
      final previousRuntimeSettings = settingsProvider.appliedRuntimeSettings ?? settingsProvider.settings;
      await _persistSettings(applyRuntime: shouldApplyRuntime, syncControllers: false);
      if (mounted && settingsProvider.error == null) {
        final currentSettings = settingsProvider.settings;
        if (shouldApplyRuntime) {
          unawaited(_refreshAfterRuntimeSettingsApplied(previousRuntimeSettings, currentSettings));
        }
      }
    } finally {
      _autoSaveInFlight = false;
      if (_autoSavePending && mounted) {
        _autoSavePending = false;
        _scheduleAutoSave(immediate: _runtimeApplyPending);
      }
    }
  }

  Future<void> _testWebDavConnection() async {
    final didSave = await _persistSettings(applyRuntime: true);
    if (!didSave || !mounted) return;

    final settingsProvider = context.read<AppSettingsProvider>();
    final isConnected = await settingsProvider.testWebDavConnection();
    if (!mounted) return;

    if (isConnected) {
      AppMessage.success('OpenList WebDAV 连接成功');
    } else {
      AppMessage.error('OpenList WebDAV 连接失败');
    }
  }

  Future<void> _testTmdbConnection() async {
    final didSave = await _persistSettings(applyRuntime: true);
    if (!didSave || !mounted) return;

    final settingsProvider = context.read<AppSettingsProvider>();
    final isConnected = await settingsProvider.testTmdbConnection();
    if (!mounted) return;

    if (isConnected) {
      AppMessage.success('TMDB 连接成功');
    } else {
      AppMessage.error('TMDB 连接失败');
    }
  }

  Future<void> _confirmRescrapeLibrary() async {
    final confirmed = await AppModal.confirm(
      context: context,
      title: '补全媒体库元数据？',
      message: '这会先同步 WebDAV 根目录，移除已不存在的本地记录，然后只为缺少元数据的文件请求 TMDB。已有匹配结果、播放进度和收藏会保留。',
      confirmLabel: '开始补全',
      icon: Icons.manage_search_rounded,
    );

    if (confirmed != true || !mounted) return;

    final didSave = await _persistSettings(applyRuntime: true);
    if (!didSave || !mounted) return;

    final settingsProvider = context.read<AppSettingsProvider>();
    final mediaLibraryProvider = context.read<MediaLibraryProvider>();

    if (!settingsProvider.hasTmdbApiKey) {
      AppMessage.error('补全元数据前请先设置 TMDB API 密钥');
      return;
    }

    await mediaLibraryProvider.refreshLibraryMetadata();
    if (!mounted) return;

    final error = mediaLibraryProvider.error;
    if (error == null) {
      AppMessage.success('已从 WebDAV 根目录补全媒体库元数据');
    } else {
      AppMessage.error(error);
    }
  }

  Future<void> _confirmClearLibrary() async {
    final confirmed = await AppModal.confirm(
      context: context,
      title: '清空媒体库？',
      message: '这会清空本地扫描文件、元数据、播放进度和收藏，不会删除 WebDAV 上的文件。',
      confirmLabel: '清空',
      icon: Icons.delete_sweep_rounded,
      destructive: true,
    );

    if (confirmed != true || !mounted) return;

    final mediaLibraryProvider = context.read<MediaLibraryProvider>();

    await mediaLibraryProvider.clearLibrary();
    if (!mounted) return;

    AppMessage.success('媒体库已清空');
  }

  Future<bool> _persistSettings({bool applyRuntime = false, bool syncControllers = true}) async {
    final settingsProvider = context.read<AppSettingsProvider>();

    await settingsProvider.saveSettings(
      webDavUrl: _webDavUrlController.text,
      webDavUsername: _webDavUsernameController.text,
      webDavPassword: _webDavPasswordController.text,
      tmdbApiKey: _tmdbApiKeyController.text,
      tmdbApiBaseUrl: _tmdbApiBaseUrlController.text,
      tmdbProxyUrl: _tmdbProxyUrlController.text,
      tmdbProxyEnabled: _tmdbProxyEnabled,
      playbackCacheSizeMb: _parseIntField(_playbackCacheSizeMbController, AppSettings.defaultPlaybackCacheSizeMb),
      playbackReadaheadSeconds: _parseIntField(
        _playbackReadaheadSecondsController,
        AppSettings.defaultPlaybackReadaheadSeconds,
      ),
      enableHardwareAcceleration: _enableHardwareAcceleration,
      subtitleLanguagePriority: _subtitleLanguagePriorityController.text,
      subtitleFontSize: _subtitleFontSize,
      applyRuntime: applyRuntime,
    );
    if (!mounted) return false;

    final error = settingsProvider.error;
    if (error != null) {
      AppMessage.error(error);
      return false;
    }

    if (syncControllers) _syncControllers(settingsProvider);
    if (mounted && syncControllers) setState(() {});
    return true;
  }

  Future<void> _refreshAfterRuntimeSettingsApplied(AppSettings previousSettings, AppSettings currentSettings) async {
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

    if (webDavChanged && (previousSettings.hasWebDavConfig || currentSettings.hasWebDavConfig)) {
      await context.read<FileBrowserProvider>().fetchFiles('/');
    }
    if (tmdbChanged && mounted && (previousSettings.hasTmdbApiKey || currentSettings.hasTmdbApiKey)) {
      await context.read<TrendingMediaProvider>().fetch();
    }
  }

  void _syncControllers(AppSettingsProvider settingsProvider) {
    _isSyncingControllers = true;
    try {
      _setControllerText(_webDavUrlController, settingsProvider.webDavUrl);
      _setControllerText(_webDavUsernameController, settingsProvider.webDavUsername);
      _setControllerText(_webDavPasswordController, settingsProvider.webDavPassword);
      _setControllerText(_tmdbApiKeyController, settingsProvider.tmdbApiKey);
      _setControllerText(_tmdbApiBaseUrlController, settingsProvider.tmdbApiBaseUrl);
      _setControllerText(_tmdbProxyUrlController, settingsProvider.tmdbProxyUrl);
      _tmdbProxyEnabled = settingsProvider.tmdbProxyEnabled;
      _setControllerText(_playbackCacheSizeMbController, settingsProvider.playbackCacheSizeMb.toString());
      _setControllerText(_playbackReadaheadSecondsController, settingsProvider.playbackReadaheadSeconds.toString());
      _enableHardwareAcceleration = settingsProvider.enableHardwareAcceleration;
      _setControllerText(_subtitleLanguagePriorityController, settingsProvider.subtitleLanguagePriority);
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
    return Tooltip(
      message: visible ? '隐藏' : '显示',
      child: AppClickableArea(
        width: 22,
        height: 22,
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppRadii.small),
        hoverColor: AppColors.hoverSurface(context),
        child: Center(
          child: Icon(
            visible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            size: 16,
            color: AppColors.textSecondary(context),
          ),
        ),
      ),
    );
  }
}

class _SettingsActionButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String label;
  final IconData? icon;
  final bool destructive;
  final bool busy;

  const _SettingsActionButton({
    required this.onPressed,
    required this.label,
    this.icon,
    this.destructive = false,
    this.busy = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppButton(
      onPressed: onPressed,
      icon: icon,
      label: label,
      destructive: destructive,
      busy: busy,
      variant: AppButtonVariant.secondary,
      size: AppButtonSize.compact,
    );
  }
}
