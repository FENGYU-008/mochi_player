import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:mochi_player/features/library/application/media_library_provider.dart';
import 'package:mochi_player/features/library/presentation/pages/media_detail_page.dart';
import 'package:mochi_player/core/ui/widgets/media_poster_card.dart';
import 'package:mochi_player/features/playback/presentation/playback_launcher.dart';
import 'package:mochi_player/core/domain/media/models.dart';
import 'package:mochi_player/core/ui/theme/app_colors.dart';
import 'package:mochi_player/core/ui/widgets/app_header.dart';
import 'package:mochi_player/core/ui/widgets/macos_controls.dart';

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
            child: _SectionTopBar(
              title: _sectionTitle(widget.sectionType),
              onBack: widget.onBack,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTopBar extends StatelessWidget {
  final String title;
  final VoidCallback? onBack;

  const _SectionTopBar({required this.title, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return AppHeader(
      title: title,
      leading: MacosIconButton(
        onPressed: () => _goBack(context),
        icon: Icons.arrow_back_rounded,
        tooltip: '返回',
        foregroundColor: AppColors.textPrimary(context),
        backgroundColor: AppColors.hoverSurface(context),
        size: 36,
        iconSize: 20,
      ),
    );
  }

  void _goBack(BuildContext context) {
    if (onBack != null) {
      onBack!();
      return;
    }
    Navigator.of(context).maybePop();
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
          return Center(child: Text('错误：${snapshot.error}'));
        }

        final provider = context.read<MediaLibraryProvider>();
        final itemCount = _itemCount(provider, sectionType);
        if (itemCount == 0) {
          return _EmptySectionState(title: _sectionTitle(sectionType));
        }

        return _buildGrid(context, provider, itemCount);
      },
    );
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

  int _itemCount(MediaLibraryProvider provider, SectionType sectionType) {
    switch (sectionType) {
      case SectionType.continueWatching:
        return provider.continueWatching.length;
      case SectionType.recentlyAdded:
        return provider.recentlyAddedContent.length;
      case SectionType.movies:
        return provider.movies.length;
      case SectionType.tvShows:
        return provider.tvShows.length;
    }
  }

  Widget _buildGrid(
    BuildContext context,
    MediaLibraryProvider provider,
    int itemCount,
  ) {
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
          itemCount: itemCount,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: isBackdrop ? 1.35 : 0.57,
            crossAxisSpacing: isBackdrop ? 20 : 24,
            mainAxisSpacing: isBackdrop ? 24 : 32,
          ),
          itemBuilder: (context, index) {
            return _buildCard(context, provider, index);
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

  Widget _buildCard(
    BuildContext context,
    MediaLibraryProvider provider,
    int index,
  ) {
    switch (sectionType) {
      case SectionType.continueWatching:
        return _buildContinueWatchingCard(
          context,
          provider.continueWatching[index],
          provider,
        );
      case SectionType.recentlyAdded:
        return _buildRecentlyAddedCard(
          context,
          provider.recentlyAddedContent[index],
        );
      case SectionType.movies:
        return _buildMovieCard(context, provider.movies[index]);
      case SectionType.tvShows:
        return _buildTVShowCard(context, provider.tvShows[index]);
    }
  }
}

Widget _buildMovieCard(BuildContext context, Movie movie) {
  return MediaPosterCard(
    title: movie.title,
    subtitle: movie.releaseYear?.toString(),
    posterUrl: movie.posterUrl,
    rating: movie.rating,
    tmdbId: movie.tmdbId,
    cardType: MediaCardType.poster,
    onTap: () => openMediaDetailPage(context, movie),
  );
}

Widget _buildTVShowCard(BuildContext context, TVShow show) {
  String? subtitle;
  if (show.numberOfSeasons != null && show.numberOfSeasons! > 0) {
    subtitle = show.numberOfSeasons == 1 ? '1 季' : '${show.numberOfSeasons} 季';
  } else if (show.releaseYear != null) {
    subtitle = show.releaseYear.toString();
  }

  return MediaPosterCard(
    title: show.title,
    subtitle: subtitle,
    posterUrl: show.posterUrl,
    rating: show.rating,
    tmdbId: show.tmdbId,
    cardType: MediaCardType.poster,
    onTap: () => openMediaDetailPage(context, show),
  );
}

Widget _buildRecentlyAddedCard(BuildContext context, dynamic item) {
  if (item is Movie) {
    return _buildMovieCard(context, item);
  }
  if (item is TVShow) {
    return _buildTVShowCard(context, item);
  }
  return const SizedBox.shrink();
}

Widget _buildContinueWatchingCard(
  BuildContext context,
  MediaFile file,
  MediaLibraryProvider provider,
) {
  var title = file.parsedTitle;
  String? subtitle;
  String? imageUrl;
  var rating = 0.0;
  dynamic metadata;

  if (file.mediaType == MediaType.movie) {
    metadata = provider.getMovieMetadata(file.tmdbId ?? '');
    if (metadata != null) {
      title = metadata.title;
      imageUrl = metadata.backdropUrl;
      rating = metadata.rating;
      subtitle = metadata.releaseYear?.toString();
    }
  } else {
    subtitle = _episodeLabel(file);
    metadata = provider.getTVShowMetadata(file.tmdbId ?? '');
    if (metadata != null) {
      title = metadata.title;
      imageUrl = metadata.backdropUrl;
      rating = metadata.rating;
      if (subtitle == null && metadata.numberOfSeasons != null) {
        subtitle = '${metadata.numberOfSeasons} 季';
      }
    }
  }

  return MediaPosterCard(
    title: title,
    subtitle: subtitle,
    posterUrl: imageUrl,
    rating: rating,
    tmdbId: file.tmdbId,
    cardType: MediaCardType.backdrop,
    progress: file.progress,
    showProgress: true,
    onTap: () {
      PlaybackLauncher.playFile(
        context,
        file,
        contextTitle: file.mediaType == MediaType.episode ? title : null,
      );
    },
  );
}

String? _episodeLabel(MediaFile file) {
  final season = file.parsedSeason;
  final episode = file.parsedEpisode;
  if (season == null || episode == null) return null;

  return '第 $season 季 第 $episode 集';
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

class _EmptySectionState extends StatelessWidget {
  final String title;

  const _EmptySectionState({required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.movie_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            '$title为空',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            '请先扫描媒体库以发现资源',
            style: TextStyle(fontSize: 14, color: Colors.grey[400]),
          ),
        ],
      ),
    );
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
