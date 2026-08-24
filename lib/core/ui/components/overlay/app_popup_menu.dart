import 'package:flutter/material.dart';

import 'package:mochi_player/core/ui/components/basic/app_clickable_area.dart';
import 'package:mochi_player/core/ui/theme/app_colors.dart';
import 'package:mochi_player/core/ui/theme/app_radii.dart';

abstract final class AppPopupMenuMetrics {
  static const itemHeight = 36.0;
  static const panelPadding = 6.0;
}

/// Shared visual container for application-owned popup menus.
class AppPopupMenuPanel extends StatelessWidget {
  final List<Widget> children;

  const AppPopupMenuPanel({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    final shadowColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.black.withAlpha(112)
        : Colors.black.withAlpha(28);
    return DefaultTextStyle(
      style: TextStyle(
        color: AppColors.textPrimary(context),
        fontSize: 13,
        fontWeight: FontWeight.w500,
        decoration: TextDecoration.none,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.selectMenuSurface(context),
          borderRadius: BorderRadius.circular(AppRadii.control),
          border: Border.all(color: AppColors.selectBorder(context)),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppPopupMenuMetrics.panelPadding),
          child: Column(mainAxisSize: MainAxisSize.min, children: children),
        ),
      ),
    );
  }
}

/// Shared splash-free interaction row for popup menu commands.
class AppPopupMenuItem extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;

  const AppPopupMenuItem({
    super.key,
    required this.onPressed,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AppClickableArea(
      onTap: onPressed,
      height: AppPopupMenuMetrics.itemHeight,
      borderRadius: BorderRadius.circular(AppRadii.small),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      hoverColor: AppColors.hoverSurface(context),
      child: child,
    );
  }
}
