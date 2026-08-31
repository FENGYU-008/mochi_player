import 'dart:io';

import 'package:flutter/services.dart';

/// Ensures that macOS has an active security-scoped grant for a local source.
abstract interface class LocalDirectoryAccess {
  Future<void> ensureAccess(String directoryPath);
}

/// Persists and restores macOS user-selected-directory access through a
/// security-scoped bookmark managed by the native runner.
class MacLocalDirectoryAccess implements LocalDirectoryAccess {
  static const _channel = MethodChannel('mochi_player/local_directory_access');

  /// Opens the macOS directory picker and creates a security-scoped bookmark
  /// before the selected URL loses its temporary system grant.
  Future<String?> pickDirectory({String? initialDirectory}) async {
    if (!Platform.isMacOS) {
      throw UnsupportedError('本地目录选择目前仅支持 macOS');
    }
    return _channel.invokeMethod<String>('pickDirectory', {
      if (initialDirectory != null && initialDirectory.isNotEmpty) 'initialDirectory': initialDirectory,
    });
  }

  @override
  Future<void> ensureAccess(String directoryPath) async {
    if (!Platform.isMacOS) return;
    final granted = await _channel.invokeMethod<bool>('authorize', {'path': directoryPath});
    if (granted != true) {
      throw FileSystemException('macOS 未授予所选目录的访问权限', directoryPath);
    }
  }
}
