import 'package:flutter/material.dart';
import 'package:mochi_player/core/ui/components/forms/app_form_row.dart';
import 'package:mochi_player/core/ui/components/forms/app_slider.dart';
import 'package:mochi_player/core/ui/theme/app_colors.dart';
import 'package:mochi_player/core/ui/theme/app_control_metrics.dart';
import 'package:mochi_player/core/ui/theme/app_typography.dart';

class AppFormSliderRow extends StatelessWidget {
  final String label;
  final IconData icon;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final String displayValue;
  final bool enabled;
  final ValueChanged<double> onChanged;

  const AppFormSliderRow({
    super.key,
    required this.label,
    required this.icon,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.displayValue,
    required this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppFormRow(
      icon: icon,
      label: label,
      enabled: enabled,
      control: Row(
        children: [
          Expanded(
            child: AppSlider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              onChanged: enabled ? onChanged : null,
            ),
          ),
          SizedBox(
            width: AppControlMetrics.sliderValueWidth,
            child: Text(
              displayValue,
              textAlign: TextAlign.end,
              style: AppTypography.formValueEmphasis.copyWith(
                color: AppColors.textPrimary(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
