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
    expect(find.text('请先在设置中配置 OpenList').hitTestable(), findsOneWidget);

    await tester.tap(find.text('首页'));
    await tester.pumpAndSettle();
    expect(find.text('媒体库为空').hitTestable(), findsOneWidget);

    final settingsDestination = find.descendant(
      of: find.byType(Sidebar),
      matching: find.text('设置'),
    );
    await tester.tap(settingsDestination);
    await tester.pumpAndSettle();

    final settingsList = find.byKey(
      const PageStorageKey<String>('settings-scroll'),
    );
    await tester.drag(settingsList, const Offset(0, -400));
    await tester.pumpAndSettle();
    final scrollable = find
        .descendant(of: settingsList, matching: find.byType(Scrollable))
        .first;
    final offsetBeforeSwitch = tester
        .state<ScrollableState>(scrollable)
        .position
        .pixels;
    expect(offsetBeforeSwitch, greaterThan(0));

    await tester.tap(
      find.descendant(of: find.byType(Sidebar), matching: find.text('首页')),
    );
    await tester.pumpAndSettle();
    await tester.tap(settingsDestination);
    await tester.pumpAndSettle();

    final restoredScrollable = find
        .descendant(
          of: find.byKey(const PageStorageKey<String>('settings-scroll')),
          matching: find.byType(Scrollable),
        )
        .first;
    expect(
      tester.state<ScrollableState>(restoredScrollable).position.pixels,
      closeTo(offsetBeforeSwitch, 0.1),
    );
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
