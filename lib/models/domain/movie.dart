import 'artist.dart';

/// 电影 Domain Model
class Movie {
  final String tmdbId;
  final String title;
  final String? originalTitle;
  final int? releaseYear;
  final DateTime? releaseDate;
  final String? posterUrl;
  final String? backdropUrl;
  final String? overview;
  final String? certification;
  final double rating;
  final List<String> genres;
  final List<Artist> cast;

  const Movie({
    required this.tmdbId,
    required this.title,
    this.originalTitle,
    this.releaseYear,
    this.releaseDate,
    this.posterUrl,
    this.backdropUrl,
    this.overview,
    this.certification,
    this.rating = 0.0,
    this.genres = const [],
    this.cast = const [],
  });
}
