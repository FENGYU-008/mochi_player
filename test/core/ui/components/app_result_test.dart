import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mochi_player/core/ui/app_ui.dart';

void main() {
  testWidgets('renders configured status content and a custom icon', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const AppResult(
          status: AppResultStatus.empty,
          title: '没有匹配的媒体',
          subtitle: '请尝试其他关键词',
          icon: Icon(Icons.search_off_rounded),
        ),
      ),
    );

    expect(find.text('没有匹配的媒体'), findsOneWidget);
    expect(find.text('请尝试其他关键词'), findsOneWidget);
    expect(find.byIcon(Icons.search_off_rounded), findsOneWidget);
  });

  testWidgets('uses the status appearance and renders the operation area', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const AppResult(
          status: AppResultStatus.error,
          title: '页面加载失败',
          subtitle: '连接被拒绝',
          extra: TextButton(onPressed: null, child: Text('重试')),
        ),
      ),
    );

    expect(find.text('页面加载失败'), findsOneWidget);
    expect(find.text('连接被拒绝'), findsOneWidget);
    expect(find.text('重试'), findsOneWidget);
    expect(find.byIcon(Icons.close_rounded), findsOneWidget);
  });
}
