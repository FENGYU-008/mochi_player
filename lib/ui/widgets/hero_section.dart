import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/domain/models.dart';
import '../../services/tmdb_image_cache_manager.dart';
import '../pages/media_detail_page.dart';
import 'macos_controls.dart';
import 'package:mochi_player/features/playback/presentation/playback_launcher.dart';

/// 首页 Hero Section
/// 展示随机选择的一部电影或剧集，带有背景图、标题和操作按钮
class HeroSection extends StatelessWidget {
  final dynamic heroItem; // Movie 或 TVShow
  final VoidCallback? onRefresh;

  const HeroSection({super.key, required this.heroItem, this.onRefresh});

  @override
  Widget build(BuildContext context) {
    if (heroItem == null) {
      return const SizedBox(height: 420);
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
      height: 420,
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
            bottom: 48,
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
                    fontSize: 44,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    height: 1.1,
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
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 820),
                    child: Text(
                      overview,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.white.withAlpha(210),
                        height: 1.5,
                        shadows: const [
                          Shadow(blurRadius: 10, color: Colors.black54),
                        ],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
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
            Colors.black.withAlpha(44),
            Colors.black.withAlpha(140),
            bgColor.withAlpha(218),
            bgColor,
          ],
          stops: const [0.0, 0.32, 0.56, 0.86, 1.0],
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
          MacosPill(
            text: rating.toStringAsFixed(1),
            icon: Icons.star_rounded,
            rating: true,
          ),

        // 年份
        if (year != null)
          MacosPill(text: year.toString(), tone: MacosControlTone.overlay),

        // 类型标签
        ...genres
            .take(3)
            .map(
              (genre) => MacosPill(text: genre, tone: MacosControlTone.overlay),
            ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        MacosActionButton(
          onPressed: () => _handlePlay(context),
          icon: Icons.play_arrow_rounded,
          label: '播放',
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 24),
        ),
        const SizedBox(width: 12),

        MacosActionButton(
          onPressed: () => _handleMoreInfo(context),
          icon: Icons.info_outline_rounded,
          label: '详情',
          style: MacosButtonStyle.secondary,
          tone: MacosControlTone.overlay,
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 22),
        ),
      ],
    );
  }

  void _handlePlay(BuildContext context) {
    PlaybackLauncher.playLibraryItem(context, heroItem);
  }

  void _handleMoreInfo(BuildContext context) {
    openMediaDetailPage(context, heroItem);
  }
}
