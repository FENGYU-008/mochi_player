import 'package:flutter/material.dart';
import 'package:mochi_player/providers/app_settings_provider.dart';
import 'package:mochi_player/features/playback/presentation/playback_launcher.dart';
import 'package:mochi_player/ui/widgets/file_list_item.dart';
import 'package:provider/provider.dart';

// 引入核心组件和数据
import '../../providers/file_browser_provider.dart';
import '../../models/domain/media_file.dart';
import '../../models/domain/media_type.dart';
import '../theme/app_colors.dart';
import '../widgets/file_card.dart'; // 引入刚才写的方形卡片
import '../widgets/macos_controls.dart';

class FileBrowserPage extends StatefulWidget {
  const FileBrowserPage({super.key});

  @override
  State<FileBrowserPage> createState() => _FileBrowserPageState();
}

class _FileBrowserPageState extends State<FileBrowserPage> {
  bool _didScheduleInitialLoad = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // === 1. 顶部功能栏 (Top Bar) ===
          Selector<FileBrowserProvider, _FileBrowserTopBarState>(
            selector: (context, provider) => _FileBrowserTopBarState(
              currentPath: provider.currentPath,
              canGoBack: provider.canGoBack,
              viewMode: provider.viewMode,
            ),
            builder: (context, topBarState, child) {
              return _buildTopBar(
                context,
                topBarState,
                context.read<FileBrowserProvider>(),
              );
            },
          ),

          // === 2. 内容区域 (Content) ===
          Expanded(
            child:
                Selector2<
                  FileBrowserProvider,
                  AppSettingsProvider,
                  _FileBrowserContentState
                >(
                  selector: (context, fileProvider, settingsProvider) {
                    final error =
                        fileProvider.error ??
                        (settingsProvider.hasWebDavConfig
                            ? null
                            : '请先在设置中配置 WebDAV');
                    return _FileBrowserContentState(
                      items: fileProvider.items,
                      isLoading: fileProvider.isLoading,
                      hasLoaded: fileProvider.hasLoaded,
                      hasWebDavConfig: settingsProvider.hasWebDavConfig,
                      error: error,
                      viewMode: fileProvider.viewMode,
                    );
                  },
                  builder: (context, contentState, child) {
                    if (!contentState.hasWebDavConfig) {
                      return _buildEmptyState(contentState.error);
                    }

                    if (contentState.shouldLoadInitialPath) {
                      _scheduleInitialLoad();
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (contentState.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (contentState.items.isEmpty) {
                      return _buildEmptyState(contentState.error);
                    }

                    return _buildContent(
                      context,
                      contentState,
                      context.read<FileBrowserProvider>(),
                    );
                  },
                ),
          ),
        ],
      ),
    );
  }

  void _scheduleInitialLoad() {
    if (_didScheduleInitialLoad) return;
    _didScheduleInitialLoad = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final settingsProvider = context.read<AppSettingsProvider>();
      final fileProvider = context.read<FileBrowserProvider>();
      if (!settingsProvider.hasWebDavConfig ||
          fileProvider.hasLoaded ||
          fileProvider.isLoading) {
        return;
      }

      fileProvider.fetchFiles(fileProvider.currentPath);
    });
  }

  // 构建顶部导航栏
  Widget _buildTopBar(
    BuildContext context,
    _FileBrowserTopBarState state,
    FileBrowserProvider provider,
  ) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
      decoration: BoxDecoration(
        color: theme.canvasColor, // 使用主题中的画布颜色
        border: Border(
          bottom: BorderSide(
            color: theme.dividerColor.withAlpha((255 * 0.5).round()),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // A. 返回按钮 (只有能返回时才显示)
          if (state.canGoBack)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: MacosIconButton(
                onPressed: () => provider.navigateBack(),
                icon: Icons.arrow_back_ios_new_rounded,
                tooltip: "返回上一级",
                foregroundColor: AppColors.textPrimary(context),
                backgroundColor: AppColors.hoverSurface(context),
                size: 36,
                iconSize: 16,
              ),
            ),

          // B. 当前路径图标
          Icon(
            Icons.folder_open_rounded,
            color: AppColors.primary(context),
            size: 24,
          ),
          const SizedBox(width: 12),

          // C. 当前路径文字
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "浏览文件",
                  style: TextStyle(
                    color: theme.textTheme.titleMedium?.color,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  state.currentPath, // 显示 WebDAV 路径
                  style: TextStyle(
                    color: theme.textTheme.bodyMedium!.color,
                    fontSize: 16,
                    fontFamily: 'SF Pro Display',
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // D. 视图切换按钮
          MacosIconButton(
            onPressed: () => provider.toggleViewMode(),
            icon: state.viewMode == ViewMode.grid
                ? Icons.view_list_rounded
                : Icons.grid_view_rounded,
            tooltip: "切换视图",
            foregroundColor: AppColors.textPrimary(context),
            backgroundColor: AppColors.hoverSurface(context),
            size: 36,
            iconSize: 19,
          ),
          const SizedBox(width: 8),

          // E. 刷新按钮
          MacosIconButton(
            onPressed: () => provider.refresh(),
            icon: Icons.refresh_rounded,
            tooltip: "刷新目录",
            foregroundColor: AppColors.textPrimary(context),
            backgroundColor: AppColors.hoverSurface(context),
            size: 36,
            iconSize: 20,
          ),
        ],
      ),
    );
  }

  // 根据视图模式构建内容
  Widget _buildContent(
    BuildContext context,
    _FileBrowserContentState state,
    FileBrowserProvider provider,
  ) {
    if (state.viewMode == ViewMode.grid) {
      return _buildGridView(context, state.items, provider);
    } else {
      return _buildListView(context, state.items, provider);
    }
  }

  // 构建网格视图
  Widget _buildGridView(
    BuildContext context,
    List<MediaFile> items,
    FileBrowserProvider provider,
  ) {
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 130,
        childAspectRatio: 0.85,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return FileCard(
          item: item,
          onTap: () => _onItemTap(context, item, provider),
        );
      },
    );
  }

  // 构建列表视图
  Widget _buildListView(
    BuildContext context,
    List<MediaFile> items,
    FileBrowserProvider provider,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return FileListItem(
          item: item,
          onTap: () => _onItemTap(context, item, provider),
        );
      },
    );
  }

  // 统一处理项目点击事件
  void _onItemTap(
    BuildContext context,
    MediaFile item,
    FileBrowserProvider provider,
  ) {
    if (item.mediaType == MediaType.folder) {
      provider.enterFolder(item);
    } else {
      _playVideo(context, item);
    }
  }

  // 播放视频的逻辑
  void _playVideo(BuildContext context, MediaFile item) {
    PlaybackLauncher.playFile(
      context,
      item,
      loadingMessage: "正在获取播放链接: ${item.fileName}",
      failureMessage: "获取播放链接失败，请检查 Alist 配置或网络",
    );
  }

  // 构建空状态视图
  Widget _buildEmptyState(String? error) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            error == null ? Icons.folder_off_outlined : Icons.settings_outlined,
            size: 64,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            error ?? "此文件夹为空",
            style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
          ),
        ],
      ),
    );
  }
}

class _FileBrowserTopBarState {
  final String currentPath;
  final bool canGoBack;
  final ViewMode viewMode;

  const _FileBrowserTopBarState({
    required this.currentPath,
    required this.canGoBack,
    required this.viewMode,
  });

  @override
  bool operator ==(Object other) {
    return other is _FileBrowserTopBarState &&
        other.currentPath == currentPath &&
        other.canGoBack == canGoBack &&
        other.viewMode == viewMode;
  }

  @override
  int get hashCode => Object.hash(currentPath, canGoBack, viewMode);
}

class _FileBrowserContentState {
  final List<MediaFile> items;
  final bool isLoading;
  final bool hasLoaded;
  final bool hasWebDavConfig;
  final String? error;
  final ViewMode viewMode;

  const _FileBrowserContentState({
    required this.items,
    required this.isLoading,
    required this.hasLoaded,
    required this.hasWebDavConfig,
    required this.error,
    required this.viewMode,
  });

  bool get shouldLoadInitialPath => hasWebDavConfig && !hasLoaded && !isLoading;

  @override
  bool operator ==(Object other) {
    return other is _FileBrowserContentState &&
        identical(other.items, items) &&
        other.isLoading == isLoading &&
        other.hasLoaded == hasLoaded &&
        other.hasWebDavConfig == hasWebDavConfig &&
        other.error == error &&
        other.viewMode == viewMode;
  }

  @override
  int get hashCode => Object.hash(
    identityHashCode(items),
    isLoading,
    hasLoaded,
    hasWebDavConfig,
    error,
    viewMode,
  );
}
