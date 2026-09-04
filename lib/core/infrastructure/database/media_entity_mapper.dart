import 'package:mochi_player/core/domain/media/models.dart';
import 'package:mochi_player/core/infrastructure/database/entities/entities.dart'
    as entity;

/// Entity ↔ Domain 模型转换器
class MediaEntityMapper {
  // ===== MediaFile =====

  static MediaFile toMediaFile(entity.MediaFileEntity e) => MediaFile(
    id: e.id,
    sourceId: e.sourceId,
    path: e.path,
    fileName: e.fileName,
    parsedTitle: e.parsedTitle,
    parsedYear: e.parsedYear,
    parsedSeason: e.parsedSeason,
    parsedEpisode: e.parsedEpisode,
    mediaType: _toMediaType(e.mediaType),
    movieTmdbId: e.movieTmdbId,
    tvShowTmdbId: e.tvShowTmdbId,
    episodeTmdbId: e.episodeTmdbId,
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
    logoUrl: e.logoUrl,
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
    logoUrl: e.logoUrl,
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

  static WatchStatus _toWatchStatus(entity.StoredWatchStatus status) {
    switch (status) {
      case entity.StoredWatchStatus.notStarted:
        return WatchStatus.notStarted;
      case entity.StoredWatchStatus.watching:
        return WatchStatus.watching;
      case entity.StoredWatchStatus.completed:
        return WatchStatus.completed;
    }
  }

  static MediaType _toMediaType(entity.StoredMediaType type) {
    switch (type) {
      case entity.StoredMediaType.movie:
        return MediaType.movie;
      case entity.StoredMediaType.episode:
        return MediaType.episode;
      case entity.StoredMediaType.unknown:
        return MediaType.unknown;
    }
  }
}
