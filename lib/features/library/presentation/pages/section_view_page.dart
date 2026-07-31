import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:mochi_player/features/library/application/media_library_provider.dart';
import 'package:mochi_player/core/ui/app_ui.dart';
import 'package:mochi_player/features/library/presentation/widgets/continue_watching_card.dart';
import 'package:mochi_player/features/library/presentation/widgets/library_item_poster_card.dart';

/// Section 类型
enum SectionType { continueWatching, movies, tvShows, recentlyAdded }

typedef OpenSectionView = void Function(SectionType sectionType);

void openSectionViewPage(BuildContext context, SectionType sectionType) {
  final scope = SectionViewNavigationScope.maybeOf(context);
  if (scope != null) {
    scope.openSectionView(sectionType);
    return;
  }

  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (context) => SectionViewPage(sectionType: sectionType),
    ),
  );
}

class SectionViewNavigationScope extends InheritedWidget {
  final OpenSectionView openSectionView;

  const SectionViewNavigationScope({
    super.key,
    required this.openSectionView,
    required super.child,
  });

  static SectionViewNavigationScope? maybeOf(BuildContext context) {
    final widget = context
        .getElementForInheritedWidgetOfExactType<SectionViewNavigationScope>()
        ?.widget;
    return widget is SectionViewNavigationScope ? widget : null;
  }

  @override
  bool updateShouldNotify(SectionViewNavigationScope oldWidget) {
    return openSectionView != oldWidget.openSectionView;
  }
}

class SectionViewPage extends StatefulWidget {
  final SectionType sectionType;
  final VoidCallback? onBack;
  final double initialScrollOffset;
  final ValueChanged<double>? onScrollOffsetChanged;

  const SectionViewPage({
    super.key,
    required this.sectionType,
    this.onBack,
    this.initialScrollOffset = 0,
    this.onScrollOffsetChanged,
  });

  @override
  State<SectionViewPage> createState() => _SectionViewPageState();
}

class _SectionViewPageState extends State<SectionViewPage> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController(
      initialScrollOffset: widget.initialScrollOffset,
    );
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _saveScrollOffset();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    _saveScrollOffset();
  }

  void _saveScrollOffset() {
    if (!_scrollController.hasClients) return;
    widget.onScrollOffsetChanged?.call(_scrollController.offset);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          Positioned.fill(
            child: _SectionPageContent(
              sectionType: widget.sectionType,
              scrollController: _scrollController,
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: AppHeader.height,
            child: AppHeader(
              title: _sectionTitle(widget.sectionType),
              showBackButton: true,
              onBack: widget.onBack,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionPageContent extends StatelessWidget {
  final SectionType sectionType;
  final ScrollController scrollController;

  const _SectionPageContent({
    required this.sectionType,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return Selector<MediaLibraryProvider, _SectionSnapshot>(
      selector: (context, provider) => _SectionSnapshot(
        showInitialLoading: provider.isLoading && provider.totalFiles == 0,
        error: provider.error,
        contentRevision: _contentRevisionFor(provider, sectionType),
      ),
      builder: (context, snapshot, child) {
        if (snapshot.showInitialLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.error != null) {
          return AppErrorState(message: '错误：${snapshot.error}');
        }

        final provider = context.read<MediaLibraryProvider>();
        return switch (sectionType) {
          SectionType.continueWatching => _buildSection(
            provider.continueWatchingItems,
            (item) => ContinueWatchingCard(item: item),
          ),
          SectionType.recentlyAdded => _buildSection(
            provider.recentlyAddedContent,
            (item) => LibraryItemPosterCard(item: item),
          ),
          SectionType.movies => _buildSection(
            provider.movies,
            (item) => LibraryItemPosterCard(item: item),
          ),
          SectionType.tvShows => _buildSection(
            provider.tvShows,
            (item) => LibraryItemPosterCard(item: item),
          ),
        };
      },
    );
  }

  Widget _buildSection<T>(List<T> items, Widget Function(T item) itemBuilder) {
    if (items.isEmpty) {
      final title = _sectionTitle(sectionType);
      return AppEmptyState(title: '$title为空', description: '请先扫描媒体库以发现资源');
    }

    return _buildGrid(items, itemBuilder);
  }

  int _contentRevisionFor(
    MediaLibraryProvider provider,
    SectionType sectionType,
  ) {
    switch (sectionType) {
      case SectionType.continueWatching:
        return Object.hash(
          provider.mediaCatalogRevision,
          provider.metadataRevision,
          provider.watchProgressRevision,
        );
      case SectionType.recentlyAdded:
        return Object.hash(
          provider.mediaCatalogRevision,
          provider.metadataRevision,
        );
      case SectionType.movies:
      case SectionType.tvShows:
        return provider.metadataRevision;
    }
  }

  Widget _buildGrid<T>(List<T> items, Widget Function(T item) itemBuilder) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isBackdrop = sectionType == SectionType.continueWatching;
        final contentWidth = constraints.maxWidth - 80;
        final crossAxisCount = isBackdrop
            ? (contentWidth / 280).floor().clamp(2, 8).toInt()
            : _libraryPosterColumnCount(contentWidth);

        return GridView.builder(
          key: PageStorageKey<String>('section-view-${sectionType.name}'),
          controller: scrollController,
          padding: EdgeInsets.fromLTRB(
            40,
            AppHeader.height + 40,
            40,
            isBackdrop ? 44 : 40,
          ),
          itemCount: items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: isBackdrop ? 1.35 : 0.57,
            crossAxisSpacing: isBackdrop ? 20 : 24,
            mainAxisSpacing: isBackdrop ? 24 : 32,
          ),
          itemBuilder: (context, index) {
            return itemBuilder(items[index]);
          },
        );
      },
    );
  }

  int _libraryPosterColumnCount(double contentWidth) {
    const desiredItemWidth = 180.0;
    final crossAxisCount = (contentWidth / desiredItemWidth).round();
    return crossAxisCount < 3 ? 3 : crossAxisCount;
  }
}

String _sectionTitle(SectionType sectionType) {
  switch (sectionType) {
    case SectionType.continueWatching:
      return '继续观看';
    case SectionType.recentlyAdded:
      return '最近添加';
    case SectionType.movies:
      return '电影';
    case SectionType.tvShows:
      return '剧集';
  }
}

class _SectionSnapshot {
  final bool showInitialLoading;
  final String? error;
  final int contentRevision;

  const _SectionSnapshot({
    required this.showInitialLoading,
    required this.error,
    required this.contentRevision,
  });

  @override
  bool operator ==(Object other) {
    return other is _SectionSnapshot &&
        other.showInitialLoading == showInitialLoading &&
        other.error == error &&
        other.contentRevision == contentRevision;
  }

  @override
  int get hashCode => Object.hash(showInitialLoading, error, contentRevision);
}
