import 'package:flutter/material.dart';
import 'package:mochi_player/core/ui/app_ui.dart';
import 'package:mochi_player/features/library/application/media_card_view_data.dart';
import 'package:mochi_player/features/playback/presentation/playback_launcher.dart';

class ContinueWatchingCard extends StatelessWidget {
  final MediaCardViewData item;

  const ContinueWatchingCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return MediaPosterCard(
      title: item.title,
      subtitle: item.subtitle,
      posterUrl: item.imageUrl,
      rating: item.rating,
      tmdbId: item.file.tmdbId,
      cardType: MediaCardType.backdrop,
      progress: item.file.progress,
      showProgress: true,
      onTap: () => PlaybackLauncher.playFile(
        context,
        item.file,
        contextTitle: item.playbackContextTitle,
      ),
    );
  }
}
