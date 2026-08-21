import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:webdav_client/webdav_client.dart' as webdav;

import 'package:mochi_player/core/domain/media/media_file.dart';
import 'package:mochi_player/core/domain/media/media_file_kind.dart';
import 'package:mochi_player/core/infrastructure/webdav/webdav_service.dart';
import 'package:mochi_player/features/library/domain/file_browser_entry.dart';

enum FileBrowserViewMode { grid, list }

enum FileSortField { name, size, modifiedAt }

/// 文件浏览器 Provider
///
/// Owns directory navigation, filtering and sorting for the file browser.
class FileBrowserProvider extends ChangeNotifier {
  final WebDavFileSystem _fileSystem;
  final _logger = Logger(printer: PrettyPrinter(methodCount: 0));

  FileBrowserProvider({WebDavFileSystem? fileSystem})
    : _fileSystem = fileSystem ?? WebDavService();

  // === 状态变量 ===
  List<FileBrowserEntry> _items = [];
  bool _isLoading = false;
  bool _hasLoaded = false;
  String _currentPath = '/';
  String? _error;
  final List<String> _pathHistory = [];
  final List<String> _forwardHistory = [];
  FileBrowserViewMode _viewMode = FileBrowserViewMode.list;
  FileSortField _sortField = FileSortField.name;
  bool _sortAscending = true;
  String _searchQuery = '';
  int _requestGeneration = 0;

  // === Getters ===
  List<FileBrowserEntry> get items => _items;
  bool get isLoading => _isLoading;
  bool get hasLoaded => _hasLoaded;
  String get currentPath => _currentPath;
  String? get error => _error;
  bool get canGoBack => _pathHistory.isNotEmpty;
  bool get canGoForward => _forwardHistory.isNotEmpty;
  FileBrowserViewMode get viewMode => _viewMode;
  FileSortField get sortField => _sortField;
  bool get sortAscending => _sortAscending;
  String get searchQuery => _searchQuery;

  List<FileBrowserEntry> get visibleItems {
    final normalizedQuery = _searchQuery.trim().toLowerCase();
    final result = normalizedQuery.isEmpty
        ? List<FileBrowserEntry>.of(_items)
        : _items
              .where(
                (item) => item.name.toLowerCase().contains(normalizedQuery),
              )
              .toList();
    result.sort(_compareItems);
    return result;
  }

  void setSearchQuery(String value) {
    if (_searchQuery == value) return;
    _searchQuery = value;
    notifyListeners();
  }

  void setSort(FileSortField field, {required bool ascending}) {
    if (_sortField == field && _sortAscending == ascending) return;
    _sortField = field;
    _sortAscending = ascending;
    notifyListeners();
  }

  void setViewMode(FileBrowserViewMode value) {
    if (_viewMode == value) return;
    _viewMode = value;
    notifyListeners();
  }

  // 加载指定路径的文件
  Future<void> fetchFiles(String path) async {
    final requestGeneration = ++_requestGeneration;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (!_fileSystem.isInitialized) {
        _items = [];
        _error = '请先在设置中配置 WebDAV';
        _hasLoaded = true;
        return;
      }

      // Read raw directory entries; browser visibility is decided locally.
      final files = await _fileSystem.readDir(path);
      if (requestGeneration != _requestGeneration) return;

      _items = files
          .where(_isVisibleEntry)
          .map((file) => _mapFile(file, path))
          .toList();

      _currentPath = path;
      _hasLoaded = true;
      _logger.i("✅ 加载成功，在 '$path' 发现 ${_items.length} 个文件");
    } catch (e) {
      if (requestGeneration != _requestGeneration) return;
      _logger.e("❌ 加载文件失败: $e");
      _items = [];
      _error = '加载文件失败: $e';
      _hasLoaded = true;
    } finally {
      if (requestGeneration == _requestGeneration) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  bool _isVisibleEntry(webdav.File file) {
    final name = file.name;
    return name != null && name.isNotEmpty && !name.startsWith('.');
  }

  FileBrowserEntry _mapFile(webdav.File file, String parentPath) {
    final isDir = file.isDir ?? false;
    final name = file.name ?? '未知文件';
    // 构造完整路径
    String fullPath = parentPath.endsWith('/')
        ? '$parentPath$name'
        : '$parentPath/$name';
    if (isDir && !fullPath.endsWith('/')) {
      fullPath += '/';
    }

    return FileBrowserEntry(
      path: fullPath,
      name: name,
      kind: MediaFileKindResolver.resolve(name, isDirectory: isDir),
      size: file.size ?? 0,
      modifiedAt: file.mTime,
    );
  }

  /// Adapts a playable browser entry to the playback API's media model.
  /// Browser state itself never stores this temporary object.
  MediaFile createPlaybackFile(FileBrowserEntry entry) {
    if (!entry.isPlayable) {
      throw ArgumentError.value(entry.path, 'entry', 'File is not playable');
    }
    return MediaFile(
      id: -1,
      path: entry.path,
      fileName: entry.name,
      parsedTitle: entry.name,
      size: entry.size,
      container: MediaFileKindResolver.extensionOf(entry.name),
      addedAt: entry.modifiedAt ?? DateTime.now(),
    );
  }

  // === 核心功能 3: 进入文件夹 ===
  void enterFolder(FileBrowserEntry folder) {
    if (!folder.isDirectory) return;
    _pathHistory.add(_currentPath);
    _forwardHistory.clear();
    fetchFiles(folder.path);
  }

  // === 核心功能 4: 返回上一级 ===
  void navigateBack() {
    if (_pathHistory.isNotEmpty) {
      _forwardHistory.add(_currentPath);
      final previousPath = _pathHistory.removeLast();
      fetchFiles(previousPath);
    }
  }

  void navigateForward() {
    if (_forwardHistory.isEmpty) return;
    _pathHistory.add(_currentPath);
    final nextPath = _forwardHistory.removeLast();
    fetchFiles(nextPath);
  }

  void navigateToPath(String path) {
    if (path == _currentPath) return;
    _pathHistory.add(_currentPath);
    _forwardHistory.clear();
    fetchFiles(path);
  }

  // === 辅助功能: 刷新当前目录 ===
  Future<void> refresh() async {
    await fetchFiles(_currentPath);
  }

  int _compareItems(FileBrowserEntry a, FileBrowserEntry b) {
    final folderComparison = _compareFolders(a, b);
    if (folderComparison != 0) return folderComparison;

    final comparison = switch (_sortField) {
      FileSortField.name => a.name.toLowerCase().compareTo(
        b.name.toLowerCase(),
      ),
      FileSortField.size => a.size.compareTo(b.size),
      FileSortField.modifiedAt => _modifiedAt(a).compareTo(_modifiedAt(b)),
    };
    return _sortAscending ? comparison : -comparison;
  }

  int _compareFolders(FileBrowserEntry a, FileBrowserEntry b) {
    final aIsFolder = a.isDirectory;
    final bIsFolder = b.isDirectory;
    if (aIsFolder == bIsFolder) return 0;
    return aIsFolder ? -1 : 1;
  }

  DateTime _modifiedAt(FileBrowserEntry item) =>
      item.modifiedAt ?? DateTime.fromMillisecondsSinceEpoch(0);

  @override
  void dispose() {
    _requestGeneration++;
    super.dispose();
  }
}
