import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:mochi_player/features/settings/application/app_settings_provider.dart';
import 'package:mochi_player/features/library/application/media_library_provider.dart';
import 'package:mochi_player/features/settings/application/theme_provider.dart';
import 'package:mochi_player/core/ui/theme/app_theme.dart';
import 'package:mochi_player/core/infrastructure/database/database_service.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'features/library/application/file_browser_provider.dart';
import 'app/presentation/pages/main_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  await windowManager.ensureInitialized();

  // 初始化数据库
  await DatabaseService().init();

  final appSettingsProvider = AppSettingsProvider();
  await appSettingsProvider.load();

  WindowOptions windowOptions = const WindowOptions(
    size: Size(1200, 800),
    minimumSize: Size(900, 600),
    center: true,
    title: 'Mochi Player',
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden,
    windowButtonVisibility: false,
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: appSettingsProvider),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => FileBrowserProvider()),
        ChangeNotifierProvider(create: (_) => MediaLibraryProvider()),
      ],
      child: const MyInfuseApp(),
    ),
  );
}

class MyInfuseApp extends StatelessWidget {
  const MyInfuseApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Mochi Player',
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.themeMode,

      // 直接使用从 AppTheme 类中导入的主题
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,

      home: const MainPage(),
    );
  }
}
