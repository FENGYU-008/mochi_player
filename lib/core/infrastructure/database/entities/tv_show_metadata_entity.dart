import 'package:isar/isar.dart';
import 'package:mochi_player/core/infrastructure/database/entities/artist_embedded.dart';
import 'package:mochi_player/core/infrastructure/database/entities/season_metadata_entity.dart';

part 'tv_show_metadata_entity.g.dart';

/// 电视剧元数据实体 (来自 TMDB)
@collection
class TVShowMetadataEntity {
  Id id = Isar.autoIncrement;

  /// TMDB 剧集 ID (唯一标识)
  @Index(unique: true)
  late String tmdbId;

  /// 本地化标题
  late String title;

  /// 原语言标题
  String? originalTitle;

  /// 首播年份
  int? releaseYear;

  /// 首播日期
  DateTime? firstAirDate;

  /// 海报 URL
  String? posterUrl;

  /// 背景图 URL
  String? backdropUrl;

  /// Logo 图片 URL
  String? logoUrl;

  /// 剧情简介
  String? overview;

  /// 年龄分级
  String? certification;

  /// 评分 (0.0-10.0)
  double rating = 0.0;

  /// 类型标签
  List<String> genres = [];

  /// 主演列表
  List<ArtistEmbedded> cast = [];

  /// 剧集状态 (Returning/Ended/Canceled)
  String? status;

  /// 总季数
  int? numberOfSeasons;

  /// 总集数
  int? numberOfEpisodes;

  /// 关联的季
  @Backlink(to: 'tvShow')
  final seasons = IsarLinks<SeasonMetadataEntity>();
}
