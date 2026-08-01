import 'package:flutter/gestures.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mochi_player/core/ui/app_ui.dart';

void main() {
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
          body: AppTextField(
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
        home: Scaffold(body: AppTextField(controller: controller)),
      ),
    );

    await tester.tapAt(
      tester.getCenter(find.byType(CupertinoTextField)),
      kind: PointerDeviceKind.mouse,
      buttons: kSecondaryMouseButton,
    );
    await tester.pumpAndSettle();

    expect(find.byType(AppTextContextMenu), findsOneWidget);
    expect(find.byType(AppPopupMenuPanel), findsOneWidget);
    expect(find.byType(AppPopupMenuItem), findsWidgets);
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

    await tester.pumpWidget(const SizedBox.shrink());
    controller.dispose();
  });
}
