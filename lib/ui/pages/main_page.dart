import 'package:flutter/material.dart';
import 'package:mochi_player/models/domain/models.dart';
import 'package:mochi_player/providers/app_settings_provider.dart';
import 'package:mochi_player/providers/media_library_provider.dart';
import 'package:mochi_player/ui/pages/file_browser_page.dart';
import 'package:mochi_player/ui/pages/media_detail_page.dart';
import 'package:mochi_player/ui/pages/section_view_page.dart';
import 'package:mochi_player/ui/pages/settings_page.dart';
import 'package:provider/provider.dart';
import '../widgets/app_header.dart';
import '../widgets/side_bar.dart';

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
  dynamic _detailItem;
  SectionType? _sectionType;
  final Map<SectionType, double> _sectionScrollOffsets = {};
  final Map<int, double> _libraryScrollOffsets = {};

  // 用于接收首页滚动偏移量以控制 header 透明度
  double _homeScrollOffset = 0;
  double _homeContinueWatchingOffset = 0;
  double _homeRecentlyAddedOffset = 0;

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

  void _saveHomeScrollOffset(double offset) {
    _homeScrollOffset = offset;
  }

  void _saveHomeContinueWatchingOffset(double offset) {
    _homeContinueWatchingOffset = offset;
  }

  void _saveHomeRecentlyAddedOffset(double offset) {
    _homeRecentlyAddedOffset = offset;
  }

  void _openMediaDetail(dynamic item) {
    setState(() {
      _detailItem = item;
    });
  }

  void _closeMediaDetail() {
    setState(() {
      _detailItem = null;
    });
  }

  void _openSectionView(SectionType sectionType) {
    setState(() {
      _sectionType = sectionType;
      _detailItem = null;
    });
  }

  void _closeSectionView() {
    setState(() {
      _sectionType = null;
    });
  }

  void _saveSectionScrollOffset(SectionType sectionType, double offset) {
    _sectionScrollOffsets[sectionType] = offset;
  }

  void _saveLibraryScrollOffset(int index, double offset) {
    _libraryScrollOffsets[index] = offset;
  }

  String _contentKeyValue() {
    final item = _detailItem;
    if (item == null) {
      final sectionType = _sectionType;
      if (sectionType != null) return 'section:${sectionType.name}';
      return 'main-content';
    }
    if (item is Movie) return 'detail:movie:${item.tmdbId}';
    if (item is TVShow) return 'detail:tv:${item.tmdbId}';
    return 'detail:${identityHashCode(item)}';
  }

  bool _isSecondaryContentKey(Key? key) {
    return key is ValueKey<String> &&
        (key.value.startsWith('detail:') || key.value.startsWith('section:'));
  }

  // === 核心修改：页面路由表 ===
  Widget _getPageContent(int index) {
    if (_detailItem != null) {
      return MediaDetailPage(item: _detailItem, onBack: _closeMediaDetail);
    }

    final sectionType = _sectionType;
    if (sectionType != null) {
      return SectionViewPage(
        sectionType: sectionType,
        onBack: _closeSectionView,
        initialScrollOffset: _sectionScrollOffsets[sectionType] ?? 0,
        onScrollOffsetChanged: (offset) =>
            _saveSectionScrollOffset(sectionType, offset),
      );
    }

    switch (index) {
      case 0:
        return HomeContent(
          onScroll: _onHomeScroll,
          initialScrollOffset: _homeScrollOffset,
          initialContinueWatchingOffset: _homeContinueWatchingOffset,
          initialRecentlyAddedOffset: _homeRecentlyAddedOffset,
          onScrollOffsetChanged: _saveHomeScrollOffset,
          onContinueWatchingOffsetChanged: _saveHomeContinueWatchingOffset,
          onRecentlyAddedOffsetChanged: _saveHomeRecentlyAddedOffset,
        ); // 首页聚合
      case 1:
        return LibraryPage(
          key: const ValueKey('library-movies'),
          category: 'Movies',
          initialScrollOffset: _libraryScrollOffsets[index] ?? 0,
          onScrollOffsetChanged: (offset) =>
              _saveLibraryScrollOffset(index, offset),
        ); // 电影库
      case 2:
        return LibraryPage(
          key: const ValueKey('library-tv-shows'),
          category: 'TV Shows',
          initialScrollOffset: _libraryScrollOffsets[index] ?? 0,
          onScrollOffsetChanged: (offset) =>
              _saveLibraryScrollOffset(index, offset),
        ); // 剧集库
      case 3:
        return const FileBrowserPage(); // 文件浏览器
      case 4:
        return LibraryPage(
          key: const ValueKey('library-favorites'),
          category: 'Favorites',
          initialScrollOffset: _libraryScrollOffsets[index] ?? 0,
          onScrollOffsetChanged: (offset) =>
              _saveLibraryScrollOffset(index, offset),
        ); // 收藏
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
    final showHeader =
        _detailItem == null &&
        _sectionType == null &&
        _selectedIndex != 3 &&
        _selectedIndex != 5;

    return Scaffold(
      body: Row(
        children: [
          // 左侧：侧边栏
          SideBar(
            selectedIndex: _selectedIndex,
            onItemSelected: (index) {
              setState(() {
                _selectedIndex = index;
                _detailItem = null;
                _sectionType = null;
              });
            },
          ),

          // 右侧：内容容器
          Expanded(
            child: MediaDetailNavigationScope(
              openMediaDetail: _openMediaDetail,
              child: Container(
                color: theme.scaffoldBackgroundColor, // 使用主题背景色
                child: SectionViewNavigationScope(
                  openSectionView: _openSectionView,
                  child: Stack(
                    children: [
                      // === 1. 底层内容 (动态切换) ===
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 320),
                        reverseDuration: const Duration(milliseconds: 260),
                        switchInCurve: Curves.linear,
                        switchOutCurve: Curves.linear,
                        layoutBuilder: (currentChild, previousChildren) {
                          final stackChildren = <Widget>[];
                          final currentIsSecondary =
                              currentChild != null &&
                              _isSecondaryContentKey(currentChild.key);

                          if (currentChild != null && !currentIsSecondary) {
                            stackChildren.add(
                              Positioned.fill(child: currentChild),
                            );
                          }

                          stackChildren.addAll(
                            previousChildren.map(
                              (child) => Positioned.fill(child: child),
                            ),
                          );

                          if (currentChild != null && currentIsSecondary) {
                            stackChildren.add(
                              Positioned.fill(child: currentChild),
                            );
                          }

                          return Stack(children: stackChildren);
                        },
                        transitionBuilder: (child, animation) {
                          final isSecondary = _isSecondaryContentKey(child.key);
                          final curved = CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeOutQuart,
                            reverseCurve: Curves.easeInCubic,
                          );
                          final offset = Tween<Offset>(
                            begin: isSecondary
                                ? const Offset(0.025, 0)
                                : Offset.zero,
                            end: Offset.zero,
                          ).animate(curved);

                          return FadeTransition(
                            opacity: curved,
                            child: SlideTransition(
                              position: offset,
                              child: child,
                            ),
                          );
                        },
                        child: KeyedSubtree(
                          key: ValueKey(_contentKeyValue()),
                          child: _getPageContent(_selectedIndex),
                        ),
                      ),

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
                            top: _detailItem != null
                                ? 76
                                : _sectionType != null
                                ? 76
                                : showHeader
                                ? 70
                                : 16,
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
                          height: AppHeader.height,
                          child: AppHeader(
                            title: _getTitle(_selectedIndex),
                            opacity: headerOpacity,
                            ignoreWhenTransparent: _selectedIndex == 0,
                          ),
                        ),
                    ],
                  ),
                ),
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
