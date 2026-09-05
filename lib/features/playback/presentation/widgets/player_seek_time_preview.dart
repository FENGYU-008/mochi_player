import 'package:flutter/material.dart';
import 'package:mochi_player/core/ui/app_ui.dart';
import 'package:mochi_player/features/playback/presentation/widgets/player_overlay.dart';

/// Glass timestamp shown above the seek bar for a hovered or dragged position.
class PlayerSeekTimePreview extends StatelessWidget {
  final Duration position;

  const PlayerSeekTimePreview({super.key, required this.position});

  @override
  Widget build(BuildContext context) {
    return AppGlassSurface(
      borderRadius: const BorderRadius.all(Radius.circular(AppRadii.control)),
      color: PlayerOverlayGlass.background,
      borderColor: PlayerOverlayGlass.border,
      blur: PlayerOverlayGlass.blur,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      child: Text(
        _formatDuration(position),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          decoration: TextDecoration.none,
          fontFeatures: [FontFeature.tabularFigures()],
        ),
      ),
    );
  }

  static String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return duration.inHours > 0 ? '${duration.inHours}:$minutes:$seconds' : '$minutes:$seconds';
  }
}
