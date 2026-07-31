import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mochi_player/core/domain/media/media_file_kind.dart';
import 'package:mochi_player/core/infrastructure/webdav/webdav_service.dart';
import 'package:mochi_player/features/library/application/file_browser_provider.dart';
import 'package:webdav_client/webdav_client.dart' as webdav;

void main() {
  test(
    'maps raw directory entries without borrowing playback metadata',
    () async {
      final modifiedAt = DateTime(2026, 7, 31, 12, 30);
      final fileSystem = _FakeFileSystem(
        (_) async => [
          webdav.File(name: '.hidden', isDir: false),
          webdav.File(name: 'Movies', isDir: true, mTime: modifiedAt),
          webdav.File(
            name: 'episode.mp4',
            isDir: false,
            size: 2048,
            mTime: modifiedAt,
          ),
          webdav.File(name: 'theme.flac', isDir: false, size: 1024),
          webdav.File(name: 'notes.txt', isDir: false, size: 12),
        ],
      );
      final provider = FileBrowserProvider(fileSystem: fileSystem);

      await provider.fetchFiles('/');

      expect(provider.items.map((item) => item.name), [
        'Movies',
        'episode.mp4',
        'theme.flac',
        'notes.txt',
      ]);
      expect(provider.items[0].kind, MediaFileKind.directory);
      expect(provider.items[1].kind, MediaFileKind.video);
      expect(provider.items[1].modifiedAt, modifiedAt);
      expect(provider.items[2].kind, MediaFileKind.other);
      expect(provider.items[2].isPlayable, isFalse);
      expect(provider.items[3].kind, MediaFileKind.other);
    },
  );

  test('ignores a stale directory response', () async {
    final first = Completer<List<webdav.File>>();
    final second = Completer<List<webdav.File>>();
    final fileSystem = _FakeFileSystem(
      (path) => path == '/first' ? first.future : second.future,
    );
    final provider = FileBrowserProvider(fileSystem: fileSystem);

    final firstRequest = provider.fetchFiles('/first');
    final secondRequest = provider.fetchFiles('/second');
    second.complete([webdav.File(name: 'new.mp4', isDir: false)]);
    await secondRequest;
    first.complete([webdav.File(name: 'stale.mp4', isDir: false)]);
    await firstRequest;

    expect(provider.currentPath, '/second');
    expect(provider.items.single.name, 'new.mp4');
    expect(provider.isLoading, isFalse);
  });
}

class _FakeFileSystem implements WebDavFileSystem {
  final Future<List<webdav.File>> Function(String path) _read;

  _FakeFileSystem(this._read);

  @override
  bool get isInitialized => true;

  @override
  Future<List<webdav.File>> readDir(String path) => _read(path);
}
