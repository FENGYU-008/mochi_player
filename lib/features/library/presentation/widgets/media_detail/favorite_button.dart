import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mochi_player/features/library/application/media_library_provider.dart';
import 'package:mochi_player/core/ui/app_ui.dart';

class FavoriteButton extends StatelessWidget {
  final String tmdbId;
  final Color? overrideColor;
  final bool showLabel;

  const FavoriteButton({
    super.key,
    required this.tmdbId,
    this.overrideColor,
    this.showLabel = false,
  });

  @override
  Widget build(BuildContext context) {
    final isFavorite = context.select<MediaLibraryProvider, bool>(
      (provider) => provider.isFavorite(tmdbId),
    );
    final usesOverlayAppearance = overrideColor != null;
    final baseColor = overrideColor ?? AppColors.textPrimary(context);
    final favoriteColor = AppColors.favorite(context);
    final icon = isFavorite
        ? Icons.favorite_rounded
        : Icons.favorite_border_rounded;
    void toggleFavorite() {
      context.read<MediaLibraryProvider>().setFavorite(
        tmdbId,
        isFavorite: !isFavorite,
      );
    }

    if (showLabel) {
      return AppActionButton(
        onPressed: toggleFavorite,
        icon: icon,
        iconColor: usesOverlayAppearance && isFavorite ? favoriteColor : null,
        label: isFavorite ? '已收藏' : '加入收藏',
        variant: AppButtonVariant.secondary,
        appearance: usesOverlayAppearance
            ? AppControlAppearance.overlay
            : AppControlAppearance.adaptive,
        selected: isFavorite,
        accentColor: favoriteColor,
        height: 36,
        borderRadius: 10,
        padding: const EdgeInsets.symmetric(horizontal: 15),
      );
    }

    final backgroundColor = usesOverlayAppearance
        ? Colors.white.withAlpha(isFavorite ? 54 : 34)
        : isFavorite
        ? favoriteColor.withAlpha(24)
        : AppColors.hoverSurface(context);
    return AppIconButton(
      onPressed: toggleFavorite,
      icon: icon,
      tooltip: isFavorite ? "取消收藏" : "加入收藏",
      selected: isFavorite,
      appearance: usesOverlayAppearance
          ? AppControlAppearance.overlay
          : AppControlAppearance.adaptive,
      selectedColor: favoriteColor,
      foregroundColor: baseColor,
      backgroundColor: backgroundColor,
      size: 44,
      iconSize: 22,
    );
  }
}
