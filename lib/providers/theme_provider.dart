import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 用于存储主题偏好的键
const String _themePrefKey = 'theme_mode';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system; // 默认跟随系统

  ThemeMode get themeMode => _themeMode;

  ThemeProvider() {
    _loadTheme();
  }

  // 从 SharedPreferences 加载主题设置
  void _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt(_themePrefKey) ?? ThemeMode.system.index;
    _themeMode = ThemeMode.values[themeIndex];
    notifyListeners();
  }

  // 切换主题并保存到 SharedPreferences
  void setTheme(ThemeMode themeMode) async {
    if (_themeMode == themeMode) return;

    _themeMode = themeMode;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    prefs.setInt(_themePrefKey, themeMode.index);
  }
}
