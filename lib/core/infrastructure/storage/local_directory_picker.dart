import 'package:file_selector/file_selector.dart';

/// Opens the platform directory picker for a local media source.
///
/// The selected absolute path is valid on macOS and Windows. Persistent
/// sandbox grants are intentionally not managed here: Mochi is distributed as
/// a non-sandboxed desktop app.
class LocalDirectoryPicker {
  const LocalDirectoryPicker();

  Future<String?> pickDirectory({String? initialDirectory}) {
    return getDirectoryPath(initialDirectory: initialDirectory, canCreateDirectories: true);
  }
}
