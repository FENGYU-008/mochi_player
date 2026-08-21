import 'package:isar/isar.dart';
import 'package:mochi_player/core/infrastructure/database/entities/artist_embedded.dart';
import 'package:mochi_player/core/infrastructure/database/entities/season_metadata_entity.dart';

part 'episode_metadata_entity.g.dart';

/// 单集元数据实体 (来自 TMDB)
@collection
class EpisodeMetadataEntity {
  Id id = Isar.autoIncrement;

  /// TMDB 单集 ID (唯一标识)
  @Index(unique: true)
  late String tmdbId;

  /// 集编号
  late int episodeNumber;

  /// 单集标题
  late String title;

  /// 播出日期
  DateTime? airDate;

  /// 单集简介
  String? overview;

  /// 剧照 URL
  String? stillUrl;

  /// 客串演员
  List<ArtistEmbedded> guestStars = [];

  /// 所属季
  final season = IsarLink<SeasonMetadataEntity>();
}
