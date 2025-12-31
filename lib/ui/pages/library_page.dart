import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/media_library_provider.dart';
import '../../models/domain/models.dart';
import '../widgets/media_poster_card.dart';

class LibraryPage extends StatelessWidget {
  final String category;

  const LibraryPage({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Consumer<MediaLibraryProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.mediaFiles.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error != null) {
          return Center(child: Text("Error: ${provider.error}"));
        }

        // 根据 category 选择显示内容
        Widget content;
        switch (category) {
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

  Widget _buildMovieGrid(BuildContext context, MediaLibraryProvider provider) {
    final items = provider.movies;

    if (items.isEmpty) {
      return _buildEmptyState('Movies');
    }

    return _buildGridView(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final movie = items[index];
        return MediaPosterCard(
          title: movie.title,
          subtitle: movie.releaseYear?.toString(),
          posterUrl: movie.posterUrl,
          rating: movie.rating,
          tmdbId: movie.tmdbId,
          cardType: MediaCardType.poster,
          onTap: () {
            // TODO: 打开电影详情
          },
        );
      },
    );
  }

  Widget _buildTVShowGrid(BuildContext context, MediaLibraryProvider provider) {
    final items = provider.tvShows;

    if (items.isEmpty) {
      return _buildEmptyState('TV Shows');
    }

    return _buildGridView(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final show = items[index];
        // 构建副标题：显示季数
        String? subtitle;
        if (show.numberOfSeasons != null && show.numberOfSeasons! > 0) {
          subtitle = show.numberOfSeasons == 1
              ? '1 Season'
              : '${show.numberOfSeasons} Seasons';
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
          onTap: () {
            // TODO: 打开剧集详情
          },
        );
      },
    );
  }

  Widget _buildFavoritesGrid(
    BuildContext context,
    MediaLibraryProvider provider,
  ) {
    final items = provider.favorites;

    if (items.isEmpty) {
      return _buildEmptyState('Favorites');
    }

    return _buildGridView(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final file = items[index];
        String title = file.parsedTitle;
        String? posterUrl;
        String? subtitle;
        double rating = 0.0;

        if (file.mediaType == MediaType.movie && file.tmdbId != null) {
          final meta = provider.getMovieMetadata(file.tmdbId!);
          if (meta != null) {
            title = meta.title;
            posterUrl = meta.posterUrl;
            rating = meta.rating;
            subtitle = meta.releaseYear?.toString();
          }
        } else if (file.tmdbId != null) {
          final meta = provider.getTVShowMetadata(file.tmdbId!);
          if (meta != null) {
            title = meta.title;
            posterUrl = meta.posterUrl;
            rating = meta.rating;
            if (meta.numberOfSeasons != null && meta.numberOfSeasons! > 0) {
              subtitle = meta.numberOfSeasons == 1
                  ? '1 Season'
                  : '${meta.numberOfSeasons} Seasons';
            }
          }
        }

        return MediaPosterCard(
          title: title,
          subtitle: subtitle,
          posterUrl: posterUrl,
          rating: rating,
          tmdbId: file.tmdbId,
          cardType: MediaCardType.poster,
          onTap: () {},
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
      return _buildEmptyState('Uncategorized');
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
          padding: const EdgeInsets.fromLTRB(40, 100, 40, 40),
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.movie_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No $category found',
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
}
