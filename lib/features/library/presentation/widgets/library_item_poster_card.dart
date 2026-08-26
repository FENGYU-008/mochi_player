import 'package:flutter/material.dart';
import 'package:mochi_player/core/domain/media/models.dart';
import 'package:mochi_player/core/ui/app_ui.dart';
import 'package:mochi_player/features/library/presentation/pages/media_detail_page.dart';
import 'package:mochi_player/features/library/presentation/widgets/media_card.dart';

class LibraryItemPosterCard extends StatelessWidget {
  final LibraryItem item;
  final MediaArtworkType artworkType;
  final VoidCallback? onTap;

  const LibraryItemPosterCard({super.key, required this.item, this.artworkType = MediaArtworkType.poster, this.onTap});

  @override
  Widget build(BuildContext context) {
    return MediaCard(
      title: item.title,
      subtitle: _subtitle(item),
      imageUrl: artworkType == MediaArtworkType.backdrop ? item.backdropUrl : item.posterUrl,
      rating: item.rating,
      artworkType: artworkType,
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
