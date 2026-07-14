import 'package:isar/isar.dart';

part 'artist_embedded.g.dart';

/// 演员信息 (嵌入式对象)
@embedded
class ArtistEmbedded {
  /// TMDB 演员 ID
  String? tmdbId;

  /// 演员名称
  late String name;

  /// 饰演角色
  String? character;

  /// 头像 URL
  String? profileUrl;
}
