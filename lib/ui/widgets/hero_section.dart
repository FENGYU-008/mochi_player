import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/domain/models.dart';
import '../../services/tmdb_image_cache_manager.dart';
import '../pages/media_detail_modals.dart';
import 'media_detail/playback_helper.dart';

/// 首页 Hero Section
/// 展示随机选择的一部电影或剧集，带有背景图、标题和操作按钮
class HeroSection extends StatelessWidget {
  final dynamic heroItem; // Movie 或 TVShow
  final VoidCallback? onRefresh;

  const HeroSection({super.key, required this.heroItem, this.onRefresh});

  @override
  Widget build(BuildContext context) {
    if (heroItem == null) {
      return const SizedBox(height: 450);
    }

    final isMovie = heroItem is Movie;
    final movie = isMovie ? heroItem as Movie : null;
    final tvShow = !isMovie ? heroItem as TVShow : null;

    final title = isMovie ? movie!.title : tvShow!.title;
    final backdropUrl = isMovie ? movie!.backdropUrl : tvShow!.backdropUrl;
    final posterUrl = isMovie ? movie!.posterUrl : tvShow!.posterUrl;
    final rating = isMovie ? movie!.rating : tvShow!.rating;
    final overview = isMovie ? movie!.overview : tvShow!.overview;
    final genres = isMovie ? movie!.genres : tvShow!.genres;
    final releaseYear = isMovie ? movie!.releaseYear : tvShow!.releaseYear;

    return SizedBox(
      height: 500,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 背景图
          _buildBackdropImage(backdropUrl, posterUrl),

          // 渐变遮罩
          _buildGradientOverlay(context),

          // 内容
          Positioned(
            bottom: 60,
            left: 40,
            right: 40,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 评分 + 年份 + 类型
                _buildMetaRow(rating, releaseYear, genres),
                const SizedBox(height: 16),

                // 标题
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    height: 1.1,
                    letterSpacing: -1.0,
                    shadows: [
                      Shadow(
                        offset: Offset(0, 4),
                        blurRadius: 20,
                        color: Colors.black54,
                      ),
                    ],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),

                // 简介
                if (overview != null && overview.isNotEmpty)
                  Text(
                    overview,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.white.withAlpha(200),
                      height: 1.5,
                      shadows: const [
                        Shadow(blurRadius: 10, color: Colors.black54),
                      ],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 24),

                // 操作按钮
                _buildActionButtons(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackdropImage(String? backdropUrl, String? posterUrl) {
    final imageUrl = backdropUrl ?? posterUrl;
    if (imageUrl == null || imageUrl.isEmpty) {
      return Container(
        color: const Color(0xFF1C1C1E),
        child: const Center(
          child: Icon(Icons.movie, color: Colors.white24, size: 120),
        ),
      );
    }

    return CachedNetworkImage(
      cacheManager: TmdbImageCacheManager.instance,
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      alignment: Alignment.topCenter,
      placeholder: (context, url) => Container(color: const Color(0xFF1C1C1E)),
      errorWidget: (context, url, error) =>
          Container(color: const Color(0xFF1C1C1E)),
    );
  }

  Widget _buildGradientOverlay(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = theme.scaffoldBackgroundColor;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withAlpha(50),
            Colors.black.withAlpha(150),
            bgColor.withAlpha(230),
            bgColor,
          ],
          stops: const [0.0, 0.3, 0.5, 0.8, 1.0],
        ),
      ),
    );
  }

  Widget _buildMetaRow(double rating, int? year, List<String> genres) {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        // 评分
        if (rating > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.amber,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star_rounded, color: Colors.black87, size: 16),
                const SizedBox(width: 4),
                Text(
                  rating.toStringAsFixed(1),
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

        // 年份
        if (year != null)
          Text(
            year.toString(),
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withAlpha(200),
              fontWeight: FontWeight.w500,
            ),
          ),

        // 类型标签
        ...genres
            .take(3)
            .map(
              (genre) => Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(30),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  genre,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withAlpha(220),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        // 播放按钮
        ElevatedButton.icon(
          onPressed: () => _handlePlay(context),
          icon: const Icon(
            Icons.play_arrow_rounded,
            color: Colors.white,
            size: 24,
          ),
          label: const Text(
            '播放',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF007AFF),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 8,
            shadowColor: const Color(0xFF007AFF).withAlpha(100),
          ),
        ),
        const SizedBox(width: 16),

        // 更多信息按钮
        OutlinedButton.icon(
          onPressed: () => _handleMoreInfo(context),
          icon: const Icon(Icons.info_outline, color: Colors.white, size: 20),
          label: const Text(
            '详情',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: OutlinedButton.styleFrom(
            backgroundColor: Colors.black.withAlpha(60),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            side: BorderSide(color: Colors.white.withAlpha(100), width: 1.5),
          ),
        ),
      ],
    );
  }

  void _handlePlay(BuildContext context) {
    PlaybackHelper.playLibraryItem(context, heroItem);
  }

  void _handleMoreInfo(BuildContext context) {
    showMediaDetailModal(context, heroItem);
  }
}
