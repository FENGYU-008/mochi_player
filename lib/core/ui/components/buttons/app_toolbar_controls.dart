import 'package:flutter/material.dart';

import 'package:mochi_player/core/ui/components/layout/app_clickable_area.dart';
import 'package:mochi_player/core/ui/theme/app_colors.dart';
import 'package:mochi_player/core/ui/theme/app_radii.dart';

class AppToolbarGroup extends StatelessWidget {
  final List<Widget> children;

  const AppToolbarGroup({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      decoration: BoxDecoration(
        color: AppColors.selectControlSurface(context),
        borderRadius: BorderRadius.circular(AppRadii.surface),
        border: Border.all(color: AppColors.selectBorder(context)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(mainAxisSize: MainAxisSize.min, children: children),
    );
  }
}

class AppToolbarDivider extends StatelessWidget {
  const AppToolbarDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 34, color: AppColors.separator(context));
  }
}

class AppToolbarButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final bool selected;
  final bool showBorder;

  const AppToolbarButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.selected = false,
    this.showBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.primary(context);
    final neutralStateColor = AppColors.hoverSurface(context);
    final selectedSurface = AppColors.selectedSurface(context);
    final child = Tooltip(
      message: tooltip,
      child: AppClickableArea(
        onTap: onPressed,
        width: 36,
        height: 34,
        borderRadius: showBorder
            ? BorderRadius.circular(AppRadii.surface)
            : BorderRadius.zero,
        backgroundColor: selected ? selectedSurface : Colors.transparent,
        hoverColor: selected ? Colors.transparent : neutralStateColor,
        child: Icon(
          icon,
          size: 18,
          color: onPressed == null
              ? AppColors.textSecondary(context).withAlpha(90)
              : selected
              ? primary
              : AppColors.textPrimary(context),
        ),
      ),
    );
    if (!showBorder) return child;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.selectControlSurface(context),
        borderRadius: BorderRadius.circular(AppRadii.surface),
        border: Border.all(color: AppColors.selectBorder(context)),
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}
