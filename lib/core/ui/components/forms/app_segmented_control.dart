import 'package:flutter/material.dart';
import 'package:mochi_player/core/ui/components/layout/app_clickable_area.dart';
import 'package:mochi_player/core/ui/components/layout/app_panel.dart';
import 'package:mochi_player/core/ui/theme/app_colors.dart';
import 'package:mochi_player/core/ui/theme/app_control_metrics.dart';
import 'package:mochi_player/core/ui/theme/app_radii.dart';
import 'package:mochi_player/core/ui/theme/app_typography.dart';

class AppSegment<T> {
  final T value;
  final String label;
  final IconData icon;

  const AppSegment({
    required this.value,
    required this.label,
    required this.icon,
  });
}

class AppSegmentedControl<T> extends StatelessWidget {
  final T value;
  final List<AppSegment<T>> segments;
  final ValueChanged<T> onChanged;
  final double maxWidth;

  const AppSegmentedControl({
    super.key,
    required this.value,
    required this.segments,
    required this.onChanged,
    this.maxWidth = 420,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = AppColors.separator(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final controlWidth = constraints.maxWidth < maxWidth
            ? constraints.maxWidth
            : maxWidth;
        return SizedBox(
          width: controlWidth,
          height: AppControlMetrics.segmentedHeight,
          child: AppPanel(
            tone: AppPanelTone.elevated,
            showBorder: true,
            borderRadius: BorderRadius.circular(AppRadii.control),
            clipBehavior: Clip.antiAlias,
            child: Row(
              children: [
                for (var index = 0; index < segments.length; index++) ...[
                  Expanded(
                    child: _SegmentButton<T>(
                      segment: segments[index],
                      selected: segments[index].value == value,
                      onPressed: () => onChanged(segments[index].value),
                    ),
                  ),
                  if (index != segments.length - 1)
                    SizedBox(
                      height: 20,
                      child: VerticalDivider(width: 1, color: borderColor),
                    ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SegmentButton<T> extends StatelessWidget {
  final AppSegment<T> segment;
  final bool selected;
  final VoidCallback onPressed;

  const _SegmentButton({
    required this.segment,
    required this.selected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.primary(context);
    final selectedSurface = AppColors.selectedSurface(context);
    final restingForeground = AppColors.textPrimary(context).withAlpha(220);
    final foreground = selected ? primary : restingForeground;

    return AppClickableArea(
      onTap: onPressed,
      height: double.infinity,
      borderRadius: BorderRadius.zero,
      backgroundColor: selected ? selectedSurface : Colors.transparent,
      hoverColor: selected
          ? Colors.transparent
          : AppColors.hoverSurface(context),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(segment.icon, size: 16, color: foreground),
          const SizedBox(width: AppControlMetrics.iconLabelGap),
          Text(
            segment.label,
            style: AppTypography.controlLabel.copyWith(
              color: foreground,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
