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

      final glass = tester.widget<AppGlassSurface>(
        find.descendant(of: backButton, matching: find.byType(AppGlassSurface)),
      );
      expect(
        glass.borderRadius,
        const BorderRadius.all(Radius.circular(AppRadii.control)),
      );
      expect(glass.color, PlayerChromeGlass.background);
      expect(glass.borderColor, PlayerChromeGlass.border);
      expect(glass.blur, PlayerChromeGlass.blur);
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
      expect(tester.getTopLeft(panel).dx, 252);
      expect(tester.getTopRight(panel).dx, 948);
      expect(tester.getSize(panel).height, 64);
      expect(tester.getBottomRight(panel).dy, 700 - AppSpacing.md);
      final glass = tester.widget<AppGlassSurface>(panel);
      expect(glass.color, PlayerChromeGlass.background);
      expect(glass.borderColor, PlayerChromeGlass.border);
      expect(glass.blur, PlayerChromeGlass.blur);
      expect(
        tester.getTopLeft(find.byKey(const ValueKey('progress'))).dy,
        lessThan(tester.getTopLeft(find.byKey(const ValueKey('controls'))).dy),
      );
    },
  );

  testWidgets('lets the bottom control bar move within the player bounds', (
    tester,
  ) async {
    var buttonPresses = 0;
    Rect? reportedBounds;
    await tester.binding.setSurfaceSize(const Size(1200, 700));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      _testApp(
        Align(
          alignment: Alignment.bottomCenter,
          child: PlayerBottomControlBar(
            onBoundsChanged: (bounds) => reportedBounds = bounds,
            progress: const SizedBox(height: 10),
            controls: PlayerControlButton(
              key: const ValueKey('test-player-control'),
              onPressed: () => buttonPresses++,
              child: const Icon(Icons.play_arrow_rounded),
            ),
          ),
        ),
      ),
    );

    final panel = find.byKey(const ValueKey('player-bottom-control-bar'));
    final originalTopLeft = tester.getTopLeft(panel);
    expect(reportedBounds?.topLeft, originalTopLeft);
    expect(
      find.byKey(const ValueKey('player-control-bar-drag-handle')),
      findsNothing,
    );
    await tester.dragFrom(
      originalTopLeft +
          Offset(
            tester.getSize(panel).width - 8,
            tester.getSize(panel).height - 8,
          ),
      const Offset(80, -100),
    );
    await tester.pumpAndSettle();

    expect(tester.getTopLeft(panel), originalTopLeft + const Offset(80, -100));
    expect(reportedBounds?.topLeft, originalTopLeft + const Offset(80, -100));
    await tester.tap(find.byKey(const ValueKey('test-player-control')));
    expect(buttonPresses, 1);
  });

  test('uses a compact width in regular and mini-player windows', () {
    expect(PlayerChromeLayout.bottomPanelWidth(1200), 696);
    expect(PlayerChromeLayout.bottomPanelWidth(480), 448);
    expect(PlayerChromeLayout.bottomPanelWidth(2400), 1040);
  });

  test('scales subtitle text continuously with the player viewport', () {
    expect(
      PlayerSubtitleSizing.fontSize(
        configuredFontSize: 32,
        viewportSize: const Size(1200, 700),
      ),
      32,
    );
    expect(
      PlayerSubtitleSizing.fontSize(
        configuredFontSize: 32,
        viewportSize: const Size(480, 300),
      ),
      12.8,
    );
    expect(
      PlayerSubtitleSizing.fontSize(
        configuredFontSize: 32,
        viewportSize: const Size(900, 600),
      ),
      24,
    );
  });

  testWidgets(
    'keeps subtitles at the bottom unless the control bar overlaps them',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 700));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      Widget subtitleLayout(Rect controlBarBounds) => _testApp(
        PlayerSubtitleAvoidingControls(
          controlsVisible: true,
          isMiniPlayer: false,
          controlBarBounds: controlBarBounds,
          child: const SizedBox(
            key: ValueKey('test-subtitle'),
            width: 240,
            height: 40,
          ),
        ),
      );

      await tester.pumpWidget(
        subtitleLayout(const Rect.fromLTWH(252, 624, 696, 64)),
      );
      expect(
        tester.getTopLeft(find.byKey(const ValueKey('test-subtitle'))).dy,
        580,
      );

      await tester.pumpWidget(
        subtitleLayout(const Rect.fromLTWH(252, 524, 696, 64)),
      );
      expect(
        tester.getTopLeft(find.byKey(const ValueKey('test-subtitle'))).dy,
        640,
      );
    },
  );

  testWidgets('keeps subtitles at the bottom while controls are hidden', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1200, 700));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      _testApp(
        const PlayerSubtitleAvoidingControls(
          controlsVisible: false,
          isMiniPlayer: false,
          controlBarBounds: Rect.fromLTWH(252, 624, 696, 64),
          child: SizedBox(
            key: ValueKey('test-subtitle'),
            width: 240,
            height: 40,
          ),
        ),
      ),
    );

    expect(
      tester.getTopLeft(find.byKey(const ValueKey('test-subtitle'))).dy,
      640,
    );
  });

  testWidgets('mini-player exposes playback, pin and restore controls', (
    tester,
  ) async {
    await tester.pumpWidget(
      _testApp(
        Center(
          child: PlayerMiniControls(
            isPlaying: true,
            isAlwaysOnTop: true,
            onPlayPause: () {},
            onToggleAlwaysOnTop: () {},
            onRestoreWindow: () {},
          ),
        ),
      ),
    );

    expect(find.byType(PlayerControlButton), findsNothing);
    expect(find.byType(Tooltip), findsNothing);
    expect(
      tester.getSize(find.byKey(const ValueKey('player-mini-controls'))),
      const Size(106, 38),
    );
    expect(find.byIcon(Icons.pause_rounded), findsOneWidget);
    expect(find.byIcon(Icons.push_pin_rounded), findsOneWidget);
    expect(find.byIcon(Icons.open_in_full_rounded), findsOneWidget);
  });
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
