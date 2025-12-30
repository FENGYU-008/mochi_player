import 'artist.dart';
import 'season.dart';

/// 电视剧 Domain Model
class TVShow {
  final String tmdbId;
  final String title;
  final String? originalTitle;
  final int? releaseYear;
  final DateTime? firstAirDate;
  final String? posterUrl;
  final String? backdropUrl;
  final String? overview;
  final String? certification;
  final double rating;
  final List<String> genres;
  final List<Artist> cast;
  final String? status;
  final int? numberOfSeasons;
  final int? numberOfEpisodes;
  final List<Season> seasons;

  const TVShow({
    required this.tmdbId,
    required this.title,
    this.originalTitle,
    this.releaseYear,
    this.firstAirDate,
    this.posterUrl,
    this.backdropUrl,
    this.overview,
    this.certification,
    this.rating = 0.0,
    this.genres = const [],
    this.cast = const [],
    this.status,
    this.numberOfSeasons,
    this.numberOfEpisodes,
    this.seasons = const [],
  });
}
