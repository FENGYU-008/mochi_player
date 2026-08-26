import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mochi_player/core/ui/app_ui.dart';
import 'package:mochi_player/features/library/application/file_browser_provider.dart';
import 'package:mochi_player/features/library/presentation/widgets/file_browser_toolbar.dart';

void main() {
  testWidgets('exposes the file browser toolbar actions', (tester) async {
    var backCount = 0;
    var forwardCount = 0;
    var refreshCount = 0;
    String? selectedPath;
    FileBrowserViewMode? selectedViewMode;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: SizedBox(
            width: 1200,
            child: FileBrowserToolbar(
              currentPath: '/quark/电影/',
              canGoBack: false,
              canGoForward: true,
              viewMode: FileBrowserViewMode.list,
              sortField: FileSortField.name,
              sortAscending: true,
              onBack: () => backCount++,
              onForward: () => forwardCount++,
              onPathSelected: (path) => selectedPath = path,
              onSortChanged: (_, _) {},
              onViewModeChanged: (mode) => selectedViewMode = mode,
              onRefresh: () => refreshCount++,
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byTooltip('后退'));
    await tester.tap(find.byTooltip('前进'));
    await tester.tap(find.byTooltip('网格视图'));
    await tester.tap(find.byTooltip('刷新目录'));
    await tester.tap(find.text('根目录'));

    expect(backCount, 0);
    expect(forwardCount, 1);
    expect(selectedViewMode, FileBrowserViewMode.grid);
    expect(refreshCount, 1);
    expect(selectedPath, '/');
  });
}
