import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mochi_player/core/infrastructure/tmdb/tmdb_image_cache_manager.dart';
import 'package:mochi_player/core/ui/theme/app_theme.dart';

/// 卡片类型枚举
enum MediaCardType {
  /// 竖版海报 (2:3 比例)
  poster,

  /// 横版背景图 (16:9 比例)
  backdrop,
}

/// 通用媒体海报卡片
/// 用于显示电影/剧集元数据，支持竖版海报和横版背景图
class MediaPosterCard extends StatefulWidget {
  /// 标题
  final String title;

  /// 副标题（年份、季数、当前集数等）
  final String? subtitle;

  /// 图片 URL（海报或背景图）
  final String? posterUrl;

  /// 评分 (0.0-10.0)
  final double rating;

  /// TMDB ID
  final String? tmdbId;

  /// 点击回调
  final VoidCallback? onTap;

  /// 卡片类型
  final MediaCardType cardType;

  /// 播放进度 (0.0-1.0)
  final double? progress;

  /// 是否显示进度条
  final bool showProgress;

  const MediaPosterCard({
    super.key,
    required this.title,
    this.subtitle,
    this.posterUrl,
    this.rating = 0.0,
    this.tmdbId,
    this.onTap,
    this.cardType = MediaCardType.poster,
    this.progress,
    this.showProgress = false,
  });

  @override
  State<MediaPosterCard> createState() => _MediaPosterCardState();
}

class _MediaPosterCardState extends State<MediaPosterCard> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final customTheme = theme.extension<AppThemeExtension>()!;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 图片区域
            Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutQuart,
                transform: Matrix4.identity()
                  ..scaleByDouble(
                    _isHovering ? 1.025 : 1.0,
                    _isHovering ? 1.025 : 1.0,
                    1.0,
                    1.0,
                  ),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: _isHovering
                      ? [
                          BoxShadow(
                            color: customTheme.cardShadowColor.withAlpha(10),
                            blurRadius: 40,
                            offset: const Offset(0, 20),
                          ),
                        ]
                      : [
                          BoxShadow(
                            color: customTheme.cardShadowColor.withAlpha(4),
                            blurRadius: 3,
                            offset: const Offset(0, 1),
                          ),
                        ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    children: [
                      // 图片
                      Positioned.fill(child: _buildImage(theme)),
                      // 评分徽章 (左上角)
                      if (widget.rating > 0)
                        Positioned(
                          top: 8,
                          left: 8,
                          child: _buildRatingBadge(theme),
                        ),
                      // 进度条 (底部)
                      if (widget.showProgress && widget.progress != null)
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: _buildProgressBar(theme),
                        ),
                      // 悬停高光
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 300),
                        opacity: _isHovering ? 0.05 : 0.0,
                        child: Container(
                          color: theme.brightness == Brightness.light
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            // 标题
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: _isHovering
                    ? theme.textTheme.bodyMedium!.color!.withAlpha(204)
                    : theme.textTheme.bodyMedium!.color,
              ),
              child: Text(
                widget.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // 副标题
            if (widget.subtitle != null) ...[
              const SizedBox(height: 2),
              Text(
                widget.subtitle!,
                style: TextStyle(
                  fontSize: 12,
                  color: theme.textTheme.bodyMedium!.color!.withAlpha(153),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 构建图片
  Widget _buildImage(ThemeData theme) {
    if (widget.posterUrl != null && widget.posterUrl!.isNotEmpty) {
      return CachedNetworkImage(
        cacheManager: TmdbImageCacheManager.instance,
        imageUrl: widget.posterUrl!,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: theme.canvasColor.withAlpha(128),
          child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        ),
        errorWidget: (context, url, error) => _buildPlaceholder(theme),
      );
    }
    return _buildPlaceholder(theme);
  }

  /// 构建占位图
  Widget _buildPlaceholder(ThemeData theme) {
    return Container(
      color: Colors.grey[800],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            widget.cardType == MediaCardType.backdrop
                ? Icons.videocam
                : Icons.movie,
            color: Colors.white54,
            size: 48,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              widget.title,
              style: const TextStyle(color: Colors.white54, fontSize: 12),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建评分徽章
  Widget _buildRatingBadge(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(179),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, color: Colors.amber, size: 14),
          const SizedBox(width: 3),
          Text(
            widget.rating.toStringAsFixed(1),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建进度条
  Widget _buildProgressBar(ThemeData theme) {
    return Container(
      height: 4,
      decoration: BoxDecoration(color: Colors.black.withAlpha(115)),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: widget.progress ?? 0,
        child: Container(
          decoration: BoxDecoration(
            color: theme.primaryColor,
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(2),
              bottomRight: Radius.circular(2),
            ),
          ),
        ),
      ),
    );
  }
}
