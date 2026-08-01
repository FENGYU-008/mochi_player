import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mochi_player/core/ui/app_ui.dart';

void main() {
  testWidgets('each segment fills the control height', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: Center(
            child: AppSegmentedControl<int>(
              value: 2,
              maxWidth: 300,
              segments: const [
                AppSegment(value: 0, label: '浅色', icon: Icons.light_mode),
                AppSegment(value: 1, label: '深色', icon: Icons.dark_mode),
                AppSegment(value: 2, label: '跟随系统', icon: Icons.computer),
              ],
              onChanged: (_) {},
            ),
          ),
        ),
      ),
    );

    final areas = find.descendant(
      of: find.byType(AppSegmentedControl<int>),
      matching: find.byType(AppClickableArea),
    );

    expect(areas, findsNWidgets(3));
    for (final element in areas.evaluate()) {
      expect(tester.getSize(find.byWidget(element.widget)).height, 32);
    }
  });
}
