import 'package:mochi_player/core/domain/media/models.dart';
import 'package:mochi_player/core/formatters/media_format.dart';
import 'package:mochi_player/core/infrastructure/database/entities/entities.dart'
    as entity;
import 'package:mochi_player/core/infrastructure/database/media_entity_mapper.dart';
import 'package:mochi_player/features/library/application/media_card_view_data.dart';
import 'package:mochi_player/features/library/application/media_library_catalog.dart';

/// Pure read operations derived from the current in-memory media catalog.
class MediaLibraryQueries {
  const MediaLibraryQueries(this._catalog);

  final MediaLibraryCatalog _catalog;

  List<MediaFile> get mediaFiles =>
      _catalog.mediaFiles.map(MediaEntityMapper.toMediaFile).toList();

  List<Movie> get movies {
    final availableIds = _availableMovieTmdbIds;
    return _catalog.movies
        .where((movie) => availableIds.contains(movie.tmdbId))
        .map(MediaEntityMapper.toMovie)
        .toList();
  }

  List<TVShow> get tvShows {
    final availableIds = _availableTVShowTmdbIds;
    return _catalog.tvShows
        .where((show) => availableIds.contains(show.tmdbId))
        .map(_buildTVShow)
        .toList();
  }

  bool get hasContent =>
      _hasVisibleMetadata || _catalog.continueWatchingCount > 0;

  List<MediaFile> get uncategorized => _catalog.mediaFiles
      .where(
        (file) =>
            (file.mediaType == entity.StoredMediaType.movie &&
                file.movieTmdbId == null) ||
            (file.mediaType == entity.StoredMediaType.episode &&
                file.episodeTmdbId == null),
      )
      .map(MediaEntityMapper.toMediaFile)
      .toList();

  List<MediaCardViewData> get continueWatchingItems =>
      ContinueWatchingResolver.resolve(
        mediaFiles,
      ).map((target) => _buildCard(target.file, useBackdrop: true)).toList();

  List<MediaCardViewData> get favoriteItems {
    final groupedItems = <String, MediaCardViewData>{};
    for (final file in _catalog.mediaFiles.where((file) => file.isFavorite)) {
      groupedItems.putIfAbsent(
        _favoriteGroupKey(file),
        () => _buildCard(MediaEntityMapper.toMediaFile(file)),
      );
    }
    return groupedItems.values.toList();
  }

  List<MediaFile> getVersions(String tmdbId) => _catalog.mediaFiles
      .where(
        (file) => file.movieTmdbId == tmdbId || file.tvShowTmdbId == tmdbId,
      )
      .map(MediaEntityMapper.toMediaFile)
      .toList();

  List<MediaFile> getPlaybackQueue(MediaFile currentFile) {
    if (currentFile.mediaType != MediaType.episode) return [currentFile];

    final showKey = _showKeyForMediaFile(currentFile);
    if (showKey == null || showKey.isEmpty) return [currentFile];

    final candidates =
        _catalog.mediaFiles
            .where(
              (file) =>
                  file.mediaType == entity.StoredMediaType.episode &&
                  _showKeyForEntity(file) == showKey,
            )
            .toList()
          ..sort(_compareEpisodes);

    if (candidates.isEmpty) return [currentFile];

    final queue = candidates.map(MediaEntityMapper.toMediaFile).toList();
    final hasCurrent = queue.any(
      (file) =>
          file.id == currentFile.id ||
          (file.sourceId == currentFile.sourceId &&
              file.path == currentFile.path),
    );
    return hasCurrent ? queue : [currentFile, ...queue];
  }

  List<LibraryItem> get recentlyAddedContent {
    final items = <MapEntry<DateTime, LibraryItem>>[];
    final movieIds = _availableMovieTmdbIds;
    final showIds = _availableTVShowTmdbIds;

    for (final movie in _catalog.movies) {
      if (!movieIds.contains(movie.tmdbId)) continue;
      final relatedFiles = _catalog.mediaFiles.where(
        (file) => file.movieTmdbId == movie.tmdbId,
      );
      if (relatedFiles.isEmpty) continue;
      final earliestDate = relatedFiles
          .map((file) => file.addedAt)
          .reduce((a, b) => a.isBefore(b) ? a : b);
      items.add(MapEntry(earliestDate, MediaEntityMapper.toMovie(movie)));
    }

    for (final show in _catalog.tvShows) {
      if (!showIds.contains(show.tmdbId)) continue;
      final relatedFiles = _catalog.mediaFiles.where(
        (file) => file.tvShowTmdbId == show.tmdbId,
      );
      if (relatedFiles.isEmpty) continue;
      final earliestDate = relatedFiles
          .map((file) => file.addedAt)
          .reduce((a, b) => a.isBefore(b) ? a : b);
      items.add(MapEntry(earliestDate, _buildTVShow(show)));
    }

    items.sort((a, b) => b.key.compareTo(a.key));
    return items.map((item) => item.value).toList();
  }

  LibraryItem? getRandomHeroItem([DateTime? date]) {
    final allItems = <LibraryItem>[...movies, ...tvShows];
    if (allItems.isEmpty) return null;
    final day = date ?? DateTime.now();
    final seed = day.year * 10000 + day.month * 100 + day.day;
    return allItems[seed % allItems.length];
  }

  TVShow _buildTVShow(entity.TVShowMetadataEntity show) {
    final seasons =
        _catalog.seasons
            .where((season) => season.seasonKey.startsWith('${show.tmdbId}_'))
            .map((season) {
              final episodes =
                  _catalog.episodes
                      .where(
                        (episode) => episode.tmdbId.startsWith(
                          '${show.tmdbId}_s${season.seasonNumber}e',
                        ),
                      )
                      .map(MediaEntityMapper.toEpisode)
                      .toList()
                    ..sort(
                      (a, b) => a.episodeNumber.compareTo(b.episodeNumber),
                    );
              return MediaEntityMapper.toSeasonWithEpisodes(season, episodes);
            })
            .toList()
          ..sort((a, b) => a.seasonNumber.compareTo(b.seasonNumber));
    return MediaEntityMapper.toTVShowWithSeasons(show, seasons);
  }

  String _favoriteGroupKey(entity.MediaFileEntity file) {
    if (file.mediaType == entity.StoredMediaType.episode) {
      return 'tv:${_showKeyForEntity(file) ?? '${file.sourceId}:${file.path}'}';
    }
    if (file.mediaType == entity.StoredMediaType.movie) {
      return 'movie:${file.movieTmdbId ?? '${file.sourceId}:${file.path}'}';
    }
    return 'file:${file.sourceId}:${file.path}';
  }

  String? _showKeyForMediaFile(MediaFile file) {
    final tmdbKey = file.tvShowTmdbId;
    if (tmdbKey != null) return 'tmdb:$tmdbKey';
    final title = file.parsedTitle.trim().toLowerCase();
    return title.isEmpty ? null : 'title:$title';
  }

  String? _showKeyForEntity(entity.MediaFileEntity file) {
    final tmdbKey = file.tvShowTmdbId;
    if (tmdbKey != null) return 'tmdb:$tmdbKey';
    final title = file.parsedTitle.trim().toLowerCase();
    return title.isEmpty ? null : 'title:$title';
  }

  int _compareEpisodes(entity.MediaFileEntity a, entity.MediaFileEntity b) {
    final season = (a.parsedSeason ?? 999999).compareTo(
      b.parsedSeason ?? 999999,
    );
    if (season != 0) return season;
    final episode = (a.parsedEpisode ?? 999999).compareTo(
      b.parsedEpisode ?? 999999,
    );
    if (episode != 0) return episode;
    return a.path.toLowerCase().compareTo(b.path.toLowerCase());
  }

  Set<String> get _availableMovieTmdbIds => _catalog.mediaFiles
      .where(
        (file) =>
            file.mediaType == entity.StoredMediaType.movie &&
            file.movieTmdbId != null &&
            file.movieTmdbId!.isNotEmpty,
      )
      .map((file) => file.movieTmdbId!)
      .toSet();

  Set<String> get _availableTVShowTmdbIds => _catalog.mediaFiles
      .where(
        (file) =>
            file.mediaType == entity.StoredMediaType.episode &&
            file.tvShowTmdbId != null &&
            file.tvShowTmdbId!.isNotEmpty,
      )
      .map((file) => file.tvShowTmdbId!)
      .toSet();

  bool get _hasVisibleMetadata {
    final movieIds = _availableMovieTmdbIds;
    if (_catalog.movies.any((movie) => movieIds.contains(movie.tmdbId))) {
      return true;
    }
    final showIds = _availableTVShowTmdbIds;
    return _catalog.tvShows.any((show) => showIds.contains(show.tmdbId));
  }

  MediaCardViewData _buildCard(MediaFile file, {bool useBackdrop = false}) {
    LibraryItem? libraryItem;
    if (file.mediaType == MediaType.movie && file.movieTmdbId != null) {
      final index = _catalog.movies.indexWhere(
        (movie) => movie.tmdbId == file.movieTmdbId,
      );
      if (index >= 0) {
        libraryItem = MediaEntityMapper.toMovie(_catalog.movies[index]);
      }
    } else if (file.mediaType == MediaType.episode &&
        file.tvShowTmdbId != null) {
      final index = _catalog.tvShows.indexWhere(
        (show) => show.tmdbId == file.tvShowTmdbId,
      );
      if (index >= 0) {
        libraryItem = _buildTVShow(_catalog.tvShows[index]);
      }
    }

    String? subtitle;
    if (file.mediaType == MediaType.episode && useBackdrop) {
      subtitle = MediaFormat.episodeLabel(file);
    }
    if (subtitle == null && libraryItem is TVShow) {
      final localSeasonCount = libraryItem.seasons.length;
      if (localSeasonCount > 0) {
        subtitle = MediaFormat.seasonCount(localSeasonCount);
      }
    }
    subtitle ??= libraryItem?.releaseYear?.toString();

    return MediaCardViewData(
      file: file,
      libraryItem: libraryItem,
      title: libraryItem?.title ?? file.parsedTitle,
      subtitle: subtitle,
      imageUrl: useBackdrop ? libraryItem?.backdropUrl : libraryItem?.posterUrl,
      rating: libraryItem?.rating ?? 0,
      playbackContextTitle: file.mediaType == MediaType.episode
          ? libraryItem?.title
          : null,
    );
  }
}
