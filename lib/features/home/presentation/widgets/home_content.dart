import 'package:flutter/material.dart';
import 'package:mochi_player/core/ui/app_ui.dart';
import 'package:mochi_player/features/library/application/media_library_provider.dart';
import 'package:mochi_player/features/library/presentation/pages/media_detail_page.dart';
import 'package:mochi_player/features/library/presentation/pages/section_view_page.dart';
import 'package:mochi_player/features/playback/presentation/playback_launcher.dart';
import 'package:mochi_player/core/domain/media/models.dart';
import 'package:provider/provider.dart';

import 'hero_section.dart';
import 'trending_category_card.dart';

class HomeContent extends StatefulWidget {
  /// 回调函数，用于通知父组件滚动偏移量
  final void Function(double offset)? onScroll;
  final double initialScrollOffset;
  final double initialContinueWatchingOffset;
  final double initialRecentlyAddedOffset;
  final ValueChanged<double>? onScrollOffsetChanged;
  final ValueChanged<double>? onContinueWatchingOffsetChanged;
  final ValueChanged<double>? onRecentlyAddedOffsetChanged;

  const HomeContent({
    super.key,
    this.onScroll,
    this.initialScrollOffset = 0,
    this.initialContinueWatchingOffset = 0,
    this.initialRecentlyAddedOffset = 0,
    this.onScrollOffsetChanged,
    this.onContinueWatchingOffsetChanged,
    this.onRecentlyAddedOffsetChanged,
  });

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  late final ScrollController _mainScrollController;
  late final ScrollController _continueWatchingCtrl;
  late final ScrollController _recentlyAddedCtrl;

  @override
  void initState() {
    super.initState();
    _mainScrollController = ScrollController(
      initialScrollOffset: widget.initialScrollOffset,
    );
    _continueWatchingCtrl = ScrollController(
      initialScrollOffset: widget.initialContinueWatchingOffset,
    );
    _recentlyAddedCtrl = ScrollController(
      initialScrollOffset: widget.initialRecentlyAddedOffset,
    );
    _mainScrollController.addListener(_onScroll);
    _continueWatchingCtrl.addListener(_onContinueWatchingScroll);
    _recentlyAddedCtrl.addListener(_onRecentlyAddedScroll);
  }

  void _onScroll() {
    if (!_mainScrollController.hasClients) return;
    final offset = _mainScrollController.offset;
    widget.onScroll?.call(offset);
    widget.onScrollOffsetChanged?.call(offset);
  }

  void _saveMainScrollOffset() {
    if (!_mainScrollController.hasClients) return;
    widget.onScrollOffsetChanged?.call(_mainScrollController.offset);
  }

  void _onContinueWatchingScroll() {
    if (!_continueWatchingCtrl.hasClients) return;
    widget.onContinueWatchingOffsetChanged?.call(_continueWatchingCtrl.offset);
  }

  void _onRecentlyAddedScroll() {
    if (!_recentlyAddedCtrl.hasClients) return;
    widget.onRecentlyAddedOffsetChanged?.call(_recentlyAddedCtrl.offset);
  }

  @override
  void dispose() {
    _saveMainScrollOffset();
    _onContinueWatchingScroll();
    _onRecentlyAddedScroll();
    _mainScrollController.removeListener(_onScroll);
    _continueWatchingCtrl.removeListener(_onContinueWatchingScroll);
    _recentlyAddedCtrl.removeListener(_onRecentlyAddedScroll);
    _mainScrollController.dispose();
    _continueWatchingCtrl.dispose();
    _recentlyAddedCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Selector<MediaLibraryProvider, _HomeShellState>(
      selector: (context, provider) => _HomeShellState(
        showInitialLoading: provider.isLoading && provider.totalFiles == 0,
        hasHomeContent: provider.hasHomeContent,
      ),
      builder: (context, shellState, child) {
        if (shellState.showInitialLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!shellState.hasHomeContent) {
          return _buildEmptyState();
        }

        return CustomScrollView(
          controller: _mainScrollController,
          slivers: [
            // Hero Section (无 padding，直接到顶部)
            Selector<MediaLibraryProvider, _LibraryContentRevision>(
              selector: (context, provider) => _LibraryContentRevision(
                mediaCatalogRevision: provider.mediaCatalogRevision,
                metadataRevision: provider.metadataRevision,
              ),
              builder: (context, revision, child) {
                final heroItem = context
                    .read<MediaLibraryProvider>()
                    .getRandomHeroItem();
                return SliverToBoxAdapter(
                  child: HeroSection(heroItem: heroItem),
                );
              },
            ),

            // 继续观看
            Selector<MediaLibraryProvider, _ContinueWatchingRevision>(
              selector: (context, provider) => _ContinueWatchingRevision(
                mediaCatalogRevision: provider.mediaCatalogRevision,
                metadataRevision: provider.metadataRevision,
                watchProgressRevision: provider.watchProgressRevision,
              ),
              builder: (context, revision, child) {
                final provider = context.read<MediaLibraryProvider>();
                final continueWatchingItems = provider.continueWatching;
                if (continueWatchingItems.isEmpty) {
                  return const SliverToBoxAdapter(child: SizedBox.shrink());
                }

                return SliverMainAxisGroup(
                  slivers: [
                    _buildSectionHeaderSliver(
                      context,
                      '继续观看',
                      onSeeAll: () => openSectionViewPage(
                        context,
                        SectionType.continueWatching,
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
                );
              },
            ),

            // 最近添加
            Selector<MediaLibraryProvider, _LibraryContentRevision>(
              selector: (context, provider) => _LibraryContentRevision(
                mediaCatalogRevision: provider.mediaCatalogRevision,
                metadataRevision: provider.metadataRevision,
              ),
              builder: (context, revision, child) {
                final recentlyAddedItems = context
                    .read<MediaLibraryProvider>()
                    .recentlyAddedContent
                    .take(15)
                    .toList();
                if (recentlyAddedItems.isEmpty) {
                  return const SliverToBoxAdapter(child: SizedBox.shrink());
                }

                return SliverMainAxisGroup(
                  slivers: [
                    _buildSectionHeaderSliver(
                      context,
                      '最近添加',
                      onSeeAll: () => openSectionViewPage(
                        context,
                        SectionType.recentlyAdded,
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: _buildRecentlyAddedList(recentlyAddedItems),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 30)),
                  ],
                );
              },
            ),

            // Trending on TMDB (三卡片布局)
            Selector<MediaLibraryProvider, _TrendingRevision>(
              selector: (context, provider) => _TrendingRevision(
                trendingRevision: provider.trendingRevision,
                isTrendingLoading: provider.isTrendingLoading,
              ),
              builder: (context, revision, child) {
                final provider = context.read<MediaLibraryProvider>();
                final hasTrendingData =
                    provider.trendingMovies.isNotEmpty ||
                    provider.trendingTV.isNotEmpty ||
                    provider.topRated.isNotEmpty;
                if (!hasTrendingData && !provider.isTrendingLoading) {
                  return const SliverToBoxAdapter(child: SizedBox.shrink());
                }

                return SliverMainAxisGroup(
                  slivers: [
                    _buildSectionHeaderSliver(context, 'TMDB 趋势'),
                    SliverToBoxAdapter(child: _buildTrendingCards(provider)),
                    const SliverToBoxAdapter(child: SizedBox(height: 30)),
                  ],
                );
              },
            ),

            // 底部留白
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return const AppEmptyState(title: '媒体库为空', description: '请先扫描媒体库以发现资源');
  }

  SliverToBoxAdapter _buildSectionHeaderSliver(
    BuildContext context,
    String title, {
    VoidCallback? onSeeAll,
  }) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.page,
          0,
          AppSpacing.page,
          15,
        ),
        child: Row(
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                        '查看全部',
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
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
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
              subtitle = _episodeLabel(file);
              final metadata = provider.getTVShowMetadata(file.tmdbId ?? '');
              if (metadata != null) {
                title = metadata.title;
                imageUrl = metadata.backdropUrl;
                rating = metadata.rating;
                // 显示当前观看的季和集
                if (subtitle == null && metadata.numberOfSeasons != null) {
                  subtitle = '${metadata.numberOfSeasons} 季';
                }
              }
            }

            return SizedBox(
              width: wideImageWidth,
              child: Padding(
                padding: const EdgeInsets.only(right: AppSpacing.xl),
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
                    PlaybackLauncher.playFile(
                      context,
                      file,
                      contextTitle: file.mediaType == MediaType.episode
                          ? title
                          : null,
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

  String? _episodeLabel(MediaFile file) {
    final season = file.parsedSeason;
    final episode = file.parsedEpisode;
    if (season == null || episode == null) return null;

    return '第 $season 季 第 $episode 集';
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
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
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
                    ? '1 季'
                    : '${show.numberOfSeasons} 季';
              }
            }

            return SizedBox(
              width: posterWidth,
              child: Padding(
                padding: const EdgeInsets.only(right: AppSpacing.xl),
                child: MediaPosterCard(
                  title: title,
                  subtitle: subtitle,
                  posterUrl: posterUrl,
                  rating: rating,
                  tmdbId: tmdbId,
                  cardType: MediaCardType.poster,
                  onTap: () => openMediaDetailPage(context, item),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// 构建趋势三卡片布局
  Widget _buildTrendingCards(MediaLibraryProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Trending Movies
          Expanded(
            child: TrendingCategoryCard(
              config: const TrendingCardConfig(
                icon: Icons.local_fire_department_rounded,
                iconColor: Color(0xFFFF6B35),
                title: '热门电影',
                subtitle: '全球前三',
              ),
              items: provider.trendingMovies,
              isLoading: provider.isTrendingLoading,
            ),
          ),
          const SizedBox(width: 16),
          // Trending TV
          Expanded(
            child: TrendingCategoryCard(
              config: TrendingCardConfig(
                icon: Icons.tv_rounded,
                iconColor: AppColors.primary(context),
                title: '热门剧集',
                subtitle: '最多观看',
              ),
              items: provider.trendingTV,
              isLoading: provider.isTrendingLoading,
            ),
          ),
          const SizedBox(width: 16),
          // Top Rated
          Expanded(
            child: TrendingCategoryCard(
              config: const TrendingCardConfig(
                icon: Icons.star_rounded,
                iconColor: Color(0xFFFFD60A),
                title: '高分佳作',
                subtitle: '评分最高',
              ),
              items: provider.topRated,
              isLoading: provider.isTrendingLoading,
              showRating: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeShellState {
  final bool showInitialLoading;
  final bool hasHomeContent;

  const _HomeShellState({
    required this.showInitialLoading,
    required this.hasHomeContent,
  });

  @override
  bool operator ==(Object other) {
    return other is _HomeShellState &&
        other.showInitialLoading == showInitialLoading &&
        other.hasHomeContent == hasHomeContent;
  }

  @override
  int get hashCode => Object.hash(showInitialLoading, hasHomeContent);
}

class _LibraryContentRevision {
  final int mediaCatalogRevision;
  final int metadataRevision;

  const _LibraryContentRevision({
    required this.mediaCatalogRevision,
    required this.metadataRevision,
  });

  @override
  bool operator ==(Object other) {
    return other is _LibraryContentRevision &&
        other.mediaCatalogRevision == mediaCatalogRevision &&
        other.metadataRevision == metadataRevision;
  }

  @override
  int get hashCode => Object.hash(mediaCatalogRevision, metadataRevision);
}

class _ContinueWatchingRevision {
  final int mediaCatalogRevision;
  final int metadataRevision;
  final int watchProgressRevision;

  const _ContinueWatchingRevision({
    required this.mediaCatalogRevision,
    required this.metadataRevision,
    required this.watchProgressRevision,
  });

  @override
  bool operator ==(Object other) {
    return other is _ContinueWatchingRevision &&
        other.mediaCatalogRevision == mediaCatalogRevision &&
        other.metadataRevision == metadataRevision &&
        other.watchProgressRevision == watchProgressRevision;
  }

  @override
  int get hashCode => Object.hash(
    mediaCatalogRevision,
    metadataRevision,
    watchProgressRevision,
  );
}

class _TrendingRevision {
  final int trendingRevision;
  final bool isTrendingLoading;

  const _TrendingRevision({
    required this.trendingRevision,
    required this.isTrendingLoading,
  });

  @override
  bool operator ==(Object other) {
    return other is _TrendingRevision &&
        other.trendingRevision == trendingRevision &&
        other.isTrendingLoading == isTrendingLoading;
  }

  @override
  int get hashCode => Object.hash(trendingRevision, isTrendingLoading);
}
