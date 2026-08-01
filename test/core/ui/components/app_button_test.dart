import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mochi_player/core/ui/app_ui.dart';

void main() {
  testWidgets('keeps selected overlay buttons neutral with an accent icon', (
    tester,
  ) async {
    const accent = Color(0xFFB45F73);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: AppActionButton(
            onPressed: _noop,
            icon: Icons.favorite,
            iconColor: accent,
            label: '已收藏',
            variant: AppButtonVariant.secondary,
            tone: AppControlTone.overlay,
            selected: true,
            accentColor: accent,
          ),
        ),
      ),
    );

    final container = tester.widget<Container>(
      find.descendant(
        of: find.byType(AppActionButton),
        matching: find.byType(Container),
      ),
    );
    final decoration = container.decoration! as BoxDecoration;
    expect(decoration.color, Colors.black.withAlpha(76));
    expect(
      (decoration.border! as Border).top.color,
      Colors.white.withAlpha(58),
    );
    expect(tester.widget<Icon>(find.byIcon(Icons.favorite)).color, accent);
    expect(
      tester.widget<Text>(find.text('已收藏')).style?.color,
      Colors.white.withAlpha(235),
    );
  });
}

void _noop() {}
