import 'package:flutter/material.dart';
import 'package:mochi_player/providers/theme_provider.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      // 为了与深色模式兼容，背景色从 scaffoldBackgroundColor 获取
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: ListView(
        padding: const EdgeInsets.all(40.0),
        children: [
          const Text(
            'Settings',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 40),
          _buildThemeSettings(context, themeProvider),
          // 在这里可以添加更多设置项
        ],
      ),
    );
  }

  Widget _buildThemeSettings(BuildContext context, ThemeProvider themeProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Appearance',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
        const SizedBox(height: 16),
        _buildThemeOption(
          context: context,
          title: 'Light',
          value: ThemeMode.light,
          currentValue: themeProvider.themeMode,
          onChanged: (mode) => themeProvider.setTheme(mode!),
        ),
        const Divider(height: 1),
        _buildThemeOption(
          context: context,
          title: 'Dark',
          value: ThemeMode.dark,
          currentValue: themeProvider.themeMode,
          onChanged: (mode) => themeProvider.setTheme(mode!),
        ),
        const Divider(height: 1),
        _buildThemeOption(
          context: context,
          title: 'System',
          value: ThemeMode.system,
          currentValue: themeProvider.themeMode,
          onChanged: (mode) => themeProvider.setTheme(mode!),
        ),
      ],
    );
  }

  // 封装的单选列表项
  Widget _buildThemeOption({
    required BuildContext context,
    required String title,
    required ThemeMode value,
    required ThemeMode currentValue,
    required ValueChanged<ThemeMode?> onChanged,
  }) {
    return RadioListTile<ThemeMode>(
      title: Text(
        title,
        style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
      ),
      value: value,
      groupValue: currentValue,
      onChanged: onChanged,
      activeColor: Theme.of(context).primaryColor,
      contentPadding: EdgeInsets.zero,
    );
  }
}
