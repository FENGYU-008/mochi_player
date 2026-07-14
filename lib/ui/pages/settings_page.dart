import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mochi_player/providers/app_settings_provider.dart';
import 'package:mochi_player/features/library/application/file_browser_provider.dart';
import 'package:mochi_player/features/library/application/media_library_provider.dart';
import 'package:mochi_player/providers/theme_provider.dart';
import 'package:mochi_player/services/app_settings_service.dart';
import 'package:mochi_player/ui/theme/app_colors.dart';
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
          child: _SettingsSegmentedControl<ThemeMode>(
            value: themeMode,
            segments: const [
              _SettingsSegment(
                value: ThemeMode.light,
                label: '浅色',
                icon: Icons.light_mode_outlined,
              ),
              _SettingsSegment(
                value: ThemeMode.dark,
                label: '深色',
                icon: Icons.dark_mode_outlined,
              ),
              _SettingsSegment(
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
    return _SettingsSection(
      title: 'WebDAV',
      child: Column(
        children: [
          _SettingsTextField(
            controller: _webDavUrlController,
            keyboardType: TextInputType.url,
            label: '服务器地址',
            icon: Icons.link_rounded,
          ),
          const SizedBox(height: 14),
          _SettingsTextField(
            controller: _webDavUsernameController,
            label: '用户名',
            icon: Icons.person_outline_rounded,
          ),
          const SizedBox(height: 14),
          _SettingsTextField(
            controller: _webDavPasswordController,
            obscureText: !_showWebDavPassword,
            label: '密码',
            icon: Icons.lock_outline_rounded,
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
  }

  Widget _buildTmdbSettings(BuildContext context) {
    return _SettingsSection(
      title: 'TMDB',
      child: Column(
        children: [
          _SettingsTextField(
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
          const SizedBox(height: 14),
          _SettingsTextField(
            controller: _tmdbApiBaseUrlController,
            keyboardType: TextInputType.url,
            label: 'API 地址',
            icon: Icons.travel_explore_rounded,
          ),
          const SizedBox(height: 14),
          _SettingsSwitchRow(
            title: '使用 TMDB 代理',
            subtitle: '用于 TMDB API 和图片下载',
            icon: Icons.route_rounded,
            value: _tmdbProxyEnabled,
            onChanged: (value) {
              setState(() {
                _tmdbProxyEnabled = value;
              });
            },
          ),
          const SizedBox(height: 14),
          _SettingsTextField(
            controller: _tmdbProxyUrlController,
            enabled: _tmdbProxyEnabled,
            keyboardType: TextInputType.url,
            label: 'HTTP 代理',
            icon: Icons.route_rounded,
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
          _SettingsFieldGrid(
            children: [
              _SettingsTextField(
                controller: _playbackCacheSizeMbController,
                keyboardType: TextInputType.number,
                label: '缓存大小',
                icon: Icons.storage_rounded,
                suffixText: 'MB',
              ),
              _SettingsTextField(
                controller: _playbackReadaheadSecondsController,
                keyboardType: TextInputType.number,
                label: '预读',
                icon: Icons.cloud_download_rounded,
                suffixText: '秒',
              ),
            ],
          ),
          const SizedBox(height: 14),
          _SettingsSwitchRow(
            title: '硬件解码',
            icon: Icons.memory_rounded,
            value: _enableHardwareAcceleration,
            onChanged: (value) {
              setState(() {
                _enableHardwareAcceleration = value;
              });
            },
          ),
          const SizedBox(height: 14),
          _SettingsTextField(
            controller: _audioLanguagePriorityController,
            label: '默认音轨语言',
            icon: Icons.graphic_eq_rounded,
          ),
          const SizedBox(height: 14),
          _SettingsTextField(
            controller: _subtitleLanguagePriorityController,
            label: '默认字幕语言',
            icon: Icons.subtitles_rounded,
          ),
          const SizedBox(height: 14),
          _SettingsSliderRow(
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
            },
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
            _SettingsActionButton(
              onPressed: isBusy ? null : _saveSettings,
              icon: Icons.save_outlined,
              label: isBusy ? '保存中' : '保存',
              primary: true,
              busy: isBusy,
            ),
            _SettingsActionButton(
              onPressed: isBusy ? null : _testWebDavConnection,
              icon: Icons.wifi_tethering_rounded,
              label: '测试 WebDAV',
            ),
            _SettingsActionButton(
              onPressed: isBusy ? null : _testTmdbConnection,
              icon: Icons.public_rounded,
              label: '测试 TMDB',
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
              _SettingsActionButton(
                onPressed: isBusy ? null : _confirmRescrapeLibrary,
                icon: Icons.manage_search_outlined,
                label: isBusy ? '刮削中' : '补全元数据',
                busy: isBusy,
              ),
              _SettingsActionButton(
                onPressed: isBusy ? null : _confirmClearLibrary,
                icon: Icons.delete_sweep_outlined,
                label: '清空媒体库',
                destructive: true,
              ),
            ],
          ),
        );
      },
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
    final messenger = ScaffoldMessenger.of(context);

    if (!settingsProvider.hasTmdbApiKey) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('补全元数据前请先设置 TMDB API 密钥'),
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
        content: Text(error ?? '已从 WebDAV 根目录补全媒体库元数据'),
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

class _SettingsSegment<T> {
  final T value;
  final String label;
  final IconData icon;

  const _SettingsSegment({
    required this.value,
    required this.label,
    required this.icon,
  });
}

class _SettingsSegmentedControl<T> extends StatelessWidget {
  final T value;
  final List<_SettingsSegment<T>> segments;
  final ValueChanged<T> onChanged;

  const _SettingsSegmentedControl({
    required this.value,
    required this.segments,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = AppColors.separator(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final controlWidth = constraints.maxWidth < 420
            ? constraints.maxWidth
            : 420.0;
        return SizedBox(
          width: controlWidth,
          child: Container(
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.elevatedSurface(context),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: borderColor),
            ),
            clipBehavior: Clip.antiAlias,
            child: Row(
              children: [
                for (var index = 0; index < segments.length; index++) ...[
                  Expanded(
                    child: _SettingsSegmentButton<T>(
                      segment: segments[index],
                      selected: segments[index].value == value,
                      onPressed: () => onChanged(segments[index].value),
                    ),
                  ),
                  if (index != segments.length - 1)
                    SizedBox(
                      height: 24,
                      child: VerticalDivider(width: 1, color: borderColor),
                    ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SettingsSegmentButton<T> extends StatefulWidget {
  final _SettingsSegment<T> segment;
  final bool selected;
  final VoidCallback onPressed;

  const _SettingsSegmentButton({
    required this.segment,
    required this.selected,
    required this.onPressed,
  });

  @override
  State<_SettingsSegmentButton<T>> createState() =>
      _SettingsSegmentButtonState<T>();
}

class _SettingsSegmentButtonState<T> extends State<_SettingsSegmentButton<T>> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.primary(context);
    final selected = widget.selected;
    final foreground = selected
        ? Colors.white
        : AppColors.textPrimary(context).withAlpha(220);
    final background = selected
        ? primary
        : _hovering
        ? AppColors.hoverSurface(context)
        : Colors.transparent;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          height: double.infinity,
          color: background,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.segment.icon, size: 17, color: foreground),
              const SizedBox(width: 7),
              Text(
                widget.segment.label,
                style: TextStyle(
                  color: foreground,
                  fontSize: 14,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                  height: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsFieldGrid extends StatelessWidget {
  final List<Widget> children;

  const _SettingsFieldGrid({required this.children});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 560) {
          return Column(
            children: [
              for (var index = 0; index < children.length; index++) ...[
                children[index],
                if (index != children.length - 1) const SizedBox(height: 14),
              ],
            ],
          );
        }

        return Row(
          children: [
            for (var index = 0; index < children.length; index++) ...[
              Expanded(child: children[index]),
              if (index != children.length - 1) const SizedBox(width: 14),
            ],
          ],
        );
      },
    );
  }
}

class _SettingsTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool enabled;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? trailing;
  final String? suffixText;

  const _SettingsTextField({
    required this.controller,
    required this.label,
    required this.icon,
    this.enabled = true,
    this.obscureText = false,
    this.keyboardType,
    this.trailing,
    this.suffixText,
  });

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.primary(context);
    final textColor = AppColors.textPrimary(context);
    final secondaryColor = AppColors.textSecondary(context);
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 120),
      opacity: enabled ? 1 : 0.5,
      child: Container(
        height: 58,
        padding: const EdgeInsets.fromLTRB(13, 7, 10, 7),
        decoration: _settingsFieldDecoration(context),
        child: Row(
          children: [
            Icon(icon, size: 21, color: enabled ? secondaryColor : null),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: secondaryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      enabled: enabled,
                      obscureText: obscureText,
                      keyboardType: keyboardType,
                      cursorColor: primary,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        height: 1.2,
                      ),
                      decoration: const InputDecoration(
                        isCollapsed: true,
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (suffixText != null) ...[
              const SizedBox(width: 8),
              Text(
                suffixText!,
                style: TextStyle(
                  color: secondaryColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
            if (trailing != null) ...[const SizedBox(width: 4), trailing!],
          ],
        ),
      ),
    );
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
      iconSize: 20,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints.tightFor(width: 32, height: 32),
      icon: Icon(
        visible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
      ),
    );
  }
}

class _SettingsSwitchRow extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsSwitchRow({
    required this.title,
    required this.icon,
    required this.value,
    required this.onChanged,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 58),
      padding: const EdgeInsets.fromLTRB(13, 9, 10, 9),
      decoration: _settingsFieldDecoration(context),
      child: Row(
        children: [
          Icon(icon, size: 21, color: AppColors.textSecondary(context)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppColors.textPrimary(context),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      color: AppColors.textSecondary(context),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      height: 1.2,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.white,
            activeTrackColor: AppColors.primary(context),
          ),
        ],
      ),
    );
  }
}

class _SettingsSliderRow extends StatelessWidget {
  final String label;
  final IconData icon;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final String displayValue;
  final ValueChanged<double> onChanged;

  const _SettingsSliderRow({
    required this.label,
    required this.icon,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.displayValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.fromLTRB(13, 8, 12, 8),
      decoration: _settingsFieldDecoration(context),
      child: Row(
        children: [
          Icon(icon, size: 21, color: AppColors.textSecondary(context)),
          const SizedBox(width: 12),
          SizedBox(
            width: 82,
            child: Text(
              label,
              style: TextStyle(
                color: AppColors.textPrimary(context),
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              label: displayValue,
              activeColor: AppColors.primary(context),
              onChanged: onChanged,
            ),
          ),
          SizedBox(
            width: 36,
            child: Text(
              displayValue,
              textAlign: TextAlign.end,
              style: TextStyle(
                color: AppColors.textPrimary(context),
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsActionButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String label;
  final bool primary;
  final bool destructive;
  final bool busy;

  const _SettingsActionButton({
    required this.onPressed,
    required this.icon,
    required this.label,
    this.primary = false,
    this.destructive = false,
    this.busy = false,
  });

  @override
  State<_SettingsActionButton> createState() => _SettingsActionButtonState();
}

class _SettingsActionButtonState extends State<_SettingsActionButton> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    final primary = AppColors.primary(context);
    final danger = Colors.redAccent;
    final background = widget.primary
        ? primary
        : widget.destructive
        ? danger.withAlpha(_hovering ? 26 : 14)
        : AppColors.elevatedSurface(context);
    final foreground = widget.primary
        ? Colors.white
        : widget.destructive
        ? danger
        : AppColors.textPrimary(context).withAlpha(220);
    final borderColor = widget.primary
        ? Colors.transparent
        : widget.destructive
        ? danger.withAlpha(_hovering ? 190 : 128)
        : AppColors.separator(context);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 120),
          opacity: enabled ? 1 : 0.5,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            curve: Curves.easeOut,
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: borderColor),
              boxShadow: widget.primary && enabled
                  ? [
                      BoxShadow(
                        color: primary.withAlpha(_hovering ? 70 : 42),
                        blurRadius: _hovering ? 14 : 10,
                        offset: const Offset(0, 5),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.busy)
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: foreground,
                    ),
                  )
                else
                  Icon(widget.icon, size: 18, color: foreground),
                const SizedBox(width: 8),
                Text(
                  widget.label,
                  style: TextStyle(
                    color: foreground,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

BoxDecoration _settingsFieldDecoration(BuildContext context) {
  return BoxDecoration(
    color: AppColors.elevatedSurface(context),
    borderRadius: BorderRadius.circular(8),
    border: Border.all(color: AppColors.separator(context)),
  );
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
