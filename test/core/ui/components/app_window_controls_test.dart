import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mochi_player/core/ui/app_ui.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const windowManagerChannel = MethodChannel('window_manager');
  late List<String> methodCalls;
  var isMaximized = false;
  var isFullScreen = false;

  setUp(() {
    methodCalls = [];
    isMaximized = false;
    isFullScreen = false;

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(windowManagerChannel, (call) async {
          methodCalls.add(call.method);
          return switch (call.method) {
            'isMaximized' => isMaximized,
            'isFullScreen' => isFullScreen,
            _ => null,
          };
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(windowManagerChannel, null);
  });

  testWindowsWidgets(
    'renders compact Windows controls and invokes window commands',
    (tester) async {
      await tester.pumpWidget(_testApp(const AppWindowControls()));
      await tester.pump();

      expect(
        tester.getSize(find.byType(AppWindowControls)),
        const Size(AppWindowControls.width, AppWindowControls.height),
      );
      expect(
        AppWindowChromeMetrics.leadingInset + AppWindowControls.width,
        lessThan(AppWindowChromeMetrics.leadingContentInset),
      );
      expect(find.bySemanticsLabel('最小化'), findsOneWidget);
      expect(find.bySemanticsLabel('最大化'), findsOneWidget);
      expect(find.bySemanticsLabel('关闭'), findsOneWidget);
      final buttons = find.descendant(
        of: find.byType(AppWindowControls),
        matching: find.byType(TweenAnimationBuilder<double>),
      );
      expect(buttons, findsNWidgets(3));
      for (final element in buttons.evaluate()) {
        expect(
          tester.getSize(find.byWidget(element.widget)),
          const Size.square(AppWindowControls.buttonSize),
        );
        final buttonContainer = find.descendant(
          of: find.byWidget(element.widget),
          matching: find.byType(Container),
        );
        final decoration =
            tester.widget<Container>(buttonContainer).decoration!
                as BoxDecoration;
        expect(decoration.borderRadius, BorderRadius.circular(9));
      }

      await tester.tap(find.bySemanticsLabel('最小化'));
      await tester.tap(find.bySemanticsLabel('最大化'));
      await tester.tap(find.bySemanticsLabel('关闭'));
      await tester.pump();

      expect(
        methodCalls,
        containsAllInOrder(['minimize', 'maximize', 'close']),
      );
    },
  );

  testWindowsWidgets(
    'uses hover-only color and keeps it unchanged while pressed',
    (tester) async {
      await tester.pumpWidget(_testApp(const AppWindowControls()));
      await tester.pump();

      final closeButton = find.bySemanticsLabel('关闭');
      final animatedButton = find.descendant(
        of: closeButton,
        matching: find.byType(TweenAnimationBuilder<double>),
      );

      Color buttonColor() {
        final container = find.descendant(
          of: animatedButton,
          matching: find.byType(Container),
        );
        return (tester.widget<Container>(container).decoration!
                as BoxDecoration)
            .color!;
      }

      final context = tester.element(closeButton);
      expect(buttonColor(), AppColors.favorite(context).withAlpha(0));

      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: Offset.zero);
      final center = tester.getCenter(closeButton);
      await mouse.moveTo(center);
      await tester.pumpAndSettle();
      final expectedHoverColor = AppColors.favorite(context).withAlpha(34);
      expect(buttonColor(), expectedHoverColor);

      await mouse.down(center);
      await tester.pump();
      expect(buttonColor(), expectedHoverColor);
      await mouse.up();
      await mouse.removePointer();
    },
  );

  testWindowsWidgets('shows restore for a maximized window', (tester) async {
    isMaximized = true;

    await tester.pumpWidget(_testApp(const AppWindowControls()));
    await tester.pump();

    expect(find.bySemanticsLabel('还原'), findsOneWidget);
    expect(find.bySemanticsLabel('最大化'), findsNothing);
    await tester.tap(find.bySemanticsLabel('还原'));
    await tester.pump();
    expect(methodCalls, contains('unmaximize'));
  });

  testWindowsWidgets('hides controls in fullscreen', (tester) async {
    isFullScreen = true;

    await tester.pumpWidget(_testApp(const AppWindowControls()));
    await tester.pump();

    expect(find.bySemanticsLabel('最小化'), findsNothing);
    expect(tester.getSize(find.byType(AppWindowControls)), Size.zero);
  });

  testWindowsWidgets(
    'keeps the shared header independent from caption buttons',
    (tester) async {
      await tester.pumpWidget(
        _testApp(
          const SizedBox(
            width: 800,
            child: AppHeader(title: '文件浏览', searchWidth: 240),
          ),
        ),
      );
      await tester.pump();

      final headerRight = tester.getTopRight(find.byType(AppHeader)).dx;
      final searchRight = tester.getTopRight(find.byType(AppSearchBar)).dx;
      expect(headerRight - searchRight, AppSpacing.page);
    },
  );
}

void testWindowsWidgets(String description, WidgetTesterCallback callback) {
  testWidgets(description, (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    try {
      await callback(tester);
    } finally {
      await tester.pumpWidget(const SizedBox.shrink());
      debugDefaultTargetPlatformOverride = null;
    }
  });
}

Widget _testApp(Widget child) {
  return MaterialApp(
    theme: AppTheme.lightTheme,
    darkTheme: AppTheme.darkTheme,
    home: Scaffold(
      body: Align(alignment: Alignment.topRight, child: child),
    ),
  );
}
