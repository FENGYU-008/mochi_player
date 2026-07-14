import 'package:flutter_test/flutter_test.dart';
import 'package:mochi_player/core/domain/media/media_file.dart';
import 'package:mochi_player/features/playback/application/playback_session_controller.dart';
import 'package:mochi_player/features/library/application/media_library_provider.dart';

MediaFile _file(int id, String path) => MediaFile(
  id: id,
  path: path,
  fileName: path.split('/').last,
  parsedTitle: 'Show',
  addedAt: DateTime(2026),
);

class _FakeLibraryProvider extends MediaLibraryProvider {
  _FakeLibraryProvider({this.failProgressWrites = false});

  final bool failProgressWrites;
  final progressWrites = <int>[];

  @override
  Future<MediaFile?> getLatestMediaFile(MediaFile file) async => file;

  @override
  Future<void> updateProgress(
    MediaFile file,
    int position, {
    int? duration,
  }) async {
    if (failProgressWrites) throw StateError('database unavailable');
    progressWrites.add(position);
  }
}

void main() {
  test(
    'saves current progress before resolving and committing a queue move',
    () async {
      final library = _FakeLibraryProvider();
      final first = _file(1, '/media/one.mkv');
      final second = _file(2, '/media/two.mkv');
      final events = <String>[];
      final session = PlaybackSessionController(
        libraryProvider: library,
        initialItem: first,
        queueItems: [first, second],
        initialUrl: 'https://example.test/one',
        resolveDirectLink: (path) async {
          events.add('link:$path');
          return 'https://example.test/two';
        },
      );

      final move = await session.moveBy(1, positionMs: 4000, durationMs: 10000);

      expect(move?.isReady, isTrue);
      expect(session.currentItem, second);
      expect(session.currentUrl, 'https://example.test/two');
      expect(library.progressWrites, [4000]);
      expect(events, ['link:/media/two.mkv']);
    },
  );

  test(
    'keeps the current item when a target link cannot be resolved',
    () async {
      final library = _FakeLibraryProvider();
      final first = _file(1, '/media/one.mkv');
      final second = _file(2, '/media/two.mkv');
      final session = PlaybackSessionController(
        libraryProvider: library,
        initialItem: first,
        queueItems: [first, second],
        initialUrl: 'https://example.test/one',
        resolveDirectLink: (_) async => null,
      );

      final move = await session.moveBy(1, positionMs: 4000, durationMs: 10000);

      expect(move?.isReady, isFalse);
      expect(session.currentItem, first);
      expect(session.currentUrl, 'https://example.test/one');
    },
  );

  test('continues switching when progress persistence fails', () async {
    final library = _FakeLibraryProvider(failProgressWrites: true);
    final first = _file(1, '/media/one.mkv');
    final second = _file(2, '/media/two.mkv');
    final session = PlaybackSessionController(
      libraryProvider: library,
      initialItem: first,
      queueItems: [first, second],
      initialUrl: 'https://example.test/one',
      resolveDirectLink: (_) async => 'https://example.test/two',
    );

    final move = await session.moveBy(1, positionMs: 4000, durationMs: 10000);

    expect(move?.isReady, isTrue);
    expect(session.currentItem, second);
  });
}
