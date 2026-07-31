import 'package:flutter/material.dart';

import 'package:mochi_player/core/ui/components/overlays/app_menu_button.dart';
import 'package:mochi_player/core/ui/theme/app_colors.dart';
import 'package:mochi_player/core/ui/theme/app_control_metrics.dart';
import 'package:mochi_player/core/ui/theme/app_icons.dart';
import 'package:mochi_player/core/ui/theme/app_radii.dart';
import 'package:mochi_player/core/ui/theme/app_spacing.dart';
import 'package:mochi_player/core/ui/theme/app_typography.dart';

class AppSelectOption<T> {
  final T value;
  final String label;

  const AppSelectOption({required this.value, required this.label});
}

class AppSelect<T> extends StatelessWidget {
  final T? value;
  final String placeholder;
  final List<AppSelectOption<T>> options;
  final ValueChanged<T>? onSelected;
  final bool enabled;
  final double height;
  final double borderRadius;
  final double width;

  const AppSelect({
    super.key,
    required this.value,
    required this.options,
    required this.onSelected,
    this.placeholder = '选择',
    this.enabled = true,
    this.height = AppControlMetrics.selectHeight,
    this.borderRadius = AppRadii.control,
    this.width = 96,
  });

  @override
  Widget build(BuildContext context) {
    final selectedLabel = _labelFor(value) ?? placeholder;
    final foreground = AppColors.textPrimary(context).withAlpha(230);
    final isEnabled = enabled && onSelected != null;

    return AnimatedOpacity(
      duration: AppControlMetrics.stateAnimationDuration,
      opacity: isEnabled ? 1 : 0.5,
      child: AppMenuButton<T>(
        tooltip: '',
        selectedValue: value,
        menuWidth: width,
        onSelected: isEnabled ? onSelected : null,
        options: options
            .map(
              (option) =>
                  AppMenuOption<T>(value: option.value, label: option.label),
            )
            .toList(),
        child: SizedBox(
          width: width,
          height: height,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.selectControlSurface(context),
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(color: AppColors.selectBorder(context)),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.compact,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      selectedLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.controlLabel.copyWith(
                        color: foreground,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Icon(AppIcons.chevronDown, size: 13, color: foreground),
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
