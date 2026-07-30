import 'package:flutter/material.dart';

import 'package:mochi_player/core/ui/theme/app_colors.dart';
import 'package:mochi_player/core/ui/theme/app_radii.dart';

enum AppSurfaceTone { subtle, elevated }

class AppSurface extends StatelessWidget {
  final Widget child;
  final AppSurfaceTone tone;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry? padding;
  final bool showBorder;
  final VoidCallback? onTap;
  final Clip clipBehavior;

  const AppSurface({
    super.key,
    required this.child,
    this.tone = AppSurfaceTone.subtle,
    this.borderRadius = const BorderRadius.all(
      Radius.circular(AppRadii.control),
    ),
    this.padding,
    this.showBorder = false,
    this.onTap,
    this.clipBehavior = Clip.antiAlias,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final backgroundColor = tone == AppSurfaceTone.elevated
        ? AppColors.elevatedSurface(context)
        : theme.brightness == Brightness.dark
        ? Colors.white.withAlpha(12)
        : Colors.black.withAlpha(6);
    final decoration = BoxDecoration(
      color: backgroundColor,
      borderRadius: borderRadius,
      border: showBorder
          ? Border.all(color: AppColors.separator(context))
          : null,
    );
    final paddedChild = padding == null
        ? child
        : Padding(padding: padding!, child: child);
    final content = onTap == null
        ? DecoratedBox(decoration: decoration, child: paddedChild)
        : DecoratedBox(
            decoration: decoration,
            child: Material(
              color: Colors.transparent,
              borderRadius: borderRadius,
              clipBehavior: clipBehavior,
              child: InkWell(
                onTap: onTap,
                borderRadius: borderRadius,
                child: paddedChild,
              ),
            ),
          );

    if (clipBehavior == Clip.none) return content;
    return ClipRRect(
      borderRadius: borderRadius,
      clipBehavior: clipBehavior,
      child: content,
    );
  }
}
