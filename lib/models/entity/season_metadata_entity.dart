import 'package:isar/isar.dart';
import 'tv_show_metadata_entity.dart';
import 'episode_metadata_entity.dart';

part 'season_metadata_entity.g.dart';

/// 季元数据实体
@collection
class SeasonMetadataEntity {
  Id id = Isar.autoIncrement;

  /// 唯一标识: "{tvShowTmdbId}_s{seasonNumber}"
  @Index(unique: true)
  late String seasonKey;

  /// 季编号
  late int seasonNumber;

  /// 季标题
  late String title;

  /// 季海报 URL
  String? posterUrl;

  /// 季简介
  String? overview;

  /// 本季集数
  int? numberOfEpisodes;

  /// 所属剧集
  final tvShow = IsarLink<TVShowMetadataEntity>();

  /// 关联的集
  @Backlink(to: 'season')
  final episodes = IsarLinks<EpisodeMetadataEntity>();
}
