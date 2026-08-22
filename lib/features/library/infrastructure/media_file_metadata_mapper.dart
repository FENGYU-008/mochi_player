import 'package:mochi_player/core/infrastructure/database/entities/entities.dart';
import 'package:mochi_player/features/library/infrastructure/filename_parser.dart';

/// Maps parsed filename metadata onto the persisted physical-file entity.
abstract final class MediaFileMetadataMapper {
  static MediaFileEntity createEntity({
    required String path,
    required String fileName,
    required int size,
    required ParsedMediaFilename metadata,
  }) {
    final entity = MediaFileEntity()
      ..path = path
      ..fileName = fileName
      ..size = size;
    updateEntity(entity, metadata, preserveExistingTmdbId: false);
    return entity;
  }

  static void updateEntity(
    MediaFileEntity entity,
    ParsedMediaFilename metadata, {
    bool preserveExistingTmdbId = true,
  }) {
    final previousMediaType = entity.mediaType;
    final parsedMediaType = _mediaType(metadata);
    entity
      ..parsedTitle = metadata.title
      ..parsedYear = metadata.year
      ..parsedSeason = metadata.season
      ..parsedEpisode = metadata.episode
      ..mediaType = parsedMediaType
      ..container = metadata.container
      ..height = metadata.height
      ..videoCodec = metadata.videoCodec
      ..audioCodec = metadata.audioCodec
      ..audioChannels = metadata.audioChannels
      ..isHdr = metadata.isHdr
      ..hdrFormat = metadata.hdrFormat
      ..versionLabel = _nonEmpty(metadata.versionLabel);

    final parsedTmdbId = _nonEmpty(metadata.tmdbId);
    final mediaTypeChanged =
        previousMediaType != StoredMediaType.unknown &&
        previousMediaType != parsedMediaType;
    if (parsedTmdbId != null || !preserveExistingTmdbId || mediaTypeChanged) {
      entity.tmdbId = parsedTmdbId;
    }
  }

  static StoredMediaType _mediaType(ParsedMediaFilename metadata) {
    if (metadata.season != null || metadata.episode != null) {
      return StoredMediaType.episode;
    }
    if (metadata.title.isNotEmpty) return StoredMediaType.movie;
    return StoredMediaType.unknown;
  }

  static String? _nonEmpty(String? value) {
    final normalized = value?.trim();
    return normalized == null || normalized.isEmpty ? null : normalized;
  }
}
