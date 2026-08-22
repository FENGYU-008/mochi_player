import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mochi_player/core/domain/media/media_file_kind.dart';
import 'package:mochi_player/core/ui/theme/app_theme.dart';
import 'package:mochi_player/features/library/domain/file_browser_entry.dart';
import 'package:mochi_player/features/library/presentation/widgets/file_browser_list.dart';

void main() {
  testWidgets('handles transient layout heights smaller than the summary', (
    tester,
  ) async {
    final item = FileBrowserEntry(
      path: '/movie.mkv',
      name: 'movie.mkv',
      kind: MediaFileKind.video,
      size: 1024,
      modifiedAt: null,
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 600,
            height: 20,
            child: FileBrowserListSection(
              items: [item],
              totalItemCount: 1,
              isFiltered: false,
              onItemTap: (_) {},
              scrollStorageKey: const PageStorageKey<String>(
                'test-file-browser-list',
              ),
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 600,
            height: 60,
            child: FileBrowserListSection(
              items: [item],
              totalItemCount: 1,
              isFiltered: false,
              onItemTap: (_) {},
              scrollStorageKey: const PageStorageKey<String>(
                'test-file-browser-list',
              ),
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });
}
