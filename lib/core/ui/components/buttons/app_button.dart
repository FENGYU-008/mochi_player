import 'package:flutter/material.dart';

import 'package:mochi_player/core/ui/theme/app_colors.dart';
import 'package:mochi_player/core/ui/theme/app_radii.dart';
import 'package:mochi_player/core/ui/theme/app_spacing.dart';

enum AppButtonVariant { primary, secondary }

enum AppControlTone { adaptive, overlay }

class AppActionButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final IconData? icon;
  final String label;
  final TextStyle? textStyle;
  final Color? iconColor;
  final AppButtonVariant variant;
  final AppControlTone tone;
  final bool destructive;
  final bool selected;
  final Color? accentColor;
  final bool busy;
  final double height;
  final double borderRadius;
  final EdgeInsetsGeometry padding;

  const AppActionButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.icon,
    this.textStyle,
    this.iconColor,
    this.variant = AppButtonVariant.primary,
    this.tone = AppControlTone.adaptive,
    this.destructive = false,
    this.selected = false,
    this.accentColor,
    this.busy = false,
    this.height = 44,
    this.borderRadius = AppRadii.surface,
    this.padding = const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
  });

  @override
  State<AppActionButton> createState() => _AppActionButtonState();
}

class _AppActionButtonState extends State<AppActionButton> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null && !widget.busy;
    final isPrimary = widget.variant == AppButtonVariant.primary;
    final isDestructive = widget.destructive;
    final primary = AppColors.primary(context);
    final danger = Colors.redAccent;
    final actionColor = isDestructive ? danger : widget.accentColor ?? primary;
    final overlayTone = widget.tone == AppControlTone.overlay;
    final adaptiveSurface = AppColors.elevatedSurface(context);
    final adaptiveHoverSurface = Color.alphaBlend(
      AppColors.hoverSurface(context),
      adaptiveSurface,
    );
    final palette = _AppActionButtonPalette.resolve(
      context: context,
      actionColor: actionColor,
      dangerColor: danger,
      isPrimary: isPrimary,
      isDestructive: isDestructive,
      isOverlay: overlayTone,
      isSelected: widget.selected,
      adaptiveSurface: adaptiveSurface,
      adaptiveHoverSurface: adaptiveHoverSurface,
    );

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: enabled ? widget.onPressed : null,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 120),
          opacity: enabled ? 1 : 0.45,
          child: TweenAnimationBuilder<double>(
            tween: Tween(end: _isHovering && enabled ? 1 : 0),
            duration: const Duration(milliseconds: 140),
            curve: Curves.easeOut,
            builder: (context, hoverProgress, child) {
              return Container(
                height: widget.height,
                padding: widget.padding,
                decoration: BoxDecoration(
                  color: enabled
                      ? Color.lerp(
                          palette.restingBackground,
                          palette.hoverBackground,
                          hoverProgress,
                        )
                      : palette.disabledBackground,
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  border: Border.all(
                    color: Color.lerp(
                      palette.restingBorder,
                      palette.hoverBorder,
                      hoverProgress,
                    )!,
                  ),
                  boxShadow: isPrimary && enabled
                      ? [
                          BoxShadow(
                            color: actionColor.withAlpha(
                              (46 + (32 * hoverProgress)).round(),
                            ),
                            blurRadius: 12 + (6 * hoverProgress),
                            offset: const Offset(0, 6),
                          ),
                        ]
                      : null,
                ),
                child: child,
              );
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.busy)
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: palette.foreground,
                    ),
                  )
                else if (widget.icon != null)
                  Icon(
                    widget.icon,
                    size: 19,
                    color: widget.iconColor ?? palette.foreground,
                  ),
                if (widget.busy || widget.icon != null)
                  const SizedBox(width: 8),
                Text(
                  widget.label,
                  style:
                      widget.textStyle?.copyWith(color: palette.foreground) ??
                      TextStyle(
                        color: palette.foreground,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        height: 1,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AppActionButtonPalette {
  final Color restingBackground;
  final Color hoverBackground;
  final Color disabledBackground;
  final Color foreground;
  final Color restingBorder;
  final Color hoverBorder;

  const _AppActionButtonPalette({
    required this.restingBackground,
    required this.hoverBackground,
    required this.disabledBackground,
    required this.foreground,
    required this.restingBorder,
    required this.hoverBorder,
  });

  factory _AppActionButtonPalette.resolve({
    required BuildContext context,
    required Color actionColor,
    required Color dangerColor,
    required bool isPrimary,
    required bool isDestructive,
    required bool isOverlay,
    required bool isSelected,
    required Color adaptiveSurface,
    required Color adaptiveHoverSurface,
  }) {
    if (isPrimary) {
      return _AppActionButtonPalette(
        restingBackground: actionColor,
        hoverBackground: actionColor,
        disabledBackground: actionColor.withAlpha(90),
        foreground: Colors.white,
        restingBorder: Colors.transparent,
        hoverBorder: Colors.transparent,
      );
    }
    if (isDestructive) {
      return _AppActionButtonPalette(
        restingBackground: dangerColor.withAlpha(14),
        hoverBackground: dangerColor.withAlpha(26),
        disabledBackground: dangerColor.withAlpha(14),
        foreground: dangerColor,
        restingBorder: dangerColor.withAlpha(128),
        hoverBorder: dangerColor.withAlpha(190),
      );
    }
    if (isOverlay) {
      return _AppActionButtonPalette(
        restingBackground: Colors.black.withAlpha(76),
        hoverBackground: Colors.black.withAlpha(100),
        disabledBackground: Colors.black.withAlpha(42),
        foreground: Colors.white.withAlpha(235),
        restingBorder: Colors.white.withAlpha(58),
        hoverBorder: Colors.white.withAlpha(92),
      );
    }
    if (isSelected) {
      return _AppActionButtonPalette(
        restingBackground: actionColor.withAlpha(28),
        hoverBackground: actionColor.withAlpha(42),
        disabledBackground: AppColors.hoverSurface(context),
        foreground: actionColor,
        restingBorder: actionColor.withAlpha(150),
        hoverBorder: actionColor.withAlpha(190),
      );
    }
    return _AppActionButtonPalette(
      restingBackground: adaptiveSurface,
      hoverBackground: adaptiveHoverSurface,
      disabledBackground: AppColors.hoverSurface(context),
      foreground: AppColors.textPrimary(context).withAlpha(220),
      restingBorder: AppColors.separator(context),
      hoverBorder: AppColors.separator(context),
    );
  }
}
