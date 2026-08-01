import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mochi_player/core/ui/app_ui.dart';

void main() {
  testWidgets('uses hover color spaces for transparent areas and borders', (
    tester,
  ) async {
    const areaKey = Key('clickable-area');
    const hoverBorderColor = Color(0xFF3A3A3C);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: AppClickableArea(
                key: areaKey,
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

    final context = tester.element(find.byKey(areaKey));
    final hoverColor = AppColors.hoverSurface(context);
    final container = tester.widget<Container>(
      find.descendant(
        of: find.byKey(areaKey),
        matching: find.byType(Container),
      ),
    );
    final decoration = container.decoration! as BoxDecoration;

    expect(decoration.color, hoverColor.withAlpha(0));
    expect(
      (decoration.border! as Border).top.color,
      hoverBorderColor.withAlpha(0),
    );
  });

  testWidgets('supports a hover border without a resting border', (
    tester,
  ) async {
    const areaKey = Key('hover-border-only-area');
    const hoverBorderColor = Color(0xFF7065A8);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AppClickableArea(
            key: areaKey,
            onTap: _noop,
            borderRadius: BorderRadius.zero,
            hoverColor: Colors.transparent,
            hoverBorderColor: hoverBorderColor,
            child: SizedBox(width: 80, height: 40),
          ),
        ),
      ),
    );

    Color borderColor() {
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byKey(areaKey),
          matching: find.byType(Container),
        ),
      );
      return (container.decoration! as BoxDecoration).border!.top.color;
    }

    expect(borderColor(), hoverBorderColor.withAlpha(0));

    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer(location: Offset.zero);
    await gesture.moveTo(tester.getCenter(find.byKey(areaKey)));
    await tester.pumpAndSettle();
    expect(borderColor(), hoverBorderColor);
    await gesture.removePointer();
  });

  testWidgets('keeps the hover color unchanged while pressed', (tester) async {
    const areaKey = Key('opaque-clickable-area');
    const backgroundColor = Color(0xFF202023);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: Scaffold(
          body: Center(
            child: AppClickableArea(
              key: areaKey,
              onTap: () {},
              borderRadius: BorderRadius.zero,
              backgroundColor: backgroundColor,
              hoverColor: const Color(0x16F5F5F7),
              child: const SizedBox(width: 80, height: 40),
            ),
          ),
        ),
      ),
    );

    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer(location: Offset.zero);
    final center = tester.getCenter(find.byKey(areaKey));
    await gesture.moveTo(center);
    await tester.pumpAndSettle();

    Color areaColor() {
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byKey(areaKey),
          matching: find.byType(Container),
        ),
      );
      return (container.decoration! as BoxDecoration).color!;
    }

    final expectedHoverColor = Color.alphaBlend(
      const Color(0x16F5F5F7),
      backgroundColor,
    );
    expect(areaColor(), expectedHoverColor);

    await gesture.down(center);
    await tester.pump();
    expect(areaColor(), expectedHoverColor);

    await gesture.up();
    await gesture.removePointer();
  });

  testWidgets('applies external state colors without an implicit transition', (
    tester,
  ) async {
    const areaKey = Key('stateful-clickable-area');
    const selectedColor = Color(0xFF35323F);
    late StateSetter updateState;
    var selected = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              updateState = setState;
              return AppClickableArea(
                key: areaKey,
                onTap: () {},
                borderRadius: BorderRadius.zero,
                backgroundColor: selected ? selectedColor : Colors.transparent,
                hoverColor: selected
                    ? Colors.transparent
                    : AppColors.hoverSurface(context),
                child: const SizedBox(width: 80, height: 40),
              );
            },
          ),
        ),
      ),
    );

    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer(location: Offset.zero);
    await gesture.moveTo(tester.getCenter(find.byKey(areaKey)));
    await tester.pumpAndSettle();

    updateState(() => selected = true);
    await tester.pump();

    final container = tester.widget<Container>(
      find.descendant(
        of: find.byKey(areaKey),
        matching: find.byType(Container),
      ),
    );
    expect((container.decoration! as BoxDecoration).color, selectedColor);

    await gesture.removePointer();
  });
}

void _noop() {}
