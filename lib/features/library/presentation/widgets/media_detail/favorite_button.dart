import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mochi_player/features/library/application/media_library_provider.dart';
import 'package:mochi_player/core/ui/app_ui.dart';

class FavoriteButton extends StatefulWidget {
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
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton> {
  bool _isFavorite = false;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      _checkFavoriteStatus();
    }
  }

  void _checkFavoriteStatus() {
    final provider = Provider.of<MediaLibraryProvider>(context, listen: false);
    final files = provider.getVersions(widget.tmdbId);
    if (files.isNotEmpty) {
      if (mounted) {
        setState(() => _isFavorite = files.any((f) => f.isFavorite));
      }
    }
  }

  Future<void> _toggleFavorite() async {
    final provider = Provider.of<MediaLibraryProvider>(context, listen: false);
    final files = provider.getVersions(widget.tmdbId);
    if (files.isEmpty) return;

    for (final file in files) {
      await provider.toggleFavorite(file);
    }

    if (mounted) {
      setState(() => _isFavorite = !_isFavorite);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isFavorite ? '已加入收藏' : '已取消收藏'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final overlayTone = widget.overrideColor != null;
    final baseColor = widget.overrideColor ?? AppColors.textPrimary(context);
    final icon = _isFavorite
        ? Icons.favorite_rounded
        : Icons.favorite_border_rounded;

    if (widget.showLabel) {
      return AppActionButton(
        onPressed: _toggleFavorite,
        icon: icon,
        label: _isFavorite ? '已收藏' : '加入收藏',
        variant: AppButtonVariant.secondary,
        tone: overlayTone ? AppControlTone.overlay : AppControlTone.adaptive,
        selected: _isFavorite,
        accentColor: AppColors.favorite,
        height: 36,
        borderRadius: 10,
        padding: const EdgeInsets.symmetric(horizontal: 15),
      );
    }

    final backgroundColor = overlayTone
        ? Colors.white.withAlpha(_isFavorite ? 54 : 34)
        : _isFavorite
        ? AppColors.favorite.withAlpha(24)
        : AppColors.hoverSurface(context);
    return AppIconButton(
      onPressed: _toggleFavorite,
      icon: icon,
      tooltip: _isFavorite ? "取消收藏" : "加入收藏",
      selected: _isFavorite,
      tone: overlayTone ? AppControlTone.overlay : AppControlTone.adaptive,
      selectedColor: AppColors.favorite,
      foregroundColor: baseColor,
      backgroundColor: backgroundColor,
      size: 44,
      iconSize: 22,
    );
  }
}
