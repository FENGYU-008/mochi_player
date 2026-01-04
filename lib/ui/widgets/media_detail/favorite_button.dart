import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/media_library_provider.dart';

class FavoriteButton extends StatefulWidget {
  final String tmdbId;
  final Color? overrideColor;

  const FavoriteButton({super.key, required this.tmdbId, this.overrideColor});

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
          content: Text(
            _isFavorite ? 'Added to Favorites' : 'Removed from Favorites',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = widget.overrideColor ?? Colors.white;
    // 圆形按钮样式
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: baseColor.withAlpha((255 * 0.15).round()),
        border: Border.all(
          color: baseColor.withAlpha((255 * 0.4).round()),
          width: 1.5,
        ),
      ),
      child: IconButton(
        onPressed: _toggleFavorite,
        icon: Icon(
          _isFavorite ? Icons.favorite : Icons.favorite_border,
          color: _isFavorite ? Colors.red : baseColor,
          size: 26,
        ),
        padding: EdgeInsets.zero,
        tooltip: _isFavorite ? "Remove from Favorites" : "Add to Favorites",
      ),
    );
  }
}
