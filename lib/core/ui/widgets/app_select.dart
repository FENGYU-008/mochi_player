import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radii.dart';

class AppSelectOption<T> {
  final T value;
  final String label;

  const AppSelectOption({required this.value, required this.label});
}

class AppSelect<T> extends StatelessWidget {
  final T? value;
  final String placeholder;
  final List<AppSelectOption<T>> options;
  final ValueChanged<T> onSelected;
  final double height;
  final double borderRadius;
  final double width;

  const AppSelect({
    super.key,
    required this.value,
    required this.options,
    required this.onSelected,
    this.placeholder = '选择',
    this.height = 34,
    this.borderRadius = AppRadii.control,
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
