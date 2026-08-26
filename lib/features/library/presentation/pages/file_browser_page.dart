import 'package:flutter/material.dart';
import 'package:mochi_player/core/ui/app_ui.dart';
import 'package:mochi_player/features/library/application/file_browser_provider.dart';
import 'package:mochi_player/features/library/domain/file_browser_entry.dart';
import 'package:mochi_player/features/library/presentation/widgets/file_browser_grid_tile.dart';
import 'package:mochi_player/features/library/presentation/widgets/file_browser_list.dart';
import 'package:mochi_player/features/library/presentation/widgets/file_browser_toolbar.dart';
import 'package:mochi_player/features/playback/presentation/playback_launcher.dart';
import 'package:mochi_player/features/settings/application/app_settings_provider.dart';
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
    final provider = context.read<FileBrowserProvider>();

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppHeader(
            title: '文件浏览',
            trailing: SizedBox(
              width: 300,
              child: AppSearchInput(placeholder: '搜索当前目录…', onChanged: provider.setSearchQuery),
            ),
          ),
          Expanded(
            child: Selector2<FileBrowserProvider, AppSettingsProvider, _FileBrowserState>(
              selector: (context, fileProvider, settingsProvider) {
                final error = fileProvider.error ?? (settingsProvider.hasWebDavConfig ? null : '请先在设置中配置 OpenList');
                return _FileBrowserState(
                  items: fileProvider.visibleItems,
                  totalItemCount: fileProvider.items.length,
                  isLoading: fileProvider.isLoading,
                  hasLoaded: fileProvider.hasLoaded,
                  hasWebDavConfig: settingsProvider.hasWebDavConfig,
                  error: error,
                  currentPath: fileProvider.currentPath,
                  canGoBack: fileProvider.canGoBack,
                  canGoForward: fileProvider.canGoForward,
                  viewMode: fileProvider.viewMode,
                  sortField: fileProvider.sortField,
                  sortAscending: fileProvider.sortAscending,
                  hasSearchQuery: fileProvider.searchQuery.trim().isNotEmpty,
                );
              },
              builder: (context, state, child) {
                if (state.shouldLoadInitialPath) _scheduleInitialLoad();
                return _FileBrowserBody(
                  state: state,
                  provider: context.read<FileBrowserProvider>(),
                  onItemTap: (item) => _onItemTap(context, item, provider),
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
      if (!settingsProvider.hasWebDavConfig || fileProvider.hasLoaded || fileProvider.isLoading) {
        return;
      }
      fileProvider.fetchFiles(fileProvider.currentPath);
    });
  }

  void _onItemTap(BuildContext context, FileBrowserEntry item, FileBrowserProvider provider) {
    if (item.isDirectory) {
      provider.enterFolder(item);
      return;
    }
    if (!item.isPlayable) return;
    PlaybackLauncher.playFile(
      context,
      provider.createPlaybackFile(item),
      loadingMessage: '正在获取播放链接: ${item.name}',
      failureMessage: '获取播放链接失败，请检查 OpenList 配置或网络',
    );
  }
}

class _FileBrowserBody extends StatelessWidget {
  final _FileBrowserState state;
  final FileBrowserProvider provider;
  final ValueChanged<FileBrowserEntry> onItemTap;

  const _FileBrowserBody({required this.state, required this.provider, required this.onItemTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.section, AppSpacing.xxl, AppSpacing.section, AppSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FileBrowserToolbar(
            currentPath: state.currentPath,
            canGoBack: state.canGoBack,
            canGoForward: state.canGoForward,
            viewMode: state.viewMode,
            sortField: state.sortField,
            sortAscending: state.sortAscending,
            onBack: provider.navigateBack,
            onForward: provider.navigateForward,
            onPathSelected: provider.navigateToPath,
            onSortChanged: (field, ascending) => provider.setSort(field, ascending: ascending),
            onViewModeChanged: provider.setViewMode,
            onRefresh: provider.refresh,
          ),
          const SizedBox(height: AppSpacing.xxl),
          Expanded(child: _buildContent(context)),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (!state.hasWebDavConfig) {
      return AppResult(
        status: AppResultStatus.info,
        title: '尚未配置 OpenList',
        subtitle: state.error ?? '请先在设置中完成连接配置',
        icon: Icon(Icons.settings_outlined, size: 44, color: AppColors.primary(context)),
      );
    }
    if (state.isLoading || state.shouldLoadInitialPath) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.items.isEmpty) {
      if (state.hasSearchQuery) {
        return AppResult(
          status: AppResultStatus.empty,
          title: '没有匹配的文件',
          subtitle: '请尝试其他关键词',
          icon: Icon(Icons.search_off_rounded, size: 44, color: AppColors.textSecondary(context)),
        );
      }
      if (state.error != null) {
        return AppResult(status: AppResultStatus.error, title: '文件加载失败', subtitle: state.error);
      }
      return const AppResult(
        status: AppResultStatus.empty,
        title: '此文件夹为空',
        icon: Icon(Icons.folder_off_outlined, size: 44),
      );
    }
    if (state.viewMode == FileBrowserViewMode.grid) return _buildGrid();
    return _buildList();
  }

  Widget _buildGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: GridView.builder(
            key: PageStorageKey<String>('file-browser-grid:${state.currentPath}'),
            padding: EdgeInsets.zero,
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 138,
              childAspectRatio: 0.95,
              crossAxisSpacing: AppSpacing.md,
              mainAxisSpacing: AppSpacing.md,
            ),
            itemCount: state.items.length,
            itemBuilder: (context, index) {
              final item = state.items[index];
              return FileBrowserGridTile(
                item: item,
                onTap: item.isDirectory || item.isPlayable ? () => onItemTap(item) : null,
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _buildSummary(),
      ],
    );
  }

  Widget _buildList() {
    return FileBrowserListSection(
      items: state.items,
      totalItemCount: state.totalItemCount,
      isFiltered: state.hasSearchQuery,
      onItemTap: onItemTap,
      scrollStorageKey: PageStorageKey<String>('file-browser-list:${state.currentPath}'),
    );
  }

  Widget _buildSummary() =>
      FileBrowserSummary(items: state.items, totalItemCount: state.totalItemCount, isFiltered: state.hasSearchQuery);
}

class _FileBrowserState {
  final List<FileBrowserEntry> items;
  final int totalItemCount;
  final bool isLoading;
  final bool hasLoaded;
  final bool hasWebDavConfig;
  final String? error;
  final String currentPath;
  final bool canGoBack;
  final bool canGoForward;
  final FileBrowserViewMode viewMode;
  final FileSortField sortField;
  final bool sortAscending;
  final bool hasSearchQuery;

  const _FileBrowserState({
    required this.items,
    required this.totalItemCount,
    required this.isLoading,
    required this.hasLoaded,
    required this.hasWebDavConfig,
    required this.error,
    required this.currentPath,
    required this.canGoBack,
    required this.canGoForward,
    required this.viewMode,
    required this.sortField,
    required this.sortAscending,
    required this.hasSearchQuery,
  });

  bool get shouldLoadInitialPath => hasWebDavConfig && !hasLoaded && !isLoading;

  @override
  bool operator ==(Object other) {
    return other is _FileBrowserState &&
        _sameItems(other.items, items) &&
        other.totalItemCount == totalItemCount &&
        other.isLoading == isLoading &&
        other.hasLoaded == hasLoaded &&
        other.hasWebDavConfig == hasWebDavConfig &&
        other.error == error &&
        other.currentPath == currentPath &&
        other.canGoBack == canGoBack &&
        other.canGoForward == canGoForward &&
        other.viewMode == viewMode &&
        other.sortField == sortField &&
        other.sortAscending == sortAscending &&
        other.hasSearchQuery == hasSearchQuery;
  }

  @override
  int get hashCode => Object.hash(
    Object.hashAll(items),
    totalItemCount,
    isLoading,
    hasLoaded,
    hasWebDavConfig,
    error,
    currentPath,
    canGoBack,
    canGoForward,
    viewMode,
    sortField,
    sortAscending,
    hasSearchQuery,
  );

  static bool _sameItems(List<FileBrowserEntry> a, List<FileBrowserEntry> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (var index = 0; index < a.length; index++) {
      if (!identical(a[index], b[index])) return false;
    }
    return true;
  }
}
