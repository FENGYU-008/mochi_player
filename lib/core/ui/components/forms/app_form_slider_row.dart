import 'package:flutter/material.dart';
import 'package:mochi_player/core/ui/theme/app_colors.dart';
import 'package:mochi_player/core/ui/theme/app_spacing.dart';

const _controlHeight = 36.0;
const _labelWidth = 104.0;
const _fieldGap = 6.0;

class AppFormSliderRow extends StatelessWidget {
  final String label;
  final IconData icon;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final String displayValue;
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
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _controlHeight,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.compact),
      child: Row(
        children: [
          Icon(icon, size: 17, color: AppColors.textSecondary(context)),
          const SizedBox(width: _fieldGap),
          SizedBox(
            width: _labelWidth,
            child: Text(
              label,
              style: TextStyle(
                color: AppColors.textPrimary(context),
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 3,
                activeTrackColor: AppColors.primary(context),
                inactiveTrackColor: AppColors.separator(context),
                thumbColor: AppColors.primary(context),
                overlayShape: SliderComponentShape.noOverlay,
                thumbShape: const RoundSliderThumbShape(
                  enabledThumbRadius: 7,
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
            ),
          ),
          SizedBox(
            width: 36,
            child: Text(
              displayValue,
              textAlign: TextAlign.end,
              style: TextStyle(
                color: AppColors.textPrimary(context),
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
