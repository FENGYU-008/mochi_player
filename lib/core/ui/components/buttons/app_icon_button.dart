import 'package:flutter/material.dart';

import 'package:mochi_player/core/ui/theme/app_colors.dart';
import 'app_button.dart';

class AppIconButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String tooltip;
  final bool selected;
  final AppControlTone tone;
  final Color? selectedColor;
  final Color? foregroundColor;
  final Color? backgroundColor;
  final Color? hoverBackgroundColor;
  final Color? borderColor;
  final double size;
  final double iconSize;

  const AppIconButton({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.tooltip,
    this.selected = false,
    this.tone = AppControlTone.adaptive,
    this.selectedColor,
    this.foregroundColor,
    this.backgroundColor,
    this.hoverBackgroundColor,
    this.borderColor,
    this.size = 40,
    this.iconSize = 20,
  });

  @override
  State<AppIconButton> createState() => _AppIconButtonState();
}

class _AppIconButtonState extends State<AppIconButton> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    final overlayTone = widget.tone == AppControlTone.overlay;
    final selectedColor = widget.selectedColor ?? AppColors.primary(context);
    final foreground = widget.selected
        ? selectedColor
        : widget.foregroundColor ??
              AppColors.textPrimary(context).withAlpha(214);
    final restingBackground =
        widget.backgroundColor ??
        (widget.selected
            ? selectedColor.withAlpha(22)
            : overlayTone
            ? Colors.white.withAlpha(34)
            : AppColors.hoverSurface(context));
    final hoverBackground =
        widget.hoverBackgroundColor ??
        widget.backgroundColor ??
        (widget.selected
            ? selectedColor.withAlpha(34)
            : overlayTone
            ? Colors.white.withAlpha(50)
            : Color.alphaBlend(
                AppColors.hoverSurface(context),
                restingBackground,
              ));
    final borderColor =
        widget.borderColor ??
        (widget.selected
            ? selectedColor.withAlpha(90)
            : overlayTone
            ? Colors.white.withAlpha(56)
            : AppColors.separator(context));

    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovering = true),
        onExit: (_) => setState(() => _isHovering = false),
        cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
        child: GestureDetector(
          onTap: widget.onPressed,
          child: TweenAnimationBuilder<double>(
            tween: Tween(end: _isHovering && enabled ? 1 : 0),
            duration: const Duration(milliseconds: 140),
            curve: Curves.easeOut,
            builder: (context, hoverProgress, child) {
              final background = Color.lerp(
                restingBackground,
                hoverBackground,
                hoverProgress,
              )!;
              return Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  color: enabled ? background : background.withAlpha(80),
                  shape: BoxShape.circle,
                  border: Border.all(color: borderColor),
                ),
                child: child,
              );
            },
            child: Icon(widget.icon, size: widget.iconSize, color: foreground),
          ),
        ),
      ),
    );
  }
}
