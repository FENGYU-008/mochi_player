import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/media_library_provider.dart';
import '../../theme/app_colors.dart';
import '../macos_controls.dart';

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
      return _FavoriteLabelButton(
        onPressed: _toggleFavorite,
        icon: icon,
        label: _isFavorite ? '已收藏' : '加入收藏',
        selected: _isFavorite,
        overlayTone: overlayTone,
      );
    }

    final backgroundColor = overlayTone
        ? Colors.white.withAlpha(_isFavorite ? 54 : 34)
        : _isFavorite
        ? AppColors.favorite.withAlpha(24)
        : AppColors.hoverSurface(context);
    return MacosIconButton(
      onPressed: _toggleFavorite,
      icon: icon,
      tooltip: _isFavorite ? "取消收藏" : "加入收藏",
      selected: _isFavorite,
      tone: overlayTone ? MacosControlTone.overlay : MacosControlTone.adaptive,
      selectedColor: AppColors.favorite,
      foregroundColor: baseColor,
      backgroundColor: backgroundColor,
      size: 44,
      iconSize: 22,
    );
  }
}

class _FavoriteLabelButton extends StatefulWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String label;
  final bool selected;
  final bool overlayTone;

  const _FavoriteLabelButton({
    required this.onPressed,
    required this.icon,
    required this.label,
    required this.selected,
    required this.overlayTone,
  });

  @override
  State<_FavoriteLabelButton> createState() => _FavoriteLabelButtonState();
}

class _FavoriteLabelButtonState extends State<_FavoriteLabelButton> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final selectedColor = AppColors.favorite;
    final foreground = widget.selected
        ? selectedColor
        : widget.overlayTone
        ? Colors.white.withAlpha(235)
        : AppColors.textPrimary(context).withAlpha(220);
    final background = widget.overlayTone
        ? Colors.black.withAlpha(_hovering ? 100 : 76)
        : Color.alphaBlend(
            AppColors.hoverSurface(context),
            AppColors.elevatedSurface(context),
          );
    final borderColor = widget.selected
        ? selectedColor.withAlpha(widget.overlayTone ? 170 : 120)
        : widget.overlayTone
        ? Colors.white.withAlpha(_hovering ? 92 : 58)
        : AppColors.separator(context);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOut,
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, size: 18, color: foreground),
              const SizedBox(width: 8),
              Text(
                widget.label,
                style: TextStyle(
                  color: foreground,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
