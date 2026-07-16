import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mochi_player/features/library/application/media_library_provider.dart';
import 'package:mochi_player/features/playback/presentation/playback_launcher.dart';
import 'package:mochi_player/core/domain/media/models.dart';
import 'package:mochi_player/core/infrastructure/tmdb/tmdb_image_cache_manager.dart';
import 'package:mochi_player/core/ui/theme/app_radii.dart';
import 'package:mochi_player/core/ui/theme/app_spacing.dart';
import 'package:mochi_player/core/ui/widgets/app_select.dart';
import 'package:mochi_player/core/ui/widgets/app_surface.dart';

class EpisodeList extends StatefulWidget {
  final TVShow tvShow;

  const EpisodeList({super.key, required this.tvShow});

  @override
  State<EpisodeList> createState() => _EpisodeListState();
}

class _EpisodeListState extends State<EpisodeList> {
  List<Season> _sortedSeasons = [];
  Season? _selectedSeason;
  List<Episode> _sortedEpisodes = [];
  Map<String, MediaFile> _mediaFileByTmdbId = const {};

  @override
  void initState() {
    super.initState();
    _prepareSeasons();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _mediaFileByTmdbId = _buildMediaFileIndex();
  }

  @override
  void didUpdateWidget(covariant EpisodeList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tvShow != widget.tvShow) {
      _prepareSeasons();
      _mediaFileByTmdbId = _buildMediaFileIndex();
    }
  }

  void _prepareSeasons() {
    _sortedSeasons = List.from(widget.tvShow.seasons)
      ..sort((a, b) => a.seasonNumber.compareTo(b.seasonNumber));

    if (_sortedSeasons.isNotEmpty) {
      _selectedSeason = _sortedSeasons.first;
      _sortedEpisodes = _sortedEpisodesFor(_selectedSeason!);
    } else {
      _selectedSeason = null;
      _sortedEpisodes = [];
    }
  }

  Map<String, MediaFile> _buildMediaFileIndex() {
    final mediaFiles = context.read<MediaLibraryProvider>().mediaFiles;
    final result = <String, MediaFile>{};
    for (final file in mediaFiles) {
      final tmdbId = file.tmdbId;
      if (tmdbId != null && tmdbId.isNotEmpty) {
        result.putIfAbsent(tmdbId, () => file);
      }
    }
    return result;
  }

  List<Episode> _sortedEpisodesFor(Season season) {
    return List<Episode>.from(season.episodes)
      ..sort((a, b) => a.episodeNumber.compareTo(b.episodeNumber));
  }

  void _selectSeason(Season season) {
    setState(() {
      _selectedSeason = season;
      _sortedEpisodes = _sortedEpisodesFor(season);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_sortedSeasons.isEmpty) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.only(top: 32),
          child: Text("暂无季信息", style: TextStyle(color: Colors.grey)),
        ),
      );
    }

    final theme = Theme.of(context);

    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: _EpisodeHeader(
            theme: theme,
            sortedSeasons: _sortedSeasons,
            selectedSeason: _selectedSeason,
            onSeasonSelected: _selectSeason,
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              if (index.isOdd) {
                return const SizedBox(height: 16);
              }

              final episode = _sortedEpisodes[index ~/ 2];
              return _buildEpisodeCard(
                context,
                episode,
                _mediaFileByTmdbId[episode.tmdbId],
              );
            },
            childCount: _sortedEpisodes.isEmpty
                ? 0
                : _sortedEpisodes.length * 2 - 1,
            addAutomaticKeepAlives: false,
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 20)),
      ],
    );
  }

  Widget _buildEpisodeCard(
    BuildContext context,
    Episode episode,
    MediaFile? episodeFile,
  ) {
    final theme = Theme.of(context);
    final available = episodeFile != null;
    final progress = episodeFile?.progress.clamp(0.0, 1.0) ?? 0.0;
    final completed =
        episodeFile?.watchStatus == WatchStatus.completed || progress >= 0.95;
    final showStatus = !available || completed;

    return AppSurface(
      onTap: available
          ? () => PlaybackLauncher.playEpisode(
              context,
              episode,
              showTitle: widget.tvShow.title,
            )
          : null,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStill(episode, episodeFile, theme),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${episode.episodeNumber}. ${episode.title}',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: available
                              ? theme.textTheme.bodyLarge?.color
                              : theme.textTheme.bodySmall?.color,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (showStatus) ...[
                      const SizedBox(width: 10),
                      _EpisodeStatusPill(
                        available: available,
                        completed: completed,
                      ),
                    ] else ...[
                      const SizedBox(width: 8),
                      Icon(
                        Icons.play_arrow_rounded,
                        size: 20,
                        color: theme.colorScheme.primary.withAlpha(190),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  episode.overview ?? '',
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: theme.textTheme.bodySmall?.color,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 9),
                _EpisodeMetaRow(episode: episode, file: episodeFile),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStill(Episode episode, MediaFile? file, ThemeData theme) {
    final progress = file?.progress.clamp(0.0, 1.0) ?? 0.0;
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: SizedBox(
        width: 132,
        height: 76,
        child: Stack(
          fit: StackFit.expand,
          children: [
            episode.stillUrl != null
                ? CachedNetworkImage(
                    cacheManager: TmdbImageCacheManager.instance,
                    imageUrl: episode.stillUrl!,
                    width: 132,
                    height: 76,
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        Container(color: Colors.grey[300]),
                    errorWidget: (context, url, error) => _stillPlaceholder(),
                  )
                : _stillPlaceholder(),
            if (file == null) Container(color: Colors.black.withAlpha(95)),
            if (progress > 0 && progress < 0.95)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 3,
                  backgroundColor: Colors.black.withAlpha(80),
                  valueColor: AlwaysStoppedAnimation(theme.colorScheme.primary),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _stillPlaceholder() {
    return Container(
      color: Colors.grey[300],
      child: const Icon(Icons.movie, color: Colors.grey),
    );
  }
}

class _EpisodeStatusPill extends StatelessWidget {
  final bool available;
  final bool completed;

  const _EpisodeStatusPill({required this.available, required this.completed});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final label = !available
        ? '缺失'
        : completed
        ? '已看'
        : '';
    if (label.isEmpty) return const SizedBox.shrink();

    final color = !available
        ? theme.textTheme.bodySmall?.color ?? Colors.grey
        : completed
        ? Colors.green
        : theme.colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withAlpha(28),
        borderRadius: BorderRadius.circular(AppRadii.small),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

class _EpisodeMetaRow extends StatelessWidget {
  final Episode episode;
  final MediaFile? file;

  const _EpisodeMetaRow({required this.episode, required this.file});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final parts = <String>[];
    if (episode.airDate != null) {
      parts.add(_formatDate(episode.airDate!));
    }
    final mediaFile = file;
    if (mediaFile != null && mediaFile.duration > 0) {
      parts.add(_formatDuration(Duration(milliseconds: mediaFile.duration)));
    }

    if (parts.isEmpty) return const SizedBox.shrink();
    return Text(
      parts.join(' • '),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 12,
        color: theme.textTheme.bodySmall?.color,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      final minutes = duration.inMinutes
          .remainder(60)
          .toString()
          .padLeft(2, '0');
      return '${duration.inHours}h ${minutes}m';
    }
    return '${duration.inMinutes}m';
  }
}

class _EpisodeHeader extends StatelessWidget {
  final ThemeData theme;
  final List<Season> sortedSeasons;
  final Season? selectedSeason;
  final ValueChanged<Season> onSeasonSelected;

  const _EpisodeHeader({
    required this.theme,
    required this.sortedSeasons,
    required this.selectedSeason,
    required this.onSeasonSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '剧集',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
            AppSelect<Season>(
              value: selectedSeason,
              placeholder: '选择季',
              width: 92,
              options: [
                for (final season in sortedSeasons)
                  AppSelectOption(
                    value: season,
                    label: '第 ${season.seasonNumber} 季',
                  ),
              ],
              onSelected: onSeasonSelected,
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
