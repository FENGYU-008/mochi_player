import 'package:flutter/material.dart';

import 'package:mochi_player/core/ui/theme/app_colors.dart';
import 'package:mochi_player/core/ui/theme/app_radii.dart';
import 'package:mochi_player/core/ui/theme/app_spacing.dart';

enum AppButtonVariant { primary, secondary }

enum AppControlTone { adaptive, overlay }

class AppActionButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String label;
  final AppButtonVariant variant;
  final AppControlTone tone;
  final bool destructive;
  final bool busy;
  final double height;
  final double borderRadius;
  final EdgeInsetsGeometry padding;

  const AppActionButton({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.label,
    this.variant = AppButtonVariant.primary,
    this.tone = AppControlTone.adaptive,
    this.destructive = false,
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
    final isDestructive = widget.destructive && !isPrimary;
    final primary = AppColors.primary(context);
    final danger = Colors.redAccent;
    final overlayTone = widget.tone == AppControlTone.overlay;
    final adaptiveSurface = AppColors.elevatedSurface(context);
    final adaptiveHoverSurface = Color.alphaBlend(
      AppColors.hoverSurface(context),
      adaptiveSurface,
    );
    final background = isPrimary
        ? primary
        : isDestructive
        ? danger.withAlpha(_isHovering ? 26 : 14)
        : overlayTone
        ? Colors.black.withAlpha(_isHovering ? 100 : 76)
        : _isHovering
        ? adaptiveHoverSurface
        : adaptiveSurface;
    final foreground = isPrimary
        ? Colors.white
        : isDestructive
        ? danger
        : overlayTone
        ? Colors.white.withAlpha(235)
        : AppColors.textPrimary(context).withAlpha(220);
    final borderColor = isPrimary
        ? Colors.transparent
        : isDestructive
        ? danger.withAlpha(_isHovering ? 190 : 128)
        : overlayTone
        ? Colors.white.withAlpha(_isHovering ? 92 : 58)
        : AppColors.separator(context);
    final disabledBackground = isPrimary
        ? primary.withAlpha(90)
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
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            curve: Curves.easeOut,
            height: widget.height,
            padding: widget.padding,
            decoration: BoxDecoration(
              color: enabled ? background : disabledBackground,
              borderRadius: BorderRadius.circular(widget.borderRadius),
              border: Border.all(color: borderColor),
              boxShadow: isPrimary && enabled
                  ? [
                      BoxShadow(
                        color: primary.withAlpha(_isHovering ? 78 : 46),
                        blurRadius: _isHovering ? 18 : 12,
                        offset: const Offset(0, 6),
                      ),
                    ]
                  : null,
            ),
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
                else
                  Icon(widget.icon, size: 19, color: foreground),
                const SizedBox(width: 8),
                Text(
                  widget.label,
                  style: TextStyle(
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
