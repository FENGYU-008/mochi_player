/// A file or directory inside a storage source.
class StorageEntry {
  final String name;
  final bool isDirectory;
  final int size;
  final DateTime? modifiedAt;

  const StorageEntry({required this.name, required this.isDirectory, required this.size, required this.modifiedAt});
}
