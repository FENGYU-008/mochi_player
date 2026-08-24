import 'package:flutter/material.dart';

import 'package:mochi_player/core/ui/components/data_display/app_tag.dart';
import 'package:mochi_player/core/ui/theme/app_colors.dart';

/// Applies the media rating style while reusing the shared tag component.
class MediaRatingTag extends StatelessWidget {
  const MediaRatingTag({super.key, required this.rating});

  final double rating;

  @override
  Widget build(BuildContext context) {
    return AppTag(
      text: rating.toStringAsFixed(1),
      icon: Icons.star_rounded,
      backgroundColor: AppColors.rating,
      foregroundColor: Colors.black.withAlpha(220),
      outlined: false,
    );
  }
}
