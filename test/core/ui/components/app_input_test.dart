import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mochi_player/core/ui/app_ui.dart';
import 'package:mochi_player/core/ui/components/input/internal/app_text_context_menu.dart';
import 'package:mochi_player/core/ui/components/overlay/internal/menu_parts.dart';

void main() {
  testWidgets('uses the width provided by its parent', (tester) async {
    final controller = TextEditingController();

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: SizedBox(width: 320, child: AppInput(controller: controller)),
        ),
      ),
    );

    expect(tester.getSize(find.byType(AppInput)).width, 320);

    await tester.pumpWidget(const SizedBox.shrink());
    controller.dispose();
  });

  testWidgets('reports a committed edit when focus leaves the field', (
    tester,
  ) async {
    final controller = TextEditingController();
    final focusNode = FocusNode();
    var focusLostCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: AppInput(
            controller: controller,
            focusNode: focusNode,
            onFocusLost: () => focusLostCount++,
          ),
        ),
      ),
    );

    focusNode.requestFocus();
    await tester.pump();
    focusNode.unfocus();
    await tester.pump();

    expect(focusLostCount, 1);

    await tester.pumpWidget(const SizedBox.shrink());
    controller.dispose();
    focusNode.dispose();
  });

  testWidgets('uses the compact application text context menu', (tester) async {
    final controller = TextEditingController(text: 'admin');
    controller.selection = const TextSelection(baseOffset: 0, extentOffset: 5);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(body: AppInput(controller: controller)),
      ),
    );

    final mouse = await tester.createGesture(
      kind: PointerDeviceKind.mouse,
      buttons: kSecondaryMouseButton,
    );
    final inputCenter = tester.getCenter(find.byType(CupertinoTextField));
    await mouse.addPointer(location: inputCenter);
    await mouse.down(inputCenter);
    await mouse.up();
    await tester.pumpAndSettle();

    expect(find.byType(AppTextContextMenu), findsOneWidget);
    expect(find.byType(MenuPanel), findsOneWidget);
    expect(find.byType(MenuOptionRow), findsWidgets);
    final labels = tester
        .widgetList<Text>(
          find.descendant(
            of: find.byType(AppTextContextMenu),
            matching: find.byType(Text),
          ),
        )
        .map((text) => text.data)
        .whereType<String>()
        .toList();
    const localizedLabels = {
      '剪切',
      '复制',
      '粘贴',
      '全选',
      '删除',
      '查询',
      '网页搜索',
      '分享',
      '实况文本',
      '操作',
    };
    expect(labels, isNotEmpty);
    expect(labels.every(localizedLabels.contains), isTrue);

    final editable = tester.widget<EditableText>(find.byType(EditableText));
    expect(editable.focusNode.hasFocus, isTrue);
    await mouse.moveTo(tester.getCenter(find.text(labels.first)));
    await tester.pumpAndSettle();

    expect(editable.focusNode.hasFocus, isTrue);
    expect(find.byType(AppTextContextMenu), findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pumpAndSettle();
    expect(find.byType(AppTextContextMenu), findsOneWidget);
    expect(find.byType(MenuOptionRow), findsWidgets);
    await mouse.removePointer();

    await tester.pumpWidget(const SizedBox.shrink());
    controller.dispose();
  });

  testWidgets('search input composes the shared input', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const Scaffold(
          body: Align(child: SizedBox(width: 280, child: AppSearchInput())),
        ),
      ),
    );

    expect(find.byType(AppSearchInput), findsOneWidget);
    expect(find.byType(AppInput), findsOneWidget);
    expect(find.byIcon(CupertinoIcons.search), findsOneWidget);
    expect(tester.getSize(find.byType(AppSearchInput)).width, 280);
  });

  testWidgets('search input focuses itself with Ctrl+K', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const Scaffold(
          body: SizedBox(width: 240, child: AppSearchInput()),
        ),
      ),
    );

    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.keyK);
    await tester.pump();

    final editable = tester.widget<EditableText>(find.byType(EditableText));
    expect(editable.focusNode.hasFocus, isTrue);

    await tester.sendKeyUpEvent(LogicalKeyboardKey.keyK);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
  });
}
