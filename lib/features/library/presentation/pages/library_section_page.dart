import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mochi_player/app/routing/app_route_paths.dart';
import 'package:mochi_player/core/ui/app_ui.dart';
import 'package:mochi_player/features/library/application/media_library_provider.dart';
import 'package:mochi_player/features/library/presentation/widgets/continue_watching_card.dart';
import 'package:mochi_player/features/library/presentation/widgets/library_item_poster_card.dart';
import 'package:provider/provider.dart';

/// Section 类型
enum LibrarySection { continueWatching, movies, tvShows, recentlyAdded }

void openLibrarySectionPage(BuildContext context, LibrarySection section) {
  context.push(AppRoutePaths.librarySection(section.name));
}

class LibrarySectionPage extends StatefulWidget {
  final LibrarySection section;

  const LibrarySectionPage({super.key, required this.section});

  @override
  State<LibrarySectionPage> createState() => _LibrarySectionPageState();
}

class _LibrarySectionPageState extends State<LibrarySectionPage> {
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
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          Positioned.fill(
            child: _SectionPageContent(section: widget.section, scrollController: _scrollController),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: AppHeader.height,
            child: AppHeader.back(title: _sectionTitle(widget.section)),
          ),
        ],
      ),
    );
  }
}

class _SectionPageContent extends StatelessWidget {
  final LibrarySection section;
  final ScrollController scrollController;

  const _SectionPageContent({required this.section, required this.scrollController});

  @override
  Widget build(BuildContext context) {
    return Selector<MediaLibraryProvider, _SectionSnapshot>(
      selector: (context, provider) => _SectionSnapshot(
        showInitialLoading: provider.isLoading && provider.totalFiles == 0,
        error: provider.error,
        contentRevision: _contentRevisionFor(provider, section),
      ),
      builder: (context, snapshot, child) {
        if (snapshot.showInitialLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.error != null) {
          return AppResult(status: AppResultStatus.error, title: '内容加载失败', subtitle: snapshot.error);
        }

        final provider = context.read<MediaLibraryProvider>();
        return switch (section) {
          LibrarySection.continueWatching => _buildSection(
            provider.continueWatchingItems,
            (item) => ContinueWatchingCard(item: item),
          ),
          LibrarySection.recentlyAdded => _buildSection(
            provider.recentlyAddedContent,
            (item) => LibraryItemPosterCard(item: item),
          ),
          LibrarySection.movies => _buildSection(provider.movies, (item) => LibraryItemPosterCard(item: item)),
          LibrarySection.tvShows => _buildSection(provider.tvShows, (item) => LibraryItemPosterCard(item: item)),
        };
      },
    );
  }

  Widget _buildSection<T>(List<T> items, Widget Function(T item) itemBuilder) {
    if (items.isEmpty) {
      final title = _sectionTitle(section);
      return AppResult(status: AppResultStatus.empty, title: '$title为空', subtitle: '请先扫描媒体库以发现资源');
    }

    return _buildGrid(items, itemBuilder);
  }

  int _contentRevisionFor(MediaLibraryProvider provider, LibrarySection section) {
    switch (section) {
      case LibrarySection.continueWatching:
        return Object.hash(provider.mediaCatalogRevision, provider.metadataRevision, provider.watchProgressRevision);
      case LibrarySection.recentlyAdded:
        return Object.hash(provider.mediaCatalogRevision, provider.metadataRevision);
      case LibrarySection.movies:
      case LibrarySection.tvShows:
        return provider.metadataRevision;
    }
  }

  Widget _buildGrid<T>(List<T> items, Widget Function(T item) itemBuilder) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isBackdrop = section == LibrarySection.continueWatching;
        final contentWidth = constraints.maxWidth - 80;
        final crossAxisCount = isBackdrop
            ? (contentWidth / 280).floor().clamp(2, 8).toInt()
            : _libraryPosterColumnCount(contentWidth);

        return GridView.builder(
          key: PageStorageKey<String>('library-section-${section.name}'),
          controller: scrollController,
          padding: EdgeInsets.fromLTRB(40, AppHeader.height + 40, 40, isBackdrop ? 44 : 40),
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

String _sectionTitle(LibrarySection section) {
  switch (section) {
    case LibrarySection.continueWatching:
      return '继续观看';
    case LibrarySection.recentlyAdded:
      return '最近添加';
    case LibrarySection.movies:
      return '电影';
    case LibrarySection.tvShows:
      return '剧集';
  }
}

class _SectionSnapshot {
  final bool showInitialLoading;
  final String? error;
  final int contentRevision;

  const _SectionSnapshot({required this.showInitialLoading, required this.error, required this.contentRevision});

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
