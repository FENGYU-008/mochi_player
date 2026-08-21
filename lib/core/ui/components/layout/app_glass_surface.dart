import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:mochi_player/core/ui/theme/app_radii.dart';

class AppGlassSurface extends StatelessWidget {
  final Widget child;
  final BorderRadius borderRadius;
  final Color color;
  final Color borderColor;
  final double blur;
  final EdgeInsetsGeometry? padding;

  const AppGlassSurface({
    super.key,
    required this.child,
    this.borderRadius = const BorderRadius.all(
      Radius.circular(AppRadii.surface),
    ),
    this.color = const Color(0x33FFFFFF),
    this.borderColor = const Color(0x33FFFFFF),
    this.blur = 14,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: color,
            borderRadius: borderRadius,
            border: Border.all(color: borderColor),
          ),
          child: padding == null
              ? child
              : Padding(padding: padding!, child: child),
        ),
      ),
    );
  }
}
