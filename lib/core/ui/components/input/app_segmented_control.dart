import 'package:flutter/material.dart';
import 'package:mochi_player/core/ui/components/basic/app_clickable_area.dart';
import 'package:mochi_player/core/ui/theme/app_colors.dart';
import 'package:mochi_player/core/ui/theme/app_control_metrics.dart';
import 'package:mochi_player/core/ui/theme/app_radii.dart';
import 'package:mochi_player/core/ui/theme/app_typography.dart';

class AppSegmentedOption<T> {
  final T value;
  final String label;
  final IconData? icon;
  final bool _iconOnly;

  const AppSegmentedOption({required this.value, required this.label, this.icon}) : _iconOnly = false;

  const AppSegmentedOption.icon({required this.value, required this.label, required this.icon}) : _iconOnly = true;
}

class AppSegmentedControl<T> extends StatelessWidget {
  final T value;
  final List<AppSegmentedOption<T>> options;
  final ValueChanged<T>? onChanged;

  const AppSegmentedControl({super.key, required this.value, required this.options, this.onChanged});

  @override
  Widget build(BuildContext context) {
    assert(options.length >= 2, 'A segmented control needs at least 2 options.');
    final borderColor = AppColors.separator(context);
    final enabled = onChanged != null;
    return AnimatedOpacity(
      duration: AppControlMetrics.stateAnimationDuration,
      opacity: enabled ? 1 : 0.5,
      child: SizedBox(
        height: AppControlMetrics.segmentedHeight,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadii.control),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.elevatedSurface(context),
              borderRadius: BorderRadius.circular(AppRadii.control),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              children: [
                for (var index = 0; index < options.length; index++) ...[
                  Expanded(
                    child: _SegmentButton<T>(
                      option: options[index],
                      selected: options[index].value == value,
                      onPressed: enabled ? () => onChanged!(options[index].value) : null,
                    ),
                  ),
                  if (index != options.length - 1)
                    SizedBox(height: 20, child: VerticalDivider(width: 1, color: borderColor)),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SegmentButton<T> extends StatelessWidget {
  final AppSegmentedOption<T> option;
  final bool selected;
  final VoidCallback? onPressed;

  const _SegmentButton({required this.option, required this.selected, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.primary(context);
    final selectedSurface = AppColors.selectedSurface(context);
    final restingForeground = AppColors.textPrimary(context).withAlpha(220);
    final foreground = selected ? primary : restingForeground;

    final button = Semantics(
      container: true,
      label: option.label,
      button: true,
      selected: selected,
      enabled: onPressed != null,
      onTap: onPressed,
      excludeSemantics: true,
      child: AppClickableArea(
        onTap: onPressed,
        height: double.infinity,
        borderRadius: BorderRadius.zero,
        backgroundColor: selected ? selectedSurface : Colors.transparent,
        hoverColor: selected ? Colors.transparent : AppColors.hoverSurface(context),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (option.icon != null) Icon(option.icon, size: 16, color: foreground),
            if (option.icon != null && !option._iconOnly) const SizedBox(width: AppControlMetrics.iconLabelGap),
            if (!option._iconOnly)
              Text(
                option.label,
                style: AppTypography.controlLabel.copyWith(
                  color: foreground,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                ),
              ),
          ],
        ),
      ),
    );

    if (!option._iconOnly) return button;
    return Tooltip(message: option.label, excludeFromSemantics: true, child: button);
  }
}
