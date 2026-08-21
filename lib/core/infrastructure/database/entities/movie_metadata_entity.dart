import 'package:isar/isar.dart';
import 'package:mochi_player/core/infrastructure/database/entities/artist_embedded.dart';

part 'movie_metadata_entity.g.dart';

/// 电影元数据实体 (来自 TMDB)
@collection
class MovieMetadataEntity {
  Id id = Isar.autoIncrement;

  /// TMDB 电影 ID (唯一标识)
  @Index(unique: true)
  late String tmdbId;

  /// 本地化标题 (如 "肖申克的救赎")
  late String title;

  /// 原语言标题 (如 "The Shawshank Redemption")
  String? originalTitle;

  /// 上映年份
  int? releaseYear;

  /// 上映日期
  DateTime? releaseDate;

  /// 海报 URL
  String? posterUrl;

  /// 背景图 URL
  String? backdropUrl;

  /// Logo 图片 URL
  String? logoUrl;

  /// 剧情简介
  String? overview;

  /// 年龄分级 (PG-13, R)
  String? certification;

  /// 评分 (0.0-10.0)
  double rating = 0.0;

  /// 类型标签
  List<String> genres = [];

  /// 演职员表
  List<ArtistEmbedded> cast = [];
}
