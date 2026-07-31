import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mochi_player/core/ui/app_ui.dart';

void main() {
  testWidgets('opens the custom splash-free menu and selects an option', (
    tester,
  ) async {
    String? selected;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: Center(
            child: AppMenuButton<String>(
              tooltip: '操作',
              onSelected: (value) => selected = value,
              options: const [AppMenuOption(value: 'open', label: '打开')],
              child: const SizedBox(
                width: 36,
                height: 34,
                child: Icon(AppIcons.more),
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.byType(InkWell), findsNothing);
    expect(find.byType(PopupMenuItem<String>), findsNothing);

    await tester.tap(find.byIcon(AppIcons.more));
    await tester.pumpAndSettle();

    final menuTextContext = tester.element(find.text('打开'));
    expect(
      DefaultTextStyle.of(menuTextContext).style.decoration,
      TextDecoration.none,
    );

    await tester.tap(find.text('打开'));
    await tester.pumpAndSettle();

    expect(selected, 'open');
  });
}
