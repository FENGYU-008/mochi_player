import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Makes an entire desktop UI area clickable with hover and keyboard-focus
/// feedback, without Material ink splash or pressed-state highlight.
class AppClickableArea extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry padding;
  final Color backgroundColor;
  final Color hoverColor;
  final Color? borderColor;
  final double? width;
  final double? height;

  const AppClickableArea({
    super.key,
    required this.child,
    required this.borderRadius,
    required this.hoverColor,
    this.onTap,
    this.padding = EdgeInsets.zero,
    this.backgroundColor = Colors.transparent,
    this.borderColor,
    this.width,
    this.height,
  });

  @override
  State<AppClickableArea> createState() => _AppClickableAreaState();
}

class _AppClickableAreaState extends State<AppClickableArea> {
  bool _hovering = false;
  bool _focused = false;

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
    final borderColor = widget.borderColor;

    return Semantics(
      button: enabled,
      enabled: enabled,
      onTap: widget.onTap,
      child: MouseRegion(
        cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
        onEnter: enabled ? (_) => setState(() => _hovering = true) : null,
        onExit: enabled ? (_) => setState(() => _hovering = false) : null,
        child: FocusableActionDetector(
          enabled: enabled,
          onShowFocusHighlight: (value) => setState(() => _focused = value),
          shortcuts: const {
            SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
            SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
          },
          actions: {
            ActivateIntent: CallbackAction<ActivateIntent>(
              onInvoke: (_) {
                widget.onTap?.call();
                return null;
              },
            ),
          },
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.onTap,
            child: TweenAnimationBuilder<double>(
              // Only pointer entry, exit, and keyboard focus own this
              // animation. External selection changes update immediately.
              tween: Tween(end: enabled && (_hovering || _focused) ? 1 : 0),
              duration: const Duration(milliseconds: 140),
              curve: Curves.easeOutCubic,
              builder: (context, hoverProgress, child) => Container(
                width: widget.width,
                height: widget.height,
                padding: widget.padding,
                decoration: BoxDecoration(
                  color: Color.lerp(restingColor, hoverColor, hoverProgress),
                  borderRadius: widget.borderRadius,
                  border: borderColor == null
                      ? null
                      : Border.all(color: borderColor),
                ),
                child: child,
              ),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}
