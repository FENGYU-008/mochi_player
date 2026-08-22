import 'package:flutter_test/flutter_test.dart';
import 'package:mochi_player/core/infrastructure/database/entities/entities.dart';
import 'package:mochi_player/features/library/infrastructure/filename_parser.dart';
import 'package:mochi_player/features/library/infrastructure/media_file_metadata_mapper.dart';

void main() {
  test('creates a media entity from parsed filename metadata', () {
    final entity = MediaFileMetadataMapper.createEntity(
      path: '/shows/example.mkv',
      fileName: 'example.mkv',
      size: 1024,
      metadata: const ParsedMediaFilename(
        title: 'Example',
        year: 2026,
        season: 2,
        episode: 3,
        tmdbId: ' 123_s2e3 ',
        container: 'mkv',
        height: 2160,
        videoCodec: 'hevc',
        audioCodec: 'truehd',
        audioChannels: '7.1',
        isHdr: true,
        hdrFormat: 'dolby_vision',
        versionLabel: '2160p BluRay',
      ),
    );

    expect(entity.path, '/shows/example.mkv');
    expect(entity.fileName, 'example.mkv');
    expect(entity.size, 1024);
    expect(entity.parsedTitle, 'Example');
    expect(entity.parsedYear, 2026);
    expect(entity.parsedSeason, 2);
    expect(entity.parsedEpisode, 3);
    expect(entity.mediaType, StoredMediaType.episode);
    expect(entity.tmdbId, '123_s2e3');
    expect(entity.container, 'mkv');
    expect(entity.height, 2160);
    expect(entity.videoCodec, 'hevc');
    expect(entity.audioCodec, 'truehd');
    expect(entity.audioChannels, '7.1');
    expect(entity.isHdr, isTrue);
    expect(entity.hdrFormat, 'dolby_vision');
    expect(entity.versionLabel, '2160p BluRay');
  });

  test('preserves a scraped TMDB id when reparsing has no embedded id', () {
    final entity = MediaFileEntity()
      ..path = '/movies/example.mkv'
      ..fileName = 'example.mkv'
      ..parsedTitle = 'Old title'
      ..tmdbId = '456'
      ..position = 12000
      ..isFavorite = true;

    MediaFileMetadataMapper.updateEntity(
      entity,
      const ParsedMediaFilename(title: 'Example', versionLabel: ''),
    );

    expect(entity.parsedTitle, 'Example');
    expect(entity.mediaType, StoredMediaType.movie);
    expect(entity.tmdbId, '456');
    expect(entity.versionLabel, isNull);
    expect(entity.position, 12000);
    expect(entity.isFavorite, isTrue);
  });

  test('prefers an embedded TMDB id when reparsing an existing entity', () {
    final entity = MediaFileEntity()
      ..path = '/movies/{tmdb-789}/example.mkv'
      ..fileName = 'example.mkv'
      ..parsedTitle = 'Example'
      ..tmdbId = '456';

    MediaFileMetadataMapper.updateEntity(
      entity,
      const ParsedMediaFilename(title: 'Example', tmdbId: '789'),
    );

    expect(entity.tmdbId, '789');
  });

  test('clears an incompatible TMDB id when media type changes', () {
    final entity = MediaFileEntity()
      ..mediaType = StoredMediaType.movie
      ..tmdbId = '1555290';

    MediaFileMetadataMapper.updateEntity(
      entity,
      const ParsedMediaFilename(
        title: '街头餐厅斗士',
        season: 1,
        episode: 1,
        isEpisode: true,
      ),
    );

    expect(entity.mediaType, StoredMediaType.episode);
    expect(entity.tmdbId, isNull);
  });
}
