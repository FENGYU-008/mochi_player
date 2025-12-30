import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:mochi_player/providers/file_browser_provider.dart';
import 'package:mochi_player/providers/media_library_provider.dart';
import 'package:mochi_player/ui/pages/file_browser_page.dart';
import 'package:mochi_player/ui/pages/settings_page.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import '../widgets/side_bar.dart';
import '../widgets/search_bar.dart';

// 引入拆分出去的子页面
import '../widgets/home_content.dart';
import 'library_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0; // 默认选中 Home

  @override
  void initState() {
    super.initState();
    // 在 Widget 构建完成后触发初始化流程
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
    });
  }

  Future<void> _initializeApp() async {
    final libraryProvider = context.read<MediaLibraryProvider>();

    // 1. 先从数据库加载缓存数据 (快速显示)
    await libraryProvider.loadFromDatabase();

    // 2. 加载文件列表 (WebDAV 已在 main.dart 初始化)
    await context.read<FileBrowserProvider>().fetchFiles('/');

    // 3. 扫描媒体库 (增量更新)
    await libraryProvider.scanLibrary();
  }

  // === 核心修改：页面路由表 ===
  Widget _getPageContent(int index) {
    switch (index) {
      case 0:
        return const HomeContent(); // 首页聚合
      case 1:
        return const LibraryPage(category: 'Movies'); // 电影库
      case 2:
        return const LibraryPage(category: 'TV Shows'); // 剧集库
      case 3:
        return const FileBrowserPage(); // 文件浏览器
      case 4:
        return const LibraryPage(category: 'Favorites'); // 收藏
      case 5:
        return const SettingsPage(); // 设置页面
      default:
        return const Center(child: Text("Coming Soon"));
    }
  }

  // 获取顶部标题
  String _getTitle(int index) {
    switch (index) {
      case 0:
        return "Home";
      case 1:
        return "Movies";
      case 2:
        return "TV Shows";
      case 3:
        return "File Browser";
      case 4:
        return "Favorites";
      case 5:
        return "Settings";
      default:
        return "Library";
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Row(
        children: [
          // 左侧：侧边栏
          SideBar(
            selectedIndex: _selectedIndex,
            onItemSelected: (index) => setState(() => _selectedIndex = index),
          ),

          // 右侧：内容容器
          Expanded(
            child: Container(
              color: theme.scaffoldBackgroundColor, // 使用主题背景色
              child: Stack(
                children: [
                  // === 1. 底层内容 (动态切换) ===
                  _getPageContent(_selectedIndex),

                  // === 2. 顶层毛玻璃 Header (当不是文件浏览器或设置页面时显示) ===
                  if (_selectedIndex != 3 && _selectedIndex != 5)
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height: 60,
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onPanStart: (details) {
                          windowManager.startDragging();
                        },
                        child: ClipRect(
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 40,
                              ),
                              decoration: BoxDecoration(
                                // 根据主题调整毛玻璃颜色
                                color: theme.brightness == Brightness.light
                                    ? Colors.white.withAlpha(
                                        (255 * 0.8).round(),
                                      )
                                    : const Color(0xFF2C2C2E).withAlpha(
                                        (255 * 0.8).round(),
                                      ), // 使用深色模式下的canvasColor
                                border: Border(
                                  bottom: BorderSide(
                                    color: theme.dividerColor,
                                    width: 1,
                                  ),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _getTitle(_selectedIndex), // 标题随 index 变
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: -0.5,
                                      color: theme.textTheme.bodyMedium?.color,
                                    ),
                                  ),
                                  const AppSearchBar(),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
