import 'package:flutter/material.dart';
import 'package:mochi_player/core/domain/media/models.dart';
import 'package:mochi_player/core/ui/app_ui.dart';
import 'package:mochi_player/features/library/presentation/pages/media_detail_page.dart';

class LibraryItemPosterCard extends StatelessWidget {
  final LibraryItem item;
  final MediaCardType cardType;
  final VoidCallback? onTap;

  const LibraryItemPosterCard({
    super.key,
    required this.item,
    this.cardType = MediaCardType.poster,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return MediaPosterCard(
      title: item.title,
      subtitle: _subtitle(item),
      posterUrl: cardType == MediaCardType.backdrop
          ? item.backdropUrl
          : item.posterUrl,
      rating: item.rating,
      tmdbId: item.tmdbId,
      cardType: cardType,
      onTap: onTap ?? () => openMediaDetailPage(context, item),
    );
  }

  String? _subtitle(LibraryItem item) {
    if (item is TVShow) {
      final seasons = item.numberOfSeasons;
      if (seasons != null && seasons > 0) {
        return MediaFormat.seasonCount(seasons);
      }
    }
    return item.releaseYear?.toString();
  }
}
