import 'package:flutter/material.dart';
import 'package:mochi_player/core/ui/app_ui.dart';
import 'package:mochi_player/features/home/application/trending_media_provider.dart';
import 'package:mochi_player/features/library/application/media_library_provider.dart';
import 'package:mochi_player/features/library/presentation/pages/library_section_page.dart';
import 'package:mochi_player/core/domain/media/models.dart';
import 'package:mochi_player/features/library/application/media_card_view_data.dart';
import 'package:mochi_player/features/library/presentation/widgets/continue_watching_card.dart';
import 'package:mochi_player/features/library/presentation/widgets/library_item_poster_card.dart';
import 'package:provider/provider.dart';

import 'package:mochi_player/features/home/presentation/widgets/hero_section.dart';
import 'package:mochi_player/features/home/presentation/widgets/trending_category_card.dart';

class HomeContent extends StatefulWidget {
  final void Function(double offset)? onScroll;

  const HomeContent({super.key, this.onScroll});

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
    _mainScrollController = ScrollController();
    _continueWatchingCtrl = ScrollController();
    _recentlyAddedCtrl = ScrollController();
    _mainScrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _onScroll());
  }

  void _onScroll() {
    if (!_mainScrollController.hasClients) return;
    widget.onScroll?.call(_mainScrollController.offset);
  }

  @override
  void dispose() {
    _mainScrollController.removeListener(_onScroll);
    _mainScrollController.dispose();
    _continueWatchingCtrl.dispose();
    _recentlyAddedCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasTrendingContent = context.select<TrendingMediaProvider, bool>(
      (provider) => provider.hasContent,
    );
    return Selector<MediaLibraryProvider, _HomeShellState>(
      selector: (context, provider) => _HomeShellState(
        showInitialLoading: provider.isLoading && provider.totalFiles == 0,
        hasHomeContent: provider.hasLibraryContent || hasTrendingContent,
      ),
      builder: (context, shellState, child) {
        if (shellState.showInitialLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!shellState.hasHomeContent) {
          return const AppEmptyState(
            title: '媒体库为空',
            description: '请先扫描媒体库以发现资源',
          );
        }

        return CustomScrollView(
          key: const PageStorageKey('home-main-scroll'),
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
                final continueWatchingItems = provider.continueWatchingItems;
                if (continueWatchingItems.isEmpty) {
                  return const SliverToBoxAdapter(child: SizedBox.shrink());
                }

                return SliverMainAxisGroup(
                  slivers: [
                    _buildSectionHeaderSliver(
                      context,
                      '继续观看',
                      onSeeAll: () => openLibrarySectionPage(
                        context,
                        LibrarySection.continueWatching,
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: _buildContinueWatchingList(continueWatchingItems),
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
                      onSeeAll: () => openLibrarySectionPage(
                        context,
                        LibrarySection.recentlyAdded,
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
            Consumer<TrendingMediaProvider>(
              builder: (context, provider, child) {
                if (!provider.hasContent && !provider.isLoading) {
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

  Widget _buildContinueWatchingList(List<MediaCardViewData> items) {
    const double wideImageWidth = 280;
    const double wideImageHeight = 158;
    const double textSectionHeight = 48;
    final double listHeight = wideImageHeight + textSectionHeight;

    return SizedBox(
      height: listHeight,
      child: AppHorizontalScrollView(
        controller: _continueWatchingCtrl,
        bottomPadding: textSectionHeight,
        child: ListView.builder(
          key: const PageStorageKey('home-continue-watching-scroll'),
          controller: _continueWatchingCtrl,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
          scrollDirection: Axis.horizontal,
          itemCount: items.length,
          itemBuilder: (context, index) {
            return SizedBox(
              width: wideImageWidth,
              child: Padding(
                padding: const EdgeInsets.only(right: AppSpacing.xl),
                child: ContinueWatchingCard(item: items[index]),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildRecentlyAddedList(List<LibraryItem> items) {
    const double posterWidth = 160;
    const double posterHeight = 200;
    const double textSectionHeight = 48;
    final double listHeight = posterHeight + textSectionHeight;

    return SizedBox(
      height: listHeight,
      child: AppHorizontalScrollView(
        controller: _recentlyAddedCtrl,
        bottomPadding: textSectionHeight,
        child: ListView.builder(
          key: const PageStorageKey('home-recently-added-scroll'),
          controller: _recentlyAddedCtrl,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
          scrollDirection: Axis.horizontal,
          itemCount: items.length,
          itemBuilder: (context, index) {
            return SizedBox(
              width: posterWidth,
              child: Padding(
                padding: const EdgeInsets.only(right: AppSpacing.xl),
                child: LibraryItemPosterCard(item: items[index]),
              ),
            );
          },
        ),
      ),
    );
  }

  /// 构建趋势三卡片布局
  Widget _buildTrendingCards(TrendingMediaProvider provider) {
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
              items: provider.movies,
              isLoading: provider.isLoading,
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
              items: provider.tvShows,
              isLoading: provider.isLoading,
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
              isLoading: provider.isLoading,
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
