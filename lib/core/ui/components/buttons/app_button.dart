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
    final selectedOverlay = overlayTone && widget.selected && !isPrimary;
    final adaptiveSurface = AppColors.elevatedSurface(context);
    final adaptiveHoverSurface = Color.alphaBlend(
      AppColors.hoverSurface(context),
      adaptiveSurface,
    );
    final restingBackground = isPrimary
        ? actionColor
        : isDestructive
        ? danger.withAlpha(14)
        : selectedOverlay
        ? Colors.black.withAlpha(76)
        : widget.selected
        ? actionColor.withAlpha(28)
        : overlayTone
        ? Colors.black.withAlpha(76)
        : adaptiveSurface;
    final hoverBackground = isPrimary
        ? actionColor
        : isDestructive
        ? danger.withAlpha(26)
        : selectedOverlay
        ? Colors.black.withAlpha(100)
        : widget.selected
        ? actionColor.withAlpha(42)
        : overlayTone
        ? Colors.black.withAlpha(100)
        : adaptiveHoverSurface;
    final foreground = isPrimary
        ? Colors.white
        : isDestructive
        ? danger
        : selectedOverlay
        ? Colors.white.withAlpha(235)
        : widget.selected
        ? actionColor
        : overlayTone
        ? Colors.white.withAlpha(235)
        : AppColors.textPrimary(context).withAlpha(220);
    final restingBorderColor = isPrimary
        ? Colors.transparent
        : isDestructive
        ? danger.withAlpha(128)
        : selectedOverlay
        ? Colors.white.withAlpha(58)
        : widget.selected
        ? actionColor.withAlpha(150)
        : overlayTone
        ? Colors.white.withAlpha(58)
        : AppColors.separator(context);
    final hoverBorderColor = isPrimary
        ? Colors.transparent
        : isDestructive
        ? danger.withAlpha(190)
        : selectedOverlay
        ? Colors.white.withAlpha(92)
        : widget.selected
        ? actionColor.withAlpha(190)
        : overlayTone
        ? Colors.white.withAlpha(92)
        : AppColors.separator(context);
    final disabledBackground = isPrimary
        ? actionColor.withAlpha(90)
        : isDestructive
        ? danger.withAlpha(14)
        : overlayTone
        ? Colors.black.withAlpha(42)
        : AppColors.hoverSurface(context);

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
                          restingBackground,
                          hoverBackground,
                          hoverProgress,
                        )
                      : disabledBackground,
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  border: Border.all(
                    color: Color.lerp(
                      restingBorderColor,
                      hoverBorderColor,
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
                      color: foreground,
                    ),
                  )
                else if (widget.icon != null)
                  Icon(
                    widget.icon,
                    size: 19,
                    color: widget.iconColor ?? foreground,
                  ),
                if (widget.busy || widget.icon != null)
                  const SizedBox(width: 8),
                Text(
                  widget.label,
                  style:
                      widget.textStyle?.copyWith(color: foreground) ??
                      TextStyle(
                        color: foreground,
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
