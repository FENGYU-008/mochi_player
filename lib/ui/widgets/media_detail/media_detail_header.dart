import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../models/domain/models.dart';
import '../../../../providers/media_library_provider.dart';
import '../../../../services/tmdb_image_cache_manager.dart';
import '../../view_models/media_detail_view_model.dart';
import '../macos_controls.dart';
import 'favorite_button.dart';
import 'playback_helper.dart';

const double _detailReadableWidth = 820;

class MediaDetailHeader extends StatelessWidget {
  final MediaDetailViewModel viewModel;

  const MediaDetailHeader({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = theme.brightness == Brightness.dark
        ? const Color(0xFF1C1C1E)
        : Colors.white;

    return RepaintBoundary(
      child: SizedBox(
        height: 320,
        child: Stack(
          fit: StackFit.expand,
          children: [
            _buildBackdrop(context),
            _buildGradientOverlay(cardColor),
            Padding(
              padding: const EdgeInsets.fromLTRB(40, 30, 40, 28),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final compact = constraints.maxWidth < 760;
                  if (compact) {
                    return _HeaderContent(viewModel: viewModel, compact: true);
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (viewModel.posterUrl.isNotEmpty) ...[
                        _PosterImage(posterUrl: viewModel.posterUrl),
                        const SizedBox(width: 28),
                      ],
                      Expanded(child: _HeaderContent(viewModel: viewModel)),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackdrop(BuildContext context) {
    final imageUrl = viewModel.backdropUrl.isNotEmpty
        ? viewModel.backdropUrl
        : viewModel.posterUrl;
    if (imageUrl.isEmpty) {
      return const _FallbackBackdrop();
    }

    return CachedNetworkImage(
      cacheManager: TmdbImageCacheManager.instance,
      imageUrl: imageUrl,
      width: double.infinity,
      height: 320,
      fit: BoxFit.cover,
      alignment: Alignment.topCenter,
      placeholder: (context, url) => const _FallbackBackdrop(),
      errorWidget: (context, url, error) => const _FallbackBackdrop(),
    );
  }

  Widget _buildGradientOverlay(Color cardColor) {
    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Colors.black.withAlpha(120),
                Colors.black.withAlpha(76),
                Colors.black.withAlpha(18),
                Colors.transparent,
              ],
              stops: const [0.0, 0.34, 0.68, 1.0],
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withAlpha(10),
                Colors.black.withAlpha(28),
                Colors.black.withAlpha(78),
                Colors.transparent,
                cardColor.withAlpha(70),
                cardColor.withAlpha(185),
                cardColor,
              ],
              stops: const [0.0, 0.24, 0.52, 0.66, 0.78, 0.92, 1.0],
            ),
          ),
        ),
      ],
    );
  }
}

class _FallbackBackdrop extends StatelessWidget {
  const _FallbackBackdrop();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2A2D34), Color(0xFF111216)],
        ),
      ),
    );
  }
}

class _HeaderContent extends StatelessWidget {
  final MediaDetailViewModel viewModel;
  final bool compact;

  const _HeaderContent({required this.viewModel, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final hasLogo = viewModel.logoUrl?.isNotEmpty == true;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (hasLogo) ...[
          _LogoImage(
            logoUrl: viewModel.logoUrl!,
            fallbackTitle: viewModel.title,
            compact: compact,
          ),
          const SizedBox(height: 14),
        ],
        _MetadataStrip(viewModel: viewModel),
        if (!hasLogo) ...[
          const SizedBox(height: 12),
          _TitleText(title: viewModel.title, compact: compact),
        ],
        const SizedBox(height: 12),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _detailReadableWidth),
          child: Text(
            viewModel.overview,
            maxLines: compact ? 2 : 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withAlpha(225),
              fontSize: 14,
              height: 1.45,
              shadows: const [
                Shadow(
                  offset: Offset(0, 1),
                  blurRadius: 4,
                  color: Colors.black54,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        _PrimaryActionArea(viewModel: viewModel),
      ],
    );
  }
}

class _PrimaryActionArea extends StatelessWidget {
  final MediaDetailViewModel viewModel;

  const _PrimaryActionArea({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    context.select<MediaLibraryProvider, int>(
      (provider) => provider.watchProgressRevision,
    );

    return _ActionRow(
      viewModel: viewModel,
      action: _resolvePrimaryAction(context),
    );
  }

  _PrimaryPlayAction _resolvePrimaryAction(BuildContext context) {
    final provider = context.read<MediaLibraryProvider>();
    final files = provider.getVersions(viewModel.tmdbId);
    final resumeFile = _latestResumeFile(files);

    if (resumeFile != null) {
      return _PrimaryPlayAction(
        label: viewModel.isTVShow
            ? _episodeActionLabel(resumeFile, '继续')
            : '继续播放',
        detail: _resumeDetail(resumeFile),
        onPressed: () => PlaybackHelper.playFile(
          context,
          resumeFile,
          contextTitle: viewModel.isTVShow ? viewModel.title : null,
        ),
      );
    }

    if (viewModel.isMovie) {
      return _PrimaryPlayAction(
        label: '播放',
        detail: files.isEmpty ? '未找到本地文件' : _versionCount(files),
        enabled: files.isNotEmpty,
        onPressed: files.isEmpty
            ? null
            : () => PlaybackHelper.playMovie(
                context,
                viewModel.originalItem as Movie,
              ),
      );
    }

    final firstFile = _firstPlayableEpisodeFile(files);
    return _PrimaryPlayAction(
      label: firstFile == null ? '不可播放' : _episodeActionLabel(firstFile, '播放'),
      detail: firstFile == null ? '未找到可播放剧集' : _episodeCountDetail(files),
      enabled: firstFile != null,
      onPressed: firstFile == null
          ? null
          : () => PlaybackHelper.playFile(
              context,
              firstFile,
              contextTitle: viewModel.title,
            ),
    );
  }

  MediaFile? _latestResumeFile(List<MediaFile> files) {
    final candidates = files
        .where(
          (file) =>
              file.position > 0 && file.progress > 0 && file.progress < 0.95,
        )
        .toList();
    if (candidates.isEmpty) return null;
    candidates.sort(
      (a, b) => (b.lastWatchedAt ?? DateTime(0)).compareTo(
        a.lastWatchedAt ?? DateTime(0),
      ),
    );
    return candidates.first;
  }

  MediaFile? _firstPlayableEpisodeFile(List<MediaFile> files) {
    final candidates = files
        .where((file) => file.mediaType == MediaType.episode)
        .toList();
    if (candidates.isEmpty) return null;
    candidates.sort((a, b) {
      final season = (a.parsedSeason ?? 999999).compareTo(
        b.parsedSeason ?? 999999,
      );
      if (season != 0) return season;
      return (a.parsedEpisode ?? 999999).compareTo(b.parsedEpisode ?? 999999);
    });
    return candidates.first;
  }

  String _episodeActionLabel(MediaFile file, String verb) {
    final episode = file.parsedEpisode;
    if (episode != null) return '$verb第 $episode 集';

    return '$verb第 ?? 集';
  }

  String _resumeDetail(MediaFile file) {
    if (file.duration <= 0) return '从上次进度继续';
    return '从 ${_formatDuration(Duration(milliseconds: file.position))} 继续';
  }

  String _versionCount(List<MediaFile> files) {
    return files.length == 1 ? '1 个版本可播放' : '${files.length} 个版本可播放';
  }

  String _episodeCountDetail(List<MediaFile> files) {
    final count = files
        .where((file) => file.mediaType == MediaType.episode)
        .length;
    return count == 1 ? '1 集可播放' : '$count 集可播放';
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (hours > 0) return '$hours:$minutes:$seconds';
    return '$minutes:$seconds';
  }
}

class _MetadataStrip extends StatelessWidget {
  final MediaDetailViewModel viewModel;

  const _MetadataStrip({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[];
    if (viewModel.rating > 0) {
      items.add(_RatingPill(rating: viewModel.rating));
    }
    if (viewModel.releaseYear != null) {
      items.add(_TextPill('${viewModel.releaseYear}'));
    }
    if (viewModel.certification != null &&
        viewModel.certification!.isNotEmpty) {
      items.add(_TextPill(viewModel.certification!));
    }
    if (viewModel.isTVShow) {
      final seasons = viewModel.seasons.length;
      if (seasons > 0) {
        items.add(_TextPill(seasons == 1 ? '1 季' : '$seasons 季'));
      }
    }
    items.addAll(viewModel.genres.take(3).map(_TextPill.new));

    return Wrap(spacing: 8, runSpacing: 8, children: items);
  }
}

class _ActionRow extends StatelessWidget {
  final MediaDetailViewModel viewModel;
  final _PrimaryPlayAction action;

  const _ActionRow({required this.viewModel, required this.action});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 10,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        MacosActionButton(
          onPressed: action.enabled ? action.onPressed : null,
          icon: Icons.play_arrow_rounded,
          label: action.label,
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 24),
        ),
        FavoriteButton(
          tmdbId: viewModel.tmdbId,
          overrideColor: Colors.white,
          showLabel: true,
        ),
        if (action.detail != null)
          Padding(
            padding: const EdgeInsets.only(left: 2),
            child: Text(
              action.detail!,
              style: TextStyle(
                color: Colors.white.withAlpha(205),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }
}

class _PosterImage extends StatelessWidget {
  final String posterUrl;

  const _PosterImage({required this.posterUrl});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: 150,
        height: 225,
        child: posterUrl.isNotEmpty
            ? CachedNetworkImage(
                cacheManager: TmdbImageCacheManager.instance,
                imageUrl: posterUrl,
                width: 150,
                height: 225,
                fit: BoxFit.cover,
                placeholder: (context, url) => _placeholder(),
                errorWidget: (context, url, error) => _placeholder(),
              )
            : _placeholder(),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: Colors.white.withAlpha(24),
      child: const Icon(Icons.movie_rounded, color: Colors.white54, size: 44),
    );
  }
}

class _LogoImage extends StatelessWidget {
  final String logoUrl;
  final String fallbackTitle;
  final bool compact;

  const _LogoImage({
    required this.logoUrl,
    required this.fallbackTitle,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 62,
      child: Align(
        alignment: Alignment.centerLeft,
        child: SizedBox(
          width: 260,
          height: 62,
          child: CachedNetworkImage(
            cacheManager: TmdbImageCacheManager.instance,
            imageUrl: logoUrl,
            width: 260,
            height: 62,
            fit: BoxFit.contain,
            alignment: Alignment.centerLeft,
            fadeInDuration: Duration.zero,
            fadeOutDuration: Duration.zero,
            placeholder: (context, url) => const SizedBox.expand(),
            errorWidget: (context, url, error) =>
                _TitleText(title: fallbackTitle, compact: compact),
          ),
        ),
      ),
    );
  }
}

class _TitleText extends StatelessWidget {
  final String title;
  final bool compact;

  const _TitleText({required this.title, required this.compact});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: Colors.white,
        fontSize: compact ? 30 : 36,
        fontWeight: FontWeight.w800,
        height: 1.08,
        shadows: const [
          Shadow(offset: Offset(0, 2), blurRadius: 10, color: Colors.black54),
        ],
      ),
    );
  }
}

class _RatingPill extends StatelessWidget {
  final double rating;

  const _RatingPill({required this.rating});

  @override
  Widget build(BuildContext context) {
    return MacosPill(
      text: rating.toStringAsFixed(1),
      icon: Icons.star_rounded,
      rating: true,
    );
  }
}

class _TextPill extends StatelessWidget {
  final String text;

  const _TextPill(this.text);

  @override
  Widget build(BuildContext context) {
    return MacosPill(text: text, tone: MacosControlTone.overlay);
  }
}

class _PrimaryPlayAction {
  final String label;
  final String? detail;
  final VoidCallback? onPressed;
  final bool enabled;

  const _PrimaryPlayAction({
    required this.label,
    this.detail,
    this.onPressed,
    this.enabled = true,
  });
}
