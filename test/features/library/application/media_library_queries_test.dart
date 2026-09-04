import 'package:flutter_test/flutter_test.dart';
import 'package:mochi_player/core/infrastructure/database/entities/entities.dart';
import 'package:mochi_player/features/library/application/media_library_catalog.dart';
import 'package:mochi_player/features/library/application/media_library_queries.dart';

void main() {
  group('MediaLibraryQueries', () {
    test('orders episodes by season and episode number', () {
      final catalog = MediaLibraryCatalog();
      catalog.mediaFiles.addAll([
        _episode(id: 2, season: 1, episode: 2),
        _episode(id: 3, season: 2, episode: 1),
        _episode(id: 1, season: 1, episode: 1),
      ]);
      final queries = MediaLibraryQueries(catalog);

      final queue = queries.getPlaybackQueue(queries.mediaFiles.first);

      expect(queue.map((file) => file.id), [1, 2, 3]);
    });

    test('groups favorite episodes into one TV show card', () {
      final catalog = MediaLibraryCatalog();
      catalog.mediaFiles.addAll([
        _episode(id: 1, season: 1, episode: 1, isFavorite: true),
        _episode(id: 2, season: 1, episode: 2, isFavorite: true),
      ]);

      final favorites = MediaLibraryQueries(catalog).favoriteItems;

      expect(favorites, hasLength(1));
    });

    test('falls back to the parsed title when a TMDB id is unusable', () {
      final catalog = MediaLibraryCatalog();
      catalog.mediaFiles.addAll([
        _episode(id: 1, season: 1, episode: 1, tvShowTmdbId: 'unknown'),
        _episode(id: 2, season: 1, episode: 2, tvShowTmdbId: 'unknown'),
      ]);
      final queries = MediaLibraryQueries(catalog);

      final queue = queries.getPlaybackQueue(queries.mediaFiles.first);

      expect(queue.map((file) => file.id), [1, 2]);
    });
  });
}

MediaFileEntity _episode({
  required int id,
  required int season,
  required int episode,
  bool isFavorite = false,
  String? tvShowTmdbId,
}) {
  return MediaFileEntity()
    ..id = id
    ..path = '/show/s${season}e$episode.mkv'
    ..fileName = 's${season}e$episode.mkv'
    ..parsedTitle = 'Example Show'
    ..parsedSeason = season
    ..parsedEpisode = episode
    ..mediaType = StoredMediaType.episode
    ..tvShowTmdbId = tvShowTmdbId ?? '123'
    ..episodeTmdbId = '${tvShowTmdbId ?? '123'}_s${season}e$episode'
    ..isFavorite = isFavorite;
}
