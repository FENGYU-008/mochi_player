import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mochi_player/features/library/application/media_library_provider.dart';
import 'package:mochi_player/features/library/presentation/pages/media_detail_page.dart';
import 'package:mochi_player/core/ui/app_ui.dart';
import 'package:mochi_player/features/library/presentation/widgets/library_item_poster_card.dart';

class LibraryPage extends StatefulWidget {
  final String category;
  final double initialScrollOffset;
  final ValueChanged<double>? onScrollOffsetChanged;

  const LibraryPage({
    super.key,
    required this.category,
    this.initialScrollOffset = 0,
    this.onScrollOffsetChanged,
  });

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController(
      initialScrollOffset: widget.initialScrollOffset,
    );
    _scrollController.addListener(_saveScrollOffset);
  }

  @override
  void dispose() {
    _saveScrollOffset();
    _scrollController.removeListener(_saveScrollOffset);
    _scrollController.dispose();
    super.dispose();
  }

  void _saveScrollOffset() {
    if (!_scrollController.hasClients) return;
    widget.onScrollOffsetChanged?.call(_scrollController.offset);
  }

  @override
  Widget build(BuildContext context) {
    return Selector<MediaLibraryProvider, _LibraryPageSnapshot>(
      selector: (context, provider) => _LibraryPageSnapshot(
        showInitialLoading: provider.isLoading && provider.totalFiles == 0,
        error: provider.error,
        contentRevision: _contentRevisionFor(provider),
      ),
      builder: (context, snapshot, child) {
        if (snapshot.showInitialLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.error != null) {
          return AppErrorState(message: '错误：${snapshot.error}');
        }

        final provider = context.read<MediaLibraryProvider>();

        // 根据 category 选择显示内容
        Widget content;
        switch (widget.category) {
          case 'Movies':
            content = _buildMovieGrid(context, provider);
            break;
          case 'TV Shows':
            content = _buildTVShowGrid(context, provider);
            break;
          case 'Favorites':
            content = _buildFavoritesGrid(context, provider);
            break;
          default:
            content = _buildUncategorizedGrid(context, provider);
        }

        return content;
      },
    );
  }

  int _contentRevisionFor(MediaLibraryProvider provider) {
    switch (widget.category) {
      case 'Movies':
      case 'TV Shows':
        return provider.metadataRevision;
      case 'Favorites':
        return Object.hash(
          provider.mediaCatalogRevision,
          provider.metadataRevision,
          provider.favoriteRevision,
        );
      default:
        return provider.mediaCatalogRevision;
    }
  }

  Widget _buildMovieGrid(BuildContext context, MediaLibraryProvider provider) {
    final items = provider.movies;

    if (items.isEmpty) {
      return _buildEmptyState('电影');
    }

    return _buildGridView(
      itemCount: items.length,
      itemBuilder: (context, index) {
        return LibraryItemPosterCard(item: items[index]);
      },
    );
  }

  Widget _buildTVShowGrid(BuildContext context, MediaLibraryProvider provider) {
    final items = provider.tvShows;

    if (items.isEmpty) {
      return _buildEmptyState('剧集');
    }

    return _buildGridView(
      itemCount: items.length,
      itemBuilder: (context, index) {
        return LibraryItemPosterCard(item: items[index]);
      },
    );
  }

  Widget _buildFavoritesGrid(
    BuildContext context,
    MediaLibraryProvider provider,
  ) {
    final items = provider.favoriteItems;

    if (items.isEmpty) {
      return _buildEmptyState('收藏');
    }

    return _buildGridView(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];

        return MediaPosterCard(
          title: item.title,
          subtitle: item.subtitle,
          posterUrl: item.imageUrl,
          rating: item.rating,
          tmdbId: item.file.tmdbId,
          cardType: MediaCardType.poster,
          onTap: () {
            final libraryItem = item.libraryItem;
            if (libraryItem != null) {
              openMediaDetailPage(context, libraryItem);
            }
          },
        );
      },
    );
  }

  Widget _buildUncategorizedGrid(
    BuildContext context,
    MediaLibraryProvider provider,
  ) {
    final items = provider.uncategorized;

    if (items.isEmpty) {
      return _buildEmptyState('未分类资源');
    }

    return _buildGridView(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final file = items[index];
        return MediaPosterCard(
          title: file.parsedTitle,
          subtitle: file.parsedYear?.toString(),
          posterUrl: null,
          rating: 0.0,
          tmdbId: null,
          cardType: MediaCardType.poster,
          onTap: () {},
        );
      },
    );
  }

  Widget _buildGridView({
    required int itemCount,
    required Widget Function(BuildContext, int) itemBuilder,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double width = constraints.maxWidth;
        double contentWidth = width - 80;

        const double desiredItemWidth = 180;
        int crossAxisCount = (contentWidth / desiredItemWidth).round();
        if (crossAxisCount < 3) crossAxisCount = 3;

        return GridView.builder(
          key: PageStorageKey<String>('library-${widget.category}'),
          controller: _scrollController,
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.page,
            100,
            AppSpacing.page,
            AppSpacing.page,
          ),
          itemCount: itemCount,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 0.57,
            crossAxisSpacing: 24,
            mainAxisSpacing: 32,
          ),
          itemBuilder: itemBuilder,
        );
      },
    );
  }

  Widget _buildEmptyState(String category) {
    return AppEmptyState(title: '没有找到$category', description: '请先扫描媒体库以发现资源');
  }
}

class _LibraryPageSnapshot {
  final bool showInitialLoading;
  final String? error;
  final int contentRevision;

  const _LibraryPageSnapshot({
    required this.showInitialLoading,
    required this.error,
    required this.contentRevision,
  });

  @override
  bool operator ==(Object other) {
    return other is _LibraryPageSnapshot &&
        other.showInitialLoading == showInitialLoading &&
        other.error == error &&
        other.contentRevision == contentRevision;
  }

  @override
  int get hashCode => Object.hash(showInitialLoading, error, contentRevision);
}
