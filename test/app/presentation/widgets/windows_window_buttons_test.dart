import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mochi_player/app/presentation/widgets/windows_window_buttons.dart';
import 'package:mochi_player/core/platform/window_controls_layout.dart';
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
    'renders compact buttons and invokes Windows window commands',
    (tester) async {
      await tester.pumpWidget(_testApp(const WindowsWindowButtons()));
      await tester.pump();

      expect(
        tester.getSize(find.byType(WindowsWindowButtons)),
        const Size(88, 60),
      );
      expect(
        WindowControlsLayout.leadingInset + 88,
        lessThan(WindowControlsLayout.leadingContentInset),
      );
      expect(find.bySemanticsLabel('最小化'), findsOneWidget);
      expect(find.bySemanticsLabel('最大化'), findsOneWidget);
      expect(find.bySemanticsLabel('关闭'), findsOneWidget);

      final buttons = find.descendant(
        of: find.byType(WindowsWindowButtons),
        matching: find.byType(TweenAnimationBuilder<double>),
      );
      expect(buttons, findsNWidgets(3));
      for (final element in buttons.evaluate()) {
        expect(
          tester.getSize(find.byWidget(element.widget)),
          const Size(28, 28),
        );
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

  testWindowsWidgets('uses hover color without adding a pressed color', (
    tester,
  ) async {
    await tester.pumpWidget(_testApp(const WindowsWindowButtons()));
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
      return (tester.widget<Container>(container).decoration! as BoxDecoration)
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
  });

  testWindowsWidgets('shows restore for a maximized window', (tester) async {
    isMaximized = true;

    await tester.pumpWidget(_testApp(const WindowsWindowButtons()));
    await tester.pump();

    expect(find.bySemanticsLabel('还原'), findsOneWidget);
    expect(find.bySemanticsLabel('最大化'), findsNothing);
    await tester.tap(find.bySemanticsLabel('还原'));
    await tester.pump();
    expect(methodCalls, contains('unmaximize'));
  });

  testWindowsWidgets('hides buttons in fullscreen', (tester) async {
    isFullScreen = true;

    await tester.pumpWidget(_testApp(const WindowsWindowButtons()));
    await tester.pump();

    expect(find.bySemanticsLabel('最小化'), findsNothing);
    expect(tester.getSize(find.byType(WindowsWindowButtons)), Size.zero);
  });
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
      body: Align(alignment: Alignment.topLeft, child: child),
    ),
  );
}
