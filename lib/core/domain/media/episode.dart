import 'artist.dart';

/// 单集 Domain Model
class Episode {
  final String tmdbId;
  final int episodeNumber;
  final String title;
  final DateTime? airDate;
  final String? overview;
  final String? stillUrl;
  final List<Artist> guestStars;

  const Episode({
    required this.tmdbId,
    required this.episodeNumber,
    required this.title,
    this.airDate,
    this.overview,
    this.stillUrl,
    this.guestStars = const [],
  });
}
