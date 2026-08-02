import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mochi_player/core/ui/app_ui.dart';

void main() {
  testWidgets('removes inherited text decoration in overlay contexts', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const DefaultTextStyle(
          style: TextStyle(decoration: TextDecoration.underline),
          child: AppActivityBanner(
            message: '正在获取播放链接…',
            tone: AppActivityBannerTone.progress,
          ),
        ),
      ),
    );

    final mergedStyle = tester
        .widget<DefaultTextStyle>(
          find
              .descendant(
                of: find.byType(AppActivityBanner),
                matching: find.byType(DefaultTextStyle),
              )
              .last,
        )
        .style;

    expect(mergedStyle.decoration, TextDecoration.none);
  });
}
