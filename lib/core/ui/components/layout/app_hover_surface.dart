import 'package:flutter/material.dart';

/// A desktop-oriented clickable surface with hover/press feedback and no
/// Material ink splash.
class AppHoverSurface extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry padding;
  final Color backgroundColor;
  final Color hoverColor;
  final Color pressedColor;
  final Color? borderColor;
  final Color? hoverBorderColor;
  final double? width;
  final double? height;
  final Duration duration;

  const AppHoverSurface({
    super.key,
    required this.child,
    required this.borderRadius,
    required this.hoverColor,
    this.onTap,
    this.padding = EdgeInsets.zero,
    this.backgroundColor = Colors.transparent,
    Color? pressedColor,
    this.borderColor,
    this.hoverBorderColor,
    this.width,
    this.height,
    this.duration = const Duration(milliseconds: 140),
  }) : pressedColor = pressedColor ?? hoverColor;

  @override
  State<AppHoverSurface> createState() => _AppHoverSurfaceState();
}

class _AppHoverSurfaceState extends State<AppHoverSurface> {
  bool _hovering = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    // Keep transparent resting surfaces in the same color space as the hover
    // target. Otherwise ColorTween interpolates from transparent black, which
    // creates a muddy intermediate frame for light hover colors in dark mode.
    final restingColor = widget.backgroundColor.a == 0
        ? widget.hoverColor.withAlpha(0)
        : widget.backgroundColor;
    final backgroundColor = !enabled
        ? restingColor
        : _pressed
        ? widget.pressedColor
        : _hovering
        ? widget.hoverColor
        : restingColor;
    final restingBorderColor = switch ((
      widget.borderColor,
      widget.hoverBorderColor,
    )) {
      (final border?, final hoverBorder?) when border.a == 0 =>
        hoverBorder.withAlpha(0),
      (final border, _) => border,
    };
    final borderColor = enabled && _hovering
        ? widget.hoverBorderColor ?? restingBorderColor
        : restingBorderColor;

    return Semantics(
      button: enabled,
      enabled: enabled,
      child: MouseRegion(
        cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
        onEnter: enabled ? (_) => setState(() => _hovering = true) : null,
        onExit: enabled
            ? (_) => setState(() {
                _hovering = false;
                _pressed = false;
              })
            : null,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
          onTapUp: enabled ? (_) => setState(() => _pressed = false) : null,
          onTapCancel: enabled ? () => setState(() => _pressed = false) : null,
          child: AnimatedContainer(
            duration: widget.duration,
            curve: Curves.easeOutCubic,
            width: widget.width,
            height: widget.height,
            padding: widget.padding,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: widget.borderRadius,
              border: borderColor == null
                  ? null
                  : Border.all(color: borderColor),
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
