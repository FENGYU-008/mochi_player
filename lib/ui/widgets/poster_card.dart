import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/entity/entities.dart';
import '../../providers/media_library_provider.dart';
import '../theme/app_theme.dart';

class PosterCard extends StatefulWidget {
  final MediaFileEntity file;
  final MediaLibraryProvider provider;
  final bool useBackdrop;

  const PosterCard({
    super.key,
    required this.file,
    required this.provider,
    this.useBackdrop = false,
  });

  @override
  State<PosterCard> createState() => _PosterCardState();
}

class _PosterCardState extends State<PosterCard> {
  bool _isHovering = false;

  /// 获取图片 URL
  String get _imageUrl {
    final tmdbId = widget.file.tmdbId;
    if (tmdbId == null) return '';

    if (widget.file.mediaType == MediaType.movie) {
      final metadata = widget.provider.getMovieMetadata(tmdbId);
      if (metadata != null) {
        return widget.useBackdrop
            ? (metadata.backdropUrl ?? '')
            : (metadata.posterUrl ?? '');
      }
    } else if (widget.file.mediaType == MediaType.episode) {
      final metadata = widget.provider.getTVShowMetadata(tmdbId);
      if (metadata != null) {
        return widget.useBackdrop
            ? (metadata.backdropUrl ?? '')
            : (metadata.posterUrl ?? '');
      }
    }
    return '';
  }

  /// 获取显示标题
  String get _title {
    final tmdbId = widget.file.tmdbId;
    if (tmdbId != null) {
      if (widget.file.mediaType == MediaType.movie) {
        final metadata = widget.provider.getMovieMetadata(tmdbId);
        if (metadata != null) return metadata.title;
      } else if (widget.file.mediaType == MediaType.episode) {
        final metadata = widget.provider.getTVShowMetadata(tmdbId);
        if (metadata != null) return metadata.title;
      }
    }
    return widget.file.parsedTitle;
  }

  /// 获取评分
  String get _rating {
    final tmdbId = widget.file.tmdbId;
    if (tmdbId == null) return '';

    if (widget.file.mediaType == MediaType.movie) {
      final metadata = widget.provider.getMovieMetadata(tmdbId);
      if (metadata != null) return metadata.rating.toStringAsFixed(1);
    } else if (widget.file.mediaType == MediaType.episode) {
      final metadata = widget.provider.getTVShowMetadata(tmdbId);
      if (metadata != null) return metadata.rating.toStringAsFixed(1);
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final customTheme = theme.extension<AppThemeExtension>()!;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          // TODO: 打开详情页
        },
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
                        child: _imageUrl.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: _imageUrl,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  color: theme.canvasColor.withAlpha(128),
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
                                        widget.file.parsedTitle,
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
                      // 质量标签
                      if (widget.file.quality.isNotEmpty)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              widget.file.quality,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ),
                      // 进度条
                      if (widget.file.watchStatus == WatchStatus.watching)
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: LinearProgressIndicator(
                            value: widget.file.progress,
                            backgroundColor: Colors.black45,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Colors.orange,
                            ),
                            minHeight: 3,
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
              child: Text(_title, maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
            const SizedBox(height: 4),
            // 评分 + 质量
            Row(
              children: [
                if (_rating.isNotEmpty) ...[
                  const Icon(Icons.star_rounded, color: Colors.amber, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    _rating,
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.textTheme.titleMedium!.color,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                if (widget.file.versionLabel != null)
                  Text(
                    widget.file.versionLabel!,
                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
