import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mochi_player/core/ui/app_ui.dart';

void main() {
  testWidgets('uses hover color spaces for transparent surfaces and borders', (
    tester,
  ) async {
    const surfaceKey = Key('hover-surface');
    const hoverBorderColor = Color(0xFF3A3A3C);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: AppHoverSurface(
                key: surfaceKey,
                onTap: () {},
                borderRadius: BorderRadius.zero,
                hoverColor: AppColors.hoverSurface(context),
                borderColor: Colors.transparent,
                hoverBorderColor: hoverBorderColor,
                child: const SizedBox(width: 80, height: 40),
              ),
            ),
          ),
        ),
      ),
    );

    final context = tester.element(find.byKey(surfaceKey));
    final hoverColor = AppColors.hoverSurface(context);
    final container = tester.widget<AnimatedContainer>(
      find.descendant(
        of: find.byKey(surfaceKey),
        matching: find.byType(AnimatedContainer),
      ),
    );
    final decoration = container.decoration! as BoxDecoration;

    expect(decoration.color, hoverColor.withAlpha(0));
    expect(
      (decoration.border! as Border).top.color,
      hoverBorderColor.withAlpha(0),
    );
  });
}
