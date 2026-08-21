import 'package:mochi_player/core/domain/media/artist.dart';
import 'package:mochi_player/core/domain/media/library_item.dart';
import 'package:mochi_player/core/domain/media/season.dart';

/// 电视剧 Domain Model
class TVShow implements LibraryItem {
  @override
  final String tmdbId;
  @override
  final String title;
  @override
  final String? originalTitle;
  @override
  final int? releaseYear;
  final DateTime? firstAirDate;
  @override
  final String? posterUrl;
  @override
  final String? backdropUrl;
  @override
  final String? logoUrl;
  @override
  final String? overview;
  @override
  final String? certification;
  @override
  final double rating;
  @override
  final List<String> genres;
  @override
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
    this.logoUrl,
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
