import 'package:flutter/material.dart';

import 'app_colors.dart';

// 1. 定义自定义主题扩展
@immutable
class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  const AppThemeExtension({
    required this.searchBarColor,
    required this.searchBarHintColor,
    required this.searchBarIconColor,
    required this.keyCapColor,
    required this.keyCapTextColor,
    required this.cardShadowColor,
  });

  final Color searchBarColor;
  final Color searchBarHintColor;
  final Color searchBarIconColor;
  final Color keyCapColor;
  final Color keyCapTextColor;
  final Color cardShadowColor; // 为卡片阴影添加颜色

  @override
  AppThemeExtension copyWith({
    Color? searchBarColor,
    Color? searchBarHintColor,
    Color? searchBarIconColor,
    Color? keyCapColor,
    Color? keyCapTextColor,
    Color? cardShadowColor,
  }) {
    return AppThemeExtension(
      searchBarColor: searchBarColor ?? this.searchBarColor,
      searchBarHintColor: searchBarHintColor ?? this.searchBarHintColor,
      searchBarIconColor: searchBarIconColor ?? this.searchBarIconColor,
      keyCapColor: keyCapColor ?? this.keyCapColor,
      keyCapTextColor: keyCapTextColor ?? this.keyCapTextColor,
      cardShadowColor: cardShadowColor ?? this.cardShadowColor,
    );
  }

  @override
  AppThemeExtension lerp(ThemeExtension<AppThemeExtension>? other, double t) {
    if (other is! AppThemeExtension) {
      return this;
    }
    return AppThemeExtension(
      searchBarColor: Color.lerp(searchBarColor, other.searchBarColor, t)!,
      searchBarHintColor: Color.lerp(
        searchBarHintColor,
        other.searchBarHintColor,
        t,
      )!,
      searchBarIconColor: Color.lerp(
        searchBarIconColor,
        other.searchBarIconColor,
        t,
      )!,
      keyCapColor: Color.lerp(keyCapColor, other.keyCapColor, t)!,
      keyCapTextColor: Color.lerp(keyCapTextColor, other.keyCapTextColor, t)!,
      cardShadowColor: Color.lerp(cardShadowColor, other.cardShadowColor, t)!,
    );
  }
}

// 2. 定义浅色和深色主题
class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    useMaterial3: true,
    primaryColor: AppColors.accent,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.accent,
      brightness: Brightness.light,
      primary: AppColors.accent,
      secondary: AppColors.accent,
    ),
    scaffoldBackgroundColor: Colors.white,
    canvasColor: const Color(0xFFF5F5F7),
    dividerColor: const Color(0xFFE5E5E5),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: Color(0xFF1D1D1F)), // 主要文字
      // 恢复次要文字为更深的颜色，以获得更高对比度
      titleMedium: TextStyle(color: Color(0xFF1D1D1F)),
    ),
    extensions: const <ThemeExtension<dynamic>>[
      AppColorSchemeExtension(
        textPrimary: Color(0xFF1D1D1F),
        textSecondary: Color(0xA61D1D1F),
        separator: Color(0xFFE5E5EA),
        sidebarBackground: Color(0xFFF5F5F7),
        elevatedSurface: Color(0xFFF2F2F7),
        subtleSurface: Color(0x06000000),
        hoverSurface: Color(0x0D1D1D1F),
        inputBackground: Color(0xD2FFFFFF),
        headerBackground: Color(0xD9FFFFFF),
        activitySurface: Color(0xEBFFFFFF),
        modalSurface: Colors.white,
        selectMenuSurface: Colors.white,
        selectControlSurface: Color(0x06000000),
        selectBorder: Color(0x181D1D1F),
        mediaHoverOverlay: Colors.white,
      ),
      AppThemeExtension(
        searchBarColor: Color(0xFFF2F2F7),
        searchBarHintColor: Color(0xFF8E8E93),
        searchBarIconColor: Color(0xFF8E8E93),
        keyCapColor: Colors.white,
        keyCapTextColor: Color(0xFF8E8E93),
        cardShadowColor: Colors.black,
      ),
    ],
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    // 恢复为你喜欢的、更深的蓝色
    primaryColor: AppColors.accentDark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.accentDark,
      brightness: Brightness.dark,
      primary: AppColors.accentDark,
      secondary: AppColors.accentDark,
    ),
    scaffoldBackgroundColor: const Color(0xFF1C1C1E),
    // 主背景
    canvasColor: const Color(0xFF2C2C2E),
    // 侧边栏背景
    dividerColor: const Color(0xFF3A3A3C),
    textTheme: const TextTheme(
      // 恢复侧边栏和次要文字为更亮的颜色，以获得更高对比度
      bodyMedium: TextStyle(color: Color(0xFFE5E5E7)), // 主要文字
      titleMedium: TextStyle(color: Color(0xFFE5E5E7)), // 次要文字 (恢复亮度)
    ),
    extensions: const <ThemeExtension<dynamic>>[
      AppColorSchemeExtension(
        textPrimary: Color(0xFFF5F5F7),
        textSecondary: Color(0xA6F5F5F7),
        separator: Color(0xFF3A3A3C),
        sidebarBackground: Color(0xFF202023),
        elevatedSurface: Color(0xFF2C2C2E),
        subtleSurface: Color(0x0CFFFFFF),
        hoverSurface: Color(0x16F5F5F7),
        inputBackground: Color(0x24000000),
        headerBackground: Color(0xD92C2C2E),
        activitySurface: Color(0xF21F1F22),
        modalSurface: Color(0xFF2C2C2E),
        selectMenuSurface: Color(0xFF2A2A2D),
        selectControlSurface: Color(0x0EFFFFFF),
        selectBorder: Color(0x2AF5F5F7),
        mediaHoverOverlay: Colors.black,
      ),
      AppThemeExtension(
        searchBarColor: Color(0xFF3A3A3C),
        searchBarHintColor: Color(0xFF8E8E93),
        searchBarIconColor: Color(0xFF8E8E93),
        keyCapColor: Color(0xFF4A4A4C),
        keyCapTextColor: Color(0xFFE5E5E7),
        cardShadowColor: Colors.black,
      ),
    ],
  );
}
