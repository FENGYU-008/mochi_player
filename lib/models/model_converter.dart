import 'entity/entities.dart' as entity;
import 'domain/models.dart';

/// Entity ↔ Domain 模型转换器
class ModelConverter {
  // ===== MediaFile =====

  static MediaFile toMediaFile(entity.MediaFileEntity e) => MediaFile(
    id: e.id,
    path: e.path,
    fileName: e.fileName,
    parsedTitle: e.parsedTitle,
    parsedYear: e.parsedYear,
    parsedSeason: e.parsedSeason,
    parsedEpisode: e.parsedEpisode,
    mediaType: _toMediaType(e.mediaType),
    tmdbId: e.tmdbId,
    size: e.size,
    container: e.container,
    width: e.width,
    height: e.height,
    videoCodec: e.videoCodec,
    audioCodec: e.audioCodec,
    audioChannels: e.audioChannels,
    isHdr: e.isHdr,
    hdrFormat: e.hdrFormat,
    versionLabel: e.versionLabel,
    duration: e.duration,
    position: e.position,
    watchStatus: _toWatchStatus(e.watchStatus),
    lastWatchedAt: e.lastWatchedAt,
    isFavorite: e.isFavorite,
    addedAt: e.addedAt,
  );

  // ===== Movie =====

  static Movie toMovie(entity.MovieMetadataEntity e) => Movie(
    tmdbId: e.tmdbId,
    title: e.title,
    originalTitle: e.originalTitle,
    releaseYear: e.releaseYear,
    releaseDate: e.releaseDate,
    posterUrl: e.posterUrl,
    backdropUrl: e.backdropUrl,
    overview: e.overview,
    rating: e.rating,
    genres: e.genres,
    cast: e.cast.map(toArtist).toList(),
  );

  // ===== TVShow =====

  static TVShow toTVShow(entity.TVShowMetadataEntity e) =>
      toTVShowWithSeasons(e, []);

  static TVShow toTVShowWithSeasons(
    entity.TVShowMetadataEntity e,
    List<Season> seasons,
  ) => TVShow(
    tmdbId: e.tmdbId,
    title: e.title,
    originalTitle: e.originalTitle,
    releaseYear: e.releaseYear,
    firstAirDate: e.firstAirDate,
    posterUrl: e.posterUrl,
    backdropUrl: e.backdropUrl,
    overview: e.overview,
    rating: e.rating,
    genres: e.genres,
    cast: e.cast.map(toArtist).toList(),
    status: e.status,
    numberOfSeasons: e.numberOfSeasons,
    numberOfEpisodes: e.numberOfEpisodes,
    seasons: seasons,
  );

  // ===== Season =====

  static Season toSeason(entity.SeasonMetadataEntity e) =>
      toSeasonWithEpisodes(e, []);

  static Season toSeasonWithEpisodes(
    entity.SeasonMetadataEntity e,
    List<Episode> episodes,
  ) => Season(
    seasonKey: e.seasonKey,
    seasonNumber: e.seasonNumber,
    title: e.title,
    posterUrl: e.posterUrl,
    overview: e.overview,
    numberOfEpisodes: e.numberOfEpisodes,
    episodes: episodes,
  );

  // ===== Episode =====

  static Episode toEpisode(entity.EpisodeMetadataEntity e) => Episode(
    tmdbId: e.tmdbId,
    episodeNumber: e.episodeNumber,
    title: e.title,
    airDate: e.airDate,
    overview: e.overview,
    stillUrl: e.stillUrl,
    guestStars: e.guestStars.map(toArtist).toList(),
  );

  // ===== Artist =====

  static Artist toArtist(entity.ArtistEmbedded e) => Artist(
    tmdbId: e.tmdbId,
    name: e.name,
    character: e.character,
    profileUrl: e.profileUrl,
  );

  // ===== WatchStatus =====

  static WatchStatus _toWatchStatus(entity.WatchStatus status) {
    switch (status) {
      case entity.WatchStatus.notStarted:
        return WatchStatus.notStarted;
      case entity.WatchStatus.watching:
        return WatchStatus.watching;
      case entity.WatchStatus.completed:
        return WatchStatus.completed;
    }
  }

  static MediaType _toMediaType(entity.MediaType type) {
    switch (type) {
      case entity.MediaType.movie:
        return MediaType.movie;
      case entity.MediaType.episode:
        return MediaType.episode;
      case entity.MediaType.unknown:
        return MediaType.unknown;
    }
  }
}
