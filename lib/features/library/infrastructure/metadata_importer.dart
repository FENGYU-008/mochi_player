import 'package:mochi_player/core/infrastructure/database/database_service.dart';
import 'package:mochi_player/core/infrastructure/database/entities/entities.dart';
import 'package:mochi_player/core/infrastructure/tmdb/tmdb_season_result.dart';

/// Persists confirmed provider metadata and links it to local files.
///
/// It never searches by title and never performs network I/O.
class MetadataImporter {
  MetadataImporter({DatabaseService? database}) : _database = database ?? DatabaseService();

  final DatabaseService _database;

  Future<bool> importMovie(MovieMetadataEntity movie, MediaFileEntity file) async {
    final exists = await _database.getMovieByTmdbId(movie.tmdbId);
    if (exists == null) await _database.saveMovieMetadata(movie);
    file
      ..movieTmdbId = movie.tmdbId
      ..metadataMatchStatus = StoredMetadataMatchStatus.confirmed;
    await _database.saveMediaFile(file);
    return exists == null;
  }

  Future<bool> importTVShow(TVShowMetadataEntity show) async {
    final exists = await _database.getTVShowByTmdbId(show.tmdbId);
    if (exists == null) await _database.saveTVShowMetadata(show);
    return exists == null;
  }

  Future<int> importSeasonEpisodes(TmdbSeasonResult result, String showTmdbId, List<MediaFileEntity> files) async {
    final seasonKey = '${showTmdbId}_s${result.season.seasonNumber}';
    if (await _database.getSeasonByKey(seasonKey) == null) {
      await _database.saveSeasonMetadata(result.season);
    }
    final episodesByNumber = {for (final episode in result.episodes) episode.episodeNumber: episode};

    var imported = 0;
    for (final file in files) {
      final episode = episodesByNumber[file.parsedEpisode];
      if (episode == null) continue;
      if (await _database.getEpisodeByTmdbId(episode.tmdbId) == null) {
        await _database.saveEpisodeMetadata(episode);
      }
      file
        ..tvShowTmdbId = showTmdbId
        ..episodeTmdbId = episode.tmdbId
        ..metadataMatchStatus = StoredMetadataMatchStatus.confirmed;
      await _database.saveMediaFile(file);
      imported++;
    }
    return imported;
  }

  Future<void> markUnmatched(List<MediaFileEntity> files) async {
    if (files.isEmpty) return;
    for (final file in files) {
      file.metadataMatchStatus = StoredMetadataMatchStatus.unmatched;
      if (file.mediaType == StoredMediaType.movie) {
        file.movieTmdbId = null;
      } else if (file.mediaType == StoredMediaType.episode) {
        file
          ..tvShowTmdbId = null
          ..episodeTmdbId = null;
      }
    }
    await _database.saveMediaFiles(files);
  }
}
