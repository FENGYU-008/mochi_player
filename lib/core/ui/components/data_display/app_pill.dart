import 'package:flutter/material.dart';

import 'package:mochi_player/core/ui/components/buttons/app_button.dart';
import 'package:mochi_player/core/ui/theme/app_colors.dart';
import 'package:mochi_player/core/ui/theme/app_radii.dart';
import 'package:mochi_player/core/ui/theme/app_spacing.dart';

class AppPill extends StatelessWidget {
  final String text;
  final IconData? icon;
  final bool rating;
  final AppControlTone tone;

  const AppPill({
    super.key,
    required this.text,
    this.icon,
    this.rating = false,
    this.tone = AppControlTone.adaptive,
  });

  @override
  Widget build(BuildContext context) {
    final overlayTone = tone == AppControlTone.overlay;
    final background = rating
        ? AppColors.rating
        : overlayTone
        ? Colors.white.withAlpha(42)
        : AppColors.elevatedSurface(context);
    final foreground = rating
        ? Colors.black.withAlpha(220)
        : overlayTone
        ? Colors.white
        : AppColors.textPrimary(context).withAlpha(220);
    final borderColor = overlayTone
        ? Colors.white.withAlpha(44)
        : AppColors.separator(context);

    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.compact),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadii.chip),
        border: rating ? null : Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 15, color: foreground),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              color: foreground,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}
