import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mochi_player/providers/app_settings_provider.dart';
import 'package:mochi_player/providers/file_browser_provider.dart';
import 'package:mochi_player/providers/media_library_provider.dart';
import 'package:mochi_player/providers/theme_provider.dart';
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

  bool _controllersInitialized = false;
  bool _showWebDavPassword = false;
  bool _showTmdbApiKey = false;

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final settingsProvider = context.watch<AppSettingsProvider>();

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
                    'Settings',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 40),
                  _buildThemeSettings(context, themeProvider),
                  const SizedBox(height: 36),
                  _buildWebDavSettings(context),
                  const SizedBox(height: 36),
                  _buildTmdbSettings(context),
                  const SizedBox(height: 36),
                  _buildLibraryMaintenance(context),
                  const SizedBox(height: 32),
                  _buildActions(context, settingsProvider),
                  if (settingsProvider.error != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      settingsProvider.error!,
                      style: const TextStyle(color: Colors.redAccent),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeSettings(
    BuildContext context,
    ThemeProvider themeProvider,
  ) {
    return _SettingsSection(
      title: 'Appearance',
      child: SegmentedButton<ThemeMode>(
        segments: const [
          ButtonSegment(
            value: ThemeMode.light,
            label: Text('Light'),
            icon: Icon(Icons.light_mode_outlined),
          ),
          ButtonSegment(
            value: ThemeMode.dark,
            label: Text('Dark'),
            icon: Icon(Icons.dark_mode_outlined),
          ),
          ButtonSegment(
            value: ThemeMode.system,
            label: Text('System'),
            icon: Icon(Icons.computer_rounded),
          ),
        ],
        selected: {themeProvider.themeMode},
        onSelectionChanged: (selection) {
          themeProvider.setTheme(selection.first);
        },
      ),
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
              label: 'Server URL',
              icon: Icons.link_rounded,
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _webDavUsernameController,
            decoration: _inputDecoration(
              context,
              label: 'Username',
              icon: Icons.person_outline_rounded,
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _webDavPasswordController,
            obscureText: !_showWebDavPassword,
            decoration: _inputDecoration(
              context,
              label: 'Password',
              icon: Icons.lock_outline_rounded,
              suffixIcon: IconButton(
                tooltip: _showWebDavPassword ? 'Hide' : 'Show',
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
              label: 'API Key',
              icon: Icons.key_rounded,
              suffixIcon: IconButton(
                tooltip: _showTmdbApiKey ? 'Hide' : 'Show',
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
              label: 'API Base URL',
              icon: Icons.travel_explore_rounded,
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _tmdbProxyUrlController,
            keyboardType: TextInputType.url,
            decoration: _inputDecoration(
              context,
              label: 'HTTP Proxy',
              icon: Icons.route_rounded,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(
    BuildContext context,
    AppSettingsProvider settingsProvider,
  ) {
    final isBusy = settingsProvider.isSaving;

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
          label: Text(settingsProvider.isSaving ? 'Saving' : 'Save'),
        ),
        OutlinedButton.icon(
          onPressed: isBusy ? null : _testWebDavConnection,
          icon: const Icon(Icons.wifi_tethering_rounded),
          label: const Text('Test WebDAV'),
        ),
        OutlinedButton.icon(
          onPressed: isBusy ? null : _testTmdbConnection,
          icon: const Icon(Icons.public_rounded),
          label: const Text('Test TMDB'),
        ),
      ],
    );
  }

  Widget _buildLibraryMaintenance(BuildContext context) {
    final mediaLibraryProvider = context.watch<MediaLibraryProvider>();
    final isBusy = mediaLibraryProvider.isLoading;

    return _SettingsSection(
      title: 'Library',
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
            label: Text(isBusy ? 'Rescraping' : 'Rescrape Library'),
          ),
          OutlinedButton.icon(
            onPressed: isBusy ? null : _confirmClearLibrary,
            icon: const Icon(Icons.delete_sweep_outlined),
            label: const Text('Clear Media Library'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.redAccent,
              side: const BorderSide(color: Colors.redAccent),
            ),
          ),
        ],
      ),
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

    messenger.showSnackBar(const SnackBar(content: Text('Settings saved')));
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
        content: Text(isConnected ? 'WebDAV connected' : 'WebDAV failed'),
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
        content: Text(isConnected ? 'TMDB connected' : 'TMDB failed'),
        backgroundColor: isConnected ? null : Colors.redAccent,
      ),
    );
  }

  Future<void> _confirmRescrapeLibrary() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Rescrape media library?'),
          content: const Text(
            'This clears local metadata and TMDB matches, then scrapes the existing scanned files again. '
            'Watch progress, favorites, and WebDAV files are kept.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Rescrape'),
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
          content: Text('Set a TMDB API key before rescraping'),
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
        content: Text(error ?? 'Media library rescraped from WebDAV root'),
        backgroundColor: error == null ? null : Colors.redAccent,
      ),
    );
  }

  Future<void> _confirmClearLibrary() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Clear media library?'),
          content: const Text(
            'This clears local scanned files, metadata, watch progress, and favorites. '
            'It will not delete files from WebDAV.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
              child: const Text('Clear'),
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

    messenger.showSnackBar(
      const SnackBar(content: Text('Media library cleared')),
    );
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
    return true;
  }

  void _syncControllers(AppSettingsProvider settingsProvider) {
    _webDavUrlController.text = settingsProvider.webDavUrl;
    _webDavUsernameController.text = settingsProvider.webDavUsername;
    _webDavPasswordController.text = settingsProvider.webDavPassword;
    _tmdbApiKeyController.text = settingsProvider.tmdbApiKey;
    _tmdbApiBaseUrlController.text = settingsProvider.tmdbApiBaseUrl;
    _tmdbProxyUrlController.text = settingsProvider.tmdbProxyUrl;
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
