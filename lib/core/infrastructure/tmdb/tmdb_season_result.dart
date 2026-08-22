import 'package:mochi_player/core/infrastructure/database/entities/entities.dart';

class TmdbSeasonResult {
  const TmdbSeasonResult({required this.season, required this.episodes});

  final SeasonMetadataEntity season;
  final List<EpisodeMetadataEntity> episodes;
}
