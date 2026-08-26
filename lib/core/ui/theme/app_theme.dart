import 'package:flutter/material.dart';
import 'package:mochi_player/core/ui/theme/app_colors.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    useMaterial3: true,
    primaryColor: AppColors.primaryLight,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primaryLight,
      brightness: Brightness.light,
      primary: AppColors.primaryLight,
      secondary: AppColors.primaryLight,
    ),
    scaffoldBackgroundColor: Colors.white,
    canvasColor: const Color(0xFFF5F5F7),
    dividerColor: const Color(0xFFE5E5E5),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: Color(0xFF1D1D1F)),
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
        selectedSurface: Color(0xFFECEAF4),
        inputBackground: Color(0xD2FFFFFF),
        headerBackground: Color(0xD9FFFFFF),
        activitySurface: Color(0xEBFFFFFF),
        modalSurface: Colors.white,
        selectMenuSurface: Colors.white,
        selectControlSurface: Color(0x06000000),
        selectBorder: Color(0x181D1D1F),
        mediaHoverOverlay: Colors.white,
        searchBackground: Color(0xFFF2F2F7),
        searchHint: Color(0xFF8E8E93),
        searchIcon: Color(0xFF8E8E93),
        keyCapBackground: Colors.white,
        keyCapForeground: Color(0xFF8E8E93),
        cardShadow: Colors.black,
      ),
    ],
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    primaryColor: AppColors.primaryDark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primaryDark,
      brightness: Brightness.dark,
      primary: AppColors.primaryDark,
      secondary: AppColors.primaryDark,
    ),
    scaffoldBackgroundColor: const Color(0xFF1C1C1E),
    canvasColor: const Color(0xFF2C2C2E),
    dividerColor: const Color(0xFF3A3A3C),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: Color(0xFFE5E5E7)),
      titleMedium: TextStyle(color: Color(0xFFE5E5E7)),
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
        selectedSurface: Color(0xFF35323F),
        inputBackground: Color(0x24000000),
        headerBackground: Color(0xD92C2C2E),
        activitySurface: Color(0xF21F1F22),
        modalSurface: Color(0xFF2C2C2E),
        selectMenuSurface: Color(0xFF2A2A2D),
        selectControlSurface: Color(0x0EFFFFFF),
        selectBorder: Color(0x2AF5F5F7),
        mediaHoverOverlay: Colors.black,
        searchBackground: Color(0xFF3A3A3C),
        searchHint: Color(0xFF8E8E93),
        searchIcon: Color(0xFF8E8E93),
        keyCapBackground: Color(0xFF4A4A4C),
        keyCapForeground: Color(0xFFE5E5E7),
        cardShadow: Colors.black,
      ),
    ],
  );
}
