import 'package:flutter/material.dart';

import 'package:mochi_player/core/ui/components/overlay/internal/menu_parts.dart';
import 'package:mochi_player/core/ui/theme/app_colors.dart';
import 'package:mochi_player/core/ui/theme/app_icons.dart';
import 'package:mochi_player/core/ui/theme/app_radii.dart';

class AppDropdownOption<T> {
  const AppDropdownOption({required this.value, required this.label, this.icon});

  final T value;
  final String label;
  final IconData? icon;
}

/// An anchored pointer-operated application menu.
class AppDropdown<T> extends StatelessWidget {
  const AppDropdown({
    super.key,
    required this.trigger,
    required this.options,
    this.onSelected,
    this.selectedValue,
    this.tooltip,
    this.menuWidth = 160,
  });

  final Widget trigger;
  final List<AppDropdownOption<T>> options;
  final ValueChanged<T>? onSelected;
  final T? selectedValue;
  final String? tooltip;
  final double menuWidth;

  bool get _enabled => onSelected != null && options.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final shadowColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.black.withAlpha(112)
        : Colors.black.withAlpha(28);
    return MenuAnchor(
      consumeOutsideTap: true,
      useRootOverlay: true,
      clipBehavior: Clip.none,
      alignmentOffset: const Offset(0, 6),
      style: MenuStyle(
        // MenuAnchor interprets bottomEnd as starting the menu at the
        // trigger's right edge. bottomStart places it directly below the
        // trigger, which is the expected dropdown geometry in an LTR UI.
        alignment: AlignmentDirectional.bottomStart,
        backgroundColor: WidgetStatePropertyAll(AppColors.selectMenuSurface(context)),
        surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
        shadowColor: WidgetStatePropertyAll(shadowColor),
        elevation: const WidgetStatePropertyAll(8),
        padding: const WidgetStatePropertyAll(EdgeInsets.all(6)),
        fixedSize: WidgetStatePropertyAll(Size.fromWidth(menuWidth)),
        side: WidgetStatePropertyAll(BorderSide(color: AppColors.selectBorder(context))),
        shape: const WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(AppRadii.control))),
        ),
      ),
      menuChildren: [
        for (final option in options)
          _DropdownOptionRow<T>(
            option: option,
            selected: option.value == selectedValue,
            onPressed: () => onSelected?.call(option.value),
          ),
      ],
      builder: (context, controller, child) {
        final button = MenuTriggerArea(
          onPressed: _enabled ? () => controller.isOpen ? controller.close() : controller.open() : null,
          child: trigger,
        );
        final resolvedTooltip = tooltip;
        if (resolvedTooltip == null || resolvedTooltip.isEmpty) return button;
        return Tooltip(message: resolvedTooltip, excludeFromSemantics: true, child: button);
      },
    );
  }
}

class _DropdownOptionRow<T> extends StatelessWidget {
  const _DropdownOptionRow({required this.option, required this.selected, required this.onPressed});

  final AppDropdownOption<T> option;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final foreground = selected ? AppColors.primary(context) : AppColors.textPrimary(context);
    return MenuOptionRow(
      onPressed: () {
        MenuController.maybeOf(context)?.close();
        onPressed();
      },
      child: Row(
        children: [
          if (option.icon != null) ...[Icon(option.icon, size: 15, color: foreground), const SizedBox(width: 8)],
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
          if (selected) Icon(AppIcons.check, size: 14, color: AppColors.primary(context)),
        ],
      ),
    );
  }
}
