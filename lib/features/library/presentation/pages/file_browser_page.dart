import 'package:flutter/material.dart';
import 'package:mochi_player/features/library/application/file_browser_provider.dart';
import 'package:mochi_player/features/library/presentation/widgets/file_card.dart';
import 'package:mochi_player/features/library/presentation/widgets/file_list_item.dart';
import 'package:mochi_player/features/settings/application/app_settings_provider.dart';
import 'package:mochi_player/features/playback/presentation/playback_launcher.dart';
import 'package:mochi_player/core/domain/media/media_file.dart';
import 'package:mochi_player/core/domain/media/media_type.dart';
import 'package:mochi_player/core/ui/app_ui.dart';
import 'package:provider/provider.dart';

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
    return AppHeader(
      title: state.currentPath,
      subtitle: '浏览文件',
      showSearch: false,
      showBackButton: state.canGoBack,
      onBack: provider.navigateBack,
      leading: state.canGoBack
          ? null
          : Icon(
              Icons.folder_open_rounded,
              color: AppColors.primary(context),
              size: 24,
            ),
      actions: [
        AppIconButton(
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
        AppIconButton(
          onPressed: () => provider.refresh(),
          icon: Icons.refresh_rounded,
          tooltip: "刷新目录",
          foregroundColor: AppColors.textPrimary(context),
          backgroundColor: AppColors.hoverSurface(context),
          size: 36,
          iconSize: 20,
        ),
      ],
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
    return AppEmptyState(
      title: error ?? '此文件夹为空',
      icon: error == null ? Icons.folder_off_outlined : Icons.settings_outlined,
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
