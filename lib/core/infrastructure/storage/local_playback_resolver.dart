import 'dart:io';

import 'package:mochi_player/core/domain/media/media_file.dart';
import 'package:mochi_player/core/domain/playback/playback_target.dart';
import 'package:mochi_player/core/domain/playback/playback_target_resolver.dart';
import 'package:mochi_player/core/domain/storage/models.dart';
import 'package:path/path.dart' as path;

/// Resolves a source-relative media file to a local `file://` URL.
class LocalPlaybackResolver implements PlaybackTargetResolver {
  LocalPlaybackResolver({required this.source});

  final StorageSource source;

  @override
  Future<PlaybackTarget?> resolve(MediaFile file) async {
    if (source.type != StorageSourceType.local || file.sourceId != source.id) {
      return null;
    }
    final root = source.endpoint.trim();
    if (root.isEmpty || !path.isAbsolute(root)) return null;
    final relativePath = file.path.replaceFirst(RegExp(r'^/+'), '');
    final resolved = path.normalize(path.join(root, relativePath));
    if (resolved != path.normalize(root) && !path.isWithin(root, resolved)) {
      return null;
    }
    return PlaybackTarget(url: File(resolved).uri.toString());
  }
}
