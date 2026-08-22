import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mochi_player/features/library/application/media_library_provider.dart';
import 'package:mochi_player/features/library/presentation/pages/media_detail_page.dart';
import 'package:mochi_player/core/ui/app_ui.dart';
import 'package:mochi_player/features/library/presentation/widgets/library_item_poster_card.dart';

enum LibraryCategory { movies, series, favorites }

class LibraryPage extends StatefulWidget {
  final LibraryCategory category;

  const LibraryPage({super.key, required this.category});

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
          return AppErrorState(message: '错误：${snapshot.error}');
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
          key: PageStorageKey<String>('library-${widget.category.name}'),
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
