import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/media_library_provider.dart';
import '../../view_models/media_detail_view_model.dart';
import 'favorite_button.dart';
import 'playback_helper.dart';

class MediaDetailHeader extends StatelessWidget {
  final MediaDetailViewModel viewModel;

  const MediaDetailHeader({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    // Use a fixed height similar to Hero Section (500-550)
    // to accommodate Metadata -> Title -> Overview -> Actions stack
    return SizedBox(
      height: 550,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _buildBackdrop(),
          _buildGradientOverlay(context),

          // Logo (Top Left, Smaller)
          _buildTopLogo(),

          _buildContentColumn(context),
        ],
      ),
    );
  }

  Widget _buildBackdrop() {
    return CachedNetworkImage(
      imageUrl: viewModel.backdropUrl.isNotEmpty
          ? viewModel.backdropUrl
          : viewModel.posterUrl,
      fit: BoxFit.cover,
      alignment: Alignment.topCenter,
      placeholder: (context, url) => Container(color: Colors.grey[100]),
      errorWidget: (context, url, error) => Container(color: Colors.grey[300]),
    );
  }

  Widget _buildGradientOverlay(BuildContext context) {
    // Determine the card background color based on theme
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1C1C1E) : Colors.white;

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      height: 350, // Matches Hero Section height/scale
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withAlpha(50), // Hero-style black tint
              Colors.black.withAlpha(150),
              cardColor.withAlpha(230), // Fade to card color
              cardColor,
            ],
            stops: const [0.0, 0.3, 0.5, 0.8, 1.0],
          ),
        ),
      ),
    );
  }

  Widget _buildTopLogo() {
    if (viewModel.logoUrl == null) return const SizedBox.shrink();
    return Positioned(
      top: 40,
      left: 40,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 150, maxHeight: 60),
        child: CachedNetworkImage(
          imageUrl: viewModel.logoUrl!,
          fit: BoxFit.contain,
          alignment: Alignment.centerLeft,
          filterQuality: FilterQuality.high,
        ),
      ),
    );
  }

  Widget _buildContentColumn(BuildContext context) {
    return Positioned(
      bottom: 24,
      left: 40,
      right: 40,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Metadata Row (Rating, Year, Genres)
          _buildMetadataRow(context),

          const SizedBox(height: 16),

          // 2. Big Text Title (Always Text, matching Hero)
          _buildTextTitle(),

          const SizedBox(height: 16),

          // 3. Overview (Max 3 lines, White text w/ shadow)
          if (viewModel.overview.isNotEmpty)
            Text(
              viewModel.overview,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
                color: Colors.white, // Always white on dark gradient
                shadows: [
                  Shadow(
                    offset: Offset(0, 1),
                    blurRadius: 4,
                    color: Colors.black54,
                  ),
                ],
              ),
            ),

          const SizedBox(height: 24),

          // 4. Action Buttons
          _buildActions(context),
        ],
      ),
    );
  }

  Widget _buildTextTitle() {
    return Text(
      viewModel.title,
      style: const TextStyle(
        fontSize: 48, // Larger title like Hero
        fontWeight: FontWeight.w900,
        color: Colors.white,
        height: 1.1,
        letterSpacing: -0.5,
        shadows: [
          Shadow(offset: Offset(0, 2), blurRadius: 10, color: Colors.black54),
        ],
      ),
    );
  }

  Widget _buildMetadataRow(BuildContext context) {
    // With the Hero-style black tinted gradient, we can safely use white text
    // for metadata even in light mode.

    final List<Widget> items = [];

    // 1. Rating Badge (Always Amber)
    if (viewModel.rating > 0) {
      items.add(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.amber,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.star_rounded, color: Colors.black87, size: 16),
              const SizedBox(width: 4),
              Text(
                viewModel.rating.toStringAsFixed(1),
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 2. Year (White text)
    if (viewModel.releaseYear != null) {
      items.add(
        Text(
          '${viewModel.releaseYear}',
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withAlpha(200),
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    // Technical Specs / Certification (Badge Style)
    if (viewModel.certification != null &&
        viewModel.certification!.isNotEmpty) {
      items.add(_buildBadge(viewModel.certification!));
    }

    // Seasons Count (TV Only)
    if (viewModel.isTVShow) {
      items.add(
        Text(
          '${viewModel.seasons.length} Seasons',
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withAlpha(200),
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    // 3. Genres (Badge Style)
    items.addAll(viewModel.genres.map((g) => _buildBadge(g)));

    // Technical Specs from File
    final provider = Provider.of<MediaLibraryProvider>(context, listen: false);
    final files = provider.getVersions(viewModel.tmdbId);
    final bestFile = files.isNotEmpty ? files.first : null;

    if (bestFile != null) {
      final quality = bestFile.quality;
      if (quality.isNotEmpty) {
        if (bestFile.isHdr) {
          items.add(_buildBadge('$quality ${bestFile.hdrFormat ?? "HDR"}'));
        } else {
          items.add(_buildBadge(quality));
        }
      }
      if (bestFile.audioChannels != null &&
          bestFile.audioChannels!.isNotEmpty) {
        items.add(_buildBadge(bestFile.audioChannels!));
      }
    }

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: items,
    );
  }

  // Consistent Badge Style (Hero Genre Style - White translucent)
  Widget _buildBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(30),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: Colors.white.withAlpha(220),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      children: [
        // Play Button
        ElevatedButton.icon(
          onPressed: () => _handlePlay(context),
          icon: const Icon(
            Icons.play_arrow_rounded,
            color: Colors.white,
            size: 24,
          ),
          label: const Text(
            'Play',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF007AFF),
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
        ),
        const SizedBox(width: 12),
        // Favorite Button (Always white-ish border/icon on dark overlay)
        FavoriteButton(tmdbId: viewModel.tmdbId, overrideColor: Colors.white),
      ],
    );
  }

  void _handlePlay(BuildContext context) {
    if (viewModel.isMovie) {
      PlaybackHelper.playMovie(context, viewModel.originalItem);
    } else {
      if (viewModel.seasons.isNotEmpty &&
          viewModel.seasons.first.episodes.isNotEmpty) {
        PlaybackHelper.playEpisode(
          context,
          viewModel.seasons.first.episodes.first,
          showTitle: viewModel.title,
        );
      }
    }
  }
}
