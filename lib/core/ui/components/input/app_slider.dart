import 'package:flutter/material.dart';
import 'package:mochi_player/core/ui/theme/app_colors.dart';
import 'package:mochi_player/core/ui/theme/app_control_metrics.dart';

class AppSlider extends StatelessWidget {
  final double value;
  final double min;
  final double max;
  final int? divisions;
  final ValueChanged<double>? onChanged;

  const AppSlider({
    super.key,
    required this.value,
    required this.min,
    required this.max,
    this.divisions,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        trackHeight: AppControlMetrics.sliderTrackHeight,
        activeTrackColor: AppColors.primary(context),
        inactiveTrackColor: AppColors.separator(context),
        thumbColor: AppColors.primary(context),
        overlayShape: SliderComponentShape.noOverlay,
        thumbShape: const RoundSliderThumbShape(
          enabledThumbRadius: AppControlMetrics.sliderThumbRadius,
          disabledThumbRadius: 6,
        ),
        activeTickMarkColor: Colors.transparent,
        inactiveTickMarkColor: Colors.transparent,
        showValueIndicator: ShowValueIndicator.never,
      ),
      child: Slider(
        value: value,
        min: min,
        max: max,
        divisions: divisions,
        onChanged: onChanged,
      ),
    );
  }
}
