import 'package:flutter/material.dart';

import 'package:mochi_player/core/ui/theme/app_colors.dart';
import 'package:mochi_player/core/ui/theme/app_radii.dart';

enum AppPanelTone { subtle, elevated }

class AppPanel extends StatelessWidget {
  final Widget child;
  final AppPanelTone tone;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry? padding;
  final bool showBorder;
  final Clip clipBehavior;

  const AppPanel({
    super.key,
    required this.child,
    this.tone = AppPanelTone.subtle,
    this.borderRadius = const BorderRadius.all(
      Radius.circular(AppRadii.control),
    ),
    this.padding,
    this.showBorder = false,
    this.clipBehavior = Clip.antiAlias,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor = tone == AppPanelTone.elevated
        ? AppColors.elevatedSurface(context)
        : AppColors.subtleSurface(context);
    final decoration = BoxDecoration(
      color: backgroundColor,
      borderRadius: borderRadius,
      border: showBorder
          ? Border.all(color: AppColors.separator(context))
          : null,
    );
    final content = DecoratedBox(
      decoration: decoration,
      child: padding == null ? child : Padding(padding: padding!, child: child),
    );

    if (clipBehavior == Clip.none) return content;
    return ClipRRect(
      borderRadius: borderRadius,
      clipBehavior: clipBehavior,
      child: content,
    );
  }
}
