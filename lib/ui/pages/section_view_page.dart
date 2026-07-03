import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/domain/models.dart';
import '../../providers/media_library_provider.dart';
import '../widgets/media_poster_card.dart';
import '../widgets/media_detail/playback_helper.dart';
import 'media_detail_modals.dart';

/// Section 类型
enum SectionType { continueWatching, movies, tvShows }

/// 显示 Section 详情模态窗口
void showSectionModal(
  BuildContext context, {
  required String title,
  required SectionType sectionType,
  List<Movie>? movies,
  List<TVShow>? tvShows,
  List<MediaFile>? mediaFiles,
}) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: "Dismiss",
    barrierColor: Colors.transparent,
    transitionDuration: const Duration(milliseconds: 300),
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curvedAnimation = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutQuart,
        reverseCurve: Curves.easeInCubic,
      );
      return Stack(
        children: [
          FadeTransition(
            opacity: curvedAnimation,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              behavior: HitTestBehavior.opaque,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  color: Colors.black.withAlpha((255 * 0.2).round()),
                ),
              ),
            ),
          ),
          ScaleTransition(
            scale: Tween<double>(
              begin: 0.92,
              end: 1.0,
            ).animate(curvedAnimation),
            child: FadeTransition(opacity: curvedAnimation, child: child),
          ),
        ],
      );
    },
    pageBuilder: (context, animation, secondaryAnimation) {
      return Center(
        child: Material(
          color: Colors.transparent,
          child: GestureDetector(
            onTap: () {},
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: 1000,
                maxHeight: MediaQuery.of(context).size.height * 0.85,
              ),
              child: _SectionModalContent(
                title: title,
                sectionType: sectionType,
                movies: movies,
                tvShows: tvShows,
                mediaFiles: mediaFiles,
              ),
            ),
          ),
        ),
      );
    },
  );
}

/// 便捷方法：显示电影列表
void showMoviesSection(BuildContext context, String title, List<Movie> items) {
  showSectionModal(
    context,
    title: title,
    sectionType: SectionType.movies,
    movies: items,
  );
}

/// 便捷方法：显示剧集列表
void showTVShowsSection(
  BuildContext context,
  String title,
  List<TVShow> items,
) {
  showSectionModal(
    context,
    title: title,
    sectionType: SectionType.tvShows,
    tvShows: items,
  );
}

/// 便捷方法：显示继续观看列表
void showContinueWatchingSection(
  BuildContext context,
  String title,
  List<MediaFile> items,
) {
  showSectionModal(
    context,
    title: title,
    sectionType: SectionType.continueWatching,
    mediaFiles: items,
  );
}

class _SectionModalContent extends StatelessWidget {
  final String title;
  final SectionType sectionType;
  final List<Movie>? movies;
  final List<TVShow>? tvShows;
  final List<MediaFile>? mediaFiles;

  const _SectionModalContent({
    required this.title,
    required this.sectionType,
    this.movies,
    this.tvShows,
    this.mediaFiles,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.read<MediaLibraryProvider>();

    return Container(
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.light
            ? Colors.white
            : const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((255 * 0.2).round()),
            blurRadius: 50,
            offset: const Offset(0, 30),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            // Header
            _buildHeader(context, theme),
            // 分割线
            Container(height: 1, color: theme.dividerColor),
            // 内容区域
            Expanded(child: _buildContent(context, provider, theme)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // 标题
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.textTheme.bodyMedium?.color,
            ),
          ),
          const Spacer(),
          // 关闭按钮
          _CloseButton(onTap: () => Navigator.pop(context)),
        ],
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    MediaLibraryProvider provider,
    ThemeData theme,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double width = constraints.maxWidth;
        double contentWidth = width - 60; // 左右各 30 padding

        // 根据类型选择不同的布局参数
        final bool isBackdrop = sectionType == SectionType.continueWatching;

        // 海报尺寸：更小的尺寸适合模态窗口
        const double posterItemWidth = 140;
        const double backdropItemWidth = 220;

        final double desiredItemWidth = isBackdrop
            ? backdropItemWidth
            : posterItemWidth;
        int crossAxisCount = (contentWidth / desiredItemWidth).floor();
        if (crossAxisCount < 2) crossAxisCount = 2;
        if (!isBackdrop && crossAxisCount < 3) crossAxisCount = 3;

        // 计算宽高比
        // 竖版海报：宽高比约 0.55 (更紧凑)
        // 横版背景：宽高比约 1.35 (16:9 图片 + 文字区域)
        final double childAspectRatio = isBackdrop ? 1.35 : 0.55;

        return GridView.builder(
          padding: const EdgeInsets.all(24),
          itemCount: _getItemCount(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: childAspectRatio,
            crossAxisSpacing: 16,
            mainAxisSpacing: 20,
          ),
          itemBuilder: (context, index) {
            return _buildCard(context, index, provider);
          },
        );
      },
    );
  }

  int _getItemCount() {
    switch (sectionType) {
      case SectionType.movies:
        return movies?.length ?? 0;
      case SectionType.tvShows:
        return tvShows?.length ?? 0;
      case SectionType.continueWatching:
        return mediaFiles?.length ?? 0;
    }
  }

  Widget _buildCard(
    BuildContext context,
    int index,
    MediaLibraryProvider provider,
  ) {
    switch (sectionType) {
      case SectionType.movies:
        return _buildMovieCard(context, movies![index]);
      case SectionType.tvShows:
        return _buildTVShowCard(context, tvShows![index]);
      case SectionType.continueWatching:
        return _buildContinueWatchingCard(
          context,
          mediaFiles![index],
          provider,
        );
    }
  }

  Widget _buildMovieCard(BuildContext context, Movie movie) {
    return MediaPosterCard(
      title: movie.title,
      subtitle: movie.releaseYear?.toString(),
      posterUrl: movie.posterUrl,
      rating: movie.rating,
      tmdbId: movie.tmdbId,
      cardType: MediaCardType.poster,
      onTap: () => showMediaDetailModal(context, movie),
    );
  }

  Widget _buildTVShowCard(BuildContext context, TVShow show) {
    String? subtitle;
    if (show.numberOfSeasons != null && show.numberOfSeasons! > 0) {
      subtitle = show.numberOfSeasons == 1
          ? '1 Season'
          : '${show.numberOfSeasons} Seasons';
    } else if (show.releaseYear != null) {
      subtitle = show.releaseYear.toString();
    }

    return MediaPosterCard(
      title: show.title,
      subtitle: subtitle,
      posterUrl: show.posterUrl,
      rating: show.rating,
      tmdbId: show.tmdbId,
      cardType: MediaCardType.poster,
      onTap: () => showMediaDetailModal(context, show),
    );
  }

  Widget _buildContinueWatchingCard(
    BuildContext context,
    MediaFile file,
    MediaLibraryProvider provider,
  ) {
    String title = file.parsedTitle;
    String? subtitle;
    String? imageUrl;
    double rating = 0.0;
    dynamic metadata;

    if (file.mediaType == MediaType.movie) {
      metadata = provider.getMovieMetadata(file.tmdbId ?? '');
      if (metadata != null) {
        title = metadata.title;
        imageUrl = metadata.backdropUrl;
        rating = metadata.rating;
        subtitle = metadata.releaseYear?.toString();
      }
    } else {
      subtitle = _episodeLabel(file);
      metadata = provider.getTVShowMetadata(file.tmdbId ?? '');
      if (metadata != null) {
        title = metadata.title;
        imageUrl = metadata.backdropUrl;
        rating = metadata.rating;
        if (subtitle == null && metadata.numberOfSeasons != null) {
          subtitle = '${metadata.numberOfSeasons} Seasons';
        }
      }
    }

    return MediaPosterCard(
      title: title,
      subtitle: subtitle,
      posterUrl: imageUrl,
      rating: rating,
      tmdbId: file.tmdbId,
      cardType: MediaCardType.backdrop,
      progress: file.progress,
      showProgress: true,
      onTap: () {
        PlaybackHelper.playFile(
          context,
          file,
          contextTitle: file.mediaType == MediaType.episode ? title : null,
        );
      },
    );
  }

  String? _episodeLabel(MediaFile file) {
    final season = file.parsedSeason;
    final episode = file.parsedEpisode;
    if (season == null || episode == null) return null;

    final seasonLabel = season.toString().padLeft(2, '0');
    final episodeLabel = episode.toString().padLeft(2, '0');
    return 'S${seasonLabel}E$episodeLabel';
  }
}

/// 关闭按钮
class _CloseButton extends StatefulWidget {
  final VoidCallback onTap;

  const _CloseButton({required this.onTap});

  @override
  State<_CloseButton> createState() => _CloseButtonState();
}

class _CloseButtonState extends State<_CloseButton> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconColor = theme.textTheme.bodyMedium!.color!;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _isHovering ? iconColor.withAlpha(25) : Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.close, color: iconColor, size: 20),
        ),
      ),
    );
  }
}
