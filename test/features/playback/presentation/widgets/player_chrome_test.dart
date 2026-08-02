import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mochi_player/core/ui/app_ui.dart';
import 'package:mochi_player/features/playback/presentation/widgets/player_chrome.dart';

void main() {
  testWidgets('places the back button after macOS window controls', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1200, 700));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
    try {
      await tester.pumpWidget(
        _testApp(
          PlayerTopBar(
            title: '进击的巨人',
            secondaryTitle: '第 1 季 · 第 1 集',
            systemTime: '18:11',
            isFullScreen: false,
            onBack: () {},
          ),
        ),
      );

      final backButton = find.byKey(const ValueKey('player-back-button'));
      expect(
        tester.getTopLeft(backButton).dx,
        AppWindowChromeMetrics.leadingContentInset,
      );
      expect(tester.getSize(backButton), const Size(38, 36));
      expect(find.text('进击的巨人'), findsOneWidget);
      expect(find.text('第 1 季 · 第 1 集'), findsOneWidget);

      final time = find.byKey(const ValueKey('player-system-time'));
      expect(tester.getTopRight(time).dx, 1176);

      final glass = tester.widget<GlassSurface>(
        find.descendant(of: backButton, matching: find.byType(GlassSurface)),
      );
      expect(
        glass.borderRadius,
        const BorderRadius.all(Radius.circular(AppRadii.control)),
      );
    } finally {
      await tester.pumpWidget(const SizedBox.shrink());
      debugDefaultTargetPlatformOverride = null;
    }
  });

  test('uses the same leading content inset on Windows and macOS', () {
    expect(
      PlayerChromeLayout.topLeftInset(
        platform: TargetPlatform.windows,
        isFullScreen: false,
      ),
      PlayerChromeLayout.topLeftInset(
        platform: TargetPlatform.macOS,
        isFullScreen: false,
      ),
    );
  });

  testWidgets('uses the regular page inset in fullscreen', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 700));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      _testApp(
        PlayerTopBar(
          title: '电影',
          systemTime: '18:11',
          isFullScreen: true,
          onBack: () {},
        ),
      ),
    );

    expect(
      tester.getTopLeft(find.byKey(const ValueKey('player-back-button'))).dx,
      AppSpacing.xxl,
    );
  });

  testWidgets(
    'keeps the bottom glass panel inset and progress above controls',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 700));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        _testApp(
          const Align(
            alignment: Alignment.bottomCenter,
            child: PlayerBottomControlBar(
              progress: SizedBox(key: ValueKey('progress'), height: 10),
              controls: SizedBox(
                key: ValueKey('controls'),
                height: PlayerChromeLayout.controlHeight,
              ),
            ),
          ),
        ),
      );

      final panel = find.byKey(const ValueKey('player-bottom-control-bar'));
      expect(tester.getTopLeft(panel).dx, 180);
      expect(tester.getTopRight(panel).dx, 1020);
      expect(tester.getSize(panel).height, 64);
      expect(tester.getBottomRight(panel).dy, 700 - AppSpacing.md);
      final glass = tester.widget<GlassSurface>(panel);
      expect(glass.color, const Color(0x80000000));
      expect(glass.blur, 16);
      expect(
        tester.getTopLeft(find.byKey(const ValueKey('progress'))).dy,
        lessThan(tester.getTopLeft(find.byKey(const ValueKey('controls'))).dy),
      );
    },
  );
}

Widget _testApp(Widget child) {
  return MaterialApp(
    theme: AppTheme.darkTheme.copyWith(platform: TargetPlatform.macOS),
    home: Scaffold(
      backgroundColor: Colors.black,
      body: MediaQuery(
        data: const MediaQueryData(size: Size(1200, 700)),
        child: SizedBox(width: 1200, height: 700, child: child),
      ),
    ),
  );
}
