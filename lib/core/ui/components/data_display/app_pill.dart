import 'package:flutter/material.dart';

import 'package:mochi_player/core/ui/components/buttons/app_action_button.dart';
import 'package:mochi_player/core/ui/theme/app_colors.dart';
import 'package:mochi_player/core/ui/theme/app_radii.dart';
import 'package:mochi_player/core/ui/theme/app_spacing.dart';

class AppPill extends StatelessWidget {
  final String text;
  final IconData? icon;
  final bool rating;
  final AppControlAppearance appearance;

  const AppPill({
    super.key,
    required this.text,
    this.icon,
    this.rating = false,
    this.appearance = AppControlAppearance.adaptive,
  });

  @override
  Widget build(BuildContext context) {
    final usesOverlayAppearance = appearance == AppControlAppearance.overlay;
    final background = rating
        ? AppColors.rating
        : usesOverlayAppearance
        ? Colors.white.withAlpha(42)
        : AppColors.elevatedSurface(context);
    final foreground = rating
        ? Colors.black.withAlpha(220)
        : usesOverlayAppearance
        ? Colors.white
        : AppColors.textPrimary(context).withAlpha(220);
    final borderColor = usesOverlayAppearance
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
