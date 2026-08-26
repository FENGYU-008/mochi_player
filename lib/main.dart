import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:media_kit/media_kit.dart';
import 'package:mochi_player/app/presentation/widgets/windows_window_buttons.dart';
import 'package:mochi_player/app/routing/app_router.dart';
import 'package:mochi_player/core/platform/window_controls_controller.dart';
import 'package:mochi_player/core/ui/theme/window_controls_layout.dart';
import 'package:mochi_player/features/settings/application/app_settings_provider.dart';
import 'package:mochi_player/features/home/application/trending_media_provider.dart';
import 'package:mochi_player/features/library/application/media_library_provider.dart';
import 'package:mochi_player/features/settings/application/theme_provider.dart';
import 'package:mochi_player/core/ui/theme/app_theme.dart';
import 'package:mochi_player/core/infrastructure/database/database_service.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'package:mochi_player/features/library/application/file_browser_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  await windowManager.ensureInitialized();

  // 初始化数据库
  await DatabaseService().init();

  final appSettingsProvider = AppSettingsProvider();
  await appSettingsProvider.load();
  final windowControlsController = WindowControlsController();

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
      await windowControlsController.positionNativeWindowButtons();
    }
  });

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: appSettingsProvider),
        ChangeNotifierProvider.value(value: windowControlsController),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => FileBrowserProvider()),
        ChangeNotifierProvider(create: (_) => MediaLibraryProvider()),
        ChangeNotifierProvider(create: (_) => TrendingMediaProvider()),
      ],
      child: MochiPlayerApp(router: createAppRouter()),
    ),
  );
}

class MochiPlayerApp extends StatelessWidget {
  const MochiPlayerApp({super.key, required this.router});

  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final windowControlsController = context.watch<WindowControlsController>();

    return MaterialApp.router(
      routerConfig: router,
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
            if (WindowsWindowButtons.isSupported &&
                !windowControlsController.isMiniPlayer)
              const Positioned(
                top: 0,
                left: WindowControlsLayout.leadingInset,
                child: WindowsWindowButtons(),
              ),
          ],
        );
      },
    );
  }
}
