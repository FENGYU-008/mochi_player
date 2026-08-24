import 'package:flutter/material.dart';

import 'package:mochi_player/core/ui/components/basic/app_appearance.dart';
import 'package:mochi_player/core/ui/theme/app_colors.dart';
import 'package:mochi_player/core/ui/theme/app_radii.dart';
import 'package:mochi_player/core/ui/theme/app_spacing.dart';

enum AppButtonVariant { primary, secondary }

/// The shared application button API for labeled and icon-only actions.
class AppButton extends StatefulWidget {
  const AppButton({
    super.key,
    required this.onPressed,
    required this.label,
    IconData? icon,
    this.textStyle,
    this.iconColor,
    this.variant = AppButtonVariant.primary,
    this.appearance = AppAppearance.standard,
    this.destructive = false,
    this.selected = false,
    this.accentColor,
    this.busy = false,
    this.height = 44,
    this.borderRadius = AppRadii.surface,
    this.padding = const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
  }) : _leadingIcon = icon,
       _onlyIcon = null,
       tooltip = null,
       selectedColor = null,
       foregroundColor = null,
       backgroundColor = null,
       hoverBackgroundColor = null,
       borderColor = null,
       size = 40,
       iconSize = 19;

  const AppButton.icon({
    super.key,
    required this.onPressed,
    required IconData icon,
    this.tooltip,
    this.selected = false,
    this.appearance = AppAppearance.standard,
    this.selectedColor,
    this.foregroundColor,
    this.backgroundColor,
    this.hoverBackgroundColor,
    this.borderColor,
    this.size = 40,
    this.iconSize = 20,
  }) : label = '',
       _leadingIcon = null,
       _onlyIcon = icon,
       textStyle = null,
       iconColor = null,
       variant = AppButtonVariant.secondary,
       destructive = false,
       accentColor = null,
       busy = false,
       height = 40,
       borderRadius = AppRadii.full,
       padding = EdgeInsets.zero;

  final VoidCallback? onPressed;
  final String label;
  final IconData? _leadingIcon;
  final IconData? _onlyIcon;
  final String? tooltip;
  final TextStyle? textStyle;
  final Color? iconColor;
  final AppButtonVariant variant;
  final AppAppearance appearance;
  final bool destructive;
  final bool selected;
  final Color? accentColor;
  final bool busy;
  final double height;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final Color? selectedColor;
  final Color? foregroundColor;
  final Color? backgroundColor;
  final Color? hoverBackgroundColor;
  final Color? borderColor;
  final double size;
  final double iconSize;

  bool get _iconOnly => _onlyIcon != null;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _isHovering = false;

  bool get _enabled => widget.onPressed != null && !widget.busy;

  @override
  Widget build(BuildContext context) {
    final button = MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      cursor: _enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: _enabled ? widget.onPressed : null,
        child: widget._iconOnly
            ? _buildIconButton(context)
            : _buildLabeledButton(context),
      ),
    );

    final tooltip = widget.tooltip;
    if (!widget._iconOnly || tooltip == null || tooltip.isEmpty) return button;
    return Tooltip(message: tooltip, child: button);
  }

  Widget _buildLabeledButton(BuildContext context) {
    final isPrimary = widget.variant == AppButtonVariant.primary;
    final actionColor = widget.destructive
        ? Colors.redAccent
        : widget.accentColor ?? AppColors.primary(context);
    final adaptiveSurface = AppColors.elevatedSurface(context);
    final palette = _AppButtonPalette.resolve(
      context: context,
      actionColor: actionColor,
      isPrimary: isPrimary,
      isDestructive: widget.destructive,
      isOverlay: widget.appearance == AppAppearance.overlay,
      isSelected: widget.selected,
      adaptiveSurface: adaptiveSurface,
      adaptiveHoverSurface: Color.alphaBlend(
        AppColors.hoverSurface(context),
        adaptiveSurface,
      ),
    );

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 120),
      opacity: _enabled ? 1 : 0.45,
      child: TweenAnimationBuilder<double>(
        tween: Tween(end: _isHovering && _enabled ? 1 : 0),
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        builder: (context, hoverProgress, child) {
          return Container(
            height: widget.height,
            padding: widget.padding,
            decoration: BoxDecoration(
              color: _enabled
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
              boxShadow: isPrimary && _enabled
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
            else if (widget._leadingIcon != null)
              Icon(
                widget._leadingIcon,
                size: widget.iconSize,
                color: widget.iconColor ?? palette.foreground,
              ),
            if (widget.busy || widget._leadingIcon != null)
              const SizedBox(width: AppSpacing.xs),
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
    );
  }

  Widget _buildIconButton(BuildContext context) {
    final selectedColor = widget.selectedColor ?? AppColors.primary(context);
    final foreground = widget.selected
        ? selectedColor
        : widget.foregroundColor ??
              AppColors.textPrimary(context).withAlpha(214);
    final usesOverlayAppearance = widget.appearance == AppAppearance.overlay;
    final restingBackground =
        widget.backgroundColor ??
        (widget.selected
            ? selectedColor.withAlpha(22)
            : usesOverlayAppearance
            ? Colors.white.withAlpha(34)
            : AppColors.hoverSurface(context));
    final hoverBackground =
        widget.hoverBackgroundColor ??
        widget.backgroundColor ??
        (widget.selected
            ? selectedColor.withAlpha(34)
            : usesOverlayAppearance
            ? Colors.white.withAlpha(50)
            : Color.alphaBlend(
                AppColors.hoverSurface(context),
                restingBackground,
              ));
    final borderColor =
        widget.borderColor ??
        (widget.selected
            ? selectedColor.withAlpha(90)
            : usesOverlayAppearance
            ? Colors.white.withAlpha(56)
            : AppColors.separator(context));

    return TweenAnimationBuilder<double>(
      tween: Tween(end: _isHovering && _enabled ? 1 : 0),
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
            color: _enabled ? background : background.withAlpha(80),
            shape: BoxShape.circle,
            border: Border.all(color: borderColor),
          ),
          child: child,
        );
      },
      child: Icon(widget._onlyIcon, size: widget.iconSize, color: foreground),
    );
  }
}

class _AppButtonPalette {
  const _AppButtonPalette({
    required this.restingBackground,
    required this.hoverBackground,
    required this.disabledBackground,
    required this.foreground,
    required this.restingBorder,
    required this.hoverBorder,
  });

  final Color restingBackground;
  final Color hoverBackground;
  final Color disabledBackground;
  final Color foreground;
  final Color restingBorder;
  final Color hoverBorder;

  factory _AppButtonPalette.resolve({
    required BuildContext context,
    required Color actionColor,
    required bool isPrimary,
    required bool isDestructive,
    required bool isOverlay,
    required bool isSelected,
    required Color adaptiveSurface,
    required Color adaptiveHoverSurface,
  }) {
    if (isPrimary) {
      return _AppButtonPalette(
        restingBackground: actionColor,
        hoverBackground: actionColor,
        disabledBackground: actionColor.withAlpha(90),
        foreground: Colors.white,
        restingBorder: Colors.transparent,
        hoverBorder: Colors.transparent,
      );
    }
    if (isDestructive) {
      return _AppButtonPalette(
        restingBackground: Colors.redAccent.withAlpha(14),
        hoverBackground: Colors.redAccent.withAlpha(26),
        disabledBackground: Colors.redAccent.withAlpha(14),
        foreground: Colors.redAccent,
        restingBorder: Colors.redAccent.withAlpha(128),
        hoverBorder: Colors.redAccent.withAlpha(190),
      );
    }
    if (isOverlay) {
      return _AppButtonPalette(
        restingBackground: Colors.black.withAlpha(76),
        hoverBackground: Colors.black.withAlpha(100),
        disabledBackground: Colors.black.withAlpha(42),
        foreground: Colors.white.withAlpha(235),
        restingBorder: Colors.white.withAlpha(58),
        hoverBorder: Colors.white.withAlpha(92),
      );
    }
    if (isSelected) {
      return _AppButtonPalette(
        restingBackground: actionColor.withAlpha(28),
        hoverBackground: actionColor.withAlpha(42),
        disabledBackground: AppColors.hoverSurface(context),
        foreground: actionColor,
        restingBorder: actionColor.withAlpha(150),
        hoverBorder: actionColor.withAlpha(190),
      );
    }
    return _AppButtonPalette(
      restingBackground: adaptiveSurface,
      hoverBackground: adaptiveHoverSurface,
      disabledBackground: AppColors.hoverSurface(context),
      foreground: AppColors.textPrimary(context).withAlpha(220),
      restingBorder: AppColors.separator(context),
      hoverBorder: AppColors.separator(context),
    );
  }
}
