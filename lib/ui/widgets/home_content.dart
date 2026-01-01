import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/media_library_provider.dart';
import '../../models/domain/models.dart';
import '../pages/section_view_page.dart';
import '../pages/media_detail_modals.dart';
import 'media_poster_card.dart';
import 'horizontal_scroll_view.dart';
import 'hero_section.dart';

class HomeContent extends StatefulWidget {
  /// 回调函数，用于通知父组件滚动偏移量
  final void Function(double offset)? onScroll;

  const HomeContent({super.key, this.onScroll});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  final ScrollController _mainScrollController = ScrollController();
  final ScrollController _continueWatchingCtrl = ScrollController();
  final ScrollController _recentlyAddedCtrl = ScrollController();
  final ScrollController _trendingCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _mainScrollController.addListener(_onScroll);
  }

  void _onScroll() {
    widget.onScroll?.call(_mainScrollController.offset);
  }

  @override
  void dispose() {
    _mainScrollController.removeListener(_onScroll);
    _mainScrollController.dispose();
    _continueWatchingCtrl.dispose();
    _recentlyAddedCtrl.dispose();
    _trendingCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MediaLibraryProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.mediaFiles.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        final heroItem = provider.getRandomHeroItem();
        final continueWatchingItems = provider.continueWatching;
        final recentlyAddedItems = provider.recentlyAddedContent
            .take(15)
            .toList();
        final trendingItems = provider.trending;

        // 如果库完全为空，显示空状态
        if (heroItem == null &&
            continueWatchingItems.isEmpty &&
            recentlyAddedItems.isEmpty &&
            trendingItems.isEmpty) {
          return _buildEmptyState();
        }

        return CustomScrollView(
          controller: _mainScrollController,
          slivers: [
            // Hero Section (无 padding，直接到顶部)
            SliverToBoxAdapter(child: HeroSection(heroItem: heroItem)),

            // Continue Watching
            if (continueWatchingItems.isNotEmpty) ...[
              _buildSectionHeaderSliver(
                context,
                'Continue Watching',
                onSeeAll: () => showContinueWatchingSection(
                  context,
                  'Continue Watching',
                  provider.continueWatching,
                ),
              ),
              SliverToBoxAdapter(
                child: _buildContinueWatchingList(
                  continueWatchingItems,
                  provider,
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 30)),
            ],

            // Recently Added
            if (recentlyAddedItems.isNotEmpty) ...[
              _buildSectionHeaderSliver(
                context,
                'Recently Added',
                onSeeAll: () {
                  // TODO: 打开完整的最近添加页面
                },
              ),
              SliverToBoxAdapter(
                child: _buildRecentlyAddedList(recentlyAddedItems),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 30)),
            ],

            // Trending on TMDB
            if (trendingItems.isNotEmpty) ...[
              _buildSectionHeaderSliver(context, 'Trending on TMDB'),
              SliverToBoxAdapter(child: _buildTrendingList(trendingItems)),
              const SliverToBoxAdapter(child: SizedBox(height: 30)),
            ] else if (provider.isTrendingLoading) ...[
              _buildSectionHeaderSliver(context, 'Trending on TMDB'),
              const SliverToBoxAdapter(
                child: SizedBox(
                  height: 248,
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
            ],

            // 底部留白
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.movie_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Your library is empty',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Start scanning to discover media',
            style: TextStyle(fontSize: 14, color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }

  SliverToBoxAdapter _buildSectionHeaderSliver(
    BuildContext context,
    String title, {
    VoidCallback? onSeeAll,
  }) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(40, 0, 40, 15),
        child: Row(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
            const Spacer(),
            if (onSeeAll != null)
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: onSeeAll,
                  child: Row(
                    children: [
                      Text(
                        'See All',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[500],
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.chevron_right,
                        size: 16,
                        color: Colors.grey[400],
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildContinueWatchingList(
    List<MediaFile> items,
    MediaLibraryProvider provider,
  ) {
    const double wideImageWidth = 280;
    const double wideImageHeight = 158;
    const double textSectionHeight = 48;
    final double listHeight = wideImageHeight + textSectionHeight;

    return SizedBox(
      height: listHeight,
      child: HorizontalScrollView(
        controller: _continueWatchingCtrl,
        bottomPadding: textSectionHeight,
        child: ListView.builder(
          controller: _continueWatchingCtrl,
          padding: const EdgeInsets.symmetric(horizontal: 40),
          scrollDirection: Axis.horizontal,
          itemCount: items.length,
          itemBuilder: (context, index) {
            final file = items[index];
            // 获取关联的元数据
            String title = file.parsedTitle;
            String? subtitle;
            String? imageUrl;
            double rating = 0.0;

            if (file.mediaType == MediaType.movie) {
              final metadata = provider.getMovieMetadata(file.tmdbId ?? '');
              if (metadata != null) {
                title = metadata.title;
                imageUrl = metadata.backdropUrl;
                rating = metadata.rating;
                subtitle = metadata.releaseYear?.toString();
              }
            } else {
              final metadata = provider.getTVShowMetadata(file.tmdbId ?? '');
              if (metadata != null) {
                title = metadata.title;
                imageUrl = metadata.backdropUrl;
                rating = metadata.rating;
                // 显示当前观看的季和集
                if (file.parsedSeason != null && file.parsedEpisode != null) {
                  subtitle = 'S${file.parsedSeason} E${file.parsedEpisode}';
                } else if (metadata.numberOfSeasons != null) {
                  subtitle = '${metadata.numberOfSeasons} Seasons';
                }
              }
            }

            return SizedBox(
              width: wideImageWidth,
              child: Padding(
                padding: const EdgeInsets.only(right: 20),
                child: MediaPosterCard(
                  title: title,
                  subtitle: subtitle,
                  posterUrl: imageUrl,
                  rating: rating,
                  tmdbId: file.tmdbId,
                  cardType: MediaCardType.backdrop,
                  progress: file.progress,
                  showProgress: true,
                  onTap: () {
                    // 获取对应的 Movie 或 TVShow 元数据后打开详情
                    if (file.mediaType == MediaType.movie) {
                      final movie = provider.getMovieMetadata(
                        file.tmdbId ?? '',
                      );
                      if (movie != null) showMediaDetailModal(context, movie);
                    } else {
                      final show = provider.getTVShowMetadata(
                        file.tmdbId ?? '',
                      );
                      if (show != null) showMediaDetailModal(context, show);
                    }
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildRecentlyAddedList(List<dynamic> items) {
    const double posterWidth = 160;
    const double posterHeight = 200;
    const double textSectionHeight = 48;
    final double listHeight = posterHeight + textSectionHeight;

    return SizedBox(
      height: listHeight,
      child: HorizontalScrollView(
        controller: _recentlyAddedCtrl,
        bottomPadding: textSectionHeight,
        child: ListView.builder(
          controller: _recentlyAddedCtrl,
          padding: const EdgeInsets.symmetric(horizontal: 40),
          scrollDirection: Axis.horizontal,
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            final isMovie = item is Movie;

            final title = isMovie ? item.title : (item as TVShow).title;
            final posterUrl = isMovie
                ? item.posterUrl
                : (item as TVShow).posterUrl;
            final rating = isMovie ? item.rating : (item as TVShow).rating;
            final tmdbId = isMovie ? item.tmdbId : (item as TVShow).tmdbId;

            String? subtitle;
            if (isMovie) {
              subtitle = item.releaseYear?.toString();
            } else {
              final show = item as TVShow;
              if (show.numberOfSeasons != null && show.numberOfSeasons! > 0) {
                subtitle = show.numberOfSeasons == 1
                    ? '1 Season'
                    : '${show.numberOfSeasons} Seasons';
              }
            }

            return SizedBox(
              width: posterWidth,
              child: Padding(
                padding: const EdgeInsets.only(right: 20),
                child: MediaPosterCard(
                  title: title,
                  subtitle: subtitle,
                  posterUrl: posterUrl,
                  rating: rating,
                  tmdbId: tmdbId,
                  cardType: MediaCardType.poster,
                  onTap: () => showMediaDetailModal(context, item),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTrendingList(List<TrendingItem> items) {
    const double posterWidth = 160;
    const double posterHeight = 200;
    const double textSectionHeight = 48;
    final double listHeight = posterHeight + textSectionHeight;

    return SizedBox(
      height: listHeight,
      child: HorizontalScrollView(
        controller: _trendingCtrl,
        bottomPadding: textSectionHeight,
        child: ListView.builder(
          controller: _trendingCtrl,
          padding: const EdgeInsets.symmetric(horizontal: 40),
          scrollDirection: Axis.horizontal,
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return SizedBox(
              width: posterWidth,
              child: Padding(
                padding: const EdgeInsets.only(right: 20),
                child: MediaPosterCard(
                  title: item.title,
                  subtitle: item.releaseYear?.toString(),
                  posterUrl: item.posterUrl,
                  rating: item.rating,
                  tmdbId: item.tmdbId,
                  cardType: MediaCardType.poster,
                  onTap: () {
                    // Trending items 是外部数据，点击时显示提示
                    // TODO: 后续可以实现跳转到 TMDB 详情或添加到库
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '${item.title} - ${item.isMovie ? "Movie" : "TV Show"}',
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
