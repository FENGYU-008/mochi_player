/// Trending item 简化模型
/// 用于首页 Trending 展示，不持久化到数据库
class TrendingItem {
  final String tmdbId;
  final String title;
  final String? posterUrl;
  final String? backdropUrl;
  final String? overview;
  final double rating;
  final int? releaseYear;
  final List<String> genres;
  final bool isMovie;

  const TrendingItem({
    required this.tmdbId,
    required this.title,
    this.posterUrl,
    this.backdropUrl,
    this.overview,
    this.rating = 0.0,
    this.releaseYear,
    this.genres = const [],
    required this.isMovie,
  });
}
