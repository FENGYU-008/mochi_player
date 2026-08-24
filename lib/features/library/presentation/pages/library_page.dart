import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mochi_player/features/library/application/media_library_provider.dart';
import 'package:mochi_player/features/library/presentation/pages/media_detail_page.dart';
import 'package:mochi_player/core/ui/app_ui.dart';
import 'package:mochi_player/features/library/presentation/widgets/library_item_poster_card.dart';
import 'package:mochi_player/features/library/presentation/widgets/media_poster_grid.dart';

enum LibraryCategory { movies, series, favorites }

class LibraryPage extends StatefulWidget {
  final LibraryCategory category;
  final String searchQuery;

  const LibraryPage({super.key, required this.category, this.searchQuery = ''});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
          return AppResult(
            status: AppResultStatus.error,
            title: '媒体库加载失败',
            subtitle: snapshot.error,
          );
        }

        final provider = context.read<MediaLibraryProvider>();

        return switch (widget.category) {
          LibraryCategory.movies => _buildMovieGrid(context, provider),
          LibraryCategory.series => _buildTVShowGrid(context, provider),
          LibraryCategory.favorites => _buildFavoritesGrid(context, provider),
        };
      },
    );
  }

  int _contentRevisionFor(MediaLibraryProvider provider) {
    switch (widget.category) {
      case LibraryCategory.movies:
      case LibraryCategory.series:
        return provider.metadataRevision;
      case LibraryCategory.favorites:
        return Object.hash(
          provider.mediaCatalogRevision,
          provider.metadataRevision,
          provider.favoriteRevision,
        );
    }
  }

  Widget _buildMovieGrid(BuildContext context, MediaLibraryProvider provider) {
    final items = provider.searchMovies(widget.searchQuery);

    if (items.isEmpty) {
      return _buildEmptyState('电影', hasQuery: _hasSearchQuery);
    }

    return _buildGridView(
      itemCount: items.length,
      itemBuilder: (context, index) {
        return LibraryItemPosterCard(item: items[index]);
      },
    );
  }

  Widget _buildTVShowGrid(BuildContext context, MediaLibraryProvider provider) {
    final items = provider.searchTVShows(widget.searchQuery);

    if (items.isEmpty) {
      return _buildEmptyState('剧集', hasQuery: _hasSearchQuery);
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
    final items = provider.searchFavorites(widget.searchQuery);

    if (items.isEmpty) {
      return _buildEmptyState('收藏', hasQuery: _hasSearchQuery);
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

  Widget _buildGridView({
    required int itemCount,
    required Widget Function(BuildContext, int) itemBuilder,
  }) {
    return MediaPosterGrid<int>(
      items: List.generate(itemCount, (index) => index),
      itemBuilder: (context, index) => itemBuilder(context, index),
      storageKey: 'library-${widget.category.name}',
      controller: _scrollController,
    );
  }

  bool get _hasSearchQuery => widget.searchQuery.trim().isNotEmpty;

  Widget _buildEmptyState(String category, {required bool hasQuery}) {
    return AppResult(
      status: AppResultStatus.empty,
      title: hasQuery ? '没有匹配的$category' : '没有找到$category',
      subtitle: hasQuery ? '请尝试其他关键词' : '请先扫描媒体库以发现资源',
    );
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
