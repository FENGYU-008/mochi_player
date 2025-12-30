import 'episode.dart';

/// 季 Domain Model
class Season {
  final String seasonKey;
  final int seasonNumber;
  final String title;
  final String? posterUrl;
  final String? overview;
  final int? numberOfEpisodes;
  final List<Episode> episodes;

  const Season({
    required this.seasonKey,
    required this.seasonNumber,
    required this.title,
    this.posterUrl,
    this.overview,
    this.numberOfEpisodes,
    this.episodes = const [],
  });
}
