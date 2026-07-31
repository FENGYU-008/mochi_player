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
}
