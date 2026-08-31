/// Identifies an item inside a configured storage source.
class StorageLocator {
  final String sourceId;
  final String path;

  const StorageLocator({required this.sourceId, required this.path});

  String get storageKey => keyFor(sourceId, path);

  static String keyFor(String sourceId, String path) => '$sourceId:$path';
}
