import 'package:mochi_player/models/domain/media_file.dart';

/// Owns the ordered media items for one playback session.
///
/// Link resolution and player commands intentionally stay outside this class,
/// so queue state can be tested without Flutter or a media backend.
class PlaybackQueue {
  PlaybackQueue({
    required MediaFile initialItem,
    required List<MediaFile> items,
  }) : _items = _deduplicate(items) {
    _currentIndex = _items.indexWhere(
      (item) => item.id == initialItem.id || item.path == initialItem.path,
    );
    if (_currentIndex < 0) {
      _items.insert(0, initialItem);
      _currentIndex = 0;
    }
  }

  final List<MediaFile> _items;
  late int _currentIndex;

  MediaFile get current => _items[_currentIndex];
  int get currentIndex => _currentIndex;
  bool get hasPrevious => _currentIndex > 0;
  bool get hasNext => _currentIndex < _items.length - 1;

  MediaFile? itemAtOffset(int offset) {
    final index = _currentIndex + offset;
    if (index < 0 || index >= _items.length) return null;
    return _items[index];
  }

  void selectOffset(int offset) {
    final index = _currentIndex + offset;
    if (index < 0 || index >= _items.length) {
      throw RangeError.index(index, _items, 'offset');
    }
    _currentIndex = index;
  }

  void replaceCurrent(MediaFile item) {
    _items[_currentIndex] = item;
  }

  static List<MediaFile> _deduplicate(List<MediaFile> items) {
    final seenPaths = <String>{};
    return [
      for (final item in items)
        if (seenPaths.add(item.path)) item,
    ];
  }
}
