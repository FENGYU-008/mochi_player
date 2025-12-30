import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/app_theme.dart';

/// 通用媒体海报卡片
/// 用于显示电影/剧集元数据
class MediaPosterCard extends StatefulWidget {
  final String title;
  final String? posterUrl;
  final double rating;
  final String? tmdbId;
  final VoidCallback? onTap;
  final bool useBackdrop;

  const MediaPosterCard({
    super.key,
    required this.title,
    this.posterUrl,
    this.rating = 0.0,
    this.tmdbId,
    this.onTap,
    this.useBackdrop = false,
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
                transform: Matrix4.identity()..scale(_isHovering ? 1.025 : 1.0),
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
                      Positioned.fill(
                        child:
                            widget.posterUrl != null &&
                                widget.posterUrl!.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: widget.posterUrl!,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  color: theme.canvasColor.withAlpha(128),
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  color: Colors.grey[800],
                                  child: const Icon(
                                    Icons.broken_image,
                                    color: Colors.white54,
                                  ),
                                ),
                              )
                            : Container(
                                color: Colors.grey[800],
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.movie,
                                      color: Colors.white54,
                                      size: 48,
                                    ),
                                    const SizedBox(height: 8),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                      child: Text(
                                        widget.title,
                                        style: const TextStyle(
                                          color: Colors.white54,
                                          fontSize: 12,
                                        ),
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
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
            const SizedBox(height: 12),
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
            const SizedBox(height: 4),
            // 评分
            if (widget.rating > 0)
              Row(
                children: [
                  const Icon(Icons.star_rounded, color: Colors.amber, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    widget.rating.toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.textTheme.titleMedium!.color,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
