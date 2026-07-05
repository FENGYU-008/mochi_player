import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:mochi_player/providers/app_settings_provider.dart';
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

  // 用于接收首页滚动偏移量以控制 header 透明度
  double _homeScrollOffset = 0;

  @override
  void initState() {
    super.initState();
    // 在 Widget 构建完成后触发初始化流程
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
    });
  }

  Future<void> _initializeApp() async {
    final settingsProvider = context.read<AppSettingsProvider>();
    final libraryProvider = context.read<MediaLibraryProvider>();

    // 1. 先从数据库加载缓存数据 (快速显示)
    await libraryProvider.loadFromDatabase();

    // 2. 加载 TMDB 热门趋势。媒体库扫描/刮削由设置页手动触发。
    if (settingsProvider.hasTmdbApiKey) {
      await libraryProvider.fetchTrending();
    }
  }

  // 接收首页滚动偏移量
  void _onHomeScroll(double offset) {
    if (_selectedIndex == 0) {
      setState(() {
        _homeScrollOffset = offset;
      });
    }
  }

  // === 核心修改：页面路由表 ===
  Widget _getPageContent(int index) {
    switch (index) {
      case 0:
        return HomeContent(onScroll: _onHomeScroll); // 首页聚合
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
        return const Center(child: Text("即将推出"));
    }
  }

  // 获取顶部标题
  String _getTitle(int index) {
    switch (index) {
      case 0:
        return "首页";
      case 1:
        return "电影";
      case 2:
        return "剧集";
      case 3:
        return "文件浏览";
      case 4:
        return "收藏";
      case 5:
        return "设置";
      default:
        return "媒体库";
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // 计算 header 透明度：首页时根据滚动位置渐变
    double headerOpacity = 1.0;
    if (_selectedIndex == 0) {
      // 0-200px 滚动范围内从 0 渐变到 1
      headerOpacity = (_homeScrollOffset / 200).clamp(0.0, 1.0);
    }

    // 是否显示标准 header (非首页或首页滚动后)
    final showHeader = _selectedIndex != 3 && _selectedIndex != 5;

    return Scaffold(
      body: Row(
        children: [
          // 左侧：侧边栏
          SideBar(
            selectedIndex: _selectedIndex,
            onItemSelected: (index) {
              setState(() {
                _selectedIndex = index;
                // 切换页面时重置滚动偏移
                if (index != 0) _homeScrollOffset = 0;
              });
            },
          ),

          // 右侧：内容容器
          Expanded(
            child: Container(
              color: theme.scaffoldBackgroundColor, // 使用主题背景色
              child: Stack(
                children: [
                  // === 1. 底层内容 (动态切换) ===
                  _getPageContent(_selectedIndex),

                  Selector<MediaLibraryProvider, _LibraryActivityState>(
                    selector: (context, provider) => _LibraryActivityState(
                      message: provider.libraryActivityMessage,
                      progress: provider.scrapeProgress,
                    ),
                    builder: (context, activity, child) {
                      if (activity.message == null) {
                        return const SizedBox.shrink();
                      }

                      return Positioned(
                        top: showHeader ? 70 : 16,
                        left: 40,
                        right: 40,
                        child: _LibraryActivityBanner(
                          message: activity.message!,
                          progress: activity.progress,
                        ),
                      );
                    },
                  ),

                  // === 2. 顶层毛玻璃 Header ===
                  if (showHeader)
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height: 60,
                      child: IgnorePointer(
                        // 当 header 透明时，允许点击穿透到下层内容
                        ignoring: _selectedIndex == 0 && headerOpacity < 0.1,
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 150),
                          opacity: headerOpacity,
                          child: GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onPanStart: (details) {
                              windowManager.startDragging();
                            },
                            child: ClipRect(
                              child: BackdropFilter(
                                filter: ImageFilter.blur(
                                  sigmaX: 20,
                                  sigmaY: 20,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 40,
                                  ),
                                  decoration: BoxDecoration(
                                    // 根据主题调整毛玻璃颜色
                                    color: theme.brightness == Brightness.light
                                        ? Colors.white.withAlpha(
                                            (255 * 0.85).round(),
                                          )
                                        : const Color(
                                            0xFF2C2C2E,
                                          ).withAlpha((255 * 0.85).round()),
                                    border: Border(
                                      bottom: BorderSide(
                                        color: theme.dividerColor.withAlpha(
                                          (255 * headerOpacity).round(),
                                        ),
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        _getTitle(_selectedIndex),
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: -0.5,
                                          color:
                                              theme.textTheme.bodyMedium?.color,
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

class _LibraryActivityState {
  final String? message;
  final double? progress;

  const _LibraryActivityState({required this.message, required this.progress});

  @override
  bool operator ==(Object other) {
    return other is _LibraryActivityState &&
        other.message == message &&
        other.progress == progress;
  }

  @override
  int get hashCode => Object.hash(message, progress);
}

class _LibraryActivityBanner extends StatelessWidget {
  final String message;
  final double? progress;

  const _LibraryActivityBanner({required this.message, this.progress});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surfaceColor = theme.brightness == Brightness.light
        ? Colors.white.withAlpha((255 * 0.92).round())
        : const Color(0xFF1F1F22).withAlpha((255 * 0.92).round());

    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 620),
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: theme.dividerColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((255 * 0.12).round()),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    value: progress,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    message,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: theme.textTheme.bodyMedium?.color,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            if (progress != null) ...[
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  minHeight: 3,
                  value: progress,
                  backgroundColor: theme.dividerColor.withAlpha(
                    (255 * 0.45).round(),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
