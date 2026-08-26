import 'package:mochi_player/core/domain/media/models.dart';
import 'package:mochi_player/core/infrastructure/database/entities/entities.dart' as entity;
import 'package:mochi_player/core/infrastructure/database/media_entity_mapper.dart';

/// The single in-memory source of truth for persisted library records.
class MediaLibraryCatalog {
  final List<entity.MediaFileEntity> mediaFiles = [];
  final List<entity.MovieMetadataEntity> movies = [];
  final List<entity.TVShowMetadataEntity> tvShows = [];
  final List<entity.SeasonMetadataEntity> seasons = [];
  final List<entity.EpisodeMetadataEntity> episodes = [];

  int _mediaCatalogRevision = 0;
  int _metadataRevision = 0;
  int _watchProgressRevision = 0;
  int _favoriteRevision = 0;
  int _continueWatchingCount = 0;

  int get mediaCatalogRevision => _mediaCatalogRevision;

  int get metadataRevision => _metadataRevision;

  int get watchProgressRevision => _watchProgressRevision;

  int get favoriteRevision => _favoriteRevision;

  int get continueWatchingCount => _continueWatchingCount;

  void replaceAll({
    required Iterable<entity.MediaFileEntity> mediaFiles,
    required Iterable<entity.MovieMetadataEntity> movies,
    required Iterable<entity.TVShowMetadataEntity> tvShows,
    required Iterable<entity.SeasonMetadataEntity> seasons,
    required Iterable<entity.EpisodeMetadataEntity> episodes,
  }) {
    _replace(this.mediaFiles, mediaFiles);
    _replace(this.movies, movies);
    _replace(this.tvShows, tvShows);
    _replace(this.seasons, seasons);
    _replace(this.episodes, episodes);
    recountContinueWatching();
  }

  void replaceMediaFiles(Iterable<entity.MediaFileEntity> values) {
    _replace(mediaFiles, values);
    recountContinueWatching();
  }

  void replaceMetadata({
    required Iterable<entity.MovieMetadataEntity> movies,
    required Iterable<entity.TVShowMetadataEntity> tvShows,
    required Iterable<entity.SeasonMetadataEntity> seasons,
    required Iterable<entity.EpisodeMetadataEntity> episodes,
  }) {
    _replace(this.movies, movies);
    _replace(this.tvShows, tvShows);
    _replace(this.seasons, seasons);
    _replace(this.episodes, episodes);
  }

  void recountContinueWatching() {
    _continueWatchingCount = ContinueWatchingResolver.resolve(
      mediaFiles.map(MediaEntityMapper.toMediaFile).toList(),
    ).length;
  }

  void markMediaCatalogChanged() => _mediaCatalogRevision++;

  void markMetadataChanged() => _metadataRevision++;

  void markWatchProgressChanged() => _watchProgressRevision++;

  void markFavoriteChanged() => _favoriteRevision++;

  void markAllLibraryContentChanged() {
    markMediaCatalogChanged();
    markMetadataChanged();
    markWatchProgressChanged();
    markFavoriteChanged();
  }

  void clear() {
    mediaFiles.clear();
    movies.clear();
    tvShows.clear();
    seasons.clear();
    episodes.clear();
    _continueWatchingCount = 0;
    markAllLibraryContentChanged();
  }

  static void _replace<T>(List<T> target, Iterable<T> values) {
    target
      ..clear()
      ..addAll(values);
  }
}
