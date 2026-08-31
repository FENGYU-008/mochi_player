import 'package:isar/isar.dart';

part 'storage_source_entity.g.dart';

/// Persisted configuration for one configured storage source.
///
/// Credentials are currently stored in plain text at the user's request.
@collection
class StorageSourceEntity {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String sourceId;

  late String name;
  late String type;
  late String endpoint;
  String rootPath = '/';
  bool enabled = true;
  String username = '';
  String password = '';
}
