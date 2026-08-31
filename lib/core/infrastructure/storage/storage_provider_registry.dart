import 'package:mochi_player/core/domain/storage/models.dart';
import 'package:mochi_player/core/infrastructure/storage/local_storage_provider.dart';
import 'package:mochi_player/core/infrastructure/storage/webdav_storage_provider.dart';

/// Resolves the connection implementation for a configured storage protocol.
///
/// Consumers use this registry instead of checking [StorageSource.type]
/// themselves, so adding SMB or a local provider only requires registering one
/// new [StorageProvider].
class StorageProviderRegistry {
  StorageProviderRegistry(Iterable<StorageProvider> providers)
    : _providers = {for (final provider in providers) provider.type: provider} {
    if (_providers.length != providers.length) {
      throw ArgumentError('A storage provider may only be registered once per type.');
    }
  }

  factory StorageProviderRegistry.defaults() =>
      StorageProviderRegistry([LocalStorageProvider(), WebDavStorageProvider()]);

  final Map<StorageSourceType, StorageProvider> _providers;

  bool supports(StorageSourceType type) => _providers.containsKey(type);

  StorageProvider providerFor(StorageSourceType type) {
    final provider = _providers[type];
    if (provider == null) {
      throw UnsupportedError('Storage type $type is not supported.');
    }
    return provider;
  }

  Future<StorageConnection> connect(StorageSource source, StorageCredentials? credentials) {
    return providerFor(source.type).connect(source, credentials);
  }
}
