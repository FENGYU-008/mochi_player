import 'package:mochi_player/core/domain/storage/storage_source_type.dart';

/// A user-configured media storage location.
///
/// Credentials are intentionally kept outside the domain model so they are
/// never exposed when a source is listed in the UI.
class StorageSource {
  final String id;
  final String name;
  final StorageSourceType type;
  final String endpoint;
  final String rootPath;
  final bool enabled;

  const StorageSource({
    required this.id,
    required this.name,
    required this.type,
    required this.endpoint,
    this.rootPath = '/',
    this.enabled = true,
  });

  StorageSource copyWith({String? name, String? endpoint, String? rootPath, bool? enabled}) {
    return StorageSource(
      id: id,
      name: name ?? this.name,
      type: type,
      endpoint: endpoint ?? this.endpoint,
      rootPath: rootPath ?? this.rootPath,
      enabled: enabled ?? this.enabled,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is StorageSource &&
        other.id == id &&
        other.name == name &&
        other.type == type &&
        other.endpoint == endpoint &&
        other.rootPath == rootPath &&
        other.enabled == enabled;
  }

  @override
  int get hashCode => Object.hash(id, name, type, endpoint, rootPath, enabled);
}
