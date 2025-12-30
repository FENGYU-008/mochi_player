import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/media_library_provider.dart';
import '../../models/domain/models.dart';
import 'media_poster_card.dart';
import 'horizontal_scroll_view.dart';

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  final ScrollController _continueWatchingCtrl = ScrollController();
  final ScrollController _recentlyAddedCtrl = ScrollController();
  final ScrollController _moviesCtrl = ScrollController();

  @override
  void dispose() {
    _continueWatchingCtrl.dispose();
    _recentlyAddedCtrl.dispose();
    _moviesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MediaLibraryProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.mediaFiles.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        final continueWatchingItems = provider.continueWatching;
        final recentMovies = provider.movies.take(10).toList();
        final recentTVShows = provider.tvShows.take(10).toList();

        if (continueWatchingItems.isEmpty &&
            recentMovies.isEmpty &&
            recentTVShows.isEmpty) {
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

        return ListView(
          padding: const EdgeInsets.fromLTRB(0, 100, 0, 40),
          children: [
            // Continue Watching
            if (continueWatchingItems.isNotEmpty) ...[
              _buildSectionHeader(context, 'Continue Watching'),
              _buildContinueWatchingList(continueWatchingItems, provider),
              const SizedBox(height: 30),
            ],

            // Recent Movies
            if (recentMovies.isNotEmpty) ...[
              _buildSectionHeader(context, 'Movies'),
              _buildMovieList(recentMovies),
              const SizedBox(height: 30),
            ],

            // Recent TV Shows
            if (recentTVShows.isNotEmpty) ...[
              _buildSectionHeader(context, 'TV Shows'),
              _buildTVShowList(recentTVShows),
              const SizedBox(height: 30),
            ],
          ],
        );
      },
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
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
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () {
                // TODO: Navigate to full list
              },
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
                  Icon(Icons.chevron_right, size: 16, color: Colors.grey[400]),
                ],
              ),
            ),
          ),
        ],
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
            dynamic metadata;
            if (file.mediaType == MediaType.movie) {
              metadata = provider.getMovieMetadata(file.tmdbId ?? '');
            } else {
              metadata = provider.getTVShowMetadata(file.tmdbId ?? '');
            }

            return SizedBox(
              width: wideImageWidth,
              child: Padding(
                padding: const EdgeInsets.only(right: 20),
                child: _buildContinueWatchingCard(file, metadata),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildContinueWatchingCard(MediaFile file, dynamic metadata) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  color: Colors.grey[800],
                  child: metadata?.backdropUrl != null
                      ? Image.network(
                          metadata.backdropUrl!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        )
                      : const Center(
                          child: Icon(
                            Icons.movie,
                            color: Colors.white54,
                            size: 48,
                          ),
                        ),
                ),
              ),
              // 进度条
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: LinearProgressIndicator(
                  value: file.progress,
                  backgroundColor: Colors.black45,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Colors.orange,
                  ),
                  minHeight: 4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          metadata?.title ?? file.parsedTitle,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildMovieList(List<Movie> items) {
    const double posterWidth = 160;
    const double posterHeight = 200;
    const double textSectionHeight = 48;
    final double listHeight = posterHeight + textSectionHeight;

    return SizedBox(
      height: listHeight,
      child: HorizontalScrollView(
        controller: _moviesCtrl,
        bottomPadding: textSectionHeight,
        child: ListView.builder(
          controller: _moviesCtrl,
          padding: const EdgeInsets.symmetric(horizontal: 40),
          scrollDirection: Axis.horizontal,
          itemCount: items.length,
          itemBuilder: (context, index) {
            final movie = items[index];
            return SizedBox(
              width: posterWidth,
              child: Padding(
                padding: const EdgeInsets.only(right: 20),
                child: MediaPosterCard(
                  title: movie.title,
                  posterUrl: movie.posterUrl,
                  rating: movie.rating,
                  tmdbId: movie.tmdbId,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTVShowList(List<TVShow> items) {
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
            final show = items[index];
            return SizedBox(
              width: posterWidth,
              child: Padding(
                padding: const EdgeInsets.only(right: 20),
                child: MediaPosterCard(
                  title: show.title,
                  posterUrl: show.posterUrl,
                  rating: show.rating,
                  tmdbId: show.tmdbId,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
