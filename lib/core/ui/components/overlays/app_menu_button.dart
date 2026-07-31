import 'package:flutter/material.dart';

import 'package:mochi_player/core/ui/components/layout/app_hover_surface.dart';
import 'package:mochi_player/core/ui/theme/app_colors.dart';
import 'package:mochi_player/core/ui/theme/app_icons.dart';
import 'package:mochi_player/core/ui/theme/app_radii.dart';

class AppMenuOption<T> {
  final T value;
  final String label;
  final IconData? icon;

  const AppMenuOption({required this.value, required this.label, this.icon});
}

class AppMenuButton<T> extends StatefulWidget {
  final Widget child;
  final List<AppMenuOption<T>> options;
  final ValueChanged<T>? onSelected;
  final T? selectedValue;
  final String tooltip;
  final double menuWidth;
  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;

  const AppMenuButton({
    super.key,
    required this.child,
    required this.options,
    required this.onSelected,
    required this.tooltip,
    this.selectedValue,
    this.menuWidth = 160,
    this.padding = EdgeInsets.zero,
    this.borderRadius = const BorderRadius.all(Radius.circular(AppRadii.small)),
  });

  @override
  State<AppMenuButton<T>> createState() => _AppMenuButtonState<T>();
}

class _AppMenuButtonState<T> extends State<AppMenuButton<T>>
    with SingleTickerProviderStateMixin {
  static const _itemHeight = 36.0;
  static const _menuPadding = 6.0;
  static const _screenMargin = 8.0;
  static const _menuGap = 6.0;

  final _anchorKey = GlobalKey();
  OverlayEntry? _entry;
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<double> _scale;

  bool get _enabled => widget.onSelected != null && widget.options.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      reverseDuration: const Duration(milliseconds: 90),
    );
    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _scale = Tween<double>(
      begin: 0.98,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _entry?.remove();
    _controller.dispose();
    super.dispose();
  }

  void _open() {
    if (!_enabled || _entry != null) return;
    final anchor = _anchorKey.currentContext?.findRenderObject() as RenderBox?;
    final overlayState = Overlay.of(context);
    final overlay = overlayState.context.findRenderObject() as RenderBox?;
    if (anchor == null || overlay == null) return;

    final anchorOrigin = anchor.localToGlobal(Offset.zero, ancestor: overlay);
    final menuHeight = widget.options.length * _itemHeight + _menuPadding * 2;
    final availableBelow =
        overlay.size.height - anchorOrigin.dy - anchor.size.height;
    final showAbove = availableBelow < menuHeight + _menuGap;
    final desiredLeft = anchorOrigin.dx + anchor.size.width - widget.menuWidth;
    final left = desiredLeft.clamp(
      _screenMargin,
      overlay.size.width - widget.menuWidth - _screenMargin,
    );
    final top = showAbove
        ? anchorOrigin.dy - menuHeight - _menuGap
        : anchorOrigin.dy + anchor.size.height + _menuGap;
    final alignment = showAbove ? Alignment.bottomRight : Alignment.topRight;

    _entry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: _close,
            ),
          ),
          Positioned(
            left: left,
            top: top,
            width: widget.menuWidth,
            child: FadeTransition(
              opacity: _opacity,
              child: ScaleTransition(
                scale: _scale,
                alignment: alignment,
                child: _AppMenuPanel<T>(
                  options: widget.options,
                  selectedValue: widget.selectedValue,
                  onSelected: _select,
                ),
              ),
            ),
          ),
        ],
      ),
    );
    overlayState.insert(_entry!);
    _controller.forward(from: 0);
  }

  Future<void> _close() async {
    final entry = _entry;
    if (entry == null) return;
    await _controller.reverse();
    entry.remove();
    if (identical(_entry, entry)) _entry = null;
  }

  Future<void> _select(T value) async {
    await _close();
    if (mounted) widget.onSelected?.call(value);
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: AppHoverSurface(
        onTap: _enabled ? _open : null,
        borderRadius: widget.borderRadius,
        padding: widget.padding,
        hoverColor: AppColors.hoverSurface(context),
        pressedColor: AppColors.hoverSurface(context),
        child: KeyedSubtree(key: _anchorKey, child: widget.child),
      ),
    );
  }
}

class _AppMenuPanel<T> extends StatelessWidget {
  final List<AppMenuOption<T>> options;
  final T? selectedValue;
  final ValueChanged<T> onSelected;

  const _AppMenuPanel({
    required this.options,
    required this.selectedValue,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final shadowColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.black.withAlpha(112)
        : Colors.black.withAlpha(28);
    return DefaultTextStyle(
      style: TextStyle(
        color: AppColors.textPrimary(context),
        decoration: TextDecoration.none,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.selectMenuSurface(context),
          borderRadius: BorderRadius.circular(AppRadii.control),
          border: Border.all(color: AppColors.selectBorder(context)),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(_AppMenuButtonState._menuPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final option in options)
                _AppMenuOptionRow<T>(
                  option: option,
                  selected: option.value == selectedValue,
                  onTap: () => onSelected(option.value),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AppMenuOptionRow<T> extends StatelessWidget {
  final AppMenuOption<T> option;
  final bool selected;
  final VoidCallback onTap;

  const _AppMenuOptionRow({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final foreground = selected
        ? AppColors.primary(context)
        : AppColors.textPrimary(context);
    return AppHoverSurface(
      onTap: onTap,
      height: _AppMenuButtonState._itemHeight,
      borderRadius: BorderRadius.circular(AppRadii.small),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      hoverColor: AppColors.hoverSurface(context),
      pressedColor: AppColors.hoverSurface(context),
      child: Row(
        children: [
          if (option.icon != null) ...[
            Icon(option.icon, size: 15, color: foreground),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(
              option.label,
              style: TextStyle(
                color: foreground,
                fontSize: 13,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
          if (selected)
            Icon(AppIcons.check, size: 14, color: AppColors.primary(context)),
        ],
      ),
    );
  }
}
