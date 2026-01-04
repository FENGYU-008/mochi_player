import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/domain/models.dart';
import '../../../providers/media_library_provider.dart';
import 'playback_helper.dart';

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

  @override
  void initState() {
    super.initState();
    _sortedSeasons = List.from(widget.tvShow.seasons)
      ..sort((a, b) => a.seasonNumber.compareTo(b.seasonNumber));

    if (_sortedSeasons.isNotEmpty) {
      _selectSeason(_sortedSeasons.first);
    }
  }

  void _selectSeason(Season season) {
    setState(() {
      _selectedSeason = season;
      _sortedEpisodes = List.from(season.episodes)
        ..sort((a, b) => a.episodeNumber.compareTo(b.episodeNumber));
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_sortedSeasons.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 32),
        child: Text(
          "No seasons available.",
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 40), // Spacing before Episode list
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Episodes',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
            // Custom Season Selector (Clean Desktop Style)
            Theme(
              data: Theme.of(context).copyWith(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                hoverColor: Colors.transparent,
              ),
              child: PopupMenuButton<Season>(
                initialValue: _selectedSeason,
                offset: const Offset(0, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: isDark ? const Color(0xFF2C2C2E) : Colors.white,
                elevation: 4,
                tooltip: '', // Disable tooltip
                onSelected: (season) {
                  if (season != null) _selectSeason(season);
                },
                itemBuilder: (context) {
                  return _sortedSeasons.map((season) {
                    final isSelected = season == _selectedSeason;
                    return PopupMenuItem<Season>(
                      value: season,
                      height: 40,
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Season ${season.seasonNumber}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isSelected
                                    ? theme.colorScheme.primary
                                    : theme.textTheme.bodyLarge?.color,
                              ),
                            ),
                          ),
                          if (isSelected)
                            Icon(
                              Icons.check_rounded,
                              size: 16,
                              color: theme.colorScheme.primary,
                            ),
                        ],
                      ),
                    );
                  }).toList();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withAlpha(20)
                        : Colors.black.withAlpha(10),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark ? Colors.white24 : Colors.grey[300]!,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _selectedSeason != null
                            ? 'Season ${_selectedSeason!.seasonNumber}'
                            : 'Select Season',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: theme.textTheme.bodyLarge?.color,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 18,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Episode List
        if (_selectedSeason != null)
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _sortedEpisodes.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final episode = _sortedEpisodes[index];
              return _buildEpisodeCard(context, episode);
            },
          ),
      ],
    );
  }

  Widget _buildEpisodeCard(BuildContext context, Episode episode) {
    final theme = Theme.of(context);

    // Get duration from MediaFile
    final provider = Provider.of<MediaLibraryProvider>(context, listen: false);
    MediaFile? episodeFile;
    try {
      episodeFile = provider.mediaFiles.firstWhere(
        (f) => f.tmdbId == episode.tmdbId,
      );
    } catch (_) {}

    final duration = episodeFile != null && episodeFile.duration > 0
        ? '${(episodeFile.duration / 60).round()}m'
        : null;

    return InkWell(
      onTap: () => PlaybackHelper.playEpisode(
        context,
        episode,
        showTitle: widget.tvShow.title,
      ),
      borderRadius: BorderRadius.circular(8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Still Image
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              width: 130,
              height: 75,
              child: episode.stillUrl != null
                  ? CachedNetworkImage(
                      imageUrl: episode.stillUrl!,
                      fit: BoxFit.cover,
                      placeholder: (_, __) =>
                          Container(color: Colors.grey[300]),
                      errorWidget: (_, __, ___) => Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.movie, color: Colors.grey),
                      ),
                    )
                  : Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.movie, color: Colors.grey),
                    ),
            ),
          ),
          const SizedBox(width: 16),
          // Text Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${episode.episodeNumber}. ${episode.title}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (duration != null)
                      Text(
                        duration,
                        style: TextStyle(
                          fontSize: 13,
                          color: theme.textTheme.bodySmall?.color,
                        ),
                      ),
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
