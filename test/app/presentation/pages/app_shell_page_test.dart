import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mochi_player/app/routing/app_router.dart';
import 'package:mochi_player/app/presentation/widgets/sidebar.dart';
import 'package:mochi_player/core/ui/theme/app_theme.dart';
import 'package:mochi_player/core/domain/media/movie.dart';
import 'package:mochi_player/features/home/application/trending_media_provider.dart';
import 'package:mochi_player/features/library/application/file_browser_provider.dart';
import 'package:mochi_player/features/library/application/media_library_provider.dart';
import 'package:mochi_player/features/settings/application/app_settings_provider.dart';
import 'package:mochi_player/features/settings/application/theme_provider.dart';
import 'package:mochi_player/features/settings/presentation/pages/settings_page.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('shows the selected destination inside the content navigator', (
    tester,
  ) async {
    final router = createAppRouter();
    addTearDown(router.dispose);
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AppSettingsProvider()),
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => FileBrowserProvider()),
          ChangeNotifierProvider<MediaLibraryProvider>(
            create: (_) => _TestMediaLibraryProvider(),
          ),
          ChangeNotifierProvider(create: (_) => TrendingMediaProvider()),
        ],
        child: MaterialApp.router(
          theme: AppTheme.lightTheme,
          routerConfig: router,
        ),
      ),
    );
    await tester.pump();

    expect(find.text('媒体库为空').hitTestable(), findsOneWidget);

    await tester.tap(find.text('电影'));
    await tester.pumpAndSettle();
    expect(find.text('没有找到电影').hitTestable(), findsOneWidget);

    await tester.tap(find.text('文件浏览'));
    await tester.pumpAndSettle();
    expect(find.text('媒体源').hitTestable(), findsOneWidget);

    await tester.tap(find.text('首页'));
    await tester.pumpAndSettle();
    expect(find.text('媒体库为空').hitTestable(), findsOneWidget);

    final settingsDestination = find.descendant(
      of: find.byType(Sidebar),
      matching: find.text('设置'),
    );
    await tester.tap(settingsDestination);
    await tester.pumpAndSettle();

    final mediaSourceTab = find.descendant(
      of: find.byType(SettingsPage),
      matching: find.text('媒体源'),
    );
    await tester.ensureVisible(mediaSourceTab);
    await tester.tap(mediaSourceTab);
    await tester.pumpAndSettle();
    expect(find.text('清空媒体库'), findsOneWidget);

    await tester.tap(
      find.descendant(of: find.byType(Sidebar), matching: find.text('首页')),
    );
    await tester.pumpAndSettle();
    await tester.tap(settingsDestination);
    await tester.pumpAndSettle();

    expect(find.text('清空媒体库'), findsOneWidget);
  });

  testWidgets('preserves each destination navigation stack', (tester) async {
    final router = createAppRouter();
    addTearDown(router.dispose);
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AppSettingsProvider()),
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => FileBrowserProvider()),
          ChangeNotifierProvider<MediaLibraryProvider>(
            create: (_) => _TestMediaLibraryProvider(),
          ),
          ChangeNotifierProvider(create: (_) => TrendingMediaProvider()),
        ],
        child: MaterialApp.router(
          theme: AppTheme.lightTheme,
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('电影'));
    await tester.pumpAndSettle();
    router.push(
      '/movies/media',
      extra: const Movie(tmdbId: '1', title: '测试电影'),
    );
    await tester.pumpAndSettle();
    expect(find.text('测试电影'), findsWidgets);

    await tester.tap(find.text('首页'));
    await tester.pumpAndSettle();
    expect(find.text('媒体库为空').hitTestable(), findsOneWidget);

    await tester.tap(find.text('电影'));
    await tester.pumpAndSettle();
    expect(find.text('测试电影'), findsWidgets);
  });
}

class _TestMediaLibraryProvider extends MediaLibraryProvider {
  @override
  Future<void> loadFromDatabase() async {}
}
