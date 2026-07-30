import 'package:flutter/material.dart';
import 'package:mochi_player/core/ui/theme/app_colors.dart';
import 'package:mochi_player/core/ui/theme/app_control_metrics.dart';
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
    final theme = Theme.of(context);
    final selectedLabel = _labelFor(value) ?? placeholder;
    final foreground = AppColors.textPrimary(context).withAlpha(230);
    final isEnabled = enabled && onSelected != null;

    return AnimatedOpacity(
      duration: AppControlMetrics.stateAnimationDuration,
      opacity: isEnabled ? 1 : 0.5,
      child: Theme(
        data: theme.copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
        ),
        child: PopupMenuButton<T>(
          enabled: isEnabled,
          initialValue: value,
          offset: Offset(0, height + AppSpacing.xs),
          constraints: BoxConstraints.tightFor(width: width),
          menuPadding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          color: AppColors.selectMenuSurface(context),
          elevation: 6,
          tooltip: '',
          onSelected: onSelected,
          itemBuilder: (context) {
            return options.map((option) {
              final isSelected = option.value == value;
              return PopupMenuItem<T>(
                value: option.value,
                height: height,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.compact,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        option.label,
                        style: AppTypography.formValue.copyWith(
                          color: foreground,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
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
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: AppControlMetrics.iconSize,
                      color: foreground,
                    ),
                  ],
                ),
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
