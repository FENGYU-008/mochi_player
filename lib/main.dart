import 'dart:io';

import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:mochi_player/features/settings/application/app_settings_provider.dart';
import 'package:mochi_player/features/home/application/trending_media_provider.dart';
import 'package:mochi_player/features/library/application/media_library_provider.dart';
import 'package:mochi_player/features/settings/application/theme_provider.dart';
import 'package:mochi_player/core/ui/theme/app_theme.dart';
import 'package:mochi_player/core/ui/components/navigation/app_window_controls.dart';
import 'package:mochi_player/core/infrastructure/database/database_service.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'package:mochi_player/features/library/application/file_browser_provider.dart';
import 'package:mochi_player/app/presentation/pages/app_shell_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  await windowManager.ensureInitialized();

  // 初始化数据库
  await DatabaseService().init();

  final appSettingsProvider = AppSettingsProvider();
  await appSettingsProvider.load();

  final windowOptions = WindowOptions(
    size: const Size(1200, 800),
    minimumSize: const Size(900, 600),
    center: true,
    title: 'Mochi Player',
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden,
    windowButtonVisibility: Platform.isMacOS,
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
    if (Platform.isMacOS) {
      await AppWindowControls.positionNativeWindowButtons();
    }
  });

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: appSettingsProvider),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => FileBrowserProvider()),
        ChangeNotifierProvider(create: (_) => MediaLibraryProvider()),
        ChangeNotifierProvider(create: (_) => TrendingMediaProvider()),
      ],
      child: const MochiPlayerApp(),
    ),
  );
}

class MochiPlayerApp extends StatelessWidget {
  const MochiPlayerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Mochi Player',
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.themeMode,
      themeAnimationDuration: kThemeAnimationDuration,
      themeAnimationCurve: Curves.linear,

      // 直接使用从 AppTheme 类中导入的主题
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,

      builder: (context, child) {
        return Stack(
          children: [
            Positioned.fill(child: child ?? const SizedBox.shrink()),
            if (AppWindowControls.isVisible)
              const Positioned(
                top: 0,
                left: AppWindowChromeMetrics.leadingInset,
                child: AppWindowControls(),
              ),
          ],
        );
      },

      home: const AppShellPage(),
    );
  }
}
