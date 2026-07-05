import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:webdav_client/webdav_client.dart' as webdav;

import '../services/webdav_service.dart';
import '../models/domain/media_file.dart';
import '../models/domain/media_type.dart';

enum ViewMode { grid, list }

/// 文件浏览器 Provider
///
/// 使用 [MediaFile] 模型来表示文件和文件夹。
/// 注意：这里的 [MediaFile] 是临时生成的，不会保存到数据库。
class FileBrowserProvider extends ChangeNotifier {
  final _logger = Logger(printer: PrettyPrinter(methodCount: 0));

  // === 状态变量 ===
  List<MediaFile> _items = [];
  bool _isLoading = false;
  bool _hasLoaded = false;
  String _currentPath = '/';
  String? _error;
  final List<String> _pathHistory = [];
  ViewMode _viewMode = ViewMode.list;

  // === Getters ===
  List<MediaFile> get items => _items;
  bool get isLoading => _isLoading;
  bool get hasLoaded => _hasLoaded;
  String get currentPath => _currentPath;
  String? get error => _error;
  bool get canGoBack => _pathHistory.isNotEmpty;
  ViewMode get viewMode => _viewMode;

  // === 视图切换方法 ===
  void toggleViewMode() {
    _viewMode = _viewMode == ViewMode.grid ? ViewMode.list : ViewMode.grid;
    notifyListeners();
  }

  // === 核心功能 1: 初始化连接 ===
  Future<void> initConnection() async {
    // WebDAV 已在 main.dart 中初始化
    // 这里只需要加载根目录
    if (!WebDavService().isInitialized) {
      _logger.w('⚠️ WebDAV 未初始化，请检查 main.dart');
      return;
    }
    await fetchFiles('/');
  }

  // === 核心功能 2: 加载指定路径的文件 ===
  Future<void> fetchFiles(String path) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (!WebDavService().isInitialized) {
        _items = [];
        _error = '请先在设置中配置 WebDAV';
        _hasLoaded = true;
        return;
      }

      // 调用 WebDavService 获取原始文件列表
      final files = await WebDavService().readDir(path);

      // 转换为 MediaFile
      _items = files
          .map((file) => _mapWebDavFileToMediaFile(file, path))
          .toList();

      // 排序：文件夹在前
      _items.sort((a, b) {
        final aIsFolder = a.mediaType == MediaType.folder;
        final bIsFolder = b.mediaType == MediaType.folder;
        if (aIsFolder && !bIsFolder) return -1;
        if (bIsFolder && !aIsFolder) return 1;
        return a.fileName.toLowerCase().compareTo(b.fileName.toLowerCase());
      });

      _currentPath = path;
      _hasLoaded = true;
      _logger.i("✅ 加载成功，在 '$path' 发现 ${_items.length} 个文件");
    } catch (e) {
      _logger.e("❌ 加载文件失败: $e");
      _items = [];
      _error = '加载文件失败: $e';
      _hasLoaded = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 将 webdav.File 转换为 MediaFile
  MediaFile _mapWebDavFileToMediaFile(webdav.File file, String parentPath) {
    final isDir = file.isDir ?? false;
    final name = file.name ?? '未知文件';
    // 构造完整路径
    String fullPath = parentPath.endsWith('/')
        ? '$parentPath$name'
        : '$parentPath/$name';
    if (isDir && !fullPath.endsWith('/')) {
      fullPath += '/';
    }

    return MediaFile(
      // 使用 hashCode 作为临时 ID，确保同一文件大致有相同 ID（虽然不绝对保证唯一且持久，但列表展示够用）
      id: fullPath.hashCode,
      path: fullPath,
      fileName: name,
      parsedTitle: name, // 简单使用文件名作为解析标题
      mediaType: isDir ? MediaType.folder : MediaType.unknown,
      size: file.size ?? 0,
      addedAt: file.mTime ?? DateTime.now(),
      lastWatchedAt: file.mTime, // 借用 lastWatchedAt 字段临时存储修改时间，方便 UI 显示
    );
  }

  // === 核心功能 3: 进入文件夹 ===
  void enterFolder(MediaFile folder) {
    if (folder.mediaType != MediaType.folder) return;
    _pathHistory.add(_currentPath);
    fetchFiles(folder.path);
  }

  // === 核心功能 4: 返回上一级 ===
  void navigateBack() {
    if (_pathHistory.isNotEmpty) {
      String previousPath = _pathHistory.removeLast();
      fetchFiles(previousPath);
    }
  }

  // === 辅助功能: 刷新当前目录 ===
  Future<void> refresh() async {
    await fetchFiles(_currentPath);
  }
}
