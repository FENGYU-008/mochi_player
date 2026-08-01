import 'package:flutter/material.dart';

/// Makes an entire desktop UI area clickable with hover-only feedback and no
/// Material ink splash or pressed-state highlight.
class AppClickableArea extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry padding;
  final Color backgroundColor;
  final Color hoverColor;
  final Color? borderColor;
  final Color? hoverBorderColor;
  final double? width;
  final double? height;
  final Duration duration;

  const AppClickableArea({
    super.key,
    required this.child,
    required this.borderRadius,
    required this.hoverColor,
    this.onTap,
    this.padding = EdgeInsets.zero,
    this.backgroundColor = Colors.transparent,
    this.borderColor,
    this.hoverBorderColor,
    this.width,
    this.height,
    this.duration = const Duration(milliseconds: 140),
  });

  @override
  State<AppClickableArea> createState() => _AppClickableAreaState();
}

class _AppClickableAreaState extends State<AppClickableArea> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    // Keep transparent resting surfaces in the same color space as the hover
    // target. Otherwise ColorTween interpolates from transparent black, which
    // creates a muddy intermediate frame for light hover colors in dark mode.
    final restingColor = widget.backgroundColor.a == 0
        ? widget.hoverColor.withAlpha(0)
        : widget.backgroundColor;
    final hoverColor = widget.backgroundColor.a == 0
        ? widget.hoverColor
        : Color.alphaBlend(widget.hoverColor, widget.backgroundColor);
    final restingBorderColor = switch ((
      widget.borderColor,
      widget.hoverBorderColor,
    )) {
      (final border?, final hoverBorder?) when border.a == 0 =>
        hoverBorder.withAlpha(0),
      (final border, _) => border,
    };
    final hoverBorderColor = widget.hoverBorderColor ?? restingBorderColor;

    return Semantics(
      button: enabled,
      enabled: enabled,
      child: MouseRegion(
        cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
        onEnter: enabled ? (_) => setState(() => _hovering = true) : null,
        onExit: enabled ? (_) => setState(() => _hovering = false) : null,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          child: TweenAnimationBuilder<double>(
            // Only pointer entry and exit own this animation. Changes to
            // selection, page, or view state update the endpoints immediately
            // instead of producing a second implicit color transition.
            tween: Tween(end: enabled && _hovering ? 1 : 0),
            duration: widget.duration,
            curve: Curves.easeOutCubic,
            builder: (context, hoverProgress, child) => Container(
              width: widget.width,
              height: widget.height,
              padding: widget.padding,
              decoration: BoxDecoration(
                color: Color.lerp(restingColor, hoverColor, hoverProgress),
                borderRadius: widget.borderRadius,
                border: restingBorderColor == null
                    ? null
                    : Border.all(
                        color: Color.lerp(
                          restingBorderColor,
                          hoverBorderColor,
                          hoverProgress,
                        )!,
                      ),
              ),
              child: child,
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
