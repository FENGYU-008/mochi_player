import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

enum MacosButtonStyle { primary, secondary }

enum MacosControlTone { adaptive, overlay }

class MacosActionButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String label;
  final MacosButtonStyle style;
  final MacosControlTone tone;
  final double height;
  final double borderRadius;
  final EdgeInsetsGeometry padding;

  const MacosActionButton({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.label,
    this.style = MacosButtonStyle.primary,
    this.tone = MacosControlTone.adaptive,
    this.height = 44,
    this.borderRadius = 10,
    this.padding = const EdgeInsets.symmetric(horizontal: 20),
  });

  @override
  State<MacosActionButton> createState() => _MacosActionButtonState();
}

class _MacosActionButtonState extends State<MacosActionButton> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    final isPrimary = widget.style == MacosButtonStyle.primary;
    final primary = AppColors.primary(context);
    final overlayTone = widget.tone == MacosControlTone.overlay;
    final adaptiveSurface = AppColors.elevatedSurface(context);
    final adaptiveHoverSurface = Color.alphaBlend(
      AppColors.hoverSurface(context),
      adaptiveSurface,
    );
    final background = isPrimary
        ? primary
        : overlayTone
        ? Colors.black.withAlpha(_isHovering ? 100 : 76)
        : _isHovering
        ? adaptiveHoverSurface
        : adaptiveSurface;
    final foreground = isPrimary
        ? Colors.white
        : overlayTone
        ? Colors.white.withAlpha(235)
        : AppColors.textPrimary(context).withAlpha(220);
    final borderColor = isPrimary
        ? Colors.transparent
        : overlayTone
        ? Colors.white.withAlpha(_isHovering ? 92 : 58)
        : AppColors.separator(context);
    final disabledBackground = isPrimary
        ? primary.withAlpha(90)
        : overlayTone
        ? Colors.black.withAlpha(42)
        : AppColors.hoverSurface(context);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: widget.onPressed,
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

class MacosIconButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String tooltip;
  final bool selected;
  final MacosControlTone tone;
  final Color? selectedColor;
  final Color? foregroundColor;
  final Color? backgroundColor;
  final Color? borderColor;
  final double size;
  final double iconSize;

  const MacosIconButton({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.tooltip,
    this.selected = false,
    this.tone = MacosControlTone.adaptive,
    this.selectedColor,
    this.foregroundColor,
    this.backgroundColor,
    this.borderColor,
    this.size = 40,
    this.iconSize = 20,
  });

  @override
  State<MacosIconButton> createState() => _MacosIconButtonState();
}

class _MacosIconButtonState extends State<MacosIconButton> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    final overlayTone = widget.tone == MacosControlTone.overlay;
    final selectedColor = widget.selectedColor ?? AppColors.primary(context);
    final foreground = widget.selected
        ? selectedColor
        : widget.foregroundColor ??
              AppColors.textPrimary(context).withAlpha(214);
    final background =
        widget.backgroundColor ??
        (widget.selected
            ? selectedColor.withAlpha(22)
            : overlayTone
            ? Colors.white.withAlpha(_isHovering ? 50 : 34)
            : AppColors.hoverSurface(context));
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
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: enabled ? background : background.withAlpha(80),
              shape: BoxShape.circle,
              border: Border.all(color: borderColor),
            ),
            child: Icon(widget.icon, size: widget.iconSize, color: foreground),
          ),
        ),
      ),
    );
  }
}

class MacosGlassSurface extends StatelessWidget {
  final Widget child;
  final BorderRadius borderRadius;
  final Color color;
  final Color borderColor;
  final double blur;

  const MacosGlassSurface({
    super.key,
    required this.child,
    this.borderRadius = const BorderRadius.all(Radius.circular(10)),
    this.color = const Color(0x33FFFFFF),
    this.borderColor = const Color(0x33FFFFFF),
    this.blur = 14,
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
          child: child,
        ),
      ),
    );
  }
}

class MacosSelectOption<T> {
  final T value;
  final String label;

  const MacosSelectOption({required this.value, required this.label});
}

class MacosSelect<T> extends StatelessWidget {
  final T? value;
  final String placeholder;
  final List<MacosSelectOption<T>> options;
  final ValueChanged<T> onSelected;
  final double height;
  final double borderRadius;
  final double width;

  const MacosSelect({
    super.key,
    required this.value,
    required this.options,
    required this.onSelected,
    this.placeholder = '选择',
    this.height = 34,
    this.borderRadius = 8,
    this.width = 96,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final selectedLabel = _labelFor(value) ?? placeholder;
    final foreground = AppColors.textPrimary(context).withAlpha(230);

    return Theme(
      data: theme.copyWith(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
      ),
      child: PopupMenuButton<T>(
        initialValue: value,
        offset: Offset(0, height + 4),
        constraints: BoxConstraints.tightFor(width: width),
        menuPadding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        color: isDark ? const Color(0xFF2A2A2D) : Colors.white,
        elevation: 6,
        tooltip: '',
        onSelected: onSelected,
        itemBuilder: (context) {
          return options.map((option) {
            final isSelected = option.value == value;
            return PopupMenuItem<T>(
              value: option.value,
              height: height,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      option.label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: foreground,
                      ),
                    ),
                  ),
                  if (isSelected)
                    Icon(
                      Icons.check_rounded,
                      size: 16,
                      color: AppColors.primary(context),
                    ),
                ],
              ),
            );
          }).toList();
        },
        child: SizedBox(
          width: width,
          height: height,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withAlpha(14)
                  : Colors.black.withAlpha(6),
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: AppColors.textPrimary(
                  context,
                ).withAlpha(isDark ? 42 : 24),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      selectedLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: foreground,
                        height: 1,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 17,
                    color: foreground,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String? _labelFor(T? value) {
    if (value == null) return null;
    for (final option in options) {
      if (option.value == value) return option.label;
    }
    return null;
  }
}

class MacosPill extends StatelessWidget {
  final String text;
  final IconData? icon;
  final bool rating;
  final MacosControlTone tone;

  const MacosPill({
    super.key,
    required this.text,
    this.icon,
    this.rating = false,
    this.tone = MacosControlTone.adaptive,
  });

  @override
  Widget build(BuildContext context) {
    final overlayTone = tone == MacosControlTone.overlay;
    final background = rating
        ? AppColors.rating
        : overlayTone
        ? Colors.white.withAlpha(42)
        : AppColors.elevatedSurface(context);
    final foreground = rating
        ? Colors.black.withAlpha(220)
        : overlayTone
        ? Colors.white
        : AppColors.textPrimary(context).withAlpha(220);
    final borderColor = overlayTone
        ? Colors.white.withAlpha(44)
        : AppColors.separator(context);

    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(7),
        border: rating ? null : Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 15, color: foreground),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              color: foreground,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}
