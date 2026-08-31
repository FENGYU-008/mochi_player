import 'package:mochi_player/core/domain/storage/storage_entry.dart';
import 'package:mochi_player/core/domain/storage/storage_source.dart';

/// An authenticated connection to one storage source.
///
/// Every path passed to this interface is relative to [source.rootPath].
abstract interface class StorageConnection {
  StorageSource get source;

  Future<List<StorageEntry>> readDirectory(String path);

  Future<bool> testConnection();
}
